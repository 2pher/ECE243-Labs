.text
/* Program to Count the number of 1’s and Zeroes in a sequence of 32-bit words,
and determines the largest of each */
.global _start
_start:
/* Your code here */

movia r8, LargestOnes  #store addresses into r8, r9, r13
movia r9, LargestZeroes
movia r13, TEST_NUM

mov r14, r0 #initialize some values to zero for simulation purposes
mov r17, r0
mov r2, r0
mov r4, r0

movia r15, 0xffffffff #1111111... value for xor operation

WordLoop: 
		ldw r4, 0(r13) #load a word into r4 as an input to ONES
		beq r4, r0, endiloop #if reached last word, exit
		addi r13, r13, 4 #increment address of TEST_NUM
		
		call ONES #call the function to count ones
		
		bgeu r2, r14, UpdateLargestOnes #if output is greater than previous word output, branch
WordLoopTwo:
			xor r4, r4, r15 #xor input word with 1111.... inverts ones and zeroes
			call ONES #call the function to count ones (now zeroes)
			bgeu r2, r17, UpdateLargestZeroes #if output is greater than previous word output, branch
		
			br WordLoop
		
UpdateLargestOnes:
				stw r2, 0(r8) #store new result into LargestOnes and r14
				mov r14, r2
				br WordLoopTwo
				
UpdateLargestZeroes:
					stw r2, 0(r9) #store new result into LargestZeroes and r17
					mov r17, r2
					br WordLoop
				
endiloop:

		.equ LEDs, 0xFF200000
		movia r23, LEDs
		ldw r19, 0(r8) #get largestOnes into r19
		stwio r19, 0(r23) #display largestOnes on LED
		
		
		call DELAY #delay
		
		.equ LEDs, 0xFF200000
		movia r23, LEDs
		ldw r19, 0(r9) #get largestZeroes into r19
		stwio r19, 0(r23) #display largestOnes on LED
		
		call DELAY #delay
		
		br endiloop

#function ONES
ONES: 
	#ONES needs these values 
	mov r12, r0 #puts 0 into r12 (sum)
	addi r7, r0, 1 #puts 1 into r7
	mov r10, r4 #takes input from r4 into r10

	OnesCounter: 
				beq r10, r0, Done #if r10 is 0, it is done
				andi r11, r10, 0x1 #r11 becomes 1 or 0 based on LSD
				beq r11, r7, Sum #if LSD is 1 go to sum
				srli r10, r10, 1 #shift digits to right by 1
				br OnesCounter

	Sum: 
		addi r12, r12, 1 #increments sum by 1
		srli r10, r10, 1 #shift digits to right by 1
		br OnesCounter

	Done:
		mov r2, r12 #takes output r12, moves into r2
		ret
		
#function DELAY
DELAY:
	movia r18, 0x000FFFFF
	
	Counter:
			beq r18, r0, Exit
			subi r18, r18, 1
			br Counter
			
	Exit:
		ret

.data
TEST_NUM: .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
.word 0 # end of list
LargestOnes: .word 0
LargestZeroes: .word 0
