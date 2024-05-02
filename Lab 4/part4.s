.global _start
_start:
	movia r8, 0xff200000	# LEDs
	movia r9, 0xff200050 	# KEYS
	
	movi r3, 1 #need value later
	movi r6, 0x63 #99
	
	br initialize_counter
	
previous_initialize_counter:
							addi r10, r10, 0x80 #add 128(10)
							
							andi r12, r10, 0x7f 
							sub r10, r10, r12
							
							stwio r10, 0(r8)
							br counter
							
initialize_counter:
	movi r10, 0			# hundredths counter
	stwio r10, 0(r8)

counter:
	ldwio r2, 12(r9)				# Edge capture of KEYS
	andi r2, r2, 0xf				# Check if any button was pressed
	bgtu r2, r0, pressed			# If so, exit loop to pressed
	beq r10, r6, previous_initialize_counter # Restart hundredths counter if = 99(10) = 63(16)
	call Delay
	addi r10, r10, 1	

display_leds:
	stwio r10, 0(r8)				# Store current counter to LEDs
	br counter						# Continue counting

pressed:
	stwio r2, 12(r9)

idle_timer:
	ldwio r2, 12(r9)
	andi r2, r2, 0xf
	bgtu r2, r0, press_to_start
	br idle_timer

press_to_start:
	stwio r2, 12(r9)
	br counter
	
Delay:
	movia r4, 0xff202000 #timer address
	movi r5, 0x8 #stop bit stored in r5
	stwio r5, 4(r4) #stop the timer
	stwio r0, 0(r4) #clear TO bit
	movia r5, 0xF
	srli r17, r5, 16
	andi r5, r5, 0xFFFF
	stwio r17, 0x8(r4)
	stwio r5, 0xc(r4)
	
	movi r5, 0x4 #start bit stored in r5
	stwio r5, 4(r4) #start timer

	delayLoop:
			ldwio r5, 0(r4) #load TO bit
			andi r5, r5, 1 #check if TO bit is 1
			beq r5, r0, delayLoop
	
	beq r5, r3, exit
	exit:
		ret
	
	