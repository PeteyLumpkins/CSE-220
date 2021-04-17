############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

###################################################################################################################################

str_len:		# $a0 -> the base address of the string 

# Preamble
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $0					# $s0 -> number of characters in the string
# Body

str_len_loop:
	lbu $t0, 0($a0)					# load a byte in the string
	beqz $t0, str_len_done				# if next_char == '\n' -> then we're done
	
	addi $s0, $s0, 1				# else -> increment total chars
	addi $a0, $a0, 1				# else -> increment base address of the string
	j str_len_loop

str_len_done:
	move $v0, $s0					# return -> $s0 -> total characters in the string
	
# Postamble
	
	lw $s0, 0($sp)					
	addi $sp, $sp, 4
	jr $ra						# $v0 -> the length of the string
	
###################################################################################################################################
	
str_cpy:		# $a0 -> base address of the source string, $a1 -> base address of destination string

# Preamble
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $0					# $s0 -> number of copied characters
	
# Body

str_cpy_loop:
	
	lbu $t0, 0($a0)					# load character from source string
	beqz $t0, str_cpy_done				# if next_char == '\0' -> then we're done with the loop
	
	sb $t0, 0($a1)					# else -> store the byte in the destination string
	addi $s0, $s0, 1				# increment chars seen
	addi $a0, $a0, 1				# increment base address of src string
	addi $a1, $a1, 1				# increment base address of dest string
	j str_cpy_loop					# go to next character
	
str_cpy_done:

# Postamble

	move $v0, $s0					# return -> $s0 -> chars copied
	sb $0, 0($a1)					# store null terminator string at the end of dest string
	
	lw $s0, 0($sp)			
	addi $sp, $sp, 4
	jr $ra
	
###################################################################################################################################
	
str_equals:		# $a0 -> the first string, $a1 -> the second string

# No preamble required -> I don't think I need to save any registers

	lbu $t0, 0($a0)					# $t0 -> character from the first string
	lbu $t1, 0($a1)					# $t1 -> character from the second string
	
	bne $t0, $t1, str_equals_false			# if ($t0 != $t1) -> return false
	
	beqz $t0, str_equals_true			# if ($t0 == $t1 && $t0 == '\0') -> return true
	
	addi $a0, $a0, 1				# increment base address of str1
	addi $a1, $a1, 1				# increment base address of str2
	j str_equals

str_equals_true:
	li $v0, 1					# if 
	j str_equals_done
	
str_equals_false:
	move $v0, $0
	# fall through to done
	
str_equals_done:

# No postamble required -> didn't need to save any registers
	jr $ra						# $v0 == 1 -> if strings are equal, $v0 == 0 if not equal
	
###################################################################################################################################

create_person:		# $a0 -> the base address of the network structure

# Preamble

	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $a0					# save a copy of the base address of the network

# Body
	
	lw $t0, 0($s0)					# load bytes 0-3 (capacity of nodes) in the network
	lw $t1, 16($s0)					# load bytes 16-19 (current num nodes) in the network
	
	beq $t0, $t1, create_person_failed		# if current_num_nodes == capacity -> return -1
	
	addi $t2, $t1, 1				# add one node to total nodes in the network
	sb $t2, 16($s0)					# store new total nodes to the network
	
	lw $t0, 8($s0)					# load the size of a node in the network
	
	mul $t0, $t0, $t1				# (num_nodes) * (node_size) + 36 == starting address of next node
	addi $t0, $t0, 36				# increment over the initial data in the network
	add $v0, $s0, $t0				# add the increment value to base address of network -> return baseaddress of node
	
	j create_person_done
	
create_person_failed:
	li $v0, -1
	# fall through to done
	
create_person_done:

# Postamble

	lw $s0, 0($sp)
	addi $sp, $sp, 4

	jr $ra					
	
###################################################################################################################################

is_person_exists:		# $a0 -> base address of the network, $a1 -> base address of the node

# Preamble	

	addi $sp, $sp, -12
	sw $s0, 0($sp)					# $s0 -> size of node in the network
	sw $s1, 4($sp)					# $s1 -> base address of the last node in the network
	sw $s2, 8($sp)					# $s2 -> total number of nodes in the network
	
	lw $s0, 8($a0)					# load the size of a node in the network
	lw $s2, 16($a0)					# load total nodes in the network
	
	addi $t0, $s2, -1				# subtract 1 from total nodes in the network
	mul $t0, $t0, $s0				# (num_nodes) * (size_node)
	add $a0, $a0, $t0				# add to base address of network
	addi $a0, $a0, 36				# increment by 36

# Body

