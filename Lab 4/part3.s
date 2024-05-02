.global _start
_start:
	movia r8, 0xff200000	# LEDs
	movia r9, 0xff200050 	# KEYS
	movia r6, 0xff202000	# Timer
	movia r11, 0xf
	
initialize_counter:
	movi r10, 255			# Counter
	stwio r10, 0(r8)

counter:
	ldwio r2, 12(r9)				# Edge capture of KEYS
	andi r2, r2, 0xf				# Check if any button was pressed
	bgtu r2, r0, pressed			# If so, exit loop to pressed
	beq r10, r0, initialize_counter # Restart counter if = 0
	call Delay
	subi r10, r10, 1	

display_leds:
	stwio r10, 0(r8)				# Store current counter to LEDs
	br counter						# Continue counting

pressed:
	stwio r11, 12(r9)

idle_timer:
	ldwio r2, 12(r9)
	andi r2, r2, 0xf
	bgtu r2, r0, press_to_start
	br idle_timer

press_to_start:
	stwio r11, 12(r9)
	br counter
	
Delay:
	internal_counter:
		movia r4, 0x8			# Tell timer we want to stop
		stwio r4, 4(r6)			# Stop timer
		stwio r0, 0(r6)			# Clear TO bit
		movia r4, 0x5F5E10		# Initialize Counter
		srli r5, r4, 16
		andi r4, r4, 0xffff
		stwio r5, 0x8(r4)
		stwio r4, 0xc(r4) 
		movia r4, 0x4			# Tell timer we want to start
		stwio r4, 4(r6)			# Start timer

	check_bit:
		ldwio r4, 0(r6) 		# Load TO bit
		andi r4, r4, 0x1		# Check TO bit is 1
		beq r4, r0, check_bit
		ret
	
	