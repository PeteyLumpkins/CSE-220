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

# The hexadecimal number from arg2, most significant bit is Hex_8
Hex_1: .byte 0
Hex_2: .byte 0
Hex_3: .byte 0
Hex_4: .byte 0
Hex_5: .byte 0
Hex_6: .byte 0
Hex_7: .byte 0
Hex_8: .byte 0

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
start_coding_here:

#---------------------------------------------------------------------------------------------------------------#
#	PART_1_START: Validate the First Command-line Argument and the Number of Command-line Arguments		#
#														#
#	Hello grader. This is the start of Part1 of the homework. I hope it's not too confusing			#
#---------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
# 	Check that we have only two args, if not	#
#	jump to the wrong args message			#
#-------------------------------------------------------#

check_args_length:
	addi $t0, $0, 2
	lw $t1, num_args
	bne $t0, $t1, print_wrong_arg
	
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
	
	li $t2,'O'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'S'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'T'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'I'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'E'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'C'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'X'
	beq $t1, $t2, arg1_valid
	
	li $t2, 'M'
	beq $t1, $t2, arg1_valid
	
	j print_error

#-------------------------------------------------------#
# 	If arg1 is valid, then we jump here		#
#	***testing up to here was successful***		#
#-------------------------------------------------------#

arg1_valid:
	
#-------------------------------------------------------#
#	Validates the second arguement to see		#
# 	whether it is a valid hex number or not		#
#							#
#	Store arg2 in register $s0			#
#-------------------------------------------------------#

validate_arg2:

	lw $s0, arg2_addr	# load arg2 into $s0
	li $s1, 8		# load counter variable into $s1
	
#-------------------------------------------------------#
# 	Checks if the first character in the second	#
#	arguement is valid				#
#							#
#	if arg2[0] != '0' then jump to print_error	#
#-------------------------------------------------------#

check_first_char:
	li $t0, '0'
	lbu $t1, 0($s0)
	bne $t0, $t1, print_error

#-------------------------------------------------------#
#	Checks if the second character in the 2nd	#
#	arguement is valid				#
#	if arg2[1] != 'x' then jump to print_error	#
#-------------------------------------------------------#

check_second_char:
	li $t0, 'x'
	lbu $t1, 1($s0)
	bne $t0, $t1, print_error
	
#-------------------------------------------------------#
#	Validates whether the remaining 8 chars		#
#	are a valid hex number, and ignores any		#
# 	additional characters				#
#							#
#	arg2[2-8] = (1, 2, ..., 9, A, B, ..., F)	#
#-------------------------------------------------------#

check_remaining_chars:
	addi $s0, $s0, 2   # increment to position 2 in string
	li $s1, 8	   # counter variable for the loop
loop_1:	
	beq $s1, $0, select_operation
	lb $t0, 0($s0)
	
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
	addi $s2, $t0, -65	# For letters, we want to take the (char - 65 + 10) to give us the binary number
	addi $s2, $s2, 10
	j store_value
	
get_number:
	addi $s2, $t0, -48	# For numbers, all we have to do is subtract 48 assuming it is valid
	j store_value

#-------------------------------------------------------#
#	Finds the correct place to store the value	#
#	of the hex number in memory			#
#-------------------------------------------------------#

store_value:
	addi $t0, $0, 8
	beq $s1, $t0, store_h8
	
	addi $t0, $0, 7
	beq $s1, $t0, store_h7
	
	addi $t0, $0, 6
	beq $s1, $t0, store_h6
	
	addi $t0, $0, 5
	beq $s1, $t0, store_h5
	
	addi $t0, $0, 4
	beq $s1, $t0, store_h4
	
	addi $t0, $0, 3
	beq $s1, $t0, store_h3
	
	addi $t0, $0, 2
	beq $s1, $t0, store_h2
	
	addi $t0, $0, 1
	beq $s1, $t0, store_h1

