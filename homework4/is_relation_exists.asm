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
