.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"

NewLine: .asciiz "\n"
Success: .asciiz "Operation completed successfully!"

# I'm going to manually load in this value into each of these just to have something to work with
# Example: 0x30E9FFFC

Hex_1: .byte 12
Hex_2: .byte 15
Hex_3: .byte 15
Hex_4: .byte 15
Hex_5: .byte 9
Hex_6: .byte 14
Hex_7: .byte 0
Hex_8: .byte 3

.text:
.globl main
main:
	
	lb $s0, Hex_6
	sll $s0, $s0, 20
	
	lb $t0, Hex_5
	sll $t0, $t0, 16
	or $s0, $s0, $t0
	
	lb $t0, Hex_4
	sll $t0, $t0, 12
	or $s0, $s0, $t0
	
	lb $t0, Hex_3
	sll $t0, $t0, 8
	or $s0, $s0, $t0
	
	lb $t0, Hex_2
	sll $t0, $t0, 4
	or $s0, $s0, $t0
	
	lb $t0, Hex_1
	or $s0, $s0, $t0
	
	j exit
	
exit:
	move $a0, $s0
	li $v0, 1
	syscall
	
	la $a0, NewLine
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall