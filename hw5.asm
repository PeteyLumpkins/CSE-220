############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

##########################################################################################################################

# Test 1: $a0 = 2, $a1 = 5 ->   Expected: $v0 = addr term, (2, 5)	# PASSED
# Test 2: $a0 = 0, $a1 = 5 ->   Expected: $v0 = -1, null		# PASSED
# Test 3: $a0 = 3, $a1 = -3 ->  Expected: $v0 = -1, null		# PASSED
# Test 4: $a0 = -3, $a1 = 3 ->  Expected: $v0 = addr term, (-3, 3)	# PASSED
# Test 5: $a0 = 0, $a1 = -3 ->  Expected: $v0 = -1, null		# PASSED

create_term:	# $a0 -> coefficient, $a1 -> exponent

# Preamble

	addi $sp, $sp, -4
	sw $s0, 0($sp)					# copy of coefficient
	
	move $s0, $a0

# Body
	
	beqz $a0, create_term_E0			# if coefficient == 0 -> return $v0 == -1
	bltz $a1, create_term_E0			# if exponent < 0 -> return $v0 == -1
	
	li $a0, 12					# allocate 12 bytes of memeory to the heap
	li $v0, 9
	syscall
	
	sw $s0, 0($v0)					# store the coefficient at first 4 bytes
	sw $a1, 4($v0)					# store the exponent at second 4 bytes
	sw $0, 8($v0)					# initialize address of next term -> $0
	
	# move $v0, $v0	
	j create_term_done

create_term_E0:
	li $v0 -1					# if error -> return -1
	# fall through to done
	
create_term_done:	

	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra						# $v0 -> address of the term
	
##########################################################################################################################

# Test 1: $a0 -> head addr, $a1 = (2, 3)	Expected: poly.head -> term(2, 3, null), $v0 = 1	# PASSED
# Test 2: $a0 -> head addr, $a1 = (-1, 2)	Expected: poly.head -> term(-1, 2, null), $v0 = 1  	# PASSED
# Test 3: $a0 -> head addr, $a1 = (2, -2)	Expected: poly.head -> null, $v0 = -1			# PASSED
# Test 4: $a0 -> head addr, $a1 = (0, 2)	Expected: poly.head -> null, $v0 = -1			# PASSED
# Test 5: $a0 -> head addr, $a1 = (0, -1)	Expected: poly.head -> null, $v0 = -1			# PASSED

# TESTED

init_polynomial:	# $a0 -> pointer to head of the polynomial, $a1 -> array[coefficient, exponent]

# Preamble

	addi $sp, $sp, -8
	sw $ra, 0($sp)					# calling the create_term method
	sw $s0, 4($sp)					# $s0 -> copy of $a0
	
	move $s0, $a0					# save the copy of $a0 to $s0
	
# Body
	
	lw $a0, 0($a1)					# arg1 -> coefficient
	lw $a1, 4($a1)					# arg2 -> exponent
	jal create_term					# create the term
	
	bltz $v0, init_polynomial_E0			# if create_term returns $v0 == -1 -> then return $v0 == -1		
	
	# Else we initialize the polynomial
	
	sw $v0, 0($s0)					# store the address of the new term -> to head of polynomial
	
	li $v0, 1					# else -> return $v0 = 1
	j init_polynomial_done				# jump to done
	
init_polynomial_E0:
	li $v0, -1					# if error occurs while creating term -> return $v0 = -1 
	# fall through to done
	
init_polynomial_done:
	
# Postamble
	
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	
	addi $sp, $sp, 8
	
	jr $ra						# return $v0 = 1 if successfully initialized, -1 otherwise
	
##################################################################################################################################

# Test 1: $a0 -> null , $a1 -> [2 2 4 3 5 0 0 -1], $a2 -> 3	Expected: head -> (4, 3) -> (2, 2) -> (5, 0) -> null    # PASSED
#								Expected: $v0 = 3				        # PASSED

# Test 2: $a0 -> null, $a1 -> [2 3 4 3 5 0 0 -1], $a2 -> 2	Expected: head -> (2, 3) -> (5, 0) -> null	  	# PASSED
#								Expected: $v0 = 2					# PASSED

# Test 3: $a0 -> null, $a1 -> [2 2 4 3 5 0 0 -1], $a2 -> 0	Expected: head -> null					# PASSED
#								Expected: $v0 = 0					# PASSED

# Test 4: $a0 -> null $a1 -> [2 2 4 3 5 0 0 -1], $a2 -> -3	Expected: head -> null					# PASSED
# 								Expected: $v0 = 0					# PASSED

# Test 5: $a0 -> (2, 3), $a1 -> [2 2 4 3 5 0 0 -1], $a2 -> 5	Expected: head -> (2, 3) -> (2, 2) -> (5, 0) -> null	# PASSED
#								Expected: $v0 = 2					# PASSED

# TESTED - I think it works - 100 instructions per term roughly

add_N_terms_to_polynomial:	# $a0 -> pointer to head of polynomial, $a1 -> terms array, $a2 -> total terms to add

# Preamble

	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> copy of polynomial head base address
	sw $s1, 8($sp)					# $s1 -> copy of base address of terms array
	sw $s2, 12($sp)					# $s2 -> copy of total terms to add to polynomial
	
	move $s0, $a0					# copy of polynomial head pointer
	move $s1, $a1					# copy of terms array base address
	move $s2, $a2					# total terms to add
	
# Main Loop

add_N_terms_loop:

# Check if we've seen N terms

	blez $s2, add_N_terms_done			# if we have 0 terms left to add -> return total terms added to polynomial
	
