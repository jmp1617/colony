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
PRINT_CHAR = 11
READ_INT = 5

#
# DATA
#
        .data

        .align  2

input_data:
        .space  16              # holds the input data: board size, gens, a, b
x_offset:
        .word   1,1,1,0,0,-1,-1,-1
y_offset:
        .word   1,0,-1,1,-1,1,0,-1

        .align  0               # char byte align
grid_main:                      # main colony grid
        .space  MAX_CELLS

grid_temp:                      # temporary colony grid
        .space  MAX_CELLS

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
        .asciiz "\nEnter number of generations to run: "
e_a_cells:
        .asciiz "\nEnter number of live cells for colony A: "
e_b_cells:
        .asciiz "\nEnter number of live cells for colony B: "
e_locations:
        .asciiz "\nStart entering locations\n"
banner:
        .ascii  "\n**********************\n"
        .ascii  "****    Colony    ****\n"
        .asciiz "**********************\n\n"
gen_start:
        .asciiz "\n====    GENERATION "
gen_end:
        .asciiz "    ====\n"

w_board_size:
        .asciiz "\nWARNING: illegal board size, try again: "
w_generation:
        .asciiz "\nWARNING: illegal number of generations, try again: "
w_cells:
        .asciiz "\nWARNING: illegal number of live cells, try again: "
w_locations:
        .asciiz "\nERROR: illegal point location\n"

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
        la      $v0, PRINT_STRING
        la      $a0, banner
        syscall
        # get input and process
        la      $v0, PRINT_STRING       # get and store board size     
        la      $a0, e_board_size
        syscall
        j       good_board
warn_board:
        la      $v0, PRINT_STRING       # wrong size
        la      $a0, w_board_size
        syscall
good_board:
        la      $v0, READ_INT
        syscall
        li      $t4, 4
        li      $t5, 30
        slt     $t6, $v0, $t4
        bne     $t6, $zero, warn_board
        slt     $t6, $t5, $v0
        bne     $t6, $zero, warn_board

        la      $s5, input_data         # store the board size
        sw      $v0, 0($s5)

        #------ board init ------
        move    $a0, $v0
        jal     init_board
        #------------------------

        la      $v0, PRINT_STRING       # get and store number of generations
        la      $a0, e_generation
        syscall
        j       good_gen
warn_gen:
        la      $v0, PRINT_STRING       # wrong gen
        la      $a0, w_generation
        syscall
good_gen:
        la      $v0, READ_INT
        syscall
        li      $t5, 20
        slt     $t6, $t5, $v0
        bne     $t6, $zero, warn_gen
        bltz    $v0, warn_gen

        sw      $v0, 4($s5)

        la      $v0, PRINT_STRING       # get number of A cells
        la      $a0, e_a_cells
        syscall
        j       good_cell_a
warn_cell_a:
        la      $v0, PRINT_STRING       # wrong cell count
        la      $a0, w_cells
        syscall
good_cell_a:
        la      $v0, READ_INT
        syscall
        lw      $t5, 0($s5)
        mul     $t5, $t5, $t5           # number of cells on the board
        slt     $t6, $t5, $v0
        bne     $t6, $zero, warn_cell_a
        bltz    $v0, warn_cell_a

        move    $t2, $v0
        sw      $v0, 8($s5)

        la      $v0, PRINT_STRING       # print locations string
        la      $a0, e_locations
        syscall
        beq     $t2, $zero, done_a_loc
        addi    $t2, $t2, -1            # for loop count
a_loc_loop:                             # get coords and process
        la      $v0, READ_INT
        syscall
        move    $s1, $v0
        la      $v0, READ_INT
        syscall
        move    $s2, $v0

        #------ Write cell -----
        move    $a0, $s2
        move    $a1, $s1
        li      $a2, 65
        jal     write_cell
        bne     $v0, $zero, done_write_a
        la      $v0, PRINT_STRING
        la      $a0, w_locations
        syscall
        j       done_main