#-------------------------------------------------------#
#	Stores the value in $s2 at a corresponding	#
#	location in memory.				#
#							#
#	store_h1 --> Hex_1				#
#	store_hk --> Hex_k				#
#							#
#	After storing the value, we go go back	        #
# 	to the loop					#
#-------------------------------------------------------#

store_h1:
	sb $s2, Hex_1
	j next_char
store_h2:
	sb $s2, Hex_2
	j next_char
store_h3:
	sb $s2, Hex_3
	j next_char
store_h4:
	sb $s2, Hex_4
	j next_char
store_h5:
	sb $s2, Hex_5
	j next_char
store_h6:
	sb $s2, Hex_6
	j next_char
store_h7:
	sb $s2, Hex_7
	j next_char
store_h8:
	sb $s2, Hex_8
	j next_char

#-------------------------------------------------------#
#	Goes to the next character in our loop above	#
#-------------------------------------------------------#

next_char:
	addi $s0, $s0, 1
	addi $s1, $s1, -1
	j loop_1
	
#---------------------------------------------------------------------------------------------------------------#
# 	PART_1_END - this is the end of part 1. Part 1 has pretty much set everything up for parts 2, 3, 4 	#
#	and 5 by storing all of the hex values out in memory. Hopefully this will make things easier for me	#
#	to work with in the following steps									#
#---------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#
#    Selects how to operate on the given hex number	#
#    depending on parameter of the first arguement	#
#-------------------------------------------------------#

select_operation:
	lw $s0, arg1_addr
	lb $s1, 0($s0)
	
	li $t0, 'O'
	beq $s1, $t0, part_2_A
	
	li $t0, 'S'
	beq $s1, $t0, part_2_B
	
	li $t0, 'T'
	beq $s1, $t0, part_2_C
	
	li $t0, 'I'
	beq $s1, $t0, part_2_D
	
	li $t0, 'E'
	beq $s1, $t0, part_3
	
	li $t0, 'C'
	beq $s1, $t0, part_4
	
	li $t0, 'X'
	beq $s1, $t0, part_5_A
	
	li $t0, 'M'
	beq $s1, $t0, part_5_B
	
#---------------------------------------------------------------------------------------------------------------#
#	PART_2_START: Identify Components of an I-type Instruction						#
#														#
#	Please note, I have already converted the hexadecimal number to binary (kind of) in step 1 in the	#
#	loop part of the code. I stored each of the 8 hexadecimal values in main memory as bytes. They are	#
#	located at Hex_1, Hex_2, ... Hex_8, where Hex_8 contains the most significant bit.			#
#														#
#---------------------------------------------------------------------------------------------------------------#
	
#-------------------------------------------------------#
#	For this, we are going to attempt to get	#
#	the value for option 'O'			#
#							#
#	Step 1: Load Hex_8 and Hex_7			#
#							#
#	Step 2: Extend Hex_8 to right by 4 bits		#
#							#
#	Step 3: Take logical OR of Hex_8, Hex_7		#
#							#
#	Step 4: Right shift our value by 2 bits		#
#-------------------------------------------------------#
	
part_2_A:

	lb $t0, Hex_8		# Step 1
	lb $t1, Hex_7
	
	sll $t0, $t0, 4		# Step 2
	or $t2, $t1, $t0	# Step 3
	srl $t2, $t2, 2		# Step 4
	
	move $s0, $t2
	
	j print_integer
	
#-------------------------------------------------------#
#	Getting the value for option S			#
#							#
#	Step 1: load Hex_7 and Hex_6			#
#							#
#	Step 2: Shift Hex_7 left 3 bits			#
#							#
#	Step 3: Shift Hex_6 right 1 bit			#
#							#
#	Step 4: Perform logical OR on Hex_6 and Hex_7	#
#							#
#	Step 5: Perform logical AND on Step 4 and 31	#
#-------------------------------------------------------#

part_2_B:

	lb $t0, Hex_7
	lb $t1, Hex_6
	
	sll $t0, $t0, 3
	srl $t1, $t1, 1
	or $t2, $t1, $t0
	andi $t2, $t2, 31
	
	move $s0, $t2
	
	j print_integer
	