is_person_exists_loop:
	
	blez $s2, person_not_exists			# if we've inspected every base address -> we're done
	beq $a0, $a1, person_exists			# if base_address == node_address -> then it exists
	
	sub $a0, $a0, $s0				# decrement base address by one node
	addi $s2, $s2, -1				# decrement total nodes left to inspect
	j is_person_exists_loop				# inspect next element
	
person_not_exists:
	li $v0, 0
	j is_person_exists_done				# if person -> not found -> return $v0 == 0

person_exists:
	li $v0, 1					# if person -> exists -> return $v0 == 1
	# fall through to done
# Preamble

is_person_exists_done:
	
	lw $s0, 0($sp)					# restoring values and stack pointer
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra						# $v0 == 1 -> if person exists, $v0 == 0 if person does not exist
	
###################################################################################################################################

is_person_name_exists:		# $a0 -> base address of the network structure, $a1 -> base address of the name

# Preamble

	addi $sp, $sp, -20
	sw $ra, 0($sp)					# probably going to check name equality -> save return address now
	sw $s0, 4($sp)					# $s0 -> copy of base addr of network structure
	sw $s1, 8($sp)					# $s1 -> copy of base addr of name
	sw $s2, 12($sp)					# $s2 -> size of a node in the network
	sw $s3, 16($sp)					# $s3 -> next node in the network
	
	move $s0, $a0					# save copy of network
	move $s1, $a1					# save copy of string-name
	
# Body	
	
	lw $s2, 8($s0)					# load size of a node in the network
	
	move $a0, $a1					# arg1 -> base addr of name
	jal str_len
	bge $v0, $s2, person_name_not_exists		# if name_length >= node_size -> then the name doesn't exist
	
	addi $s3, $s0, 36				# increment base address by 36 -> get the address of first node
	
person_name_exists_loop:
	
	move $a0, $s0					# arg1 -> base address of network
	move $a1, $s3					# arg2 -> base address of next node
	jal is_person_exists				
	
	beqz $v0, person_name_not_exists		# if the person does not exist in the network -> then we're done
	
	move $a0, $s3					# arg1 -> base address of name in the network
	move $a1, $s1					# arg2 -> the name we want to check
	jal str_equals					
	
	bnez $v0, person_name_exists			# if $v0 != 0 -> then the person must exist
	
	add $s3, $s3, $s2				# (next_name) += node_size
	j person_name_exists_loop			# goto next iteration

person_name_not_exists:
	li $v0, 0
	j person_name_exists_done			
	
person_name_exists:
	li $v0, 1
	move $v1, $s3					# return reference to the person in the network if found
	# fall through to done
	
person_name_exists_done:

# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra			# $v0 == 0 -> if name doesn't exist, $v0 == 1 and $v1 == address of person if name exists
	
###################################################################################################################################

add_person_property:	# $a0 -> network base addr, $a1 -> base address of person node, $a2 -> property name, $a3 -> property value
# Preamble
	addi $sp, $sp, -16
	sw $ra, 0($sp)					# saving return address -> we'll have to call functions eventually
	sw $s0, 4($sp)					# $s0 -> copy of $a0
	sw $s1, 8($sp)					# $s1 -> copy of $a1
	sw $s3, 12($sp)					# $s3 -> copy of $a3
	
	move $s0, $a0					# save a copy of the network base address
	move $s1, $a1					# save a copy of the person base address
	move $s3, $a3					# save a copy of the property value
	
# First -> check property == "NAME"

	addi $sp, $sp, -5				# Allocate stack space for characters -> "N", "A", "M", "E", "\0"
	li $t0, 'N'					
	sb $t0, 0($sp)
	
	li $t0, 'A'
	sb $t0, 1($sp)
	
	li $t0, 'M'
	sb $t0, 2($sp)
	
	li $t0, 'E'
	sb $t0, 3($sp)
	
	li $t0, '\0'
	sb $t0, 4($sp)
	
	move $a0, $a2					# arg1 -> property string
	move $a1, $sp					# arg2 -> "NAME" + "\0"
	jal str_equals					
	
	addi $sp, $sp, 5				# restore the stack pointer
	
	beqz $v0, add_person_property_E0		# if prop_name != "NAME" -> return error, $v0 == 0
	
# Next -> check if the person exists in the network

	move $a0, $s0					# arg1 -> base address of the network
	move $a1, $s1					# arg2 -> address of person in the network
	jal is_person_exists				
	
	beqz $v0, add_person_property_E1		# if person does not exist -> return error, $v0 == -1
	
# Next -> check (name_length < node_size)
	
	move $a0, $s3					# arg1 -> property value
	jal str_len				
	
	lw $t0, 8($s0)					# get the size of a node in the network
	
	bge $v0, $t0, add_person_property_E2		# if property_length >= node_size -> return error, $v0 == -2
	