done_write_a:
        #-----------------------

        addi    $t2, $t2, -1
        bgez    $t2, a_loc_loop
done_a_loc:

        la      $v0, PRINT_STRING       # get number of b cells
        la      $a0, e_b_cells
        syscall
        j       good_cell_b
warn_cell_b:                            # wrong number of cells
        la      $v0, PRINT_STRING
        la      $a0, w_cells
        syscall
good_cell_b:
        la      $v0, READ_INT
        syscall
        lw      $t5, 0($s5)
        mul     $t5, $t5, $t5           # number of cells on the board
        slt     $t6, $t5, $v0
        bne     $t6, $zero, warn_cell_b
        bltz    $v0, warn_cell_b

        move    $t2, $v0
        sw      $v0, 12($s5)

        la      $v0, PRINT_STRING       # print locations string
        la      $a0, e_locations
        syscall
        beq     $t2, $zero, done_b_loc
        addi    $t2, $t2, -1
b_loc_loop:
        la      $v0, READ_INT
        syscall
        move    $s1, $v0
        la      $v0, READ_INT
        syscall
        move    $s2, $v0

        #------ Write cell -----
        move    $a0, $s2
        move    $a1, $s1
        li      $a2, 66
        jal     write_cell
        bne     $v0, $zero, done_write_b
        la      $v0, PRINT_STRING
        la      $a0, w_locations
        syscall
        j       done_main
done_write_b:
        #-----------------------

        addi    $t2, $t2, -1
        bgez    $t2, b_loc_loop
done_b_loc:
        lw      $a0, 4($s5)
        jal     run_generations
done_main:
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


# Name:         run generations
# 
# runs the generations
#
# Arguments:    a0: number of generations
# Returns:      none
#
run_generations:
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

	move    $s0, $a0
        addi    $s0, $s0, 1
        move    $s1, $zero
gen_loop:
        la      $v0, PRINT_STRING
        la      $a0, gen_start
        syscall
        la      $v0, PRINT_INT
        move    $a0, $s1
        syscall
        la      $v0, PRINT_STRING
        la      $a0, gen_end
        syscall       
        jal     print_board 
        #=======================
        jal     colony_cycle 
        #=======================

        addi    $s1, $s1, 1
        bne     $s1, $s0, gen_loop

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


# Name:         colony_cycle
# 
# runs a generatain of colony
#
# Arguments:    none
# Returns:      none
#
colony_cycle:
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

        move    $s0, $zero      # x value
        move    $s1, $zero      # y value
        la      $s2, input_data
        lw      $s2, 0($s2)     # board width
cyc_outer:
        move    $s0, $zero
cyc_inner:
        #=======================
        move    $a0, $s0
        move    $a1, $s1
        jal     get_val
        move    $s3, $v0        # ascii at that location
        li      $s4, 65
        li      $s5, 66
        move    $a0, $s0
        move    $a1, $s1
        move    $a2, $s4
        jal     count_neigh
        move    $s4, $v0        # count of A neighbors
        move    $a2, $s5
        jal     count_neigh     
        move    $s5, $v0        # count of B neighbors
        li      $t0, 32
        beq     $t0, $s3, cell_is_dead
        li      $t0, 66
        beq     $t0, $s3, cell_is_b
        #-=-=-=-=-=-=-=-=-=-=-=-
        sub     $s6, $s4, $s5   # A - B in s6 # cell is A
        li      $t0, 2
        slt     $t0, $s6, $t0   # if A-B < 2
        bne     $t0, $zero, kill_a
        li      $t0, 3
        slt     $t0, $t0, $s6   # if 3 < A-B ( A>=4)
        bne     $t0, $zero, kill_a
stay_a:                         # else, A-B = 2 or 3 so it stays alive
        move    $a0, $s0
        move    $a1, $s1
        li      $a2, 65
        jal     write_temp
        j       done_a_state