# If exp -> not in polynomial -> check if we've reached end of terms array

	lw $a0, 0($s1)					# arg1 -> coefficient of the next term
	lw $a1, 4($s1)					# arg2 -> exponent of the next term
	jal is_end_of_terms				
	bltz $v0, add_N_terms_done			# if coefficient = 0 and exp = -1 -> end of array
	
# Check if term is in polynomial or not

	move $a0, $s0					# arg1 -> address of the head of the polynomial
	lw $a1, 4($s1)					# arg2 -> exponent of next term
	jal contains_exp
	
	bgtz $v0, add_N_terms_fail			# if the exponent is already in the polynomial -> don't add this term

# Now -> we can safely create and add the term to the polynomial

	bltz $v1, add_N_term_to_back			# if $v1 == -1 -> add the term to the back of the polynomial
	
# If we aren't adding to the back -> then we use add_at method

	lw $a0, 0($s1)					# arg1 -> current terms coefficient
	lw $a1, 4($s1)					# arg2 -> current terms exponent
	jal create_term

	bltz $v0, add_N_terms_fail			# if term creation fails -> skip this term

	move $a0, $s0					# arg1 -> linked-list head pointer
	move $a1, $v0					# arg2 -> address of next node
	move $a2, $v1					# arg3 -> position to add the node
	
	jal add_at					
	
	j add_N_term_success				# go to add term success

add_N_term_to_back:
	
	lw $a0, 0($s1)					# arg1 -> current terms coefficient
	lw $a1, 4($s1)					# arg2 -> current terms exponent
	jal create_term

	bltz $v0, add_N_terms_fail			# if term creation fails -> skip this term
	
	move $a0, $s0					# arg1 -> address of the polynomial to add
	move $a1, $v0					# arg2 -> address of the node to add to the back
	jal add_to_back
	
	# fall through to add term success
	
add_N_term_success:
	addi $s3, $s3, 1				# incremet total terms added by 1
	addi $s2, $s2, -1				# decrement total terms left to add by 1
	
	j add_N_terms_next				# go to the next term in the list

add_N_terms_fail:
	# addi $s3, $s3, 0				# increment total terms added by 0 (pass pretty much)
	# go to the next term -> fall through to next 
	
add_N_terms_next:
	addi $s1, $s1, 8				# increment to the next pair in the terms array
	j add_N_terms_loop
	
add_N_terms_done:

# Postamble

	move $v0, $s3

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	
	addi $sp, $sp, 16
	
	jr $ra
	
####################################################################################################################################

# Test 1: 	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> [1 2 3 3 1 0 0 -1], $a2 -> 3		# PASSED
# Test 1:	Results: (3, 3) -> (1, 2) -> (1, 0) -> null, $v0 = 3

# Test 2: 	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> [1 3 3 3 1 0 0 -1], $a2 -> 3		# PASSED
# Test 2: 	Results: (3, 3) -> (2, 2) -> (1, 0) -> null, $v0 = 2

# Test 3:	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> [1 2 3 3 1 0 0 -1], $a2 -> 0		# PASSED
# Test 3:	Results: (4, 3) -> (2, 2) -> (5, 0) -> null, $v0 = 0

# Test 3.5:	Args: $a0 -> null, $a1 -> [], $a2 -> -1								# PASSED
# Test 3.5: 	Results: None, $v0 = 0

# Test 4:	Args: $a0 -> null, $a1 -> [1 2 3 3 1 0 0 -1], $a2 -> 3						# PASSED
# Test 4:	Results: None, $v0 = 0

update_N_terms_in_polynomial:	# $a0 -> the polynomial address, $a1 -> the base addr of terms array, $a2 -> N, num of pairs to update

# Preamble

	addi $sp, $sp, -20
	sw $ra, 0($sp)	
	sw $s0, 4($sp)					# $s0 -> temp register for the node
	sw $s1, 8($sp)					# $s1 -> the total number of terms modified in the polynomial
	
	sw $s2, 12($sp)					# $s2 -> copy of the base address of the terms array
	sw $s3, 16($sp)					# $s3 -> copy of N
	
# Setup

	lw $s0, 0($a0)					# $s0 -> address of node at head of polynomial
	move $s1, $0					# $s1 -> terms modified = 0
	move $s2, $a1					# $s2 = $a2
	move $s3, $a2					# $s3 = $a3
			
# For each term in the polynomial -> for each term in terms array -> update term in polynomial (if poly.term.exp = terms[i].exp)

update_N_terms_in_polynomial_loop:

	beqz $s0, update_N_terms_in_polynomial_done	# if polynomial base address = null -> then we return
	
	move $a0, $s0					# arg1 -> base addr of next node
	move $a1, $s2					# arg2 -> base addr of terms array
	move $a2, $s3					# arg3 -> terms to update -> N
	
	jal update_N_terms_helper 
	
	add $s1, $s1, $v0				# if term is updated -> add 1 to total terms updated
	
	lw $s0, 8($s0)					# update address of next term in the polynomial -> go to next term
	j update_N_terms_in_polynomial_loop		# go to next iteration
	
update_N_terms_in_polynomial_done:

# Postamble

	move $v0, $s1					# move return value into $v0

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	
	addi $sp, $sp, 20
	
	jr $ra
	
###################################################################################################################################

# Test 1:	$a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 1	Expected: $v0 = 3, $v1 = 4	# PASSED
# Test 2: 	$a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 2	Expected: $v0 = 2, $v1 = 2	# PASSED
# Test 3:	$a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 3	Expected: $v0 = 0, $v1 = 5	# PASSED
# Test 4:	$a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 6	Expected: $v0 = -1, $v1 = 0	# PASSED
# Test 5:	$a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 0 	Expected: $v0 = -1, $v1 = 0	# PASSED

