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

// static bool is_valid_jmp(struct jump_ana *jumps, int loc, int size, struct jump_ana *jmp)
// {
//     int i;
//     for (i = 0; i<size; ++i)
//     {
//         if(jumps[i].loc == loc)
//         {
//             jmp->group = jumps[i].group;
//             jmp->loc = jumps[i].loc;
//             jmp->target_pc = jumps[i].target_pc;

//             return true; 
//         }
//     }
//     return false; 
// }

// static void get_jmp_group(const struct jump_ana jump, struct packed_group* groups, struct packed_group *group)
// {
//     int i;
//     for (i = 0; i< UBPF_MAX_INSTS;i++)
//     {
//         if(groups[i].section_id == jump.group)
//         {
//             group->end = groups[i].end;
//             group->size = groups[i].size;
//             group->section_id = groups[i].section_id;
//             break;
//         }
//     }
// }


static int
translate(struct ubpf_vm* vm, struct jit_state* state, char** errmsg, struct load* loads/*, struct jump_ana* jumps, struct packed_group* groups, int num_vec_jumps*/)
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
    // int processed_index = 0;
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

        if(i == 0)
        {
            emit1(state,0x49);      // move lower mask to r10
            emit1(state,0xba);
            emit1(state,0x03);
            emit1(state,0x02);
            emit1(state,0x01);
            emit1(state,0x00);
            emit1(state,0x07);
            emit1(state,0x06);
            emit1(state,0x05);
            emit1(state,0x04);

            emit1(state,0x49);      // move higher mask to r11
            emit1(state,0xbb);
            emit1(state,0x0b);
            emit1(state,0x0a);
            emit1(state,0x09);
            emit1(state,0x08);
            emit1(state,0x0f);
            emit1(state,0x0e);
            emit1(state,0x0d);
            emit1(state,0x0c);

            emit1(state,0xc4);      //move lower mask from r10 to xmm2
            emit1(state,0xc1);
            emit1(state,0xf9);
            emit1(state,0x6e);
            emit1(state,0xd2);

            emit1(state,0xc4);      //move higher mask from r11 to xmm3
            emit1(state,0xc1);
            emit1(state,0xf9);
            emit1(state,0x6e);
            emit1(state,0xdb);
            
            emit1(state,0xc5);      //merge xmm2 and xmm3 to xmm2
            emit1(state,0xf9);
            emit1(state,0x6c);
            emit1(state,0xc1);
            
        }

        if(i == loads[load_count].inst_offset )
        {

            emit1(state, 0xf3);
            emit_basic_rex(state,0,0,src);
            emit1(state, 0x0f);
            emit1(state, 0x6f);
            emit_modrm_and_displacement(state, 0, src, inst.offset);

            if(load_count == 0)
            {
                //simd byteswap for xmm0 on xmm2 mask
                emit1(state,0x66);  
                emit1(state,0x0f);
                emit1(state,0x38);
                emit1(state,0x00);
                emit1(state,0xc2);
            }
            load_count++;
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
            // if(is_valid_jmp(jumps, i, num_vec_jumps, &jmp))
            // {
            //     // printf("Found a jump to change, in %d line, belongs to %d section and the index is %d\n",jmp.loc,jmp.group,processed_index);
            //     // printf("Current group id is: [%"PRIu32"]\n",current_group.section_id);
            //     if(processed_index == 0)
            //     {
                    
            //         get_jmp_group(jmp, groups, &current_group);
            //     }
            //     if(jmp.group == current_group.section_id && processed_index/4 < current_group.size/4)
            //     {
            //         emit_load_imm(state, R10, inst.imm);    //move the immediate value to register r10 which is not being used by any other instruction in this assembly
            //         emit_sse_alu64_imm32(state, 0x0F, 0x72, 6, XMM0, 32);      //first we shift 32 bit to the left
            //         // emit_sse_alu64(state, 0x0F, 0x6E, XMM0, R10, 1);           //then we load our value to xmm
            //         // emit_sse_alu64_imm32(state, 0x0F, 0x72, 6, XMM1, 32);
            //         // emit_sse_alu64(state, 0x0F, 0x6E, XMM1, dst, 1);
            //         // if (processed_index%4 == 3)         // doing the jump only if we have a full 4 pack of loads
            //         // {
            //         // emit_sse_alu64(state, 0x0F, 0x2F, XMM1, XMM0, 0); //doing the comparison
            //         // emit_jcc(state, 0x85, target_pc);
            //         // }
            //         // processed_index++;
            //         // break;
            //     }
            //     else if (processed_index == current_group.size -1)
            //         processed_index = -1;
            //     processed_index++;
            // }
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
analyse_jmp(struct ubpf_vm* vm, struct jump_ana* jumps, struct packed_group* groups, int *num_jump)
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
            if(!is_duplicate(target_pc, targets,target_index))
            {
                targets[target_index] = target_pc;
                target_index++;
            }
            jumps[num_jumps].target_pc = target_pc;
            jumps[num_jumps].loc = i;
            num_jumps++;
            break;
        case EBPF_OP_JNE_IMM:
        case EBPF_OP_JA:
        case EBPF_OP_JEQ_IMM:
        case EBPF_OP_JEQ_REG:
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
    qsort (targets, target_index, sizeof(*targets), comp);
    for (i = 0;i<target_index;i++)
    {
        printf("Lable at %d \n",targets[i]);
    }
    int group_index = -1;
    int group_id;
    groups[0].size = 0;
    groups[0].section_id = -1;
    for(i = 0;i<num_jumps;i++)
    {
        group_id = get_group(targets,target_index,jumps[i].loc);
        if (group_index == -1 || groups[group_index].section_id != group_id){
            group_index++;
            groups[group_index].section_id = group_id;
            groups[group_index].size = 1;
        }
        else{
            groups[group_index].size++;
        }
        groups[group_index].end = jumps[i].loc;
        
        jumps[i].group = group_id;
        printf("Jump Found in %d, targetting %d, belongs to section %d\n",jumps[i].loc,jumps[i].target_pc,jumps[i].group);
    }
    *num_jump = num_jumps;
    printf("total number of jumps found is:%d\n",*num_jump);

    return 0;
}

