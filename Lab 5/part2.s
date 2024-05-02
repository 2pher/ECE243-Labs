/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
        # Save registers on the stack (et, ra, ea, others as needed)
        subi	sp, sp, 16          # Make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)

        rdctl   et, ctl4            # Read exception type
        beq     et, r0, SKIP_EA_DEC # Not external?
        subi    ea, ea, 4           # Decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # Check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # If not, ignore this interrupt
        call    KEY_ISR             # If yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # Restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # Restore stack pointer
        eret                        # Return from exception

KEY_ISR:
        subi 	sp, sp, 48
        stw 	r2, 0(sp)
        stw 	r3, 4(sp)
        stw 	r4, 8(sp)
        stw 	r5, 12(sp)
        stw 	r6, 16(sp)
        stw 	r7, 20(sp)
        stw 	r8, 24(sp)
        stw 	r9, 28(sp)
        stw 	r10, 32(sp)
        stw 	r11, 36(sp)
        stw 	r12, 40(sp)
        stw 	r13, 44(sp)
		stw		ra,  48(sp)
		
		movi	r4, 0
		movi	r5, 0

		.equ KEYs, 0xff200050
		.equ HEX_BASE1, 0xff200020
		movia 	r2, KEYs
		movia 	r3, HEX_BASE1

		movi 	r6, 0x1
		movi 	r7, 0x2
		movi 	r8, 0x4
		movi 	r9, 0x8
		
		movia	r10, 0xFF 
		movia 	r11, 0xFF00
		movia 	r12, 0xFF0000
		movia 	r13, 0xFF000000
		
		ldwio 	r4, 12(r2)			# Read edge cap register -> r4
		ldwio 	r5, 0(r3)			# Read current HEX display value
		
		beq 	r4, r6, KEY0
		beq 	r4, r7, KEY1
		beq 	r4, r8, KEY2
		beq 	r4, r9, KEY3
	
KEY0:
	and 	r5, r5, r10			# Isolate value for HEX0
	beq 	r5, r0, DISPLAY_HEX0
	movi 	r4, 0x10
	movi 	r5, 0
	call	HEX_DISP
	br		END_HEX_ISR
		
		
DISPLAY_HEX0:
	movi	r4, 0
	movi	r5, 0
	call	HEX_DISP
	br		END_HEX_ISR
		
KEY1:
	and 	r5, r5, r11			# Isolate value for HEX1
	beq 	r5, r0, DISPLAY_HEX1
	movi 	r4, 0x10
	movi 	r5, 1
	call	HEX_DISP
	br		END_HEX_ISR
	
DISPLAY_HEX1:
	movi	r4, 1
	movi	r5, 1
	call	HEX_DISP
	br		END_HEX_ISR

KEY2:
	and 	r5, r5, r12			# Isolate value for HEX2
	beq 	r5, r0, DISPLAY_HEX2
	movi 	r4, 0x10
	movi 	r5, 2
	call	HEX_DISP
	br		END_HEX_ISR
	
DISPLAY_HEX2:
	movi	r4, 2
	movi	r5, 2
	call	HEX_DISP
	br		END_HEX_ISR
	
KEY3: 
	and 	r5, r5, r13			# Isolate value for HEX3
	beq 	r5, r0, DISPLAY_HEX3
	movi 	r4, 0x10
	movi 	r5, 3
	call	HEX_DISP
	br		END_HEX_ISR

DISPLAY_HEX3:
	movi	r4, 3
	movi	r5, 3
	call	HEX_DISP
	br		END_HEX_ISR
	
END_HEX_ISR:
	movia 	r2, KEYs	
	movi	r4, 0xF
	stwio	r4, 12(r2)
	
       ldw 	r2, 0(sp)
       ldw 	r3, 4(sp)
       ldw 	r4, 8(sp)
       ldw 	r5, 12(sp)
       ldw 	r6, 16(sp)
       ldw 	r7, 20(sp)
       ldw 	r8, 24(sp)
       ldw 	r9, 28(sp)
       ldw 	r10, 32(sp)
       ldw 	r11, 36(sp)
       ldw 	r12, 40(sp)
       ldw 	r13, 44(sp)
	   ldw		ra,  48(sp)
		
	addi	sp, sp, 48
	ret

/*********************************************************************************
 * Set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start
_start:

	.equ KEYs, 0xff200050
	.equ HEX_BASE1, 0xff200020
	
	movia 	sp, 0x20000	# Initialize sp (interrupt service routine)
	movia 	r2, KEYs	# Address of KEYs -> r2
    movi 	r4, 0xf		# Need to affect bit 0 using r4 of several registers!
	
    stwio 	r4, 0xC(r2) # Clears the edge capture bit for KEY0 if it was on, writing into the edge capture register
	stwio 	r4, 8(r2)	# Turn on the interrupt mask register bit 0 for KEY 0 so that this causes
	  					# an interrupt from the KEYs to go to the processor when button released
						
    movi 	r5, 0x2		# Need to turn on bit 1 below
    wrctl 	ctl3, r5 	# ctl3 also called ienable reg - bit 1 enables interupts for IRQ1->buttons
    wrctl 	ctl0, r4 	# ctl 0 also called status reg - bit 0 is Proc Interrupt Enable (PIE) bit; 
	  					# bit 1 is the User/Supervisor bit = 0 means supervisor

IDLE:   br  IDLE

# NOTE:
# r4 : 4-bit value to be displayed, blank by turning on bit-4 (e.g: 0x10)
# r5 : Controls which hex display HEX0-HEX6 to turn on

HEX_DISP:   movia	r8, BIT_CODES		# Starting address of the bit codes
	    andi	 r6, r4, 0x10			# Get bit 4 of input (r4) -> r6
	    beq		 r6, r0, not_blank 		# Check if 4th bit isn't 1; then hex display is ON!
	    mov      r2, r0					# 4th bit is 1; load 0 -> r2
	    br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   	# Confirm r4's 4-bit is 0
            add      r4, r4, r8         # Add the offset to the bit codes
            ldb      r2, 0(r4)          # Index into the bit codes

# Display it on the target HEX display
DO_DISP:    
			movia    r8, HEX_BASE1		# Load address of HEX_BASE1 -> r8
			movi     r6,  4				# Store 4 -> r6
			blt      r5, r6, FIRST_SET  # Check if HEX display chosen is in HEX_BASE1/HEX_BASE2
			sub      r5, r5, r6         # If HEX4 or HEX5, we need to adjust the shift
			addi     r8, r8, 0x0010     # Adjust address to HEX_BASE2
FIRST_SET:
			slli     r5, r5, 3          # Hex*8 shift is needed
			addi     r7, r0, 0xff       # Create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
			sll      r4, r2, r5     	# Shift the hex code we want to write
			ldwio    r5, 0(r8)          # read current value       
			and      r5, r5, r7         # AND it with the mask to clear the target hex
			or       r5, r5, r4	        # OR with the hex code
			stwio    r5, 0(r8)		    # Store back
END:			
			ret
			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			
