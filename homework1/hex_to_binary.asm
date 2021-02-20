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

Mantissa_string: .asciiz "1."

.text:
.globl main
main:
	
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

option_O:
	lb $t0, Hex_8		# Step 1
	lb $t1, Hex_7
	
	sll $t0, $t0, 4		# Step 2
	or $t2, $t1, $t0	# Step 3
	srl $t2, $t2, 2		# Step 4
	
	move $s0, $t2
	
	j option_S
	
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
	
option_S:
	lb $t0, Hex_7
	lb $t1, Hex_6
	
	sll $t0, $t0, 3
	srl $t1, $t1, 1
	or $t2, $t1, $t0
	andi $t2, $t2, 31
	
	move $s0, $t2
	
	j option_T
	
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

option_T:
	lb $t0, Hex_6
	lb $t1, Hex_5
	
	sll $t0, $t0, 4
	or $t2, $t1, $t0
	andi $t2, $t2, 31
	
	move $s0, $t2
	
	j option_I
	
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

option_I:
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
	beq $t0, $0, exit
	
	xori $s0, $s0, 65535
	addi $s0, $s0, 1
	
	li $t0, -1
	mul $s0, $s0, $t0 
	
	j part_3
	
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
	j part_4
is_odd:
	la $s0, OddMsg
	j part_4
	
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
	beq $s1, $0, part_5_A		# iterates 8 times, exits once $s1 == 0
	li $s2, 1			# reset the inner loop counter
	
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

part_5_A:
	lb $s0, Hex_8		# Step 1: load the bytes
	lb $t1, Hex_7
	lb $t2, Hex_6
	
	sll $s0, $s0, 4		# Step 2: shift Hex_8 left 4 bits
	
	or $s0, $s0, $t1	# Step 3:
	
	andi $s0, $s0, 127	# AND $s0 with 127 (01111111)
	
	sll $s0, $s0, 1		# Step 4: Shift left 1 bit
	
	srl $t2, $t2, 3		# Step 5: Shift Hex_6 right 3 bits
	
	or $s0, $s0, $t2	# Step 6: Take logical OR of $t0 and $t2
	
	addi $s0, $s0, -127
	
	j part_5_B

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

		
	
exit:
	
	la $a0, NewLine
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	