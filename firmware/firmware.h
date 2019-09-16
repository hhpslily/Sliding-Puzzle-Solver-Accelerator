// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#ifndef FIRMWARE_H
#define FIRMWARE_H

#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

// irq.c
uint32_t *irq(uint32_t *regs, uint32_t irqs);

// print.c
void print_chr(char ch);
void print_str(const char *p);
void print_dec(unsigned int val);
void print_hex(unsigned int val, int digits);

// multest.c
uint32_t hard_mul(uint32_t a, uint32_t b);
uint32_t hard_mulh(uint32_t a, uint32_t b);
uint32_t hard_mulhsu(uint32_t a, uint32_t b);
uint32_t hard_mulhu(uint32_t a, uint32_t b);
void multest(void);

//gcd_pcpi.c
void soft_puzzle();
int hard_puzzle(uint32_t a, uint32_t b);
int distance(int array[][3]);
void printboard(int array[][3]);
int rightmove(int array[][3],int zerox,int zeroy);
int leftmove(int array[][3],int zerox,int zeroy);
int downmove(int array[][3],int zerox,int zeroy);
int upmove(int array[][3],int zerox,int zeroy);

// stats.c
void stats(void);
uint32_t tick(void);

#endif