get_Nth_term:	# $a0 -> the address of the head of linked-list, $a1 -> N, the nth item to get

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# move $a0, $a0					# arg1 -> base address of the head of the linked-list
	# move $a1, $a1					# arg2 -> Nth largest term
	addi $a1, $a1, -1				# decrement value of $a1 by 1 (to get index of Nth largest element)
	jal get_term 
	
# If get_term -> returns error -> return error

	bltz $v0, get_Nth_term_E0			# if get_term -> returns -1 (out of bounds) -> return (-1, 0)

# Else -> return $v0 = exp, $v1 = coefficient

	lw $v1, 0($v0)					# return $v1 = coefficient
	lw $v0, 4($v0)					# return $v0 = exponent
	j get_Nth_term_done				# return
	
get_Nth_term_E0:					# if out of bounds or exponent doesn't exist -> return (-1, 0)
	li $v0, -1
	move $v1, $0
	# fall through to done
	
get_Nth_term_done:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra			# return $v0 = exp, $v1 = co if in bounds of list, else return $v0 = -1, $v1 = 0 if out of bounds
	
###################################################################################################################################

# Test 1:	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 1			# PASSED
#		Result: head -> (2, 2) -> (5, 0) -> null, $v0 = 3, $v1 = 4
	
# Test 2:	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 3			# PASSED
# 		Result: head -> (4, 3)  -> (2, 2) -> null, $v0 = 0, $v1 = 5
	
# Test 3:	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 6			# PASSED
#		Result: head -> (4, 3) -> (2, 2) -> (5, 0) -> null, $v0 = -1, $v1 = 0

# Test 4:	Args: $a0 -> (4, 3) -> (2, 2) -> (5, 0) -> null, $a1 -> 0			# PASSED
#		Result: head -> (4, 3) -> (2, 2) -> (5, 0) -> null, $v0 = -1, $v1 = 0

remove_Nth_term:	# $a0 -> base address of the polynomial, $a1 -> Nth item in the list to remove

# Preamble

	addi $sp, $sp, -4
	sw $ra, 0($sp)

# Body

	# move $a0, $a0					# arg1 -> base address of polynomial
	# move $a1, $a1					# arg2 -> Nth term in polynomial
	addi $a1, $a1, -1				# subtract 1 -> get index of Nth term
	jal remove_at
	
	bltz $v0, remove_Nth_term_error			# if -> remove_at throws an error -> then return (-1, 0)

# Else -> return coefficient and exponent

	lw $v1, 0($v0)					# else -> return (exponent, coefficient) = ($v0, $v1)
	lw $v0, 4($v0)
	j remove_Nth_term_done			
	
remove_Nth_term_error:					# if error -> return (-1, 0) = ($v0, $v1)
	li $v0, -1
	li $v1, 0
	# fall through to done
	
remove_Nth_term_done:

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	# if Nth term removed -> $v0 = exp, $v1 = coefficient, otherwise -> $v0 = -1, $v1 = 0
	
####################################################################################################################################

# Test 1: 	Args: $a0 -> (5, 2) -> (7, 1) -> null, $a1 -> (3, 2) -> (1, 1) -> null, $a2 -> null		# PASSED
#		Result: (8, 2) -> (8, 1) -> null $v0 = 1

# Test 2:	Args: $a0 -> (5, 2) -> (7, 1) -> null, $a1 -> (3, 3) -> (1, 2) -> null, $a2 -> null		# PASSED
#		Result: (3, 3) -> (6, 2) -> (7, 1) -> null $v0 = 1

# Test 3:	Args: $a0 -> (5, 2) -> null, $a1 -> (-5, 2) -> null, $a2 -> null				# PASSED
# 		Result: null, $v0 = 0

# Test 4:	Args: $a0 -> (5, 2) -> null, $a1 -> null, $a2 -> null						# PASSED
# 		Result: (5, 2) -> null, $v0 = 1

# Test 5:	Args: $a0 -> (-5, 2) -> null, $a1 -> null, $a2 -> null						# PASSED
#		Result: (-5, 2) -> null, $v0 = 1

add_poly:	# $a0 -> address of p1, $a1 -> address of p2, $a2 -> address of result polynomial (p1 + p2)

	addi $sp, $sp, -20
	sw $ra, 0($sp)				
	sw $s0, 4($sp)					# $s0 -> copy of p1
	sw $s1, 8($sp)					# $s1 -> copy of p2
	sw $s2, 12($sp)					# $s2 -> copy of result polynomial
	sw $s3, 16($sp)					# $s3 -> temporary value for holding next node
	
	move $s0, $a0					# $s0 = $a0
	move $s1, $a1					# $s1 = $a1
	move $s2, $a2					# $s2 = $a2
	
# Check if first polynomial is null

#	beqz $a0, add_poly_E0				# if p1 = null -> return error
	
# Check if second polynomial is null

#	beqz $a1, add_poly_E0				# if p2 = null -> return error
	
# Initialize $a2 -> result polynomial to null, or 0

	sw $0, 0($a2)					# set $a2 -> to null
	
# Add the contents of p1 to the result polynomial

	lw $s3, 0($s0)					# get address of first node in p1
	
add_poly_p1_loop:

	beqz $s3, add_poly_p1_done			# if address of $s3 = 0 -> then we're done adding terms

	move $a0, $s2					# arg1 -> the result polynomial
	move $a1, $s3					# arg2 -> the term to add to result polynomial
	jal add_term_to_poly	

	lw $s3, 8($s3)					# load the address of the next node/term to add
	j add_poly_p1_loop
	
