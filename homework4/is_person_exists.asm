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
