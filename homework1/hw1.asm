.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"

arg1_addr : .word 0
arg2_addr : .word 0
num_args : .word 0

# Some utilitiies
NewLine: .asciiz "\n"
Success: .asciiz "Operation completed successfully!"
Mantissa_string: .asciiz "1."

.text:
.globl main
main:
	sw $a0, num_args

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr

	lw $t1, 4($a1)
	sw $t1, arg2_addr
	lw $s2, arg2_addr

# do not change any line of code above this section
# you can add code to the .data section

#---------------------------------------------------------------------------------------------------------------#
#	PART_1_START: Validate the Number of Command-line Arguments and second command line arguement		#
#														#
#	Hello grader. This is the start of Part1 of the homework. I hope it's not too confusing			#
#---------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
# 	Check that we have only two args, if not	#
#	jump to the wrong args message			#
#-------------------------------------------------------#

check_args_length:
	li $t0, 2
	lw $t1, num_args
	bne $t0, $t1, print_wrong_arg
	
#-------------------------------------------------------#
#	Validates the second arguement to see		#
# 	whether it is a valid hex number or not		#
#							#
#	Store arg2 in register $s1, if $s1 is		#
#	a valid hex number, then it will be stored	#
#	in register $s0					#
#-------------------------------------------------------#

check_arg_2:

	lw $s1, arg2_addr	# $s1 == arg2

#-------------------------------------------------------#
# 	Checks if the first character in the second	#
#	arguement is valid				#
#							#
#	if arg2[0] != '0' then jump to print_error	#
#-------------------------------------------------------#

check_first_char:
	li $t0, '0'
	lbu $t1, 0($s1)
	bne $t0, $t1, print_error

#-------------------------------------------------------#
#	Checks if the second character in the 2nd	#
#	arguement is valid				#
#							#
#	if arg2[1] != 'x' then jump to print_error	#
#-------------------------------------------------------#

check_second_char:
	li $t0, 'x'
	lbu $t1, 1($s1)
	bne $t0, $t1, print_error
	
#-------------------------------------------------------#
#	Validates whether the remaining 8 chars		#
#	are a valid hex number, and ignores any		#
# 	additional characters				#
#							#
#	arg2[2-8] = (1, 2, ..., 9, A, B, ..., F)	#
#-------------------------------------------------------#
#	In the loop, I am also building the hex number	#
#	at register $s0						#
#							#
#	Suppose we have: 30E9FFFC			#
#							#
#	Iteration 1:					#
							#
#	$s0 = 0000	*** Shift left 4 bits		#
#	$s0 = 00000000					#
#	$s0 = 00000000 OR 0011   *** logical OR with 3	#			
#							#
#	Iteration 2:					#
#							#
#	$s0 = 00000011	*** Shift left 4 bits		#
#	$s0 = 000000110000  				#
#	$s0 = $s0 OR 0		*** logical OR with 0	#
#							#
#	Iteration 3:					#
#							#
#	$s0 = 00110000	*** Shift left 4 bits		#
#	$s0 = 001100000000				#
#	$s0 = $s0 OR E		*** logical OR with #	#
#	$s0 = 001100001110				#
#-------------------------------------------------------#
	
	and $s0, $s0, $0	# initialize $s0 == $0
	

check_remaining_chars:
	addi $s1, $s1, 2   # increment to position 2 in string
	li $s2, 8	   # counter variable for the loop

loop_1:	
	beqz $s2, validate_arg1
	lbu $t0, 0($s1)
	
	sll $s0, $s0, 4		# shift $s0 left 4 bits,
	
	li $t1, '0'
	beq $t0, $t1, get_number
	
	li $t1, '1'
	beq $t0, $t1, get_number
	
	li $t1, '2'
	beq $t0, $t1, get_number
	
	li $t1, '3'
	beq $t0, $t1, get_number
	
	li $t1, '4'
	beq $t0, $t1, get_number
	
	li $t1, '5'
	beq $t0, $t1, get_number
	
	li $t1, '6'
	beq $t0, $t1, get_number
	
	li $t1, '7'
	beq $t0, $t1, get_number
	
	li $t1, '8'
	beq $t0, $t1, get_number
	
	li $t1, '9'
	beq $t0, $t1, get_number
	
	li $t1, 'A'
	beq $t0, $t1, get_letter
	
	li $t1, 'B'
	beq $t0, $t1, get_letter
	
	li $t1, 'C'
	beq $t0, $t1, get_letter
	
	li $t1, 'D'
	beq $t0, $t1, get_letter
	
	li $t1, 'E'
	beq $t0, $t1, get_letter
	
	li $t1, 'F'
	beq $t0, $t1, get_letter
	
	j print_error
	
get_letter:
	addi $t0, $t0, -55	# For letters, we want to take the (char - 65 + 10) to give us the binary number
	j next_1
	