add_poly_p1_done:

# Once p1 has been added to the result -> we want to add p2 to the result

	lw $s3, 0($s1)					# get address of first node in p2

add_poly_p2_loop:

	beqz $s3, add_poly_p2_done
	
	move $a0, $s2					# arg1 -> the result polynomial
	move $a1, $s3					# arg2 -> the term to add to the result polynomial
	jal add_term_to_poly
	
	lw $s3, 8($s3)
	j add_poly_p2_loop

add_poly_p2_done:
	
	lw $t0, 0($s2)					# get address of head node of result
	
	beqz $t0, add_poly_E0				# if -> the result polynomial -> is still null -> return $v0 = 0
	
	li $v0, 1					# else -> return $v0 = 1
	j add_poly_done
	
add_poly_E0:

	li $v0, 0
	# fall through to done

add_poly_done:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	
	addi $sp, $sp, 20
	
	jr $ra
	
###################################################################################################################################
	
# Test 1: 	Args: $a0 -> (5, 2) -> (7, 1) -> null, $a1 -> (3, 2) -> (1, 1) -> null, $a2 -> null
#		Results: (15, 4) -> (26, 3) -> (7, 2) -> null, $v0 = 1						# PASSED

# Test 2:	Args: $a0 -> null, $a1 -> (3, 2) -> (1, 1) -> null, $a2 -> null
#		Results: (3, 2) -> (1, 1) -> null, $v0 = 1							# PASSED

# Test 3: 	Args: $a0 -> (-5, 2) -> (-3, 0) -> null, $a1 -> null, $a2 -> null
#		Results: (-5, 2) -> (-3, 0) -> null, $v0 = 1							# PASSED

# Test 4: 	Args: $a0 -> null, $a1 -> null, $a2 -> null
#		Results: null, $v0 = 0										# PASSED

# Test 5:	Args: $a0 -> (5, 2) -> (7, 1) -> null, $a1 -> (3, 3) -> (1, 2) -> null, $a2 -> null
# 		Results: (15, 5) -> (26, 4) -> (7, 3) -> null, $v0 = 1						# PASSED

# Test 6: 	Args: $a0 -> (5, 2) -> (7, 1) -> null, $a1 -> (-5, 2) -> (1, 1) -> null, $a2 -> null
#		Results: (-25, 4) -> (-30, 3) -> (7, 2) -> null, $v0 = 1					# PASSED

mult_poly:	# $a0 -> head address of p1, $a1 -> head address of p2, $a2 -> head address of result polynomial 

# Preamble -> now we can go ahead with the main part of the function

	addi $sp, $sp, -16
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> address of the first term of p1
	sw $s1, 8($sp)					# $s1 -> copy of head address of p2
	sw $s2, 12($sp)					# $s2 -> copy of head address of result
				
	move $s1, $a1					# $s1 = $a1
	move $s2, $a2					# $s2 = $a2
	
# Set the head of result polynomial = null
	
	sw $0, 0($a2)					# result.head = null
	
# If -> p1 = null -> do (p1 + p2) = result

	lw $t0, 0($a0)
	beqz $t0, mult_poly_identity			# if p1 == null -> result = (p1 + p2)
	
# If -> p2 = null -> do (p1 + p2) = result

	lw $t0, 0($a1)
	beqz $t0, mult_poly_identity			# if p2 == null -> result = (p1 + p2)
	
# Else -> We need to get the first term of the first polynomial

	lw $s0, 0($a0)					# get the address of the first term of p1
	
mult_poly_loop:
	
	beqz $s0, mult_poly_loop_done			# if address of the next term = 0 -> then we're done multiplying
	
	# Otherwise -> $s0 * [x for x in p2] + result -> so we multiply and add to result polynomial
	
	move $a0, $s0					# arg1 -> the term we want to multiply by
	move $a1, $s1					# arg2 -> the polynomial to multiply by
	move $a2, $s2					# arg3 -> result polynomial to store result to
	jal mult_poly_by_term
	
	lw $s0, 8($s0)					# get next term in first polynomial
	j mult_poly_loop				# goto next iteration
	
	
mult_poly_loop_done:
	li $v0, 1
	j mult_poly_done
	
mult_poly_identity:
	
	# move $a0, $a0					# arg1 -> p1
	# move $a1, $a1					# arg2 -> p2
	# move $a2, $a2					# arg3 -> result
	jal add_poly					# note** -> p1 and/or p2 should be null
	
	# move $v0, $v0					# if (p1 = null AND p2 = null) -> return $v0 = 0
	# j move_poly_done				# fall through to done
	
mult_poly_done:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	
	addi $sp, $sp, -16
	
	jr $ra

#####################################################################################################################################

# Below are my helper methods. Most of them are your typical linked list operations, and theres a few extra methods curated 
# for this particular assignment

#####################################################################################################################################

mult_poly_by_term: # $a0 -> address of term to mult by, $a1 -> address of polynomial to mult by, $a2 -> address of polynomial to add to

# Preamble

	addi $sp, $sp, -16
	
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> copy of the terms address
	sw $s1, 8($sp)					# $s1 -> copy of p1 address
	sw $s2, 12($sp)					# $s2 -> copy of p2 address
	
	move $s0, $a0					# $s0 = $a0
	move $s1, $a1					# $s1 = $a1
	move $s2, $a2					# $s2 = $a2
	
# Main loop body

	lw $s1, 0($s1)					# load the address of thee term at the head of p1

