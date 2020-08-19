.set noreorder
.set noat
.globl __start
.section text

__start:
.text
    li	$1,0x31111
    ori $2, $zero, 0   # t0 = 0
    ori $3, $zero, 0   # t1 = 0
    ori $4, $0 , 1              #1
    sll $5, $4 , 1          #2
    sll $6, $5 , 1          #3
    sll $7, $6 , 1          #4
    sll $8, $7 , 1          #5
    sll $9, $8 , 1          #6
    sll $10, $9 , 1         #7
    sll $11, $10 , 1        #8
    sll $12, $11 , 1        #9
    sll $13, $12 , 1        #10
    sll $14, $13 , 1        #11
    sll $15, $14 , 1        #12
    sll $16, $15 , 1        #13
    sll $17, $16 , 1        #14
    sll $18, $17 , 1
    sll $19, $18 , 1
    sll $20, $19 , 1
    sll $21, $20 , 1
	sll $22, $21 , 1
loop:
    addiu  $2,$2, 1     # $2 ++
        and $23,$4,$2
    srl $23,$23,0
    addu $3,$3,$23
    and $23,$5,$2
    srl $23,$23,1
    addu $3,$3,$23
    and $23,$6,$2
    srl $23,$23,2
    addu $3,$3,$23
    and $23,$7,$2
    srl $23,$23,3
    addu $3,$3,$23
    and $23,$8,$2
    srl $23,$23,4
    addu $3,$3,$23
    and $23,$9,$2
    srl $23,$23,5
    addu $3,$3,$23
    and $23,$10,$2
    srl $23,$23,6
    addu $3,$3,$23
    and $23,$11,$2
    srl $23,$23,7
    addu $3,$3,$23
    and $23,$12,$2
    srl $23,$23,8
    addu $3,$3,$23
    and $23,$13,$2
    srl $23,$23,9
    addu $3,$3,$23
    and $23,$14,$2
    srl $23,$23,10
    addu $3,$3,$23
    and $23,$15,$2
    srl $23,$23,11
    addu $3,$3,$23
    and $23,$16,$2
    srl $23,$23,12
    addu $3,$3,$23
    and $23,$17,$2
    srl $23,$23,13
    addu $3,$3,$23
    and $23,$18,$2
    srl $23,$23,14
    addu $3,$3,$23
    and $23,$19,$2
    srl $23,$23,15
    addu $3,$3,$23
    and $23,$20,$2
    srl $23,$23,16
    addu $3,$3,$23
    and $23,$21,$2
    srl $23,$23,17
    addu $3,$3,$23
    and $23,$22,$2
    srl $23,$23,18
    addu $3,$3,$23

    bne   $2, $1, loop
    ori   $zero, $zero, 0 # nop

	ori $1,$zero,0 
    lui $1, 0x8040
    sw $3,0($1)

    jr    $ra
    ori   $zero, $zero, 0 # nop
