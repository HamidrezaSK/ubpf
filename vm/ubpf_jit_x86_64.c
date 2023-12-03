// Copyright (c) 2015 Big Switch Networks, Inc
// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2015 Big Switch Networks, Inc
 * Copyright 2017 Google Inc.
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

#include "ebpf.h"
#include <stdint.h>
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <inttypes.h>
#include <sys/mman.h>
#include <errno.h>
#include <assert.h>
#include <limits.h>
#include "ubpf_int.h"
#include "ubpf_jit_x86_64.h"

#if !defined(_countof)
#define _countof(array) (sizeof(array) / sizeof(array[0]))
#endif

static void
muldivmod(struct jit_state* state, uint8_t opcode, int src, int dst, int32_t imm);

#define REGISTER_MAP_SIZE 12

/*
 * There are two common x86-64 calling conventions, as discussed at
 * https://en.wikipedia.org/wiki/X86_calling_conventions#x86-64_calling_conventions
 *
 * Please Note: R12 is special and we are *not* using it. As a result, it is omitted
 * from the list of non-volatile registers for both platforms (even though it is, in
 * fact, non-volatile).
 *
 * BPF R0-R4 are "volatile"
 * BPF R5-R10 are "non-volatile"
 * In general, we attempt to map BPF volatile registers to x64 volatile and BPF non-
 * volatile to x64 non-volatile.
 */

#if defined(_WIN32)
static int platform_nonvolatile_registers[] = {RBP, RBX, RDI, RSI, R13, R14, R15};
static int platform_parameter_registers[] = {RCX, RDX, R8, R9};
#define RCX_ALT R10
static int register_map[REGISTER_MAP_SIZE] = {
    RAX,
    R10,
    RDX,
    R8,
    R9,
    R14,
    R15,
    RDI,
    RSI,
    RBX,
    RBP,
};
#else
#define RCX_ALT R9
static int platform_nonvolatile_registers[] = {RBP, RBX, R13, R14, R15};
static int platform_parameter_registers[] = {RDI, RSI, RDX, RCX, R8, R9, R10};
static int register_map[REGISTER_MAP_SIZE] = {
    RAX,
    RDI,
    RSI,
    RDX,
    R9,
    R8,
    RBX,
    R13,
    R14,
    R15,
    RBP,
    R10,
};
#endif


static int comp (const void * elem1, const void * elem2) 
{
    uint32_t f = *((uint32_t*)elem1);
    uint32_t s = *((uint32_t*)elem2);
    if (f > s) return  1;
    if (f < s) return -1;
    return 0;
}

static int comp_load (const void * elem1, const void * elem2) 
{
    int f = ((struct load*)elem1)->inst_offset;
    int s = ((struct load*)elem2)->inst_offset;
    if (f > s) return  1;
    if (f < s) return -1;
    return 0;
}

static int comp_cpy (const void * elem1, const void * elem2) 
{
    int f = ((struct vec_memcpy*)elem1)->start_offset;
    int s = ((struct vec_memcpy*)elem2)->start_offset;
    if (f > s) return  1;
    if (f < s) return -1;
    return 0;
}

/* Return the x86 register for the given eBPF register */
static int
map_register(int r)
{
    assert(r < _BPF_REG_MAX);
    return register_map[r % _BPF_REG_MAX];
}

static inline void
emit_local_call(struct jit_state* state, uint32_t target_pc)
{
    /*
     * Pushing 4 * 8 = 32 bytes will maintain the invariant
     * that the stack is 16-byte aligned.
     */
    emit_push(state, map_register(BPF_REG_6));
    emit_push(state, map_register(BPF_REG_7));
    emit_push(state, map_register(BPF_REG_8));
    emit_push(state, map_register(BPF_REG_9));
#if defined(_WIN32)
    /* Windows x64 ABI requires home register space */
    /* Allocate home register space - 4 registers */
    emit_alu64_imm32(state, 0x81, 5, RSP, 4 * sizeof(uint64_t));
#endif
    emit1(state, 0xe8); // e8 is the opcode for a CALL
    emit_jump_target_address(state, target_pc);
#if defined(_WIN32)
    /* Deallocate home register space - 4 registers */
    emit_alu64_imm32(state, 0x81, 0, RSP, 4 * sizeof(uint64_t));
#endif
    emit_pop(state, map_register(BPF_REG_9));
    emit_pop(state, map_register(BPF_REG_8));
    emit_pop(state, map_register(BPF_REG_7));
    emit_pop(state, map_register(BPF_REG_6));
}

static uint32_t
emit_retpoline(struct jit_state* state)
{

    /*
     * Using retpolines to mitigate spectre/meltdown. Adapting the approach
     * from
     * https://www.intel.com/content/www/us/en/developer/articles/technical/software-security-guidance/technical-documentation/retpoline-branch-target-injection-mitigation.html
     */

    /* label0: */
    /* call label1 */
    uint32_t retpoline_target = state->offset;
    emit1(state, 0xe8);
    uint32_t label1_call_offset = state->offset;
    emit4(state, 0x00);

    /* capture_ret_spec: */
    /* pause */
    uint32_t capture_ret_spec = state->offset;
    emit1(state, 0xf3);
    emit1(state, 0x90);
    /* jmp  capture_ret_spec */
    emit1(state, 0xe9);
    emit_jump_target_offset(state, state->offset, capture_ret_spec);
    emit4(state, 0x00);

    /* label1: */
    /* mov rax, (rsp) */
    uint32_t label1 = state->offset;
    emit1(state, 0x48);
    emit1(state, 0x89);
    emit1(state, 0x04);
    emit1(state, 0x24);

    /* ret */
    emit1(state, 0xc3);

    emit_jump_target_offset(state, label1_call_offset, label1);

    return retpoline_target;
}

/* For testing, this changes the mapping between x86 and eBPF registers */
void
ubpf_set_register_offset(int x)
{
    int i;
    if (x < REGISTER_MAP_SIZE) {
        int tmp[REGISTER_MAP_SIZE];
        memcpy(tmp, register_map, sizeof(register_map));
        for (i = 0; i < REGISTER_MAP_SIZE; i++) {
            register_map[i] = tmp[(i + x) % REGISTER_MAP_SIZE];
        }
    } else {
        /* Shuffle array */
        unsigned int seed = x;
        for (i = 0; i < REGISTER_MAP_SIZE - 1; i++) {
            int j = i + (rand_r(&seed) % (REGISTER_MAP_SIZE - i));
            int tmp = register_map[j];
            register_map[j] = register_map[i];
            register_map[i] = tmp;
        }
    }
}

static int
translate(struct ubpf_vm* vm, struct jit_state* state, char** errmsg)
{
    int i;

    /* Save platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_push(state, platform_nonvolatile_registers[i]);
    }

    /* Move first platform parameter register into register 1 */
    if (map_register(1) != platform_parameter_registers[0]) {
        emit_mov(state, platform_parameter_registers[0], map_register(BPF_REG_1));
    }

    /*
     * Assuming that the stack is 16-byte aligned right before
     * the call insn that brought us to this code, when
     * we start executing the jit'd code, we need to regain a 16-byte
     * alignment. The UBPF_STACK_SIZE is guaranteed to be
     * divisible by 16. However, if we pushed an even number of
     * registers on the stack when we are saving state (see above),
     * then we have to add an additional 8 bytes to get back
     * to a 16-byte alignment.
     */
    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 5, RSP, 0x8);
    }

    /*
     * Set BPF R10 (the way to access the frame in eBPF) to match RSP.
     */
    emit_mov(state, RSP, map_register(BPF_REG_10));

    /* Allocate stack space */
    emit_alu64_imm32(state, 0x81, 5, RSP, UBPF_STACK_SIZE);

