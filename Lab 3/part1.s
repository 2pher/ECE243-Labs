# Program to Count the number of 1's in a 
# 32-bit word located at InputWord

.global _start
_start:

	/* Put your code here */
	movi r8, 0			# Bit counter 
	movia r9, InputWord # Address
	ldw r12, (r9)		# Store value of InputWord -> r12
	movi r10, 32		# Upper limit of 32-bit word
	movia r11, Answer	# Address of Answer -> r11
	
loop: beq r0, r10, end  # Check if r10 = 0; loop finished
	andi r13, r12, 1	# Bitwise and operation; store into r13
	add r8, r8, r13		# Increment r8 if there 1-bit detected
	addi r10, r10, -1	# Decrement r10
	roli r12, r12, 1	# Left rotate r12
	br loop

end: stw r8, (r11)		# Store sum into Answer adress

endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	