.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    li $a0, 0x80400000       # a0 = 0x80400000
    ori $t8, $zero, 1
    ori $t9, $zero, 1
    ori $t1, $zero, 4
    ori $v0, $zero, 10
    xor $t2, $t2, $t2
loop:
    addu $t0, $t8, $t9
    addu $t8, $zero, $t9
    addu $t9, $zero, $t0
    sw  $t0, 0($a0)
    addiu $t2, $t2, 1
    bne $t2, $v0, loop
    addu $a0, $a0, $t1

    jr    $ra
    ori   $zero, $zero, 0 # nop
