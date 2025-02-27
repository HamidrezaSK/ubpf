// Copyright (c) 2015 Big Switch Networks, Inc
// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2015 Big Switch Networks, Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * Generic x86-64 code generation functions
 */

#ifndef UBPF_JIT_X86_64_H
#define UBPF_JIT_X86_64_H

#include <assert.h>
#include <stdint.h>
#include <string.h>

#define RAX 0
#define RCX 1
#define RDX 2
#define RBX 3
#define RSP 4
#define RBP 5
#define RIP 5
#define RSI 6
#define RDI 7
#define R8 8
#define R9 9
#define R10 10
#define R11 11
#define R12 12
#define R13 13
#define R14 14
#define R15 15
#define XMM0 0
#define XMM1 1
#define XMM2 2
#define XMM3 3




enum operand_size
{
    S8,
    S16,
    S32,
    S64,
};

struct packed_group
{
    uint32_t section_id;                    // need this to connect the batches together. each compare group has a unique one
    uint32_t start;                           // what is the first location, to start the reduction
    uint32_t end;                           // what is the last location, to end the reduction phase
    uint32_t size;                         // how many compares are in this group
    uint32_t success_target;               // where to jump in case of success             
    uint32_t fail_target;                  // where to jump in case of failure               

};

struct jump_ana
{
    uint32_t loc;
    uint32_t target_pc;
    uint32_t group;
    uint8_t opcode;
};

struct load
{
    int addr_offset;
    int inst_offset;
};

struct jump
{
    uint32_t offset_loc;
    uint32_t target_pc;
    uint32_t target_offset;
};

struct vec_memcpy
{
    int save_reg;
    int load_reg;
    int save_addr;
    int load_addr;
    uint32_t start_offset;
    uint32_t end_offset;
};

/* Special values for target_pc in struct jump */
#define TARGET_PC_EXIT -1
#define TARGET_PC_RETPOLINE -3

struct jit_state
{
    uint8_t* buf;
    uint32_t offset;
    uint32_t size;
    uint32_t* pc_locs;
    uint32_t exit_loc;
    uint32_t unwind_loc;
    uint32_t retpoline_loc;
    struct jump* jumps;
    int num_jumps;
};

static inline void
emit_bytes(struct jit_state* state, void* data, uint32_t len)
{
    assert(state->offset <= state->size - len);
    if ((state->offset + len) > state->size) {
        state->offset = state->size;
        return;
    }
    memcpy(state->buf + state->offset, data, len);
    state->offset += len;
}

static inline void
emit1(struct jit_state* state, uint8_t x)
{
    emit_bytes(state, &x, sizeof(x));
}

static inline void
emit2(struct jit_state* state, uint16_t x)
{
    emit_bytes(state, &x, sizeof(x));
}

static inline void
emit4(struct jit_state* state, uint32_t x)
{
    emit_bytes(state, &x, sizeof(x));
}

static inline void
emit8(struct jit_state* state, uint64_t x)
{
    emit_bytes(state, &x, sizeof(x));
}

static inline void
emit_jump_target_address(struct jit_state* state, int32_t target_pc)
{
    if (state->num_jumps == UBPF_MAX_INSTS) {
        return;
    }
    struct jump* jump = &state->jumps[state->num_jumps++];
    jump->offset_loc = state->offset;
    jump->target_pc = target_pc;
    emit4(state, 0);
}

static inline void
emit_jump_target_offset(struct jit_state* state, uint32_t jump_loc, uint32_t jump_state_offset)
{
    if (state->num_jumps == UBPF_MAX_INSTS) {
        return;
    }
    struct jump* jump = &state->jumps[state->num_jumps++];
    jump->offset_loc = jump_loc;
    jump->target_offset = jump_state_offset;
}

static inline void
emit_modrm(struct jit_state* state, int mod, int r, int m)
{
    assert(!(mod & ~0xc0));
    emit1(state, (mod & 0xc0) | ((r & 7) << 3) | (m & 7));
}

static inline void
emit_modrm_reg2reg(struct jit_state* state, int r, int m)
{
    emit_modrm(state, 0xc0, r, m);
}