mult_poly_by_term_loop:

	beqz $s1, mult_poly_by_term_done		# if address of next term = 0 or '\0' -> then we're done
	
	# Else -> we want to multiply t1 * p1(i)	
	
	move $a0, $s0					# arg1 -> term1
	move $a1, $s1					# arg2 -> p1(i)
	jal multiply_terms
	
	# Create a new term with the new coefficient and new exponent
	
	addi $sp, $sp, -12				# allocate temporary space for node
	sw $v0, 0($sp)					# coefficient = $sp[0]
	sw $v1, 4($sp)					# exponent = $sp[1]
	sw $0, 8($sp)					# nextNode = $sp[2] == null (0)
	
	# move $a0, $v0					# arg1 -> coefficient of new term
	# move $a1, $v1					# arg2 -> exponent of the new term
	# jal create_term
	
	# Now we just add the new term to the polynomial
	
	move $a0, $s2					# arg1 -> address of head of polynomial to add to
	move $a1, $sp					# arg2 -> address of new term to add to polynomial
	jal add_term_to_poly
	
	addi $sp, $sp, 12				# deallocate temporary node space
	
	# go to the nex term
	
	lw $s1, 8($s1)					# get address of next term in the polynomial
	j mult_poly_by_term_loop			# goto next iteration
		
mult_poly_by_term_done:

# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	
	addi $sp, $sp, 16
	
	jr $ra
	
####################################################################################################################################

# For this function -> I'm assuming that I will only be dealing with valid terms -> I don't think it will have to deal
# invalid terms... hopefully

# UNTESTED -> null polynomial case...

# Case 1: -3x^4 + 3x^4 -> removes term from list -> TESTED
# Case 2: 3x^4 + 3x^4 -> succesfully addes 6x^4 to the list
# Case 3: 4x^5 + 3x^4 -> result contains: 4x^5 + 3x^4

add_term_to_poly:	# $a0 -> the head of a polynomial, $a1 -> the term to add to the polynomial

# Preamble

	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> copy of $a0
	sw $s1, 8($sp)					# $s1 -> copy of $a1
	sw $s2, 12($sp)					# $s2 -> temp register for addr of a term in the polynomial
	
	move $s0, $a0					# save copy of head of the polynomial
	move $s1, $a1					# save copy of term to add to polynomial

# Check if the polynomial points to null -> if so initialize with the passed term

	lw $t0, 0($a0)					# load the address to first term in polynomial
	beqz $t0, add_term_to_poly_A3			# if poly is uninitialized -> initialize it with this term

# Check if the polynomial contains the current terms exponent value already

	# move $a0, $a0					# arg1 -> base addr of poly
	lw $a1, 4($a1)					# arg2 -> exponent of term to add
	jal contains_exp
	
	bgtz $v0, add_term_to_poly_A1			# if poly contains this term already -> add to it
	
	bltz $v0, add_term_to_poly_A2			# if poly doesn't contain this term -> add it to the poly
	
	li $v0, -1
	li $v1, -1
	j add_term_to_poly_done				# if something goes wrong -> return (-1, -1)
	
add_term_to_poly_A3:	# Adds a term to polynomial -> if polynomial hasn't been initialized yet

	move $a0, $s1					# arg1 -> clone the term we want to initialize the polynomial with
	jal clone_term
	
	move $a0, $s0					# arg1 -> base address of the polynomial
	move $a1, $v0					# arg2 -> address of the term to add to the poly
	jal add_to_front				# add the term as the new head value
	
	j add_term_to_poly_done				# goto done
	
add_term_to_poly_A2:	# Adds a term to polynomial -> doesn't exist in polynomial yet

	move $a0, $s1					# arg1 -> the term we want to add to the polynomiial
	jal clone_term
	
	bltz $v1, add_term_to_poly_A22			# if index == -1 -> add to the back of the polynomial
	
# Else -> we add at whatever value $v1 is
	
	move $a0, $s0					# arg1 -> address of the polynomial to add to
	move $a1, $v0					# arg2 -> address of term to add
	move $a2, $v1					# arg3 -> index to add the term at
	jal add_at
	
	j add_term_to_poly_done
	
add_term_to_poly_A22:   # Adds a term that doesn't exist in this polynomial to the back of it

	move $a0, $s0
	move $a1, $v0
	jal add_to_back
	
	j add_term_to_poly_done

add_term_to_poly_A1:	# Adds two terms -> one of the terms is already in the polynomial 

	addi $sp, $sp, -4
	sw $v1, 0($sp)					# save a copy of index of of term in polynomial

	move $a0, $s0					# arg1 -> base address of the polynomial
	move $a1, $v1					# arg2 -> index of the term in the polynomial
	jal get_term		
	
	move $s2, $v0					# save copy of the terms address	
	
	move $a0, $v0					# arg1 -> term already in polynomial
	move $a1, $s1					# arg2 -> term to add to polynomial				
	jal add_terms
	
	beqz $v0, add_term_to_poly_E0			# if t1.co + t2.co = 0 -> then remove the term from the polynomial
	
	move $a0, $s2					# arg1 -> term in the polynomial
	move $a1, $v0					# t1.co + t2.co
	move $a2, $v1					# t1.exp and/or t2.exp (should be the same)
	jal update_term
	
	# lw $v1, 0($sp)				# don't care about the index value anymore
	addi $sp, $sp, 4
	
	j add_term_to_poly_done				# go to done
	
add_term_to_poly_E0:

	move $a0, $s0					# arg1 -> polynomial to remove term from
	lw $a1, 0($sp)					# arg2 -> index of the term to remove
	jal remove_at					
	
	addi $sp, $sp, 4				# deallocate stack space used to save index 
	# fall through to done

add_term_to_poly_done:
	
# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	
	addi $sp, $sp, 16
	
	jr $ra