get_number:
	addi $t0, $t0, -48	# For numbers, all we have to do is subtract 48 assuming it is valid
	
next_1:
	or $s0, $s0, $t0
	
	addi $s2, $s2, -1
	addi $s1, $s1, 1
	j loop_1
	
#-------------------------------------------------------#
# 	Validates whether arg1_addr is valid as per	#
# 	the instructions. 				#
# 							#
#	arg1[0] = (O, S, T, J, E, C, X, M)		#
#	arg1.length >= 1				#
#							#
#	if (arg1 is valid) 				#
#		jump to arg1_valid			#
#	else 						#
#		jump to error message			#
#-------------------------------------------------------#

validate_arg1:
	lw $t0, arg1_addr
	lbu $t1, 0($t0)
	
	li $t2, 'O'
	beq $t1, $t2, part_2_A
	
	li $t2, 'S'
	beq $t1, $t2, part_2_B
	
	li $t2, 'T'
	beq $t1, $t2, part_2_C
	
	li $t2, 'I'
	beq $t1, $t2, part_2_D
	
	li $t2, 'E'
	beq $t1, $t2, part_3
	
	li $t2, 'C'
	beq $t1, $t2, part_4
	
	li $t2, 'X'
	beq $t1, $t2, part_5_A
	
	li $t2, 'M'
	beq $t1, $t2, part_5_B
	
	j print_error
	
#-------------------------------------------------------#
#	For this, we are going to attempt to get	#
#	the value for option 'O'			#
#							#
#	Step 1: Move our hex number ($s0) into $a0	#
#							#
#	Step 2: Shift right 26 bits (get last 6 bits)	#
#							#
#	Step 3: Jump to print_integer			#
#-------------------------------------------------------#
	
part_2_A:

	or $a0, $s0, $0		# Step 1
	srl $a0, $a0, 26	# Step 2
	j print_integer		# Step 3
	
#-------------------------------------------------------#
#	Getting the value for option S	(rs nibble)	#
#							#
#	Step 1: Move $s0 (our hex number) into $a0	#
#							#
#	Step 2: shift right 21 bits 			#
#							#
#	Step 3: AND with 0x1F to isolate 5 least     	#
#		significant bits			#
#							#
#	Step 4: Print contents of $a0			#
#-------------------------------------------------------#

part_2_B:

	or $a0, $s0, $0			# Step 1
	
	srl $a0, $a0, 21		# Step 2
	
	andi $a0, $a0, 0x1F		# Step 3
	
	j print_integer			# Step 4
	
#-------------------------------------------------------#
#	Get the value for option T (rt nibble)		#
#							#
#	Step 1: move our hex numbeer into $a0		#
#							#
#	Step 2: shift 16 bits to the right		#
#							#
#	Step 3: AND with 0x1F (isolate 5 least 		#
#		significant bits
#							#
#	Step 4: print contents of $a0			#
#-------------------------------------------------------#

part_2_C:

	or $a0, $s0, $0			# Step 1
	
	srl $a0, $a0, 16		# Step 2
	
	andi $a0, $a0, 0x1F		# Step 3
	
	j print_integer			# Step 4
	
#-------------------------------------------------------#
#	Get the value for option I			#
#							#
# 	Step 1: move our hex number into $a0		#
#							#
#	Step 2: AND with FFFF to get 16-bit immediate	#
#							#
#	Step 3: AND with 7FFF to get sign bit ($t0)	#
#							#
#	Step 4: if ($t0 == 0): print $a0 (positive)	#
# 							#
#	Step 5: else: $a0 == negative number, so	#
#		flip all bits using XOR FFFF		#
#							#
#	Step 6: add 1 to $a0 (make it twos comp)	#
#							#
#	Step 7: multiply $a0 by negative 1		#
#							#
#	Step 8: print out $a0				#
#							#
#-------------------------------------------------------#

part_2_D:

	andi $a0, $s0, 0xFFFF		# Step 1
	
	andi $t0, $a0, 0x7FFF		# Step 2
	
	beqz $t0 print_integer		# Step 3
	
	xori $a0, $a0, 0xFFFF		# Step 4
	
	addi $a0, $a0, 1		# Step 5
	
	li $t0, -1			# Step 6
	
	mul $a0, $a0, $t0		# Step 7
	
	j print_integer			# Step 8
	
#---------------------------------------------------------------------------------------------------------------#
#		PART_2_END - this is the end of part 2								#
#---------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------------#
#		PART_3_START - this is the start of part 3 - odd or even hex number				#
#---------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
#	This is going to be part 3, to check 		#
#	whether or not the given hex nuumber		#
#	is even or odd.					#
#							#
#	All I'm going to do is check if the least	#
#	significant bit is 0 or 1, and therefore	#
#	even or odd respectively.			#
#-------------------------------------------------------#

