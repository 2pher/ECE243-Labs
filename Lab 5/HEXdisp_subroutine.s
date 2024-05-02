/*    Subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
 *
 *    Parameters: the low-order 4 bits of register r4 contain the digit to be displayed
		  if bit 4 of r4 is a one, then the display should be blanked
 *    		  the low order 3 bits of r5 say which HEX display number 0-5 to put the digit on
 *    Returns: r2 = bit patterm that is written to HEX display
 */

.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

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

#Display it on the target HEX display
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
			
