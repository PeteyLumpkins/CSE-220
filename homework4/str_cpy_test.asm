# add test cases to data section
.data
src: .asciiz "Jane Doe"
dest: .asciiz ""

.text:
main:
	la $a0, src
	la $a1, dest
	jal str_cpy
		
	la $s0, dest

for:
	lbu $t0, 0($s0)
	addi $s0, $s0, 1
	j for
	
	li $v0, 10
	syscall
	
.include "hw4.asm"