part_3:
	andi $t0, $s0, 1
	beqz $t0 is_even
is_odd:
	la $a0, OddMsg
	j print_string
is_even:
	la $a0, EvenMsg
	j print_string
	
#---------------------------------------------------------------------------------------------------------------#
# 		PART_3_END - this is the end of part 3								#
#---------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------------#
#		PART_4_START: Counting - this is the start of part 4						#
#---------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
#	For counting the number of 1's, I want		#
#	to perform logical AND on each of the 32 bits.	#
#							#
#	If the result of logical AND is 0, then there 	#
#	is a zero at that position in the hex number,	#
#	if I get a number, then there's a one.		#
#-------------------------------------------------------#

part_4:
	
	add $a0, $0, $0		# let $a0 = number of 1's in the hex number
	addi $s1, $0, 32		# let $s1 = counter variable
	
loop_2:
	beqz $s1, print_integer		# when $s1 = 0, print $a0 (number of 1's)
	andi $t0, $s0, 1		# check value of least significant bit (0 or 1)
	beqz $t0, next_2		# if $t0 = 0 move to the next bit
	addi $a0, $a0, 1			# else $a0++ and move to next bit
next_2:
	srl $s0, $s0, 1			# shift right to get the next bit
	addi $s1, $s1, -1		# decrement loop counter
	j loop_2

#-----------------------------------------------------------------------------------------------------------------------#
#		PART_4_END - this is the end of part 4									#
#-----------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------------------------------------------------#
#		PART_5_START: Floating Point - this is the start of part 5						#								#
#-----------------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
#	Part 5 A, extracting the exponent		#
#-------------------------------------------------------#

part_5_A:
	or $a0, $s0, $0			# move $s0 -> $a0 
	srl $a0, $a0, 23		# shift right 23 bits
	andi $a0, $a0, 0xFF		# logical AND to get 8 bit exponent
	
	addi $a0, $a0, -127
	j print_integer			# print out $a0
	
#-------------------------------------------------------#
#	Part 5B, printing the mantissa			#
#-------------------------------------------------------#
part_5_B:

	la $a0, Mantissa_string		# Print out the initial "1." before the rest of the bits
	li $v0, 4
	syscall
	
#-------------------------------------------------------#
#	This is the setup for Part 5B, I want		#
#	to do a few things initially to make 		#
#	the loop for printing out each bit as 		#
#	simple as possible				#
#-------------------------------------------------------#
	
setup:

	sll $s1, $s0, 9		# shift left 9 bits so start of mantissa is at most significant bit,
				# also appends the extra zeros to the end of the mantissa (easier for printing)
				
	addi $s2, $0, 32	# set counter variable to 32 (only want to print
	
	addi $s3, $0, 1		# this is going to be the bit I use to check whether the current bit in the hexidecimal
	sll $s3, $s3, 31	# number is a 0 or a 1. 
				#
				#	$s3 == 1000_0000_..._0000 
				#	$s1 == hexidecimal 
				#	
				#	if ($s3) AND ($s1) == 0: print(0)     else:  print(1)
	
	addi $v0, $0, 1		# set $v0 = 1


	
loop_3:				
	beqz $s2, exit		# 	if counter == 32:    jump to exit
	
	and $a0, $s1, $s3 	# 	if ($s3 AND $s1) == 0: print(0)    else: print(1)
	beqz $a0, print_zero		
	
print_one:
	addi $a0, $0, 1
	syscall
	b next_3
print_zero:			# $v0 = 1 already and $a0 should be = 0, so we can just do a syscall to print 0
	syscall
next_3:
	sll $s1, $s1, 1			# shift bitstring to the left 1 bit
	addi $s2, $s2, -1		# decrement counter variable by one
	j loop_3
	
#-------------------------------------------------------#
# 	Prints the wrong arg message, then jumps 	#             
# 	to exit				   		#
#-------------------------------------------------------#

print_wrong_arg:
	la $a0, WrongArgMsg
	j print_string
	
#-------------------------------------------------------#
#	Prints the error message arg, then jump		#
#	to exit						#
#-------------------------------------------------------#

print_error:
	la $a0, ErrMsg	
	j print_string
	
#-------------------------------------------------------#
#	Prints a string value located in $a0		#
#	then jumps to exit				#
#-------------------------------------------------------#

print_string:
	li $v0, 4
	syscall
	j exit

#-------------------------------------------------------#
#	Prints an integer value located in $a0		#
#	then jumps to exit				#
#-------------------------------------------------------#

print_integer:
	li $v0, 1
	syscall 
	j exit

#-------------------------------------------------------#
#		Exits the program			#
#-------------------------------------------------------#

exit:
	li $v0, 10		
	syscall
	



