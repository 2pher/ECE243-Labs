.text # The numbers in memory are executable instructions
.global _start
_start:

/* r13 should contain the grade of the person 
   with the student number, -1 if not found */
   
/* r10 has the student number being searched */
movia r10, 718293 		# r10 is where you put the student number being searched for

/* Your code goes here */
movia r8, Snumbers		# address of Snumbers -> r8
movia r9, Grades		# address of Grades   -> r9
movia r12, result		# address of result   -> r12

loop: ldw r11, (r8) 		# load number in list into r11
	ldw r13, (r9) 			# load corresponding grade from student number
	beq r0, r11, dne 		# reached end of list; student number not found
	beq r10, r11, finished  # check if student number equal to one being searched for
	addi r8, r8, 4			# traverse student number list
	addi r9, r9, 4			# traverse grades list
	br loop					# run loop from the start
	
dne: movi r13, -1			# student number not found, assign -1 to r13

finished: stw r13, (r12)	# assign value in r13 -> result 

iloop: br iloop				# end of program

.data # the numbers in memory that are the data

/* result should hold the grade of the student number 
   put into r10, or -1 if the student number isn’t found */

result: .word 0

/* Snumbers is the list terminated by a zero of the student numbers */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
.word 265133, 68943, 718293, 315950, 785519
.word 982966, 345018, 220809, 369328, 935042
.word 467872, 887795, 681936, 0

/* Grades is the corresponding list with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
.word 66, 95, 91, 91, 99, 76, 68
.word 69, 93, 90, 72