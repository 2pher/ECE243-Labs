.global _start
_start:
	.equ LEDs, 0xFF200000
	movia r10, LEDs 		# r23 holds LED address
	movia r9, 0xff200050 	# KEYS
	movi r3, 0				# KEY0 indicator
	movi r4, 0				# KEY1 indicator
	movi r5, 0				# KEY2 indicator
	movi r6, 0				# KEY3 indicator
	movi r7, 0				# Counter
	movi r8, 15 			# Upper limit for LEDs
	movi r11, 1				# Lower limit for LEDs

check_key:
	ldwio r2, 0(r9)			# Store value of LEDs into r2
	andi r3, r2, 0x1		# Check if KEY0 is pressed
	andi r4, r2, 0x2		# Check if KEY1 is pressed
	andi r5, r2, 0x4		# Check if KEY2 is pressed
	andi r6, r2, 0x8		# Check if KEY3 is pressed
	br update_leds			# If pressed, update on the LEDs
	
update_leds:
	bne r3, r0, pressed_key0
	bne r4, r0, pressed_key1
	bne r5, r0, pressed_key2
	bne r6, r0, pressed_key3
	br check_key

pressed_key0:
	ldwio r2, 0(r9)
	andi r3, r2, 0x1
	bne r3, r0, pressed_key0
	movi r7, 1
	br set_leds

pressed_key1:
	ldwio r2, 0(r9)
	andi r4, r2, 0x2
	bne r4, r0, pressed_key1
	addi r7, r7, 1
	br set_leds
	
pressed_key2:
	ldwio r2, 0(r9)
	andi r5, r2, 0x4
	bne r5, r0, pressed_key2
	ldwio r2, 0(r10)
	beq r2, r0, reset_to_1
	beq r2, r11, set_leds
	addi r7, r7, -1
	br set_leds
	
pressed_key3:
	ldwio r2, 0(r9)
	andi r5, r2, 0x8
	bne r5, r0, pressed_key3
	movi r7, 0
	stwio r0, 0(r10)
	br check_key
	
reset_to_1:
	addi r7, r7, 1

set_leds:
	stwio r7, 0(r10)
	br check_key