#-------------------------------------------------------#
#	Get the value for option T (rt nibble)		#
#							#
#	Step 1: Load Hex_6 and Hex_5			#
#							#
#	Step 2: Shift Hex_6 left 4 bits			#
#							#
#	Step 3: Take logical and Hex_6 and Hex_5	#
#							#
#	Step 4: Take logical and of result and 31	#
#							#
#	Step 5: Store result in $s0			#
#-------------------------------------------------------#

part_2_C:

	lb $t0, Hex_6
	lb $t1, Hex_5
	
	sll $t0, $t0, 4
	or $t2, $t1, $t0
	andi $t2, $t2, 31
	
	move $s0, $t2
	
	j print_integer
	
#-------------------------------------------------------#
#	Get the value for option I			#
#							#
# 	Step 1: Load Hex_1 - Hex_4			#
#							#
#	Step 2: Shift Hex_4 12 bits to left		#
#							#
#	Step 3: Shift Hex_3 8 bits to left		#
#							#
#	Step 4: Shift Hex_2 4 bits to left		#
# 							#
#	Step 5: OR Hex_4, Hex_3				#
#							#
#	Step 6: OR (5) and Hex_2			#
#							#
#	Step 7: OR (6) and Hex_1			#
#							#
#	Step 8: Check sign bit				#
#							#
#	if positive then print number else...		#
#							#
#	Step 9: xor (7) with 65535, to get complement	#	
#							#
#	Step 10: add one to (9) and multiply by -1	#
#-------------------------------------------------------#

part_2_D:

	lb $t0, Hex_4
	lb $t1, Hex_3
	lb $t2, Hex_2
	lb $t3, Hex_1
	
	sll $t0, $t0, 12
	sll $t1, $t1, 8
	sll $t2, $t2, 4
	
	or $s0, $t0, $t1
	or $s0, $s0, $t2
	or $s0, $s0, $t3
	
	andi $t0, $s0, 32768
	beq $t0, $0, print_integer
	
	xori $s0, $s0, 65535
	addi $s0, $s0, 1
	
	li $t0, -1
	mul $s0, $s0, $t0 
	
	j print_integer
	
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
	lb $t0, Hex_1
	andi $t0, $t0, 1
	
	beq $t0, $0, is_even
	j is_odd
is_even:
	la $s0, EvenMsg
	j print_string
is_odd:
	la $s0, OddMsg
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
	li $s0, 0	# We'll let $s0 be the number of 1's
	
	li $s1, 8	# this will be our "counter" variable for outer loop
	li $s2, 1	# this will be our special "ANDing" bit, we'll shift it left 4 times
	li $s4, 16	# this is just another constant for inner loop
	
#-------------------------------------------------------#
#	This is the outer loop for part 4. It		#
#	should iterate 8 times, once for each of	#
#	the hexadecimal values				#
#							#
#	The first part of the loop figures out		#
#	which hexadecimal value to check next		#
#-------------------------------------------------------#
	
outer_loop:
	beq $s1, $0, print_integer		# iterates 8 times, exits once $s1 == 0
	li $s2, 1				# reset the inner loop counter
	
	li $t0, 8
	beq $s1, $t0, load_h8
	
	li $t0, 7
	beq $s1, $t0, load_h7
	
	li $t0, 6
	beq $s1, $t0, load_h6
	
	li $t0, 5
	beq $s1, $t0, load_h5
	
	li $t0, 4
	beq $s1, $t0, load_h4
	
	li $t0, 3
	beq $s1, $t0, load_h3
	
	li $t0, 2
	beq $s1, $t0, load_h2
	
	li $t0, 1
	beq $s1, $t0, load_h1
	
	j exit

#-------------------------------------------------------#
#	Loads the hexadecimal value from memory		#
#	into register $s3, then goes to the inner       #
#	loop.						#
#-------------------------------------------------------# 

