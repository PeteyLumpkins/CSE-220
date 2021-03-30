.text
.globl main

main:

	li $t0, 98
	li $t1, 10
	div $t0, $t1
	
	mfhi $a0
	li $v0, 1
	syscall
	
	mflo $a0
	li $v0, 1
	syscall
	
	li $v0, 10
	syscall

	