static int
analyse(struct ubpf_vm* vm, struct load* loads, int *num_loads)
{
    int i;

    int count = 0;

    bool load_started = false;
    // int16_t started_offset = -1;
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
        case EBPF_OP_LDXH:
            if(!load_started)
            {
                // printf("we found a potential 16b packed load start at: %d \n",i);
                load_started = true;
                // started_offset = i;
                load_size = S16;
                load_counter = 1;

                loads[count].addr_offset = inst.offset;
                loads[count].inst_offset = i;
            }
            else if(load_size == S16)
            {
                if(load_counter < 8)
                {
                    // printf("This is a 16b packed load at %d which started at %d\n",i,started_offset);
                    load_counter ++;
                    if (inst.offset < loads[count].addr_offset)
                    {
                        loads[count].addr_offset = inst.offset;
                        loads[count].inst_offset = i;
                    }
                }
                if(load_counter >= 8)
                {
                    // printf("This is the last 16b load from this packed load at %d which started at %d \n",i,started_offset);
                    load_started = false;
                    // started_offset = -1;
                    load_size = -1;
                    load_counter = 0;
                    count++;
                }
            }
            break;
        case EBPF_OP_LDXB:
            if(!load_started)
            {
                // printf("we found a potential 8b packed load start at: %d\n",i);
                load_started = true;
                // started_offset = i;
                load_size = S8;
                load_counter = 1;

                loads[count].addr_offset = inst.offset;
                loads[count].inst_offset = i;
            }
            else if(load_size == S8)
            {
                if(load_counter < 16)
                {
                    // printf("This is a 8b packed load at %d which started at %d\n",i,started_offset);
                    load_counter ++;
                    if (inst.offset < loads[count].addr_offset)
                    {
                        loads[count].addr_offset = inst.offset;
                        loads[count].inst_offset = i;
                    }
                }
                if(load_counter >= 16)
                {
                    // printf("This is the last 16b load from this packed load at %d which started at %d \n",i,started_offset);
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
    for (i = 0; i < count; i++)
    {
        // printf("packed_load offset: %d, packed_load position: %d\n",loads[i].addr_offset, loads[i].inst_offset);
    }
    
    return 0;
}

int
ubpf_translate_x86_64(struct ubpf_vm* vm, uint8_t* buffer, size_t* size, char** errmsg)
{
    struct jit_state state;
    int result = -1;
    int num_vec_jumps = 0;
    int num_vec_loads = 0;


    state.offset = 0;
    state.size = *size;
    state.buf = buffer;
    state.pc_locs = calloc(UBPF_MAX_INSTS + 1, sizeof(state.pc_locs[0]));
    state.jumps = calloc(UBPF_MAX_INSTS, sizeof(state.jumps[0]));
    state.num_jumps = 0;

    struct jump_ana* my_jne = calloc(UBPF_MAX_INSTS, sizeof(my_jne[0]));
    struct packed_group* groups = calloc(UBPF_MAX_INSTS, sizeof(groups[0]));
    struct load* packed_loads = calloc(UBPF_MAX_INSTS, sizeof(packed_loads[0]));

    if (analyse(vm, packed_loads, &num_vec_loads) < 0) {
        goto out;
    }

    if (analyse_jmp(vm, my_jne, groups, &num_vec_jumps) < 0) {
        goto out;
    }

    if (translate(vm, &state, errmsg, packed_loads/*, my_jne, groups, num_vec_jumps*/) < 0) {
        goto out;
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
    free(state.pc_locs);
    free(state.jumps);
    return result;
}