#if defined(_WIN32)
    /* Windows x64 ABI requires home register space */
    /* Allocate home register space - 4 registers */
    emit_alu64_imm32(state, 0x81, 5, RSP, 4 * sizeof(uint64_t));
#endif

    /*
     * Use a call to set up a place where we can land after eBPF program's
     * final EXIT call. This makes it appear to the ebpf programs
     * as if they are called like a function. It is their responsibility
     * to deal with the non-16-byte aligned stack pointer that goes along
     * with this pretense.
     */
    emit1(state, 0xe8);
    emit4(state, 5);
    /*
     * We jump over this instruction in the first place; return here
     * after the eBPF program is finished executing.
     */
    emit_jmp(state, TARGET_PC_EXIT);

    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);
        state->pc_locs[i] = state->offset;

        int dst = map_register(inst.dst);
        int src = map_register(inst.src);
        uint32_t target_pc = i + inst.offset + 1;

        if (i == 0 || vm->int_funcs[i]) {
            /* When we are the subject of a call, we have to properly align our
             * stack pointer.
             */
            emit_alu64_imm32(state, 0x81, 5, RSP, 8);
        }

        switch (inst.opcode) {
        case EBPF_OP_ADD_IMM:
            emit_alu32_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD_REG:
            emit_alu32(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB_IMM:
            emit_alu32_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB_REG:
            emit_alu32(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL_IMM:
        case EBPF_OP_MUL_REG:
        case EBPF_OP_DIV_IMM:
        case EBPF_OP_DIV_REG:
        case EBPF_OP_MOD_IMM:
        case EBPF_OP_MOD_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR_IMM:
            emit_alu32_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR_REG:
            emit_alu32(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND_IMM:
            emit_alu32_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND_REG:
            emit_alu32(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH_IMM:
            emit_alu32_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH_IMM:
            emit_alu32_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG:
            emit_alu32(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR_IMM:
            emit_alu32_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR_REG:
            emit_alu32(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV_IMM:
            emit_alu32_imm32(state, 0xc7, 0, dst, inst.imm);
            break;
        case EBPF_OP_MOV_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH_IMM:
            emit_alu32_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 7, dst);
            break;

        case EBPF_OP_LE:
            /* No-op */
            break;
        case EBPF_OP_BE:
            if (inst.imm == 16) {
                /* rol */
                emit1(state, 0x66); /* 16-bit override */
                emit_alu32_imm8(state, 0xc1, 0, dst, 8);
                /* and */
                emit_alu32_imm32(state, 0x81, 4, dst, 0xffff);
            } else if (inst.imm == 32 || inst.imm == 64) {
                /* bswap */
                emit_basic_rex(state, inst.imm == 64, 0, dst);
                emit1(state, 0x0f);
                emit1(state, 0xc8 | (dst & 7));
            }
            break;

        case EBPF_OP_ADD64_IMM:
            emit_alu64_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD64_REG:
            emit_alu64(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB64_IMM:
            emit_alu64_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB64_REG:
            emit_alu64(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL64_IMM:
        case EBPF_OP_MUL64_REG:
        case EBPF_OP_DIV64_IMM:
        case EBPF_OP_DIV64_REG:
        case EBPF_OP_MOD64_IMM:
        case EBPF_OP_MOD64_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR64_IMM:
            emit_alu64_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR64_REG:
            emit_alu64(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND64_IMM:
            emit_alu64_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND64_REG:
            emit_alu64(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG64:
            emit_alu64(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR64_IMM:
            emit_alu64_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR64_REG:
            emit_alu64(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV64_IMM:
            emit_load_imm(state, dst, inst.imm);
            break;
        case EBPF_OP_MOV64_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 7, dst);
            break;

        /* TODO use 8 bit immediate when possible */
        case EBPF_OP_JA:
            emit_jmp(state, target_pc);
            break;
        case EBPF_OP_JEQ_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET_IMM:
            emit_alu64_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET_REG:
            emit_alu64(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JEQ32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET32_IMM:
            emit_alu32_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET32_REG:
            emit_alu32(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_CALL:
            /* We reserve RCX for shifts */
            if (inst.src == 0) {
                emit_mov(state, RCX_ALT, RCX);
                emit_call(state, vm->ext_funcs[inst.imm]);
                if (inst.imm == vm->unwind_stack_extension_index) {
                    emit_cmp_imm32(state, map_register(BPF_REG_0), 0);
                    emit_jcc(state, 0x84, TARGET_PC_EXIT);
                }
            } else if (inst.src == 1) {
                target_pc = i + inst.imm + 1;
                emit_local_call(state, target_pc);
            }
            break;
        case EBPF_OP_EXIT:
            /* On entry to every local function we add an additional 8 bytes.
             * Undo that here!
             */
            emit_alu64_imm32(state, 0x81, 0, RSP, 8);
            emit_ret(state);
            break;

        case EBPF_OP_LDXW:
            emit_load(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXH:
            emit_load(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXB:
            emit_load(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXDW:
            emit_load(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_STW:
            emit_store_imm32(state, S32, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STH:
            emit_store_imm32(state, S16, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STB:
            emit_store_imm32(state, S8, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STDW:
            emit_store_imm32(state, S64, dst, inst.offset, inst.imm);
            break;

        case EBPF_OP_STXW:
            emit_store(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_STXH:
            emit_store(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_STXB:
            emit_store(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_STXDW:
            emit_store(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_LDDW: {
            struct ebpf_inst inst2 = ubpf_fetch_instruction(vm, ++i);
            uint64_t imm = (uint32_t)inst.imm | ((uint64_t)inst2.imm << 32);
            emit_load_imm(state, dst, imm);
            break;
        }

        default:
            *errmsg = ubpf_error("Unknown instruction at PC %d: opcode %02x", i, inst.opcode);
            return -1;
        }
    }

    /* Epilogue */
    state->exit_loc = state->offset;

    /* Move register 0 into rax */
    if (map_register(BPF_REG_0) != RAX) {
        emit_mov(state, map_register(BPF_REG_0), RAX);
    }

    /* Deallocate stack space by restoring RSP from BPF R10. */
    emit_mov(state, map_register(BPF_REG_10), RSP);

    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 0, RSP, 0x8);
    }

    /* Restore platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_pop(state, platform_nonvolatile_registers[_countof(platform_nonvolatile_registers) - i - 1]);
    }

    emit1(state, 0xc3); /* ret */

    state->retpoline_loc = emit_retpoline(state);

    return 0;
}

static int
translate_cpy(struct ubpf_vm* vm, struct jit_state* state, char** errmsg, struct vec_memcpy* vec_memcpy, int num_cpy)
{
    int i;

    /* Save platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_push(state, platform_nonvolatile_registers[i]);
    }

    /* Move first platform parameter register into register 1 */
    if (map_register(1) != platform_parameter_registers[0]) {
        emit_mov(state, platform_parameter_registers[0], map_register(BPF_REG_1));
    }

    /*
     * Assuming that the stack is 16-byte aligned right before
     * the call insn that brought us to this code, when
     * we start executing the jit'd code, we need to regain a 16-byte
     * alignment. The UBPF_STACK_SIZE is guaranteed to be
     * divisible by 16. However, if we pushed an even number of
     * registers on the stack when we are saving state (see above),
     * then we have to add an additional 8 bytes to get back
     * to a 16-byte alignment.
     */
    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 5, RSP, 0x8);
    }

    /*
     * Set BPF R10 (the way to access the frame in eBPF) to match RSP.
     */
    emit_mov(state, RSP, map_register(BPF_REG_10));

    /* Allocate stack space */
    emit_alu64_imm32(state, 0x81, 5, RSP, UBPF_STACK_SIZE);

#if defined(_WIN32)
    /* Windows x64 ABI requires home register space */
    /* Allocate home register space - 4 registers */
    emit_alu64_imm32(state, 0x81, 5, RSP, 4 * sizeof(uint64_t));
#endif

    /*
     * Use a call to set up a place where we can land after eBPF program's
     * final EXIT call. This makes it appear to the ebpf programs
     * as if they are called like a function. It is their responsibility
     * to deal with the non-16-byte aligned stack pointer that goes along
     * with this pretense.
     */
    emit1(state, 0xe8);
    emit4(state, 5);
    /*
     * We jump over this instruction in the first place; return here
     * after the eBPF program is finished executing.
     */
    emit_jmp(state, TARGET_PC_EXIT);
    int copy_count = 0;
    // printf("%d,%d\n",num_cpy,vec_memcpy[0].save_addr);
    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);
        state->pc_locs[i] = state->offset;

        int dst = map_register(inst.dst);
        int src = map_register(inst.src);
        uint32_t target_pc = i + inst.offset + 1;

        if (i == 0 || vm->int_funcs[i]) {
            /* When we are the subject of a call, we have to properly align our
             * stack pointer.
             */
            emit_alu64_imm32(state, 0x81, 5, RSP, 8);
        }

        if (copy_count < num_cpy && i>= vec_memcpy[copy_count].start_offset && i <= vec_memcpy[copy_count].end_offset)
        {
            if(i == vec_memcpy[copy_count].start_offset)
            {
                emit_basic_rex(state,0,0,vec_memcpy[copy_count].load_reg);      // Loading ip address to xmm0 register from address in load_reg + offset_load
                emit1(state, 0x0f);                 
                emit1(state, 0x10);
                emit_modrm_and_displacement(state, 0, vec_memcpy[copy_count].load_reg, vec_memcpy[copy_count].load_addr);

                emit_basic_rex(state,0,0,vec_memcpy[copy_count].save_reg);      // Saving ip address from xmm0 register to address in save_reg + offset_save
                emit1(state, 0x0f);                 
                emit1(state, 0x11);
                emit_modrm_and_displacement(state, 0, vec_memcpy[copy_count].save_reg, vec_memcpy[copy_count].save_addr);
            }
            else if(i == vec_memcpy[copy_count].end_offset)
                copy_count++;
            continue;
        }

        switch (inst.opcode) {
        case EBPF_OP_ADD_IMM:
            emit_alu32_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD_REG:
            emit_alu32(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB_IMM:
            emit_alu32_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB_REG:
            emit_alu32(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL_IMM:
        case EBPF_OP_MUL_REG:
        case EBPF_OP_DIV_IMM:
        case EBPF_OP_DIV_REG:
        case EBPF_OP_MOD_IMM:
        case EBPF_OP_MOD_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR_IMM:
            emit_alu32_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR_REG:
            emit_alu32(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND_IMM:
            emit_alu32_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND_REG:
            emit_alu32(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH_IMM:
            emit_alu32_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH_IMM:
            emit_alu32_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG:
            emit_alu32(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR_IMM:
            emit_alu32_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR_REG:
            emit_alu32(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV_IMM:
            emit_alu32_imm32(state, 0xc7, 0, dst, inst.imm);
            break;
        case EBPF_OP_MOV_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH_IMM:
            emit_alu32_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 7, dst);
            break;

        case EBPF_OP_LE:
            /* No-op */
            break;
        case EBPF_OP_BE:
            if (inst.imm == 16) {
                /* rol */
                emit1(state, 0x66); /* 16-bit override */
                emit_alu32_imm8(state, 0xc1, 0, dst, 8);
                /* and */
                emit_alu32_imm32(state, 0x81, 4, dst, 0xffff);
            } else if (inst.imm == 32 || inst.imm == 64) {
                /* bswap */
                emit_basic_rex(state, inst.imm == 64, 0, dst);
                emit1(state, 0x0f);
                emit1(state, 0xc8 | (dst & 7));
            }
            break;

        case EBPF_OP_ADD64_IMM:
            emit_alu64_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD64_REG:
            emit_alu64(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB64_IMM:
            emit_alu64_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB64_REG:
            emit_alu64(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL64_IMM:
        case EBPF_OP_MUL64_REG:
        case EBPF_OP_DIV64_IMM:
        case EBPF_OP_DIV64_REG:
        case EBPF_OP_MOD64_IMM:
        case EBPF_OP_MOD64_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR64_IMM:
            emit_alu64_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR64_REG:
            emit_alu64(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND64_IMM:
            emit_alu64_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND64_REG:
            emit_alu64(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG64:
            emit_alu64(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR64_IMM:
            emit_alu64_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR64_REG:
            emit_alu64(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV64_IMM:
            emit_load_imm(state, dst, inst.imm);
            break;
        case EBPF_OP_MOV64_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 7, dst);
            break;

        /* TODO use 8 bit immediate when possible */
        case EBPF_OP_JA:
            emit_jmp(state, target_pc);
            break;
        case EBPF_OP_JEQ_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET_IMM:
            emit_alu64_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET_REG:
            emit_alu64(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JEQ32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET32_IMM:
            emit_alu32_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET32_REG:
            emit_alu32(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_CALL:
            /* We reserve RCX for shifts */
            if (inst.src == 0) {
                emit_mov(state, RCX_ALT, RCX);
                emit_call(state, vm->ext_funcs[inst.imm]);
                if (inst.imm == vm->unwind_stack_extension_index) {
                    emit_cmp_imm32(state, map_register(BPF_REG_0), 0);
                    emit_jcc(state, 0x84, TARGET_PC_EXIT);
                }
            } else if (inst.src == 1) {
                target_pc = i + inst.imm + 1;
                emit_local_call(state, target_pc);
            }
            break;
        case EBPF_OP_EXIT:
            /* On entry to every local function we add an additional 8 bytes.
             * Undo that here!
             */
            emit_alu64_imm32(state, 0x81, 0, RSP, 8);
            emit_ret(state);
            break;

        case EBPF_OP_LDXW:
            emit_load(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXH:
            emit_load(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXB:
            emit_load(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXDW:
            emit_load(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_STW:
            emit_store_imm32(state, S32, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STH:
            emit_store_imm32(state, S16, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STB:
            emit_store_imm32(state, S8, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STDW:
            emit_store_imm32(state, S64, dst, inst.offset, inst.imm);
            break;

        case EBPF_OP_STXW:
            emit_store(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_STXH:
            emit_store(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_STXB:
            emit_store(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_STXDW:
            emit_store(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_LDDW: {
            struct ebpf_inst inst2 = ubpf_fetch_instruction(vm, ++i);
            uint64_t imm = (uint32_t)inst.imm | ((uint64_t)inst2.imm << 32);
            emit_load_imm(state, dst, imm);
            break;
        }

        default:
            *errmsg = ubpf_error("Unknown instruction at PC %d: opcode %02x", i, inst.opcode);
            return -1;
        }
    }

    /* Epilogue */
    state->exit_loc = state->offset;

    /* Move register 0 into rax */
    if (map_register(BPF_REG_0) != RAX) {
        emit_mov(state, map_register(BPF_REG_0), RAX);
    }

    /* Deallocate stack space by restoring RSP from BPF R10. */
    emit_mov(state, map_register(BPF_REG_10), RSP);

    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 0, RSP, 0x8);
    }

    /* Restore platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_pop(state, platform_nonvolatile_registers[_countof(platform_nonvolatile_registers) - i - 1]);
    }

    emit1(state, 0xc3); /* ret */

    state->retpoline_loc = emit_retpoline(state);

    return 0;
}

static int
translate_compare(struct ubpf_vm* vm, struct jit_state* state, char** errmsg, struct load* loads, struct packed_group* groups, int num_groups)
{
    int i;
    int load_count = 0;

    /* Save platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_push(state, platform_nonvolatile_registers[i]);
    }

    /* Move first platform parameter register into register 1 */
    if (map_register(1) != platform_parameter_registers[0]) {
        emit_mov(state, platform_parameter_registers[0], map_register(BPF_REG_1));
    }

    /*
     * Assuming that the stack is 16-byte aligned right before
     * the call insn that brought us to this code, when
     * we start executing the jit'd code, we need to regain a 16-byte
     * alignment. The UBPF_STACK_SIZE is guaranteed to be
     * divisible by 16. However, if we pushed an even number of
     * registers on the stack when we are saving state (see above),
     * then we have to add an additional 8 bytes to get back
     * to a 16-byte alignment.
     */
    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 5, RSP, 0x8);
    }

    /*
     * Set BPF R10 (the way to access the frame in eBPF) to match RSP.
     */
    emit_mov(state, RSP, map_register(BPF_REG_10));

    /* Allocate stack space */
    emit_alu64_imm32(state, 0x81, 5, RSP, UBPF_STACK_SIZE);

#if defined(_WIN32)
    /* Windows x64 ABI requires home register space */
    /* Allocate home register space - 4 registers */
    emit_alu64_imm32(state, 0x81, 5, RSP, 4 * sizeof(uint64_t));
#endif

    /*
     * Use a call to set up a place where we can land after eBPF program's
     * final EXIT call. This makes it appear to the ebpf programs
     * as if they are called like a function. It is their responsibility
     * to deal with the non-16-byte aligned stack pointer that goes along
     * with this pretense.
     */
    emit1(state, 0xe8);
    emit4(state, 5);
    /*
     * We jump over this instruction in the first place; return here
     * after the eBPF program is finished executing.
     */
    emit_jmp(state, TARGET_PC_EXIT);

    // struct packed_group current_group = {-1,-1,-1};
    int processed_index = 0;
    bool in_packed_section = false;
    // struct jump_ana jmp = {-1,-1,-1};     

    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);
        state->pc_locs[i] = state->offset;

        int dst = map_register(inst.dst);
        int src = map_register(inst.src);
        uint32_t target_pc = i + inst.offset + 1;

        if (i == 0 || vm->int_funcs[i]) {
            /* When we are the subject of a call, we have to properly align our
             * stack pointer.
             */
            emit_alu64_imm32(state, 0x81, 5, RSP, 8);
        }
        if(i == loads[load_count].inst_offset )
        {
            emit1(state, 0xf3);                 // movdqu xmmX, xmmword ptr[src+offset] 
            emit_basic_rex(state,0,0,src);      // Loading input packet and Firewall rules to xmmX registers
            emit1(state, 0x0f);                 
            emit1(state, 0x6f);
            emit_modrm_and_displacement(state, load_count!=0, src, inst.offset);

            // if(load_count == 0)
            // {
            //     //Trying aligned load to get more performance
            //     emit1(state,0x66);  
            //     emit1(state,0x0f);
            //     emit1(state,0x38);
            //     emit1(state,0x00);
            //     emit1(state,0xc2);
            // }
            load_count++;
        }
        if(processed_index < num_groups && !in_packed_section && groups[processed_index].start == i)
        {
            in_packed_section = true;
            emit_sse_alu64(state, 0x0F, 0x76, XMM1, XMM0, 0); //doing the comparison

            emit1(state,0x66);      // move xmm1 to r11d
            emit1(state,0x44);      // moving result of comparison to a general register
            emit1(state,0x0f);
            emit1(state,0xd7);
            emit1(state,0xd9);

            emit1(state,0x41);      //compare r11d to 0xffff
            emit1(state,0x81);      // setting flags
            emit1(state,0xfb);
            emit1(state,0xff);
            emit1(state,0xff);
            emit1(state,0x00);
            emit1(state,0x00);

            emit_jcc(state, 0x85, groups[processed_index].fail_target);     // Perform jump if fail
            emit_jcc(state, 0x84, groups[processed_index].success_target);  // Perform jump if success
            continue;
        }
        else if(in_packed_section)
        {
            if (groups[processed_index].end == i)
            {
                in_packed_section = false;
                ++processed_index;
                continue;
            }
            else if(inst.opcode != EBPF_OP_LDDW)
                continue;
        }
        switch (inst.opcode) {
        case EBPF_OP_ADD_IMM:
            emit_alu32_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD_REG:
            emit_alu32(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB_IMM:
            emit_alu32_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB_REG:
            emit_alu32(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL_IMM:
        case EBPF_OP_MUL_REG:
        case EBPF_OP_DIV_IMM:
        case EBPF_OP_DIV_REG:
        case EBPF_OP_MOD_IMM:
        case EBPF_OP_MOD_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR_IMM:
            emit_alu32_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR_REG:
            emit_alu32(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND_IMM:
            emit_alu32_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND_REG:
            emit_alu32(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH_IMM:
            emit_alu32_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH_IMM:
            emit_alu32_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG:
            emit_alu32(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR_IMM:
            emit_alu32_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR_REG:
            emit_alu32(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV_IMM:
            emit_alu32_imm32(state, 0xc7, 0, dst, inst.imm);
            break;
        case EBPF_OP_MOV_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH_IMM:
            emit_alu32_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH_REG:
            emit_mov(state, src, RCX);
            emit_alu32(state, 0xd3, 7, dst);
            break;

        case EBPF_OP_LE:
            /* No-op */
            break;
        case EBPF_OP_BE:
            if (inst.imm == 16) {
                /* rol */
                emit1(state, 0x66); /* 16-bit override */
                emit_alu32_imm8(state, 0xc1, 0, dst, 8);
                /* and */
                emit_alu32_imm32(state, 0x81, 4, dst, 0xffff);
            } else if (inst.imm == 32 || inst.imm == 64) {
                /* bswap */
                emit_basic_rex(state, inst.imm == 64, 0, dst);
                emit1(state, 0x0f);
                emit1(state, 0xc8 | (dst & 7));
            }
            break;

        case EBPF_OP_ADD64_IMM:
            emit_alu64_imm32(state, 0x81, 0, dst, inst.imm);
            break;
        case EBPF_OP_ADD64_REG:
            emit_alu64(state, 0x01, src, dst);
            break;
        case EBPF_OP_SUB64_IMM:
            emit_alu64_imm32(state, 0x81, 5, dst, inst.imm);
            break;
        case EBPF_OP_SUB64_REG:
            emit_alu64(state, 0x29, src, dst);
            break;
        case EBPF_OP_MUL64_IMM:
        case EBPF_OP_MUL64_REG:
        case EBPF_OP_DIV64_IMM:
        case EBPF_OP_DIV64_REG:
        case EBPF_OP_MOD64_IMM:
        case EBPF_OP_MOD64_REG:
            muldivmod(state, inst.opcode, src, dst, inst.imm);
            break;
        case EBPF_OP_OR64_IMM:
            emit_alu64_imm32(state, 0x81, 1, dst, inst.imm);
            break;
        case EBPF_OP_OR64_REG:
            emit_alu64(state, 0x09, src, dst);
            break;
        case EBPF_OP_AND64_IMM:
            emit_alu64_imm32(state, 0x81, 4, dst, inst.imm);
            break;
        case EBPF_OP_AND64_REG:
            emit_alu64(state, 0x21, src, dst);
            break;
        case EBPF_OP_LSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 4, dst, inst.imm);
            break;
        case EBPF_OP_LSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 4, dst);
            break;
        case EBPF_OP_RSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 5, dst, inst.imm);
            break;
        case EBPF_OP_RSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 5, dst);
            break;
        case EBPF_OP_NEG64:
            emit_alu64(state, 0xf7, 3, dst);
            break;
        case EBPF_OP_XOR64_IMM:
            emit_alu64_imm32(state, 0x81, 6, dst, inst.imm);
            break;
        case EBPF_OP_XOR64_REG:
            emit_alu64(state, 0x31, src, dst);
            break;
        case EBPF_OP_MOV64_IMM:
            emit_load_imm(state, dst, inst.imm);
            break;
        case EBPF_OP_MOV64_REG:
            emit_mov(state, src, dst);
            break;
        case EBPF_OP_ARSH64_IMM:
            emit_alu64_imm8(state, 0xc1, 7, dst, inst.imm);
            break;
        case EBPF_OP_ARSH64_REG:
            emit_mov(state, src, RCX);
            emit_alu64(state, 0xd3, 7, dst);
            break;

        /* TODO use 8 bit immediate when possible */
        case EBPF_OP_JA:
            emit_jmp(state, target_pc);
            break;
        case EBPF_OP_JEQ_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET_IMM:
            emit_alu64_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET_REG:
            emit_alu64(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE_IMM:
            emit_cmp_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE_REG:
            emit_cmp(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JEQ32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JEQ32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x84, target_pc);
            break;
        case EBPF_OP_JGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x87, target_pc);
            break;
        case EBPF_OP_JGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x83, target_pc);
            break;
        case EBPF_OP_JLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x82, target_pc);
            break;
        case EBPF_OP_JLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x86, target_pc);
            break;
        case EBPF_OP_JSET32_IMM:
            emit_alu32_imm32(state, 0xf7, 0, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSET32_REG:
            emit_alu32(state, 0x85, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JNE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x85, target_pc);
            break;
        case EBPF_OP_JSGT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8f, target_pc);
            break;
        case EBPF_OP_JSGE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSGE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8d, target_pc);
            break;
        case EBPF_OP_JSLT32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLT32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8c, target_pc);
            break;
        case EBPF_OP_JSLE32_IMM:
            emit_cmp32_imm32(state, dst, inst.imm);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_JSLE32_REG:
            emit_cmp32(state, src, dst);
            emit_jcc(state, 0x8e, target_pc);
            break;
        case EBPF_OP_CALL:
            /* We reserve RCX for shifts */
            if (inst.src == 0) {
                emit_mov(state, RCX_ALT, RCX);
                emit_call(state, vm->ext_funcs[inst.imm]);
                if (inst.imm == vm->unwind_stack_extension_index) {
                    emit_cmp_imm32(state, map_register(BPF_REG_0), 0);
                    emit_jcc(state, 0x84, TARGET_PC_EXIT);
                }
            } else if (inst.src == 1) {
                target_pc = i + inst.imm + 1;
                emit_local_call(state, target_pc);
            }
            break;
        case EBPF_OP_EXIT:
            /* On entry to every local function we add an additional 8 bytes.
             * Undo that here!
             */
            emit_alu64_imm32(state, 0x81, 0, RSP, 8);
            emit_ret(state);
            break;

        case EBPF_OP_LDXW:
            emit_load(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXH:
            emit_load(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXB:
            emit_load(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_LDXDW:
            emit_load(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_STW:
            emit_store_imm32(state, S32, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STH:
            emit_store_imm32(state, S16, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STB:
            emit_store_imm32(state, S8, dst, inst.offset, inst.imm);
            break;
        case EBPF_OP_STDW:
            emit_store_imm32(state, S64, dst, inst.offset, inst.imm);
            break;

        case EBPF_OP_STXW:
            emit_store(state, S32, src, dst, inst.offset);
            break;
        case EBPF_OP_STXH:
            emit_store(state, S16, src, dst, inst.offset);
            break;
        case EBPF_OP_STXB:
            emit_store(state, S8, src, dst, inst.offset);
            break;
        case EBPF_OP_STXDW:
            emit_store(state, S64, src, dst, inst.offset);
            break;

        case EBPF_OP_LDDW: {
            struct ebpf_inst inst2 = ubpf_fetch_instruction(vm, ++i);
            uint64_t imm = (uint32_t)inst.imm | ((uint64_t)inst2.imm << 32);
            emit_load_imm(state, dst, imm);
            break;
        }

        default:
            *errmsg = ubpf_error("Unknown instruction at PC %d: opcode %02x", i, inst.opcode);
            return -1;
        }
    }

    /* Epilogue */
    state->exit_loc = state->offset;

    /* Move register 0 into rax */
    if (map_register(BPF_REG_0) != RAX) {
        emit_mov(state, map_register(BPF_REG_0), RAX);
    }

    /* Deallocate stack space by restoring RSP from BPF R10. */
    emit_mov(state, map_register(BPF_REG_10), RSP);

    if (!(_countof(platform_nonvolatile_registers) % 2)) {
        emit_alu64_imm32(state, 0x81, 0, RSP, 0x8);
    }

    /* Restore platform non-volatile registers */
    for (i = 0; i < _countof(platform_nonvolatile_registers); i++) {
        emit_pop(state, platform_nonvolatile_registers[_countof(platform_nonvolatile_registers) - i - 1]);
    }

    emit1(state, 0xc3); /* ret */

    state->retpoline_loc = emit_retpoline(state);

    return 0;
}

static void
muldivmod(struct jit_state* state, uint8_t opcode, int src, int dst, int32_t imm)
{
    bool mul = (opcode & EBPF_ALU_OP_MASK) == (EBPF_OP_MUL_IMM & EBPF_ALU_OP_MASK);
    bool div = (opcode & EBPF_ALU_OP_MASK) == (EBPF_OP_DIV_IMM & EBPF_ALU_OP_MASK);
    bool mod = (opcode & EBPF_ALU_OP_MASK) == (EBPF_OP_MOD_IMM & EBPF_ALU_OP_MASK);
    bool is64 = (opcode & EBPF_CLS_MASK) == EBPF_CLS_ALU64;
    bool reg = (opcode & EBPF_SRC_REG) == EBPF_SRC_REG;

    // Short circuit for imm == 0.
    if (!reg && imm == 0) {
        if (div || mul) {
            // For division and multiplication, set result to zero.
            emit_alu32(state, 0x31, dst, dst);
        } else {
            // For modulo, set result to dividend.
            emit_mov(state, dst, dst);
        }
        return;
    }

    if (dst != RAX) {
        emit_push(state, RAX);
    }

    if (dst != RDX) {
        emit_push(state, RDX);
    }

    // Load the divisor into RCX.
    if (imm) {
        emit_load_imm(state, RCX, imm);
    } else {
        emit_mov(state, src, RCX);
    }

    // Load the dividend into RAX.
    emit_mov(state, dst, RAX);

    // BPF has two different semantics for division and modulus. For division
    // if the divisor is zero, the result is zero.  For modulus, if the divisor
    // is zero, the result is the dividend. To handle this we set the divisor
    // to 1 if it is zero and then set the result to zero if the divisor was
    // zero (for division) or set the result to the dividend if the divisor was
    // zero (for modulo).

    if (div || mod) {
        // Check if divisor is zero.
        if (is64) {
            emit_alu64(state, 0x85, RCX, RCX);
        } else {
            emit_alu32(state, 0x85, RCX, RCX);
        }

        // Save the dividend for the modulo case.
        if (mod) {
            emit_push(state, RAX); // Save dividend.
        }

        // Save the result of the test.
        emit1(state, 0x9c); /* pushfq */

        // Set the divisor to 1 if it is zero.
        emit_load_imm(state, RDX, 1);
        emit1(state, 0x48);
        emit1(state, 0x0f);
        emit1(state, 0x44);
        emit1(state, 0xca); /* cmove rcx,rdx */

        /* xor %edx,%edx */
        emit_alu32(state, 0x31, RDX, RDX);
    }

    if (is64) {
        emit_rex(state, 1, 0, 0, 0);
    }

    // Multiply or divide.
    emit_alu32(state, 0xf7, mul ? 4 : 6, RCX);

    // Division operation stores the remainder in RDX and the quotient in RAX.
    if (div || mod) {
        // Restore the result of the test.
        emit1(state, 0x9d); /* popfq */

        // If zero flag is set, then the divisor was zero.

        if (div) {
            // Set the dividend to zero if the divisor was zero.
            emit_load_imm(state, RCX, 0);

            // Store 0 in RAX if the divisor was zero.
            // Use conditional move to avoid a branch.
            emit1(state, 0x48);
            emit1(state, 0x0f);
            emit1(state, 0x44);
            emit1(state, 0xc1); /* cmove rax,rcx */
        } else {
            // Restore dividend to RCX.
            emit_pop(state, RCX);

            // Store the dividend in RAX if the divisor was zero.
            // Use conditional move to avoid a branch.
            emit1(state, 0x48);
            emit1(state, 0x0f);
            emit1(state, 0x44);
            emit1(state, 0xd1); /* cmove rdx,rcx */
        }
    }

    if (dst != RDX) {
        if (mod) {
            emit_mov(state, RDX, dst);
        }
        emit_pop(state, RDX);
    }
    if (dst != RAX) {
        if (div || mul) {
            emit_mov(state, RAX, dst);
        }
        emit_pop(state, RAX);
    }
}

static void
resolve_jumps(struct jit_state* state)
{
    int i;
    for (i = 0; i < state->num_jumps; i++) {
        struct jump jump = state->jumps[i];

        int target_loc;
        if (jump.target_offset != 0) {
            target_loc = jump.target_offset;
        } else if (jump.target_pc == TARGET_PC_EXIT) {
            target_loc = state->exit_loc;
        } else if (jump.target_pc == TARGET_PC_RETPOLINE) {
            target_loc = state->retpoline_loc;
        } else {
            target_loc = state->pc_locs[jump.target_pc];
        }

        /* Assumes jump offset is at end of instruction */
        uint32_t rel = target_loc - (jump.offset_loc + sizeof(uint32_t));

        uint8_t* offset_ptr = &state->buf[jump.offset_loc];
        memcpy(offset_ptr, &rel, sizeof(uint32_t));
    }
}

static int
analyse_memcpy_64(struct ubpf_vm* vm, struct vec_memcpy* vec_memcpy, int *num_cpy)
{
    int i;
    printf("alo\n");
    // int count = 0;

    bool load_started = false;
    int started_offset = -1;
    int load_counter = 0;
    int save_counter = 0;

    int32_t min_imm_ld = INT_MAX;
    int32_t min_imm_sv = INT_MAX;
    int copy_counter = *num_cpy;
    int load_reg = -1;
    int save_reg = -1;

    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);
        int dst = map_register(inst.dst);
        int src = map_register(inst.src);
        switch (inst.opcode) {
        case EBPF_OP_LDXW:
            if(!load_started)
            {
                printf("we found a potential packed memcpy start at: %d, src: %d, dst: %d, imm: %d \n",i,src,dst,inst.offset);
                load_started = true;
                started_offset = i;
                load_counter = 1;
                load_reg = src;
                min_imm_ld = inst.offset;
                vec_memcpy[copy_counter].start_offset=i;

                // loads[count].addr_offset = inst.offset;
                // loads[count].inst_offset = i;
            }
            else if(load_counter < 4 && load_counter >= save_counter && src == load_reg)
            {
                printf("This is a load at %d part of the copy started at %d,src: %d, dst: %d, imm: %d \n",i,started_offset,src,dst,inst.offset);
                load_counter ++;
                if(inst.offset < min_imm_ld)
                    min_imm_ld = inst.offset;
            }
            break;
        case EBPF_OP_STXDW:
            // printf("This is a save at %d\n",i);
            // printf("conditions: loadstarted: %d, save_counter %d, load_counter  %d",load_started,save_counter, load_counter +1);
            if(load_started && save_counter + 2 == load_counter)
            {
                printf("This is a save at %d part of the copy started at %d,src: %d, dst: %d, imm: %d \n",i,started_offset,src,dst,inst.offset);
                // printf("the save address is: %d\n",inst.offset);
                save_counter+=2;
                save_reg = dst;
                if(inst.offset < min_imm_sv)
                    min_imm_sv = inst.offset;
            }
            if (save_counter >= 4 || load_counter >= 4)
            {
                load_started = false;
                vec_memcpy[copy_counter].end_offset=i;
                vec_memcpy[copy_counter].load_reg=load_reg;
                vec_memcpy[copy_counter].save_reg=save_reg;
                vec_memcpy[copy_counter].save_addr=min_imm_sv;
                vec_memcpy[copy_counter].load_addr=min_imm_ld;


                load_counter = 0;
                save_counter = 0;
                min_imm_sv = INT_MAX;
                min_imm_ld = INT_MAX;

                printf("Copy %d was completed, starting imm for load: %d, starting imm for save: %d, load address is in: %d, save address is in: %d\n",copy_counter,min_imm_ld,min_imm_sv,load_reg,save_reg);
                copy_counter ++;
            }
            break;
        case EBPF_OP_LSH64_IMM:
        case EBPF_OP_OR64_REG:
            break;
        default:
            load_started = false;
            load_counter = 0;
            save_counter = 0;
            break;
        }
    }
    qsort (vec_memcpy, copy_counter, sizeof(*vec_memcpy), comp_cpy);      // Sorting the lables

    for (i = 0; i< copy_counter; i++)
    {
        printf("vec copy start at %d, ends at %d, load address in %d reg with offset %d save address in %d reg with offset %d \n",
                                                    vec_memcpy[i].start_offset,vec_memcpy[i].end_offset,vec_memcpy[i].load_reg,vec_memcpy[i].load_addr,vec_memcpy[i].save_reg,vec_memcpy[i].save_addr);
    }
    *num_cpy = copy_counter;
    return 0;
}

static int
analyse_memcpy(struct ubpf_vm* vm, struct vec_memcpy* vec_memcpy, int *num_cpy)
{
    int i;

    // int count = 0;

    bool load_started = false;
    // int started_offset;
    int load_counter = 0;
    int save_counter = 0;

    int32_t min_imm_ld = INT_MAX;
    int32_t min_imm_sv = INT_MAX;
    int copy_counter = 0;
    int load_reg = -1;
    int save_reg = -1;

    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);
        int dst = map_register(inst.dst);
        int src = map_register(inst.src);
        switch (inst.opcode) {
        case EBPF_OP_LDXW:
            if(!load_started)
            {
                // printf("we found a potential packed memcpy start at: %d, src: %d, dst: %d, imm: %d \n",i,src,dst,inst.offset);
                load_started = true;
                // started_offset = i;
                load_counter = 1;
                load_reg = src;
                min_imm_ld = inst.offset;
                vec_memcpy[copy_counter].start_offset=i;

                // loads[count].addr_offset = inst.offset;
                // loads[count].inst_offset = i;
            }
            else if(load_counter < 4 && load_counter == save_counter && src == load_reg)
            {
                // printf("This is a load at %d part of the copy started at %d,src: %d, dst: %d, imm: %d \n",i,started_offset,src,dst,inst.offset);
                load_counter ++;
                if(inst.offset < min_imm_ld)
                    min_imm_ld = inst.offset;
            }
            break;
        case EBPF_OP_STXW:
            // printf("This is a save at %d\n",i);
            // printf("conditions: loadstarted: %d, save_counter %d, load_counter  %d",load_started,save_counter, load_counter +1);
            if(load_started && save_counter + 1 == load_counter)
            {
                // printf("This is a save at %d part of the copy started at %d,src: %d, dst: %d, imm: %d \n",i,started_offset,src,dst,inst.offset);
                // printf("the save address is: %d\n",inst.offset);
                save_counter++;
                save_reg = dst;
                if(inst.offset < min_imm_sv)
                    min_imm_sv = inst.offset;
            }
            if (save_counter >= 4 || load_counter >= 4)
            {
                load_started = false;
                vec_memcpy[copy_counter].end_offset=i;
                vec_memcpy[copy_counter].load_reg=load_reg;
                vec_memcpy[copy_counter].save_reg=save_reg;
                vec_memcpy[copy_counter].save_addr=min_imm_sv;
                vec_memcpy[copy_counter].load_addr=min_imm_ld;


                load_counter = 0;
                save_counter = 0;
                min_imm_sv = INT_MAX;
                min_imm_ld = INT_MAX;

                // printf("Copy %d was completed, starting imm for load: %d, starting imm for save: %d, load address is in: %d, save address is in: %d\n",copy_counter,min_imm_ld,min_imm_sv,load_reg,save_reg);
                copy_counter ++;
            }
            break;
        default:
            load_started = false;
            load_counter = 0;
            save_counter = 0;
            break;
        }
    }
    // for (i = 0; i< copy_counter; i++)
    // {
        // printf("vec copy start at %d, ends at %d, load address in %d reg with offset %d save address in %d reg with offset %d \n",
                                                    // vec_memcpy[i].start_offset,vec_memcpy[i].end_offset,vec_memcpy[i].load_reg,vec_memcpy[i].load_addr,vec_memcpy[i].save_reg,vec_memcpy[i].save_addr);
    // }
    *num_cpy = copy_counter;
    return 0;
}

static bool is_duplicate(uint32_t num, uint32_t *array, size_t size) {
    for (int i = 0; i < size; i++) {
        if (array[i] == num) {
            return true;
        }
    }
    return false;
}

static int get_group(const uint32_t sorted_targets[], size_t size, uint32_t pc)
{
    int i;
    for (i=0;i<size-1;i++)
    {
        if(sorted_targets[i]<pc && sorted_targets[i+1]>pc)
            return i;
    }
    return size - 1;  
}

static int
analyse_jmp(struct ubpf_vm* vm, struct jump_ana* jumps, struct packed_group* groups, int *num_groups)
{
    int i;
    uint32_t targets[UBPF_MAX_INSTS];
    targets[0] = 0;
    size_t target_index = 1;

    int num_jumps = 0;
    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);

        uint32_t target_pc = i + inst.offset + 1;

        switch (inst.opcode) {
        case EBPF_OP_JNE_REG:
            // printf("checking jump not equal instruction is in line %d, target_pc: %d, target_index: %ld\n",i ,target_pc, target_index);
            if(!is_duplicate(target_pc, targets,target_index)) // Trying to find lables or jump targets in the assembly code
            {
                targets[target_index] = target_pc;
                target_index++;
            }
            jumps[num_jumps].target_pc = target_pc;     // Add the jump to the available jumps
            jumps[num_jumps].loc = i;
            jumps[num_jumps].opcode = EBPF_OP_JNE_REG;
            num_jumps++;
            break;
        case EBPF_OP_JEQ_REG:
            // printf("checking jump not equal instruction is in line %d, target_pc: %d, target_index: %ld\n",i ,target_pc, target_index);
            if(!is_duplicate(target_pc, targets,target_index)) // Trying to find lables or jump targets in the assembly code
            {
                targets[target_index] = target_pc;
                target_index++;
            }
            jumps[num_jumps].target_pc = target_pc;     // Add the jump to the available jumps
            jumps[num_jumps].loc = i;
            jumps[num_jumps].opcode = EBPF_OP_JEQ_REG;

            num_jumps++;
            break;
        case EBPF_OP_JNE_IMM:
        case EBPF_OP_JA:
        case EBPF_OP_JEQ_IMM:

        case EBPF_OP_JGT_IMM:
        case EBPF_OP_JGT_REG:
        case EBPF_OP_JGE_IMM:
        case EBPF_OP_JGE_REG:
        case EBPF_OP_JLT_IMM:
        case EBPF_OP_JLT_REG:
        case EBPF_OP_JLE_IMM:
        case EBPF_OP_JLE_REG:
        case EBPF_OP_JSET_IMM:
        case EBPF_OP_JSET_REG:
        case EBPF_OP_JSGT_IMM:
        case EBPF_OP_JSGT_REG:
        case EBPF_OP_JSGE_IMM:
        case EBPF_OP_JSGE_REG:
        case EBPF_OP_JSLT_IMM:
        case EBPF_OP_JSLT_REG:
        case EBPF_OP_JSLE_IMM:
        case EBPF_OP_JSLE_REG:
        case EBPF_OP_JEQ32_IMM:
        case EBPF_OP_JEQ32_REG:
        case EBPF_OP_JGT32_IMM:
        case EBPF_OP_JGT32_REG:
        case EBPF_OP_JGE32_IMM:
        case EBPF_OP_JGE32_REG:
        case EBPF_OP_JLT32_IMM:
        case EBPF_OP_JLT32_REG:
        case EBPF_OP_JLE32_IMM:
        case EBPF_OP_JLE32_REG:
        case EBPF_OP_JSET32_IMM:
        case EBPF_OP_JSET32_REG:
        case EBPF_OP_JNE32_IMM:
        case EBPF_OP_JNE32_REG:
        case EBPF_OP_JSGT32_IMM:
        case EBPF_OP_JSGT32_REG:
        case EBPF_OP_JSGE32_IMM:
        case EBPF_OP_JSGE32_REG:
        case EBPF_OP_JSLT32_IMM:
        case EBPF_OP_JSLT32_REG:
        case EBPF_OP_JSLE32_IMM:
        case EBPF_OP_JSLE32_REG:
        case EBPF_OP_CALL:
            if(!is_duplicate(target_pc, targets,target_index))
            {
                targets[target_index] = target_pc;
                target_index++;
            }
            break;
        default:
            break;
        }
    }
    qsort (targets, target_index, sizeof(*targets), comp);      // Sorting the lables
    // for (i = 0;i<target_index;i++)
    // {
    //     printf("Lable at %d \n",targets[i]);
    // }
    int group_index = -1;
    int group_id;
    groups[0].size = 0;
    groups[0].section_id = -1;
     // here I want to group the jumps togather in groups of 4, the first three are going to be JNE
     // The last jump should be JE
    for(i = 0;i<num_jumps;i++)  // here I am assuming that I have just one batch jump in a section which is not a good assumption
    {
        group_id = get_group(targets,target_index,jumps[i].loc);
        if (group_index == -1 || groups[group_index].section_id != group_id){
            group_index++;
            groups[group_index].section_id = group_id;
            groups[group_index].size = 1;
            groups[group_index].start = jumps[i].loc;
        }
        else{
            groups[group_index].size++;
        }
        groups[group_index].end = jumps[i].loc;
        
        jumps[i].group = group_id;
        if (jumps[i].opcode == EBPF_OP_JNE_REG)
            groups[group_index].fail_target =  jumps[i].target_pc;
        else
            groups[group_index].success_target =  jumps[i].target_pc;
    }
    *num_groups = group_index + 1;
    // for (i = 0; i< group_index; i++)
    //     printf("group compare in section %d, started at %d, ended at %d, size is %d\n",
    //                                     groups[i].section_id, groups[i].start, groups[i].end, groups[i].size);

    return 0;
}

static int
analyse(struct ubpf_vm* vm, struct load* loads, int *num_loads)
{
    int i;

    int count = 0;

    bool load_started = false;
    // int started_offset;
    int load_counter = 0;
    enum operand_size load_size;

    for (i = 0; i < vm->num_insts; i++) {
        struct ebpf_inst inst = ubpf_fetch_instruction(vm, i);

        switch (inst.opcode) {
        case EBPF_OP_LDXW:
            if(!load_started)
            {
                // printf("we found a potential 32b packed load start at: %d \n",i);
                load_started = true;
                // started_offset = i;
                load_size = S32;
                load_counter = 1;

                loads[count].addr_offset = inst.offset;
                loads[count].inst_offset = i;
            }
            else if(load_size == S32)
            {
                if(load_counter < 4)
                {
                    // printf("This is a 32b packed load at %d which started at %d \n",i,started_offset);
                    load_counter ++;
                    if (inst.offset < loads[count].addr_offset)
                    {
                        loads[count].addr_offset = inst.offset;
                        loads[count].inst_offset = i;
                    }
                }
                if(load_counter >= 4)
                {
                    // printf("This is the last 32b load from this packed load at %d which started at %d \n",i,started_offset);
                    load_started = false;
                    // started_offset = -1;
                    load_size = -1;
                    load_counter = 0;
                    count++;
                }
            }
            break;
        }
    }
    qsort (loads, count, sizeof(*loads), comp_load);
    *num_loads = count;

    // printf("loads are sorted!!\n");
    // for (i = 0; i< count; i++)
    // {
    //     printf("32 bit load at %d offset is %d\n",loads[i].inst_offset,loads[i].addr_offset);
    // }
    
    return 0;
}

int
ubpf_translate_x86_64(struct ubpf_vm* vm, uint8_t* buffer, size_t* size, char** errmsg, int vanila)
{
    struct jit_state state;
    int result = -1;
    int num_groups = 0;
    int num_vec_loads = 0;
    int num_vec_cpys = 0;



    state.offset = 0;
    state.size = *size;
    state.buf = buffer;
    state.pc_locs = calloc(UBPF_MAX_INSTS + 1, sizeof(state.pc_locs[0]));
    state.jumps = calloc(UBPF_MAX_INSTS, sizeof(state.jumps[0]));
    state.num_jumps = 0;

    struct jump_ana* my_jne = calloc(UBPF_MAX_INSTS, sizeof(my_jne[0])); // Jumps existing in our code
    struct packed_group* groups = calloc(UBPF_MAX_INSTS, sizeof(groups[0])); // Group jumps (each jump belongs to one of these groups)
    struct load* packed_loads = calloc(UBPF_MAX_INSTS, sizeof(packed_loads[0])); // packed loads
    struct vec_memcpy* packed_cpy = calloc(UBPF_MAX_INSTS, sizeof(packed_cpy[0])); // packed copy

    
    if(vanila == 0)  
    {
        printf("Vanila JIT Compilation...\n");
        if (translate(vm, &state, errmsg) < 0) {
            goto out;
        }
    }
    
    else if (vanila == 1)  // This mode is for vector comparisons 
    {
        printf("JIT Compilation with Compare Optimization...\n");
          // Finding group data loads to put them inside XMM registers
        if (analyse(vm, packed_loads, &num_vec_loads) < 0) {
            goto out;
        }
            // Finding comparisons where we actually change the code
            // TODO: Mapping each group comparison to a XMM register to make it more general
        if (analyse_jmp(vm, my_jne, groups, &num_groups) < 0) {
            goto out;
        }
            // Changed JIT translation function (in this version we delete the whole comparison segment and replace it with our vectorized comparison)
        if (translate_compare(vm, &state, errmsg, packed_loads, groups, num_groups) < 0) {
            goto out;
        }
    }
    else if (vanila == 2) // This mode is for vector memcpy 
    {       
        printf("JIT Compilation with Memcpy Optimization...\n");
            // Finding potential group memcpies that could be done with SIMD opperations (MOVUPS)
        if (analyse_memcpy(vm, packed_cpy, &num_vec_cpys) < 0) { 
            goto out;
        }
            // Finding potential group memcpies with different patterns that could be done with SIMD opperations (MOVUPS) 
        if (analyse_memcpy_64(vm, packed_cpy, &num_vec_cpys) < 0) { 
            goto out;
        }
            // Changed JIT translation function (in this version we delete the whole move opperations founded in the analysis function and replace them with MOVUPS)
        if (translate_cpy(vm, &state, errmsg, packed_cpy, num_vec_cpys) < 0) {
            goto out;
        }
    }


    if (state.num_jumps == UBPF_MAX_INSTS) {
        *errmsg = ubpf_error("Excessive number of jump targets");
        goto out;
    }

    if (state.offset == state.size) {
        *errmsg = ubpf_error("Target buffer too small");
        goto out;
    }

    resolve_jumps(&state);
    result = 0;

    *size = state.offset;

out:
    free(my_jne);
    free(packed_cpy);
    free(groups);
    free(packed_loads);
    free(state.pc_locs);
    free(state.jumps);
    return result;
}