static inline void
emit_modrm_and_displacement(struct jit_state* state, int r, int m, int32_t d)
{
    if (d == 0 && (m & 7) != RBP) {
        emit_modrm(state, 0x00, r, m);
    } else if (d >= -128 && d <= 127) {
        emit_modrm(state, 0x40, r, m);
        emit1(state, d);
    } else {
        emit_modrm(state, 0x80, r, m);
        emit4(state, d);
    }
}

static inline void
emit_rex(struct jit_state* state, int w, int r, int x, int b)
{
    assert(!(w & ~1));
    assert(!(r & ~1));
    assert(!(x & ~1));
    assert(!(b & ~1));
    emit1(state, 0x40 | (w << 3) | (r << 2) | (x << 1) | b);
}

/*
 * Emits a REX prefix with the top bit of src and dst.
 * Skipped if no bits would be set.
 */
static inline void
emit_basic_rex(struct jit_state* state, int w, int src, int dst)
{
    if (w || (src & 8) || (dst & 8)) {
        emit_rex(state, w, !!(src & 8), 0, !!(dst & 8));
    }
}

static inline void
emit_push(struct jit_state* state, int r)
{
    emit_basic_rex(state, 0, 0, r);
    emit1(state, 0x50 | (r & 7));
}

static inline void
emit_pop(struct jit_state* state, int r)
{
    emit_basic_rex(state, 0, 0, r);
    emit1(state, 0x58 | (r & 7));
}

/* REX prefix and ModRM byte */
/* We use the MR encoding when there is a choice */
/* 'src' is often used as an opcode extension */
static inline void
emit_alu32(struct jit_state* state, int op, int src, int dst)
{
    emit_basic_rex(state, 0, src, dst);
    emit1(state, op);
    emit_modrm_reg2reg(state, src, dst);
}

/* REX prefix, ModRM byte, and 32-bit immediate */
static inline void
emit_alu32_imm32(struct jit_state* state, int op, int src, int dst, int32_t imm)
{
    emit_alu32(state, op, src, dst);
    emit4(state, imm);
}

/* REX prefix, ModRM byte, and 8-bit immediate */
static inline void
emit_alu32_imm8(struct jit_state* state, int op, int src, int dst, int8_t imm)
{
    emit_alu32(state, op, src, dst);
    emit1(state, imm);
}

/* REX.W prefix and ModRM byte */
/* We use the MR encoding when there is a choice */
/* 'src' is often used as an opcode extension */
static inline void
emit_alu64(struct jit_state* state, int op, int src, int dst)
{
    emit_basic_rex(state, 1, src, dst);
    emit1(state, op);
    emit_modrm_reg2reg(state, src, dst);
}

static inline void
emit_sse_alu64(struct jit_state* state, int p_op, int s_op, int src, int dst, int w)
{
    emit1(state, 0x66); // emit prefix
    emit_basic_rex(state, w, src, dst);
    emit1(state, p_op);
    emit1(state, s_op);
    emit_modrm_reg2reg(state, src, dst);
}

static inline void
emit_sse_alu64_imm32(struct jit_state* state, int p_op, int s_op, int src, int dst, int32_t imm)
{
    emit_sse_alu64(state, p_op, s_op, src, dst, 0);
    emit4(state, imm);
}

/* REX.W prefix, ModRM byte, and 32-bit immediate */
static inline void
emit_alu64_imm32(struct jit_state* state, int op, int src, int dst, int32_t imm)
{
    emit_alu64(state, op, src, dst);
    emit4(state, imm);
}

/* REX.W prefix, ModRM byte, and 8-bit immediate */
static inline void
emit_alu64_imm8(struct jit_state* state, int op, int src, int dst, int8_t imm)
{
    emit_alu64(state, op, src, dst);
    emit1(state, imm);
}

/* Register to register mov */
static inline void
emit_mov(struct jit_state* state, int src, int dst)
{
    emit_alu64(state, 0x89, src, dst);
}

static inline void
emit_cmp_imm32(struct jit_state* state, int dst, int32_t imm)
{
    emit_alu64_imm32(state, 0x81, 7, dst, imm);
}

static inline void
emit_cmp32_imm32(struct jit_state* state, int dst, int32_t imm)
{
    emit_alu32_imm32(state, 0x81, 7, dst, imm);
}

static inline void
emit_cmp(struct jit_state* state, int src, int dst)
{
    emit_alu64(state, 0x39, src, dst);
}

static inline void
emit_cmp32(struct jit_state* state, int src, int dst)
{
    emit_alu32(state, 0x39, src, dst);
}