##########################################################################################################################

# UNTESTED

multiply_terms:		# $a0 -> address of the first term, $a1 -> address of the second term
	
# Preamble

	addi $sp, $sp, -8
	sw $s0, 0($sp)					# term1 coefficient and exponent
	sw $s1, 4($sp)					# term2 coefficient and exponent
		
# Multiply coefficients

	lw $s0, 0($a0)					# get coefficient of t1
	lw $s1, 0($a1)					# get coefficient of t2
	mul $v0, $s0, $s1				# t1.co * t2.co = new coefficient

# Add exponents

	lw $s0, 4($a0)					# get exponent of t1
	lw $s1, 4($a1)					# get exponent of t2
	add $v1, $s0, $s1				# t1.exp + t2.exp = new exponent

# Postamble

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra		# return $v0 = (t1.co * t2.co), $v1 = (t1.exp + t2.exp)
	
##########################################################################################################################

# TESTED with one case -> I need to test more

add_terms:	# $a0 -> address of the first term, $a1 -> address of the secon term

	addi $sp, $sp, -8
	sw $s0, 0($sp)				# term1 coefficient and exponent
	sw $s1, 4($sp)				# term2 coefficient and exponent
	
# Check if exponents are valid
	
	lw $s0, 4($a0)				# get term1 exp
	lw $s1, 4($a1)				# get term2 exp
	bne $s0, $s1, add_terms_error		# if t1.exp != t2.exp -> return error
	
# If two exponents are equal -> then we can add the coefficients

	move $v1, $s0				# return $v1 = exponent of new term

	lw $s0, 0($a0)				# get term1 coefficient
	lw $s1, 0($a1)				# get term2 coefficient
	add $v0, $s0, $s1			# t1.co + t2.co = new coefficient
	
	j add_terms_done
	
add_terms_error:				# if the two terms don't have same exponent -> can't add them together

	li $v0, 0
	li $v1, -1
	# fall through to done
	
add_terms_done:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra	# returns $v0 = (t1.co + t2.co) and $v1 = t1.exp IF t1.exp = t2.exp -> otherwise, (0, -1)
	
##########################################################################################################################

# TESTED -> works so far...

# Edge case -> if the terms we're updating create and invalid term -> we should remove it from the polynomial

# Edge1 -> $a1 = 0 or $a2 = -1

update_term:	# $a0 -> the address of the term to update, $a1 -> new coefficient, $a2 -> new exponent

	sw $a1, 0($a0)					# update terms coefficient
	sw $a2, 4($a0)					# update terms exponent
	
	jr $ra						# return nothing

##########################################################################################################################

# TESTED -> works so far...

clone_term:	# $a0 -> the address of the term to clone

	addi $sp, $sp, -4
	sw $ra, 0($sp)

	lw $a1, 4($a0)					# arg2 -> exponent of the term
	lw $a0, 0($a0)					# arg1 -> coefficient of the term
	jal create_term
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	# $v0 -> address of the cloned term (without the pointer)

##########################################################################################################################

# TESTED	# Checks wether or not a given exponenet is in the current polynomial (similar to LinkedList.contains())
		# Also returns the index of the position of the element in the linked list -> might be helpful

contains_exp:	# $a0 -> base address of head of polynomial, $a1 -> exponent of term

# Preamble

	addi $sp, $sp, -8
	sw $s0, 0($sp)					# the node we want to operate on in the loop
	sw $s1, 4($sp)					# index of the node we're looking for
	
	lw $s0, 0($a0)					# load the node at the head of the polynomial into $s0
	li $s1, 0
	
	beqz $s0, contains_exp_false0			# if the polynomial is null -> return (-1, 0)
	
# Main Loop

contains_exp_loop:
	lw $t0, 4($s0)					# load the exponent of the node
	
	beq $t0, $a1, contains_exp_true			# if $s0.exp <= exp -> return true -> if 
	
	blt $t0, $a1, contains_exp_false0		# if the poly.exp < exp -> return false -> we've found where it should go 
	
	lw $t0, 8($s0)					# load the next node in the polynomial
	beqz $t0, contains_exp_false1			# if the next node == '\0' -> return false
	
	lw $s0, 8($s0)					# else -> load the next node into $s0, keep iterating
	addi $s1, $s1, 1				# increment index by 1
	j contains_exp_loop
	
contains_exp_true:
	li $v0, 1					# if the polynomial contains the exponent -> return true
	move $v1, $s1					# return index of position where node is/should be
	j contains_exp_done				# go to done
	
contains_exp_false0:					
	li $v0, -1					# if the polynomial does not contain the exp -> return false
	move $v1, $s1					# return index of position where node should be
	j contains_exp_done				# go to done
	
contains_exp_false1:
	li $v0, -1					# if the term doesn't exist in the polynomial and the term
	li $v1, -1					# needs to be added to the end of the list -> return (-1, -1)
	j contains_exp_done	
	
# Postamble

contains_exp_done:
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra			# return $v0 == 1 if exp in polynomial, otherwise -1 if not in polynomial
	
##########################################################################################################################

# TESTED -> removes the node at the head of the given linked list

remove_head:	# $a0 -> base address of the linked-list

	lw $v0, 0($a0)					# get the node at the head of the linked-list
	lw $t0, 8($v0)					# get node after the head -> head.next
	sw $t0, 0($a0)					# head = head.next -> should break the link between the nodes
	
	jr $ra	# $v0 -> the original node at the head of the linked-list (has since been removed)			

##########################################################################################################################

# TESTED -> removes the node at the given index in the given linked-list (polynomial)