# Next -> check if the name we want to add is already in the network

	move $a0, $s0					# arg1 -> base address of the network
	move $a1, $s3					# arg2 -> the person's name
	jal is_person_name_exists
	
	bnez $v0, add_person_property_E3		# if the name already exists in the network -> return error, $v0 == -3
	
# Next -> now that all errors are accounted for we can actually add the name to the network

	move $a0, $s3					# arg1 -> base address of source string (property value)
	move $a1, $s1					# arg2 -> base address of destination string (person node)
	jal str_cpy
	
# Finally -> if we've made it to this point, we're done
	
	li $v0, 1					# if we successfully added the property -> return success, $v0 == 1
	j add_person_property_done
			
add_person_property_E0:					# if property != "NAME" -> return $v0 == 0
	li $v0, 0
	j add_person_property_done
	
add_person_property_E1:					# if person does not exist -> return $v0 == -1
	li $v0, -1
	j add_person_property_done
	
add_person_property_E2:					# if person_size >= node_size -> return $v0 == -2
	li $v0, -2
	j add_person_property_done
	
add_person_property_E3:					# if person already in network -> return $v0 == -3
	li $v0, -3
	# fall through to done
	
add_person_property_done:
# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
###################################################################################################################################

get_person:		# $a0 -> the base address of the network structure, $a1 -> base address of the name to search for

# Preamble

	addi $sp, $sp, -4
	sw $ra, 0($sp)

# Body
	jal is_person_name_exists			# if name exists -> $v1 should contain reference to name in the network
	
	bnez $v0, get_person_found			# if $v0 != 0 -> then we found the person and $v1 == base address of person
	li $v0, 0
	j get_person_done				# else $v0 == 0 -> then person was not found, return $v0 == 0
	
get_person_found:
	move $v0, $v1					# if person is found -> return $v0 == base address of person in network
	# fall through to done
	
get_person_done:
# Postamble	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
###################################################################################################################################

is_relation_exists:	# $a0 -> base address of the network structure, $a1 -> base addr p1, $a2 -> base addr p2
# Preamble
	addi $sp, $sp, -20
	sw $ra, 0($sp)					# function calls
	sw $s0, 4($sp)					# $s0 -> copy of $a0 (network structure base addr)
	sw $s1, 8($sp) 					# $s1 -> address of the first edge in the network
	sw $s2, 12($sp)					# $s2 -> size of an edge in the network
	sw $s3, 16($sp)					# $s3 -> number of edges in the network
	
	move $s0, $a0					# save copy of structure to $s0
	
# First -> find starting address of the first edge
	
	addi $s1, $0, 36				# first -> increment by 36 to get to the first node
	
	lw $t0, 0($s0)					# get total nodes in the network
	lw $t1, 8($s0)					# get size of node in the network
	mul $t1, $t0, $t1				# (total_nodes) * (node_size) + 36 == base address of first edge
	
	add $s1, $s1, $t1				# add bytes for the nodes to the total
	add $s1, $s1, $s0				# need to add the networks base address to the total
	
# Next -> 1.) get the size of an edge, 2.) get current edges in network

	lw $s2, 12($s0)					# get size of an edge in network
	lw $s3, 20($s0)					# get total edges in the network
	
# Next -> we start iterating through the edges

is_relation_exists_loop:

	blez $s3, is_relation_doesnt_exist		# if we've seen all the edges and haven't found a relation -> return $v0 == 0
	
	lw $t0, 0($s1)					# get first person on the edge
	lw $t1, 4($s1)					# get second person on the edge
	
	beq $t0, $a1, is_relation_exists_person12	# if p1 == edge.p1 -> check if p2 == edge.p2
	beq $t1, $a1, is_relation_exists_person21	# if p1 == edge.p2 -> check if p2 == edge.p1
	
	j is_relation_exists_loop_next			# if p1 != edge.p1 AND p1 != edge.p2 -> goto next edge
	
is_relation_exists_person12:
	beq $t1, $a2, is_relation_does_exist		# if p1 == edge.p1 AND p2 == edge.p2 -> return $v0 == 1
	j is_relation_exists_loop_next			# else -> goto next edge
	
is_relation_exists_person21:
	beq $t0, $a2, is_relation_does_exist		# if p1 == edge.p2 AND p2 == edge.p1 -> return $v0 == 1
	j is_relation_exists_loop_next			# else -> goto next edge
	
is_relation_does_exist:
	li $v0, 1					# if a relation exists -> return $v0 == 1
	j is_relation_exists_done			
	
is_relation_doesnt_exist:
	li $v0, 0					# if no relation exists -> return $v0 == 0
	j is_relation_exists_done
	
