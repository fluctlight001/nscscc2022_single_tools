.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    li $a0, 0x80400000       # a0 = 0x80400000
    xor $v0, $v0, $v0        # v0 = 0
    xor $v1, $v1, $v1        # v1 = 0
    xor $t1, $t1, $t1        # tmp = 0
    li $t8, 0x31111        # i_max
    ori $t9, $zero, 32       # j_max
    ori $a1, $zero, 1        # i = 1
l1:
    addu $t1, $zero, $a1     # tmp = i
l2:
    andi $a3, $t1, 1         # tmp & 1
    addu $v0, $v0, $a3       # v0 = v0 + tmp & 1
    srl $t1, $t1, 1          # tmp >> 1
    bne $t1, $zero, l2   # if tmp == 0
    xor $a3, $a3, $a3

    
l2_end:
    addu $v1, $v1, $v0       # v1 = v1 + v0
    xor $v0, $v0, $v0        # v0 = 0
    bne $t8, $a1, l1         # if i != i_max
    addiu $a1, $a1, 1

    sw $v1, 0($a0)

    jr    $ra
    ori   $zero, $zero, 0 # nop