remove_at:	# $a0 -> base address of the linked-list, $a1 -> index of the element to remove

	addi $sp, $sp, -12
	sw $ra, 0($sp)				
	sw $s0, 4($sp)					# the previous node in linked-list
	sw $s1, 8($sp)					# the current node in linked-list

# If index < 0 -> out of bounds error

	bltz $a1, remove_at_error_E0			# if index < 0 -> out of bounds error
	
# If index == 0 -> removing the head of the list	
	
	beqz $a1, remove_at_head
	
	lw $s0, 0($a0)					# load address of the node at the head of the linked-list as previous node
	lw $s1, 0($a0)					# load address of the node at the head of the linked-list as current node
	
remove_at_loop:

	beqz $a1, remove_at_loop_done			# if we've hit the index of the element -> then we return current node
	
# Check if we're at the end of the list

	lw $t0, 8($s1)
	beqz $t0, remove_at_error_E0			# if index != 0 AND next.node = null -> out of bounds error
	
# If not at the end -> go to the next element

	move $s0, $s1					# previous = current
	lw $s1, 8($s1)					# current = next
	
	addi $a1, $a1, -1				# decrement the index by 1
	j remove_at_loop				# go to next iteration
	
remove_at_loop_done:

	lw $t0, 8($s1)					# get address of the next node (after current node)
	sw $t0, 8($s0)					# store address as next node of previous node (break link between $s0, $s1)
	
	move $v0, $s1					# return removed node in $v0
	j remove_at_done
	
remove_at_head:

	# move $a0, $a0					# arg1 -> base address of the linked-list
	jal remove_head				
	# move $v0, $v0					# return the head of linked list -> we removed it
	j remove_at_done				# goto done
	
remove_at_error_E0:					# if index is out of bounds -> throw an error
	li $v0, -1
	# fall through to done

remove_at_done:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	
	addi $sp, $sp, 12
	
	jr $ra		# $v0 = address of the removed node or $v0 = -1 if removal of node failed for some reason

##########################################################################################################################

# TESTED -> adds a given to node to the index in the given linked list -> DOES NOT WORK FOR THE LAST ELEMENT

add_at:		# $a0 -> base address of the linked-list, $a1 -> address of node to add, $a2 -> index/position to add element to

# Preamble

	addi $sp, $sp, -12
	sw $s0, 0($sp)					# the previous node in the linked-list
	sw $s1, 4($sp)					# the current node we are inspecting
	sw $ra, 8($sp)
	
	beqz $a2, add_at_head				# if we want to add node to the head -> special case
	
	lw $s0, 0($a0)					# load address of the head node -> as previous node
	lw $s1, 0($a0)					# load address of the head node -> as next node

# Main loop

add_at_loop:

	beqz $a2, add_at_add_node			# if we've reached the positiion -> then we insert the node
	
	move $s0, $s1					# set previous = next
	lw $s1, 8($s1)					# set current -> to next node of current 
	
	addi $a2, $a2, -1				# decrement to next node
	j add_at_loop
	
add_at_head:
		
	# move $a0, $a0					arg1 -> base address of linked list head
	# move $a1, $a1					arg2 -> base address of the node to add
	jal add_to_front			
	
	j add_at_done
	
add_at_add_node:

	sw $a1, 8($s0)					# store address of new node -> as prev.next
	sw $s1, 8($a1)					# store address of next node -> as newNode.next
	
add_at_done:

# Preamble

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra
	
##########################################################################################################################

# TESTED	# Adds the given node to the back of the linked-list

add_to_back:    # $a0 -> base address of the polynomial, $a1 -> address of the node to add to the back

# Preamble
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> copy of $a1

	move $s0, $a1					# save copy of $a1
	
# Body 
	
	# move $a0, $a0					# arg1 -> the linked-list to get last element from
	jal get_last
	
	sw $s0, 8($v0)					# set next node of last element -> to the new node we're adding
	
# Postamble 

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra						# return nothing for now

##########################################################################################################################
	
# TESTED	# adds the given node to the front of the given polynomial 

add_to_front:	# $a0 -> base address of the polynomial, $a1 -> address of the node to make the new head

	lw $t0, 0($a0)					# load node at front of linked-list
	sw $t0, 8($a1)					# set newNode.next = headNode
	
	sw $a1, 0($a0)					# store newNode -> to head of linked-list
	
	jr $ra						# return nothing (for now) 
	
##########################################################################################################################

# TESTED -> 	# gets the term of at the given index in the given linked-list

get_term:	# $a0 -> base address of the linked-list, $a1 -> index of element to get

	addi $sp, $sp, -4
	sw $s0, 0($sp)					# the node at the head of the linked-list
	
	bltz $a1, get_term_error			# if index < 0 -> out of bounds error
	
	lw $s0, 0($a0)					# load the first node in the list
	
get_term_loop:

	beqz $a1, get_term_loop_done			# if index = 0 -> return the element
	
	lw $t0, 8($s0)
	beqz $t0, get_term_error			# if next_node = null and index != 0 -> then error
	
	lw $s0, 8($s0)					# load curr.node = curr.nextNode
	addi $a1, $a1, -1				# decrement index by 1
	j get_term_loop
	
get_term_loop_done:
	
	move $v0, $s0					# return base address of the node
	j get_term_done
	
get_term_error:
	li $v0, -1					# if out of bounds error -> return -1
	# fall through to donee
	
get_term_done:

	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

##########################################################################################################################

# UNTESTED -> gets the first element in the given linked-list

get_first:    # $a0 -> base address of the linked-list; simple I know, but the abstraction might help me later

	lw $v0, 0($a0)					# get first node in the linked-list
	jr $ra						# return $v0 -> first node in linked-list
	
