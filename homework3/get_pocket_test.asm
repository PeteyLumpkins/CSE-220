.data
player: .byte 'B'
distance: .byte 0
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
    "0102030405060708091011121314"
.text
.globl main
main:
la $a0, state
lb $a1, player
lb $a2, distance
jal get_pocket

move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

.include "hw3.asm"
