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
