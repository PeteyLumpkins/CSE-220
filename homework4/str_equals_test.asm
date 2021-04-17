# add test cases to data section
.data
str1: .asciiz "Jane Doe"
str2: .asciiz "Jane Doe"

str3: .asciiz "Jane Does"
.text:
main:
	la $a0, str1
	la $a1, str2
	jal str_equals
	#write test code
	
	la $a0, str1
	la $a1, str3
	jal str_equals
	#write test code
	
	li $v0, 10
	syscall
	
.include "hw4.asm"