kill_a:
        move    $a0, $s0
        move    $a1, $s1
        li      $a2, 32
        jal     write_temp
done_a_state:
        #-=-=-=-=-=-=-=-=-=-=-=-
        j       done_cyc
cell_is_b:
        #-=-=-=-=-=-=-=-=-=-=-=-
        sub     $s6, $s5, $s4   # B - A in s6 # cell is B
stay_b:
kill_b:
        #-=-=-=-=-=-=-=-=-=-=-=-
        j       done_cyc
cell_is_dead:                                 # cell is dead
        #-=-=-=-=-=-=-=-=-=-=-=-
                
        #-=-=-=-=-=-=-=-=-=-=-=-
done_cyc:
        #=======================        
        addi    $s0, $s0, 1
        bne     $s2, $s0, cyc_inner
        addi    $s1, $s1, 1
        bne     $s2, $s1, cyc_outer

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


# Name:         print_board
# 
# prints the main board
#
# Arguments:    none
# Returns:      none
#
print_board:
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
        la      $s0, input_data
        lw      $s1, 0($s0)     #s1 is board size
        la      $s2, grid_main  #s2 is address of the grid first char
        move    $t0, $zero      #counter
	# print upper wall
        la      $v0, PRINT_STRING
        la      $a0, plus
        syscall
        la      $a0, minus
upperwall:
	syscall
        addi    $t0, $t0, 1
        bne     $t0, $s1, upperwall
        la      $a0, plus
        syscall
        la      $a0, newline
        syscall
        #print grid-------------
        move    $t0, $zero      # row counter
        move    $t2, $zero      # index in grid array
rows_printed:                   # outer loop
        move    $t1, $zero      # col counter
        la      $a0, pipe
        syscall
print_row:                      # inner loop
        #=======================
        add     $s3, $s2, $t2   # calculate address of value at index
        lb      $a0, 0($s3)     # get the value
        la      $v0, PRINT_CHAR
        syscall
        addi    $t1, $t1, 1
        addi    $t2, $t2, 1
        bne     $t1, $s1, print_row
        #=======================
        la      $v0, PRINT_STRING
        la      $a0, pipe
        syscall        
        la      $a0, newline
        syscall
        addi    $t0, $t0, 1
        bne     $t0, $s1, rows_printed

        #-----------------------
        # print lower wall
        move    $t0, $zero
        la      $v0, PRINT_STRING
        la      $a0, plus
        syscall
        la      $a0, minus
lowerwall:
	syscall
        addi    $t0, $t0, 1
        bne     $t0, $s1, lowerwall
        la      $a0, plus
        syscall
        la      $a0, newline
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


# Name:         write_cell
# 
# Adds a cell to a location based on a coord
#
# Arguments:    a0: x location
#               a1: y location
#               a2: ascii for char to write
# Returns:      1 if valid location, zero otherwise
#
write_cell:
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
#-------------------------------
        move    $s0, $a0        # s0 is x
        move    $s1, $a1        # s1 is y
        la      $t0, input_data
        lw      $s2, 0($t0)     # board size
        mul     $s3, $s1, $s2   # y * board size
        add     $s3, $s3, $s0   # (y*board size) + x : index of array
        la      $s4, grid_main
        add     $s4, $s4, $s3
        # error check
        mul     $s5, $s2, $s2   # max length
        slt     $s6, $s5, $s3   # out of bounds right
        bne     $s6, $zero, error
        slt     $s6, $s4, $zero # less than zero
        bne     $s6, $zero, error
        slt     $s6, $s0, $zero
        bne     $s6, $zero, error
        slt     $s6, $s1, $zero
        bne     $s6, $zero, error
        # ----------- 
        sb      $a2, 0($s4)     # write the char
        j       safe
error:  
        li      $v0, 0
        j       done_write
safe:
        li      $v0, 1
