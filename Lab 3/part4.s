.text
/* Program to Count the number of 1’s and 
Zeroes in a sequence of 32-bit words, and 
determines the largest of each */

.global _start
_start:

	/* Your code here  */
	movia r8, LargestOnes	# Store address of LargestOnes -> r8
	movia r9, LargestZeroes	# Store address of LargestZeroes -> r9
	movia r14, TEST_NUM		# Store address of InputWord -> r13
	
	movi r2, 0				# Bit counter (SUM)
	movi r11, 0
	movi r12, 0
	movi r10, 32			# Upper limit of 32-bit word
	movia r15, 0xfffffff 	# For XOR
	
	.equ LEDs, 0xFF200000
	movia r23, LEDs 		
	
WordLoop:
    ldw r4, (r14)           		# Store value of InputWord -> r4 (INPUT)
    beq r4, r0, endiloop    		# If InputWord = 0, list done
    call ONES               		# Function call
	
	# Built in delay
	movi r5, 500
	count1:
		addi r5, r5, -1
		bgeu r0, r5, count1

    bgeu r2, r11, ULargestOnes 		# Branch if current count is greater or equal
	br WordLoop2

ULargestOnes:
    mov r11, r2              		# Update r11 with the current count
	stwio r2, (r23)					# Display on LEDs
	
WordLoop2:
    xor r4, r4, r15         		# Flip bits to count for zeroes
    call ONES              			# Function call
	
	# Built in delay
	movi r5, 500
	count2:
		addi r5, r5, -1
		bgeu r0, r5, count2

    ldw r4, (r14)           		# Restore r4 to original value
    addi r14, r14, 4        		# Increment to next word
    bgeu r2, r12, ULargestZeroes 	# Branch if current count is greater or equal
    br WordLoop

ULargestZeroes:
    mov r12, r2             		# Update r12 with the current count
	stwio r2, (r23)					# Display on LEDs

endiloop: br endiloop

ONES: 
	movi r2, 0				# Bit counter (SUM)
	movi r10, 32			# Upper limit of 32-bit word
	
	OneCounter:
		beq r0, r10, end  	# Check if r10 = 0; loop finished
		andi r13, r4, 1		# Bitwise and operation; store into r13
		add r2, r2, r13		# Increment r8 if there 1-bit detected
		addi r10, r10, -1	# Decrement r10
		roli r4, r4, 1		# Left rotate r4
		br OneCounter
		
	end:
		ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0