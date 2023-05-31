C s390x/msa_x1/sha256-compress-n.asm

ifelse(`
   Copyright (C) 2021, 2022 Mamone Tarsha, Niels Möller
   This file is part of GNU Nettle.

   GNU Nettle is free software: you can redistribute it and/or
   modify it under the terms of either:

     * the GNU Lesser General Public License as published by the Free
       Software Foundation; either version 3 of the License, or (at your
       option) any later version.

   or

     * the GNU General Public License as published by the Free
       Software Foundation; either version 2 of the License, or (at your
       option) any later version.

   or both in parallel, as here.

   GNU Nettle is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received copies of the GNU General Public License and
   the GNU Lesser General Public License along with this program.  If
   not, see http://www.gnu.org/licenses/.
')

C KIMD (COMPUTE INTERMEDIATE MESSAGE DIGEST) is specefied in
C "z/Architecture Principles of Operation SA22-7832-12" as follows:
C A function specified by the function code in general register 0 is performed.
C General register 1 contains the logical address of the leftmost byte of the parameter block in storage.
C the second operand is processed as specified by the function code using an initial chaining value in
C the parameter block, and the result replaces the chaining value.

C This implementation uses KIMD-SHA-256 function.
C The parameter block used for the KIMD-SHA-256 function has the following format:
C *----------------------------------------------*
C |                 H0 (4 bytes)                 |
C |----------------------------------------------|
C |                 H1 (4 bytes)                 |
C |----------------------------------------------|
C |                 H2 (4 bytes)                 |
C |----------------------------------------------|
C |                 H3 (4 bytes)                 |
C |----------------------------------------------|
C |                 H4 (4 bytes)                 |
C |----------------------------------------------|
C |                 H5 (4 bytes)                 |
C |----------------------------------------------|
C |                 H6 (4 bytes)                 |
C |----------------------------------------------|
C |                 H7 (4 bytes)                 |
C *----------------------------------------------*

.file "sha256-compress-n.asm"

.text

C SHA function code
define(`SHA256_FUNCTION_CODE', `2')

C const uint8_t *
C _nettle_sha256_compress_n(uint32_t *state, const uint32_t *k,
C			    size_t blocks, const uint8_t *input)

PROLOGUE(_nettle_sha256_compress_n)
    lghi           %r0,SHA256_FUNCTION_CODE      C SHA-256 Function Code
    lgr            %r1,%r2
    lgr            %r2, %r5
    sllg	   %r3, %r4, 6                   C 64 * block size
1:  .long   0xb93e0002                           C kimd %r0,%r2. perform KIMD-SHA operation on data
    brc            1,1b
    br             RA
EPILOGUE(_nettle_sha256_compress_n)