static inline void
emit_jcc(struct jit_state* state, int code, int32_t target_pc)
{
    emit1(state, 0x0f);
    emit1(state, code);
    emit_jump_target_address(state, target_pc);
}

/* Load [src + offset] into dst */
static inline void
emit_load(struct jit_state* state, enum operand_size size, int src, int dst, int32_t offset)
{
    emit_basic_rex(state, size == S64, dst, src);

    if (size == S8 || size == S16) {
        /* movzx */
        emit1(state, 0x0f);
        emit1(state, size == S8 ? 0xb6 : 0xb7);
    } else if (size == S32 || size == S64) {
        /* mov */
        emit1(state, 0x8b);
    }

    emit_modrm_and_displacement(state, dst, src, offset);
}

/* Load sign-extended immediate into register */
static inline void
emit_load_imm(struct jit_state* state, int dst, int64_t imm)
{
    if (imm >= INT32_MIN && imm <= INT32_MAX) {
        emit_alu64_imm32(state, 0xc7, 0, dst, imm);
    } else {
        /* movabs $imm,dst */
        emit_basic_rex(state, 1, 0, dst);
        emit1(state, 0xb8 | (dst & 7));
        emit8(state, imm);
    }
}

/* Store register src to [dst + offset] */
static inline void
emit_store(struct jit_state* state, enum operand_size size, int src, int dst, int32_t offset)
{
    if (size == S16) {
        emit1(state, 0x66); /* 16-bit override */
    }
    int rexw = size == S64;
    if (rexw || src & 8 || dst & 8 || size == S8) {
        emit_rex(state, rexw, !!(src & 8), 0, !!(dst & 8));
    }
    emit1(state, size == S8 ? 0x88 : 0x89);
    emit_modrm_and_displacement(state, src, dst, offset);
}

/* Store immediate to [dst + offset] */
static inline void
emit_store_imm32(struct jit_state* state, enum operand_size size, int dst, int32_t offset, int32_t imm)
{
    if (size == S16) {
        emit1(state, 0x66); /* 16-bit override */
    }
    emit_basic_rex(state, size == S64, 0, dst);
    emit1(state, size == S8 ? 0xc6 : 0xc7);
    emit_modrm_and_displacement(state, 0, dst, offset);
    if (size == S32 || size == S64) {
        emit4(state, imm);
    } else if (size == S16) {
        emit2(state, imm);
    } else if (size == S8) {
        emit1(state, imm);
    }
}

static inline void
emit_ret(struct jit_state* state)
{
    emit1(state, 0xc3);
}

static inline void
emit_jmp(struct jit_state* state, uint32_t target_pc)
{
    emit1(state, 0xe9);
    emit_jump_target_address(state, target_pc);
}

static inline void
emit_call(struct jit_state* state, void* target)
{
    /*
     * When we enter here, our stack is 16-byte aligned. Keep
     * it that way!
     */

#if defined(_WIN32)
    /* We have to create a little space to keep our 16-byte
     * alignment happy
     */
    emit_alu64_imm32(state, 0x81, 5, RSP, sizeof(uint64_t));

    /* Windows x64 ABI spills 5th parameter to stack */
    emit_push(state, map_register(5));

    /* Windows x64 ABI requires home register space.
     * Allocate home register space - 4 registers.
     */
    emit_alu64_imm32(state, 0x81, 5, RSP, 4 * sizeof(uint64_t));
#endif

    emit_load_imm(state, RAX, (uintptr_t)target);
#ifndef UBPF_DISABLE_RETPOLINES
    emit1(state, 0xe8); // e8 is the opcode for a CALL
    emit_jump_target_address(state, TARGET_PC_RETPOLINE);
#else
    /* TODO use direct call when possible */
    /* callq *%rax */
    emit1(state, 0xff);
    // ModR/M byte: b11010000b = xd
    //               ^
    //               register-direct addressing.
    //                 ^
    //                 opcode extension (2)
    //                    ^
    //                    rax is register 0
    emit1(state, 0xd0);
#endif

#if defined(_WIN32)
    /* Deallocate home register space + spilled register + alignment space - 5 registers */
    emit_alu64_imm32(state, 0x81, 0, RSP, (4 + 1 + 1) * sizeof(uint64_t));
#endif
}

#endif
