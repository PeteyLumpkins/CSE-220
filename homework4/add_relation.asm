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
