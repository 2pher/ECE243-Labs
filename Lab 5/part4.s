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
        beq     r20, r0, TIMER_ISR  # If not, ignore this interrupt
        call    KEY_ISR             # If yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # Restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # Restore stack pointer
        eret                        # Return from exception

TIMER_ISR:
		# Store onto stack
		subi	sp, sp, 24
		stw		r2, 0(sp)
		stw 	r3, 4(sp)
		stw 	r4, 8(sp)
		stw 	r5, 12(sp)
		stw 	r6, 16(sp)
		stw		r7, 20(sp)
		
		movia	r2, COUNT
		movia	r3, RUN
		movia 	r7, TIMER
		ldw		r4, 0(r2)			# r4 stores COUNT
		ldw 	r5, 0(r3)			# r5 stores RUN
		add		r6, r4, r5
		stw 	r6, 0(r2)			# Update COUNT
		
		movi 	r4, 0x1
		stwio	r4, 0(r7)			# Clear TIMER TO bit
		
		# Clear stack
		ldw 	r2, 0(sp)
		ldw 	r3, 4(sp)
		ldw 	r4, 8(sp)
		ldw 	r5, 12(sp)
		ldw 	r6, 16(sp)
		ldw 	r7, 20(sp)
		addi	sp, sp, 24
		
		br 		END_ISR
		
KEY_ISR:
		# Store onto stack
		subi	sp, sp, 28
		stw		r2, 0(sp)
		stw 	r3, 4(sp)
		stw 	r4, 8(sp)
		stw 	r5, 12(sp)
		stw		r6, 16(sp)
		stw		r7, 20(sp)
		stw		r8, 24(sp)
		
		movia	r2, RUN
		movia	r3, KEYs
		movia	r5, TIMER
		ldwio 	r4, 0xc(r3)
		
		movi 	r6, 0x1
		beq 	r4, r6, KEY_0		# Check if KEY0 was pressed
		movi 	r6, 0x2
		beq 	r4, r6, KEY_1		# Check if KEY1 was pressed
		movi 	r6, 0x4
		beq 	r4, r6, KEY_2		# Check if KEY2 was pressed
		
		br END_ISR					# Wasn't pressed

KEY_0:
		ldw 	r5, 0(r2)
		xori	r5, r5, 0x1			# Flip RUN
		stw		r5, 0(r2)			# Store back into RUN
		br		END_KEYS

KEY_1:	
		movia	r2, CURRENT_COUNTER
		ldw 	r4, 0(r2)			# Grab value of CURRENT_COUNTER
		movi 	r7, 2				# To be divided by
		
		div 	r6, r4, r7
		bgt 	r6, r0, INIT_DIV_TIMER
		mov 	r6, r4		

INIT_DIV_TIMER:
		stw 	r6, 0(r2)			# Store back into CURRENT_COUNTER
		movi 	r4, 0x1	
		stwio 	r4, 0(r5)			# Clear TO
		movi 	r4, 0x8
		stwio 	r4, 4(r5)			# Stop timer
		stwio 	r6, 8(r5) 			# Set periodlo
		srli 	r6, r6, 16
		stwio 	r6, 12(r5) 			# Set periodhi
		movi 	r6, 0x7 			# Enable START | CONT | ITO
		stwio 	r6, 4(r5)
		
		br END_KEYS

KEY_2:
		movia	r2, CURRENT_COUNTER
		ldw 	r4, 0(r2)			# Grab value of CURRENT_COUNTER
		movi 	r7, 2				# To be multiplied by
		movia 	r8, 2147483647		# Counter max value
		mul 	r6, r4, r7
		blt 	r6, r8, INIT_MUL_TIMER
		mov 	r6, r4		

INIT_MUL_TIMER:
		stw 	r6, 0(r2)			# Store back into CURRENT_COUNTER
		movi 	r4, 0x1	
		stwio 	r4, 0(r5)			# Clear TO
		movi 	r4, 0x8	
		stwio 	r4, 4(r5)			# Stop timer
		stwio 	r6, 8(r5) 			# Set periodlo
		srli 	r6, r6, 16
		stwio 	r6, 12(r5) 			# Set periodhi
		movi 	r6, 0x7 			# Enable START | CONT | ITO
		stwio 	r6, 4(r5)
		
		br END_KEYS

END_KEYS:
		movi	r4, 0xf
		stwio 	r4, 0xc(r3)			# Clear EDGE bit
		
		# Clear stack
		ldw		r2, 0(sp)
		ldw 	r3, 4(sp)
		ldw 	r4, 8(sp)
		ldw 	r5, 12(sp)
		ldw		r6, 16(sp)
		ldw		r7, 20(sp)
		ldw		r8, 24(sp)
		addi 	sp, sp, 28
		
		ret

.text
.equ TIMER, 0xFF202000
.equ COUNTER, 25000000
.equ KEYs, 0xff200050
.equ LED_BASE, 0xff200000
.global  _start
_start:
	movia sp, 0x20000		
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
	
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:     
	#DEVICE SIDE
	movia r4, TIMER
	movia r5, COUNTER
	movi r2, 0x8 
	stwio r0, 0(r4) 	# Clear TO
	stwio r2, 4(r4) 	# Stop timer
	stwio r5, 8(r4) 	# Set periodlo
	srli r5, r5, 16
	stwio r5, 12(r4) 	# Set periodhi

    stwio r0, 0(r4) 	# Clear TO
    movi r2, 0x7 		# Enable START | CONT | ITO
	stwio r2, 4(r4)
	
	# CPU SIDE
    rdctl r6, ctl3
	ori r6, r6, 1
    wrctl ctl3, r6 		# Enable ints for IRQ0/timer
	wrctl ctl0, r6 		# Enable ints globally
	ret

CONFIG_KEYS:       
	movia r2, KEYs      # Address of KEYs -> r2
	
	movi r3, 0xf     
	stwio r3, 0xc(r2)	# Reset EDGE
	stwio r3, 8(r2)		# Reset MASK

	rdctl r5, ctl3
	ori r5, r5, 2
	wrctl ctl3, r5 		# Enable ints for IRQ1/buttons
	
	movi r4, 1
	wrctl ctl0, r4

	ret


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.global	 CURRENT_COUNTER
CURRENT_COUNTER: .word	25000000

.end

