.data
player: .byte 'T'
distance: .byte 2
size: .word 28
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
lb $a1, player
lb $a2, distance
lw $a3, size
jal set_pocket

la $a0, state
jal print_board

li $v0, 10
syscall

.include "hw3.asm"
