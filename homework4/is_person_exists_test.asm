# add test cases to data section
# Test your code with different Network layouts
# Don't assume that we will use the same layout in all our tests
.data
Network:
  .word 5   #total_nodes (bytes 0 - 3)
  .word 10  #total_edges (bytes 4- 7)
  .word 12  #size_of_node (bytes 8 - 11)
  .word 12  #size_of_edge (bytes 12 - 15)
  .word 0   #curr_num_of_nodes (bytes 16 - 19)
  .word 0   #curr_num_of_edges (bytes 20 - 23)
  .asciiz "NAME" # Name property (bytes 24 - 28)
  .asciiz "FRIEND" # FRIEND property (bytes 29 - 35)
   # nodes (bytes 36 - 95)	
  .byte 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0	
   # set of edges (bytes 96 - 215)
  .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

.text:
main:
	la $a0, Network
	jal create_person
	move $s0, $v0
	
	addi $s0, $s0, 12
	
	la $a0, Network
	move $a1, $s0
	jal is_person_exists
	#write test code
	
	li $v0, 10
	syscall
	
.include "hw4.asm"