load_h8:
	lb $s3, Hex_8
	b inner_loop
load_h7:
	lb $s3, Hex_7
	b inner_loop
load_h6:
	lb $s3, Hex_6
	b inner_loop
load_h5:
	lb $s3, Hex_5
	b inner_loop
load_h4:
	lb $s3, Hex_4
	b inner_loop
load_h3:
	lb $s3, Hex_3
	b inner_loop
load_h2:
	lb $s3, Hex_2
	b inner_loop
load_h1:
	lb $s3, Hex_1
	b inner_loop
	
#-------------------------------------------------------#
#	This is our inner loop. 			#
#							#
#	if ($s2) >= 16: increment outer loop		#
#							#
#	elif ($s3 AND $s2) == 0: increment inner 	#
#							#
#	else: add 1 to $s0 then increment inner		#
#-------------------------------------------------------#
	
inner_loop:
	bge $s2, $s4, increment_outer		# if $s2 >= 16, then increment the outer loop, go to next outer loop iteration
	and $t0, $s2, $s3			
	beq $t0, $0, increment_inner		# elif ($s2 AND $s3) != 0: increment $s0 (our total 1's) by 1
	addi $s0, $s0, 1			# else: fall through to increment_inner loop
	
#-------------------------------------------------------#
#	Incremennts the inner loop by shifting		#
#	bits in register $s2 to the left by 1		#
#	position.					#
#-------------------------------------------------------#

increment_inner:
	sll $s2, $s2, 1
	j inner_loop
	
#-------------------------------------------------------#
#	Increments the outer loop by -1			#
#-------------------------------------------------------#

increment_outer:
	addi $s1, $s1, -1
	j outer_loop
	
#-----------------------------------------------------------------------------------------------------------------------#
#		PART_4_END - this is the end of part 4									#
#-----------------------------------------------------------------------------------------------------------------------#

#-----------------------------------------------------------------------------------------------------------------------#
#		PART_5_START: Floating Point Exponent - this is the start of part 5					#								#
#-----------------------------------------------------------------------------------------------------------------------#

#-------------------------------------------------------#	#-------------------------------------------------------#
#	This is Part 5A, extractiing the exponent	#	#		Example for Part 5A			#
#-------------------------------------------------------#	#-------------------------------------------------------#
#	Step 1: Load Hex_8, Hex_7, and Hex_6		#	#	Suppose we have: 0x30E9FFFC:			#
#	Step 2: Left shift Hex_8 by 4 bits		#	#							#
#							#	#	Step 1: 3 = Hex_8 = 3 = 00000011 = 0000X011	#
#	Step 3: Take logical OR of Hex_8 and Hex_7	#	#		0 = Hex_7 = 0 = 00000000 = 00000000	#
#							#	#		E = Hex_6 = 14 = 00001110 = 00001XXX	#
#	Step 3.5: Take logical AND of (3) and 127	#	#							#
#							#	#	X's represent bits we don't care about		#
#	Step 4: Left shift (2) by 1 bit			#	#							#
#							#	#	Step 2: (0000X011) <<< (X0110000)		#				#
#	Step 5: Right shift Hex_6 3 bits		#	#							#
#							#	#	Step 3: (X0110000) + (00000000)	= (X0110000)	#			#
#	Step 6: Logical OR (4) and (5)			#	#							#
#							#	#	Step 3.5: (X0110000) * (01111111) = (00110000)	#
#	Step 7: Subtract 127 from (6)			#	#							#
#-------------------------------------------------------#	#	Step 4: (00110000) <<< (01100000)		#
								#							#
								#	Step 5: (00001XXX) >>> (00000001)		#
								#							#
								#	Step 6: (01100000) + (00000001) = (01100001)	#
								#							#
								#	Step 7: 97 - 127 = -30				#
								#-------------------------------------------------------#
