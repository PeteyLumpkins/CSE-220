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
