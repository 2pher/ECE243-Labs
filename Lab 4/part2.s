.global _start
_start:
	movia r8, 0xff200000	# LEDs
	movia r9, 0xff200050 	# KEYS
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
	stwio r2, 12(r9)
	br counter
	
Delay:
	movia r6, 0x5F5E10	# 0.25s counter	
	internal_counter:
			beq r6, r0, exit 
			subi r6, r6, 1 #decrement
			br internal_counter
			
	exit:
		ret
	
	