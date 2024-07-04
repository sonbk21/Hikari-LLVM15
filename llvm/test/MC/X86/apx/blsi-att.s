# RUN: llvm-mc -triple x86_64 --show-encoding %s | FileCheck %s
# RUN: not llvm-mc -triple i386 -show-encoding %s 2>&1 | FileCheck %s --check-prefix=ERROR

# ERROR-COUNT-12: error:
# ERROR-NOT: error:
# CHECK: {nf}	blsil	%ecx, %edx
# CHECK: encoding: [0x62,0xf2,0x6c,0x0c,0xf3,0xd9]
         {nf}	blsil	%ecx, %edx

# CHECK: {evex}	blsil	%ecx, %edx
# CHECK: encoding: [0x62,0xf2,0x6c,0x08,0xf3,0xd9]
         {evex}	blsil	%ecx, %edx

# CHECK: {nf}	blsiq	%r9, %r15
# CHECK: encoding: [0x62,0xd2,0x84,0x0c,0xf3,0xd9]
         {nf}	blsiq	%r9, %r15

# CHECK: {evex}	blsiq	%r9, %r15
# CHECK: encoding: [0x62,0xd2,0x84,0x08,0xf3,0xd9]
         {evex}	blsiq	%r9, %r15

# CHECK: {nf}	blsil	123(%rax,%rbx,4), %ecx
# CHECK: encoding: [0x62,0xf2,0x74,0x0c,0xf3,0x5c,0x98,0x7b]
         {nf}	blsil	123(%rax,%rbx,4), %ecx

# CHECK: {evex}	blsil	123(%rax,%rbx,4), %ecx
# CHECK: encoding: [0x62,0xf2,0x74,0x08,0xf3,0x5c,0x98,0x7b]
         {evex}	blsil	123(%rax,%rbx,4), %ecx

# CHECK: {nf}	blsiq	123(%rax,%rbx,4), %r9
# CHECK: encoding: [0x62,0xf2,0xb4,0x0c,0xf3,0x5c,0x98,0x7b]
         {nf}	blsiq	123(%rax,%rbx,4), %r9

# CHECK: {evex}	blsiq	123(%rax,%rbx,4), %r9
# CHECK: encoding: [0x62,0xf2,0xb4,0x08,0xf3,0x5c,0x98,0x7b]
         {evex}	blsiq	123(%rax,%rbx,4), %r9

# CHECK: blsil	%r18d, %r22d
# CHECK: encoding: [0x62,0xfa,0x4c,0x00,0xf3,0xda]
         blsil	%r18d, %r22d

# CHECK: blsiq	%r19, %r23
# CHECK: encoding: [0x62,0xfa,0xc4,0x00,0xf3,0xdb]
         blsiq	%r19, %r23

# CHECK: blsil	291(%r28,%r29,4), %r18d
# CHECK: encoding: [0x62,0x9a,0x68,0x00,0xf3,0x9c,0xac,0x23,0x01,0x00,0x00]
         blsil	291(%r28,%r29,4), %r18d

# CHECK: blsiq	291(%r28,%r29,4), %r19
# CHECK: encoding: [0x62,0x9a,0xe0,0x00,0xf3,0x9c,0xac,0x23,0x01,0x00,0x00]
         blsiq	291(%r28,%r29,4), %r19