is_relation_exists_loop_next:
	add $s1, $s1, $s2				# increment to the next edge
	addi $s3, $s3, -1				# decrement edges left to inspect
	j is_relation_exists_loop			# goto next iteration
	
is_relation_exists_done:
# Postamble

	lw $s3, 16($sp)
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)
	
	addi $sp, $sp, 20
	
	jr $ra

###################################################################################################################################

add_relation:		# $a0 -> network base addr, $a1 -> base addr of person1, $a2 -> base addr of person2
	
	addi $sp, $sp, -16				# adjusting stack pointer
	sw $ra, 0($sp)					# making nested function calls
	
	sw $s0, 4($sp)					# $s0 -> copy of network 
	sw $s1, 8($sp)					# $s1 -> copy of person1
	sw $s2, 12($sp)					# $s2 -> copy of person2
	
	move $s0, $a0					# save copy of network base address
	move $s1, $a1					# save copy of person1 base address
	move $s2, $a2					# save copy of person2 base address
	
# First -> check if person1 and person2 both exist in the network

	# move $a0, $s0					# arg1 -> network base address
	# move $a1, $s1					# arg2 -> person1 base address
	jal is_person_exists				
	
	beqz $v0, add_relation_E0			# if person1 doesn't exist -> return $v0 == 0
	
	move $a0, $s0					# arg1 -> network base address
	move $a1, $s2					# arg2 -> person2 base address
	jal is_person_exists
	
	beqz $v0, add_relation_E0		# if person2 doesn't exist -> return $v0 == 0
	
# Next -> check the number of edges in the network

	lw $t0, 4($s0)					# get total edges in the network
	lw $t1, 20($s0)					# get current number of edges in the network
	
	beq $t0, $t1, add_relation_E1			# if network has maximum number of edges -> return $v0 == -1
	
# Next -> check if the relation between the two persons already exists -> relations must be unique

	move $a0, $s0					# arg1 -> base address of network
	move $a1, $s1					# arg2 -> base address of person1
	move $a2, $s2					# arg2 -> base address of person2
	jal is_relation_exists
	
	bnez $v0, add_relation_E2			# if relation already exists -> return $v0 == -2
	
# Next -> check if person1 == person2
	
	beq $s1, $s2, add_relation_E3			# if person1 == person2 -> return $v0 == -3
	
# Next -> all errors are accounted for so we can safely add the edge between the two persons to the network

	lw $t0, 0($s0)					# get total nodes in network
	lw $t1, 8($s0)					# get size of a node in network
	mul $t0, $t0, $t1				# (node_capacity) * (node_size)
	
	lw $t2, 20($s0)					# get current edges in the network
	lw $t3, 12($s0)					# get size of an edge in the network
	mul $t2, $t2, $t3				# (current_edges) * (edge_size)
	
	add $t0, $t0, $t2				# (current_edges) * (edge_size) + (node_capcaity) * (node_size)
	addi $t0, $t0, 36				# increment total by 36 -> should get us the base addr of next place to add an edge
	add $t0, $t0, $s0				# add to base address of the network structure
	
	sw $s1, 0($t0)					# edge.p1 == person1
	sw $s2, 4($t0)					# edge.p2 == person2
	sw $0, 8($t0)					# initialize friend property == 0 (just for safetly reasons)
	
	addi $t2, $t2, 1				# increment total edges in the network
	sw $t2, 20($s0)					# add 1 edge to total edges in the network
	
	li $v0, 1					
	j add_relation_done				# if we made it here -> edge has been successfully added to the network
	
add_relation_E0:
	li $v0, 0					# if person1 OR person2 doesn't exist -> return $v0 == 0
	j add_relation_done

add_relation_E1:
	li $v0, -1					# if current_edges == max_edges -> return $v0 == -1
	j add_relation_done

add_relation_E2:
	li $v0, -2					# if person1 is related to person2 -> return $v0 == -2
	j add_relation_done

add_relation_E3:
	li $v0, -3					# if person1 == person2 -> return $v0 == -3
	j add_relation_done

add_relation_done:
	
	lw $s2, 12($sp)
	lw $s1, 8($sp)
	lw $s0, 4($sp)
	lw $ra, 0($sp)					# restoring return address
	
	addi $sp, $sp, 16				# adjusting stack pointer -> deallocating stack space
	
	jr $ra	
	
# $v0 = 1 -> success, $v0 = 0 -> person doesn't exist, $v0 = -1 -> edges full, $v0 = -2 -> p1 related p2, $v0 = -3 -> p1 = p2
	
	
###################################################################################################################################

add_relation_property:
	jr $ra
is_friend_of_friend:
	jr $ra
	
###################################################################################################################################
# 
# Additional helper methods start here!!!
#
###################################################################################################################################
