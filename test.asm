;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Tetris ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Group No.6	LCD		8259	8254    8255
;		   (pin17) (pin18) (pin19) (pin20)
;		 	0c0h	0b0h    0a0h    090h
; WU Yang
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pin assign
;8088 system        64x128 lcd
;power ground       Vss
;+5V                VDD
;NC                 Vo
;A0                 RS
;INVERTED DT/R      R/W
;CS_LCD             E
;AD0-AD7            DB0-DB7
;A1                 CS1
;A2                 CS2
;+5V                RSTB
;NC                 VOUT
;NC                 BLA
;NC                 BLK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_base				equ 0c0h
lcd_cs1_control			equ 0c2h
lcd_cs1_data			equ 0c3h
lcd_cs2_control 		equ 0c4h
lcd_cs2_data			equ 0c5h ; LCD

i8254_base_address 		equ 0a0h ; Time generator
i8255_base_address 		equ 090h ; PPI
i8259_base_address 		equ 0b0h ; Interrupt

x_base  				equ 10111000b
y_base  				equ 01000000b

seed 					equ 10110111b
a 						equ 1101b
c 						equ 11110101b ; Random generator

stack_seg	segment at 0
top_of_stack	equ 800h
stack_seg	ends

data_seg	segment at 0
	box1			db	?
	box2			db	?
	box3			db	?
	box4			db	?
	box5			db	?
	box6			db	?
	box7			db	?
	box8			db	?
	box9			db	?
	box10			db	?
	box11			db	?
	random_seed		db	?
	random_number	db	?
	center_x		db	?
	center_y		db	?
	rev1			db	?
	rev2			db	?
	rev3			db	?
	rev4			db	?
	para1			db	?
	para2			db	?
	para3			db	?
	para4
data_seg ends

; Dummy code
dummy_code	segment at 0f800h
		org 0
dumst	label	far ;CS:IP for this label will be assigned by the linker
dummy_code ends

; Code segement
; f8000-fffff for program
code_seg	segment public 'code'
;extrn exp7_test:near
		assume cs:code_seg

;Main Program
start:
	mov ax,data_seg ;initialize DS
	mov ds,ax
	assume	ds:data_seg
	mov ax,stack_seg ;initialize SS
	mov ss,ax
	assume	ss:stack_seg
	mov sp,top_of_stack ;initialise SP

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov dx, lcd_cs1_control
	mov al, 00111111b
	out dx, al ; start lcd
	
	call check_reset
	call check_busy
	mov dx, lcd_cs1_control
	mov al, 10111001b
	out dx, al ; set x
	
	call check_busy
	mov dx, lcd_cs1_control
	mov al, 01000001b
	out dx, al ; set y343
	
	call check_busy
	mov dx, lcd_cs1_data
	mov al, 00001111b
	out dx, al ; set value
	
	
	loopend:
	nop
	jmp loopend
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	check_reset proc near
		mov dx, lcd_cs1_control
		check_reset_loop
		in al, dx
		test al, 00010000b
		jnz check_reset_loop
		ret
	check_reset endp
	
	check_busy proc near
		mov dx, lcd_cs1_control
		check_busy_loop:
		in al, dx
		test al, 10000000b
		jnz check_busy_loop
		ret
	check_busy endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Setup the Reset Vector
	org 07ff0h
	jmp dumst
	code_seg ends
end start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
