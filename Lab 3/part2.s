# Program to Count the number of 1's in a 
# 32-bit word located at InputWord

.global _start
_start:

	/* Put your code here */
	movi r2, 0			# Bit counter (SUM)
	movia r9, InputWord # Store address of InputWord -> r9
	ldw r4, (r9)		# Store value of InputWord -> r4 (INPUT)
	movi r10, 32		# Upper limit of 32-bit word
	movia r11, Answer	# Address of Answer -> r11
	
	call ONES			# Function call
	stw r2, (r11)		# Store sum into Answer
	br endiloop

endiloop: br endiloop

ONES: 
	OneCounter:
		beq r0, r10, end  	# Check if r10 = 0; loop finished
		andi r13, r4, 1		# Bitwise and operation; store into r13
		add r2, r2, r13		# Increment r8 if there 1-bit detected
		addi r10, r10, -1	# Decrement r10
		roli r4, r4, 1		# Left rotate r12
		br OneCounter
		
	end:
		ret
		
InputWord: .word 0x4a01fead

Answer: .word 0
	
	