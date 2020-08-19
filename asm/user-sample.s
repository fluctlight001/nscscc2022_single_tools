.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    ori $t1, $zero, 4
    ori $t0, $zero, 2   # t0 = 1
    li $a0, 0x80400000       # a0 = 0x80400000
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1

    ori $t0, $zero, 3
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 5
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 8
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 13
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 21
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 34
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 55
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 89
    sw  $t0, 0($a0)
    addu $a0, $a0, $t1
    ori $t0, $zero, 144
    sw  $t0, 0($a0)
    jr    $ra
    ori   $zero, $zero, 0 # nop