done_write:
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

 
# Name:         init_board
# 
# fills the memory for the board with spaces
#
# Arguments:    a0: size
# Returns:      none
#
init_board:
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
        li      $s3, 32                 # ascii value of space
        move    $s0, $a0
        mul     $s0, $s0, $s0
        addi    $s0, $s0, -1
        la      $s1, grid_main          # address of the main grid
        la      $s4, grid_temp          # address of the temp grid
fill_loop:
        sb      $s3, 0($s1)
        sb      $s3, 0($s4)
        addi    $s1, $s1, 1             # 1 byte align
        addi    $s4, $s4, 1
        addi    $s0, $s0, -1
        bgez    $s0, fill_loop
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

# Name: Count Neighbors
# 
# returns n value
#
# Arguments:    a0: x coord
#               a1: y coord
#               a2: good neighbor ascii ( A or B ) (65 or 66)
# Returns:      v0: n
#
count_neigh:
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
        move    $s3, $a0        # x
        move    $s4, $a1        # y
        la      $s0, x_offset
        la      $s1, y_offset
        li      $s2, 7
        la      $s5, input_data
        lw      $s5, 0($s5)     # board size

        move    $s7, $zero
neigh_check:
        #=======================
        lw      $t0, 0($s0)
        lw      $t1, 0($s1)
        add     $t0, $t0, $s3
        add     $t1, $t1, $s4
        # mod the coords by the size of the board to enable wrap
        add     $t0, $t0, $s5   # mod the board size
        div     $t0, $s5
        mfhi    $t0
        add     $t1, $t1, $s5   # mod the board size
        div     $t1, $s5
        mfhi    $t1
        move    $a0, $t1
        move    $a1, $t0
        jal     get_val
        beq     $a2, $v0, friend_n
        j       done_n
friend_n:
        addi    $s7, $s7, 1     # if friendly, add 1
done_n:
        #=======================
	addi    $s0, $s0, 4
        addi    $s1, $s1, 4
        addi    $s2, $s2, -1
        bgez    $s2, neigh_check

        move    $v0, $s7

#--------------------------------
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


# Name: get value
# 
# returns ascii at a location
#
# Arguments:    a0: x coord
#               a1: y coord
# Returns:      v0: ascii at that location
#
get_val:
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

        move    $s0, $a0        # s0 is x
        move    $s1, $a1        # s1 is y
        la      $t0, input_data
        lw      $s2, 0($t0)     # board size
        mul     $s3, $s1, $s2   # y * board size
        add     $s3, $s3, $s0   # (y*board size) + x : index of array
        la      $s4, grid_main
        add     $s4, $s4, $s3
        lb      $v0, 0($s4)

#--------------------------------
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


# Name:         write_temp
# 
# Adds a cell to a location based on a coord
#
# Arguments:    a0: x location
#               a1: y location
#               a2: ascii for char to write
# Returns:      1 if valid location, zero otherwise
#
write_temp:
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
#-------------------------------
        move    $s0, $a0        # s0 is x
        move    $s1, $a1        # s1 is y
        la      $t0, input_data
        lw      $s2, 0($t0)     # board size
        mul     $s3, $s1, $s2   # y * board size
        add     $s3, $s3, $s0   # (y*board size) + x : index of array
        la      $s4, grid_temp
        add     $s4, $s4, $s3
        # error check
        mul     $s5, $s2, $s2   # max length
        slt     $s6, $s5, $s3   # out of bounds right
        bne     $s6, $zero, error_t
        slt     $s6, $s4, $zero # less than zero
        bne     $s6, $zero, error_t
        slt     $s6, $s0, $zero
        bne     $s6, $zero, error_t
        slt     $s6, $s1, $zero
        bne     $s6, $zero, error_t
        # ----------- 
        sb      $a2, 0($s4)     # write the char
        j       safe_t
error_t:  
        li      $v0, 0
        j       done_write_t
safe_t:
        li      $v0, 1
done_write_t:
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
