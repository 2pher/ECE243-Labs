.global _start
_start: movia r8, result 	# the address of the result -> r8
	ldw r9,4(r8)			# the number of numbers is in r9; address of r8+4 = n	
	movia r10, numbers  	# the address of the numbers is in r10

/* keep largest number so far in r11 */

	ldw	r11,(r10)			# 4 goes into r11; current number
	
/* loop to search for biggest number */

loop: subi r9, r9, 1		# subtract 1 from r9 each loop
	ble r9, r0, finished	# go to finished if r9 = 0
	addi r10, r10, 4   		# access new number in the list each iteration (+4) 
	ldw  r12, (r10)  		# load the next number into r12; number to be compared
	ble  r11, r12, loop 	# if the current lowest is still the lowest, go to loop
	mov r11, r12   			# otherwise new number is biggest, put it into r11
	br loop

finished: stw r11,(r8)    	# store the answer into result
iloop: br iloop

result: .word 0
n:	.word 15
numbers: .word 4,5,3,6
	.word 1,8,2,9
	.word 14,22,18,30
	.word 19,21,13
	
	