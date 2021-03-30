.data
board_filename: .asciiz "game01.txt"
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0108070601000404040404040400"
.text
.globl main
main:

la $a0, state
la $a1, board_filename
jal load_game
# You must write your own code here to check the correctness of the function implementation.

la $s0, state
li $s1, 22

loop:
	beqz $s1, done
	lbu $a0, 0($s0)
	li $v0, 11
	syscall
	
	addi $s1, $s1, -1
	addi $s0, $s0, 1
	
done:

li $v0, 10
syscall

.include "hw3.asm"