part_5_A:														
	lb $s0, Hex_8		# Step 1
	lb $t1, Hex_7
	lb $t2, Hex_6
	
	sll $s0, $s0, 4		# Step 2
	
	or $s0, $s0, $t1	# Step 3
	
	andi $s0, $s0, 127	# Step 3.5
	
	sll $s0, $s0, 1		# Step 4
	
	srl $t2, $t2, 3		# Step 5
	
	or $s0, $s0, $t2	# Step 6
	
	addi $s0, $s0, -127	# Step 7
	
	j print_integer
	
#-------------------------------------------------------#
#	Part 5B, extracting the mantissa		#
#-------------------------------------------------------#

#-------------------------------------------------------#
#	This is the start of Part 5 B.			#
#							#
#	First, I want to load Hex_6 - Hex_1, perform 	#
#	some bit shifts, and OR them together		#
#							#
#	Consider the example: 30E9FFFC			#
#							#
#	First we shift the bits				#
#							#
#	Hex_6 = E = 1110 <<< 20 			#
#	Hex_5 = 9 = 1001 <<< 16				#
#	Hex_4 = F = 1111 <<< 12				#
#	Hex_3 = F = 1111 <<< 8				#
#	Hex_2 = F = 1111 <<< 4				#
#	Hex_1 = C = 1100 <<< 0				#
#							#
#	Now we want to OR them all together		#
#	which comes out to be...			#
#							#
#	1110_1001_1111_1111_1111_1100			#
#							#
#	Then we shift this left 1 bit			#
#							#
#	1101_0011_1111_1111_1111_1000			#
#							#
#	Now we add on 8 zeros				#
#							#
#	1101_0011_1111_1111_1111_1000_0000_0000		#
#							#
#	And we're done!					#
#-------------------------------------------------------#

#-------------------------------------------------------#
#	part_5_B loads in all of the bytes, and		#
#	performs the shifting and OR-ing of the bits	#
#-------------------------------------------------------#

part_5_B:
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
	
	sll $s0, $s0, 1

loop_3_setup:

	la $a0, Mantissa_string	# manually print the string out "1."
	li $v0, 4
	syscall

	li $s1, 24		# initialize counter variable for loop_3
	li $s2, 8		# initialize counter variable for loop_4
	li $s3, 1		# loads my helper bit to print each bit
	sll $s3, $s3, 23	# shifts helper bit over to the right
	li $v0, 1		# load print integer into $v0
	
loop_3:
	beq $s1, $0, loop_4
	and $t0, $s0, $s3
	beq $t0, $0, print_zero
	
print_one:
	li $a0, 1
	syscall
	j loop_3_increment
	
print_zero:
	move $a0, $0
	syscall
	j loop_3_increment
	
loop_3_increment:
	addi $s1, $s1, -1
	sll $s0, $s0, 1
	j loop_3	
loop_4:
	beq $s2, $0, exit
	move $a0, $0
	syscall	
loop_4_increment:
	addi $s2, $s2, -1
	j loop_4
	
	
#-------------------------------------------------------#
# 	Prints the wrong arg message, then jumps 	#             
# 	to exit				   		#
#-------------------------------------------------------#

print_wrong_arg:
	la $s0, WrongArgMsg
	
	j print_string
	
#-------------------------------------------------------#
#	Prints the error message arg, then jump		#
#	to exit						#
#-------------------------------------------------------#

print_error:
	la $s0, ErrMsg	
		
	j print_string
	
#-------------------------------------------------------#
#	Prints a string value located in $s0		#
#	then jumps to exit				#
#-------------------------------------------------------#

print_string:
	move $a0, $s0
	li $v0, 4
	syscall
	
	j exit

#-------------------------------------------------------#
#	Prints an integer value located in $s0		#
#	then jumps to exit				#
#-------------------------------------------------------#

print_integer:
	move $a0, $s0
	li $v0, 1
	syscall 
	
	j exit

#-------------------------------------------------------#
#		Exits the program			#
#-------------------------------------------------------#

exit:
	li $v0, 10		# exiting program
	syscall
	
	

	

	