##########################################################################################################################

# TESTED	# gets the last element in the given linked list (address of last element)

get_last:	# $a0 -> head of the linked-list

# Preamble

	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	lw $s0, 0($a0)					# load the address of first node in the polynomial
	
# Iterate to the last node

get_last_loop:
	
	lw $t0, 8($s0)					# load the address of the next node in the polynomial
	beqz $t0, get_last_done				# if the next node == "\0" -> then we have the last node
	
	move $s0, $t0					# else -> set (current = next)
	j get_last_loop					# check next node
		
get_last_done:
	
# Set Return Value

	move $v0, $s0					# return $v0 -> last node in the linked-list
	
# Postamble 

	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra		# $v0 -> return address of last node in linked list

##########################################################################################################################

# TESTED -> helper method for adding N terms -> checks whether we've hit the end of the arrary -> checks for (0, -1) pretty much

is_end_of_terms:	# $a0 -> coeffcient, $a1 -> exponent

	li $v0, 1					# set return value to 1
	
	beqz $a0, is_end_of_terms_exp			# if $a0 = 0 -> check if exponent = -1
	j is_end_of_terms_done				# else -> skip to done
	
is_end_of_terms_exp:
	li $t0, -1
	bne $a1, $t0, is_end_of_terms_done		# if $a1 != -1 -> then return $v0 = 1
	li $v0 -1					# else $a1 = -1 AND $a0 = 0 -> return $v0 = -1
	# fall through to done
	
is_end_of_terms_done:

	jr $ra
	
##########################################################################################################################

# TESTED -> prints terms of the given polynomial -> terms printed according to print_term function with whitespace inbetween

print_polynomial: # $a0 -> the polynomial we want to print the contents of

# Preamble 

	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> temporary reg to hold a node
	
	lw $s0, 0($a0)					# $s0 -> address of the node at head of linked list
	
print_polynomial_loop:

	beqz $s0, print_polynomial_done
	
	move $a0, $s0					# arg1 -> address of term to print
	jal print_term					# print the term
	
	li $a0, ' '					
	li $v0, 11
	syscall						# print whitespace between the terms
	
	lw $s0, 8($s0)					# load address of the next node in the polynomial
	j print_polynomial_loop
		
print_polynomial_done:

	li $a0, '\n'
	li $v0, 11
	syscall
# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	
	addi $sp, $sp, 8
	
	jr $ra
	
##########################################################################################################################

# TESTED -> works properly -> prints the term at the address of the form (coefficient) + 'x' + (exponent)

print_term:	# $a0 -> the address of the term we want to print the contents of

# Preamble

	addi $sp, $sp, -4
	sw $s0, 0($sp)					# $s0 -> copy of the terms base address

	move $s0, $a0					# $s0 = $a0
	
# Body

	lw $a0, 0($s0)
	li $v0, 1
	syscall						# print coefficient as an integer
	
	li $a0, 'x'
	li $v0, 11
	syscall						# print the character 'x'
	
	lw $a0, 4($s0)					
	li $v0, 1
	syscall						# print exponent as an integer
	
# Postamble

	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra	# doesn't return anything
	
##########################################################################################################################

# UNTESTED

update_N_terms_helper:	# $a0 -> address of term in polynomial, $a1 -> base address of terms array, $a2 -> N terms to check

	addi $sp, $sp, -20
	sw $s0, 0($sp)					# $s0 -> copy of base address of the term in the polynomial
	sw $s1, 4($sp)					# $s1 -> copy of the starting address of the terms array
	sw $s2, 8($sp)					# $s2 -> copy of N, number of terms to inspect in the terms array
	sw $s3, 16($sp)
	
	sw $ra, 12($sp)
	
	move $s0, $a0					# $s0 = $a0
	move $s1, $a1					# $s1 = $a1
	move $s2, $a2					# $s2 = $a2
	
# Initialize the return value -> $v0 = 0

	move $s3, $0
	
update_N_terms_helper_loop:

# First -> check if N != 0

	blez $s2, update_N_terms_helper_done		# if N = 0 -> then we're done looking at the terms
	
# Next -> check that next term != (0, -1)

	lw $a0, 0($s1)					# $a0 = terms[i].coefficient
	lw $a1, 4($s1)					# $a1 = terms[i].exponent
	
	jal is_end_of_terms
	
	bltz $v0, update_N_terms_helper_done		# if terms[i] = (0, -1) -> then we're done looking at terms array
	
# Alright -> now we want to check if terms[i].exp = poly.term.exp
		
	lw $t0, 4($s1)					# $t0 = terms[i].exponent
	lw $t1, 4($s0)					# $t1 = poly.term.exponent
	
	bne $t0, $t1, update_N_terms_helper_loop_next   # if terms.exp != poly.exp -> then we can go to the next term
	
# If the exponents are equal -> we can store the new coefficient at the node in the polynomial and set $v0 = 1
		
	lw $t0, 0($s1)					# $t0 = terms[i].coefficient
	sw $t0, 0($s0)					# poly.term.coefficient = terms[i].coefficient
	
	li $s3, 1					# return $v0 = 1
	
	# j update_N_terms_helper_loop_next		# fall through to next iteration
			
update_N_terms_helper_loop_next:

	addi $s1, $s1, 8				# increment to next term in terms array
	addi $s2, $s2, -1
	j update_N_terms_helper_loop			# go to the next iteration of the loop	
	
update_N_terms_helper_done:

	move $v0, $s3					# move return value into $v0
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 16($sp)
	
	lw $ra, 12($sp)
	
	addi $sp, $sp, 20
	
	jr $ra

##########################################################################################################################

