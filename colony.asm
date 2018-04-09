# AUTHOR:       Jacob Potter
#
# DESCRIPTION:
#       This program runs the the colony simulation.
#
#

#
# CONSTANTS
#

MAX_CELLS = 900

PRINT_STRING = 4                # syscall
PRINT_INT = 1
READ_INT = 5

#
# DATA
#
        .data

        .align  2

input_data:
        .space  16             # holds the input data: board size, gens, a, b

grid_main:                      # main colony grid
        .space  4*MAX_CELLS

grid_temp:                      # temporary colony grid
        .space  4*MAX_CELLS

#
# STRINGS
#
        .align  0

newline:
        .asciiz "\n"
space:
        .asciiz " "
pipe:
        .asciiz "|"
plus:
        .asciiz "+"
minus:
        .asciiz "-"
a:
        .asciiz "A"
b:
        .asciiz "B"

e_board_size:
        .asciiz "Enter board size: "
e_generation:
        .asciiz "Enter number of generations to run: "
e_a_cells:
        .asciiz "Enter number of live cells for colony A: "
e_b_cells:
        .asciiz "Enter number of live cells for colony B: "
e_locations:
        .asciiz "Start entering locations"
banner:
        .ascii  "\n**********************\n"
        .ascii  "****    Colony    ****\n"
        .asciiz "**********************\n\n"
gen_start:
        .asciiz "====    GENERATION "
gen_end:
        .asciiz "    ===="

w_board_size:
        .asciiz "WARNING: illegal board size, try again: "
w_generation:
        .asciiz "WARNING: illegal number of generations, try again: "
w_cells:
        .asciiz "WARNING: illegal number of live cells, try again: "
w_locations:
        .asciiz "ERROR: illegal point location"

#
# CODE
#
        .text
        .align  2
        .globl  main

#
# Name:         main
#
# Arguments:    none
# Returns:      none
#
main:
#-------------------------------
        addi    $sp, $sp, -36
        sw      $ra, 0($sp)
        sw      $s0, 4($sp)
        sw      $s1, 8($sp)
        sw      $s2, 12($sp)
        sw      $s3, 16($sp)
        sw      $s4, 20($sp)
        sw      $s5, 24($sp)
        sw      $s6, 28($sp)
        sw      $s7, 32($sp)
#--------------------------------

        li      $v0, PRINT_STRING
        la      $a0, banner
        syscall

#-------------------------------
        lw      $ra, 0($sp)
        lw      $s0, 4($sp)
        lw      $s1, 8($sp)
        lw      $s2, 12($sp)
        lw      $s3, 16($sp)
        lw      $s4, 20($sp)
        lw      $s5, 24($sp)
        lw      $s6, 28($sp)
        lw      $s7, 32($sp)
        addi    $sp, $sp, 36
        jr      $ra
#--------------------------------
