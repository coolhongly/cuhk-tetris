; Mini project

; LCD
lcd_base_address_cs1	equ 0c0h
lcd_base_address_cs2 	equ 0c0h

; Time generator
i8254_base_address 	equ 0a0h

; PPI
i8255_base_address 	equ 090h

; Interrupt
i8259_base_address 	equ 0b0h

;
x_base  equ 10111000b
y_base  equ 01000000b

; Random generator
seed equ 1011011100101101b
a equ 1101b
c equ 1011101111011011b

stack_seg segment at 0
top_of_stack equ 800h
stack_seg ends

data_seg segment at 0
	box1	db	?
	box2	db	?
	box3	db	?
	box4	db	?
	box5	db	?
	box6	db	?
	box7	db	?
	box8	db	?
	box9	db	?
	box10	db	?
	box11 	db	?
	random_seed	db	?
	random_number	db	?
	center_x	db	?
	center_y	db	?
data_seg ends

; Dummy code
dummy_code segment at 0f800h
org 0
dumst label far ;CS:IP for this label will be assigned by the linker
dummy_code ends

; Code segement
; f8000-fffff for program
code_seg segment public 'code'
;extrn exp7_test:near
assume cs:code_seg

;Main Program
start:
	mov ax,data_seg ;initialize DS
	mov ds,ax
	assume ds:data_seg
	mov ax,stack_seg ;initialize SS
	mov ss,ax
	assume ss:stack_seg
	mov sp,top_of_stack ;initialise SP

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;call 8254_init not used
	mov random_seed, seed
	
	call 8255_init ; Done
	call 8259_init
	
	stage0:	; Game stage
		call LCD_init ; Done

		stage1:	; Life stage
			call random_generator ; Done
			call box_init ; Done
			call tetris_init ; 

			stage2: ; Drop stage
				call delay
				call if_dead ; al = 1 dead
				
				; dead
				cmp al, 0
				jnz dead
				
				call collision ; al = 0 if no collision, al != if collision
				
				; collision
				cmp al, 0
				jnz collision_happen
				
				call LCD_erase
				call tetris_drop
				call LCD_print
				jmp collision_happen_skip
				
				collision_happen:
					call LCD_elminate
					call LCD_drop
				collision_happen_skip:

			jmp stage2
		jmp stage1
		
		dead:
		
	jmp stage0

	loopend:
	nop
	jmp loopend
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	8254_init proc near
; 		
; 		ret
; 	8254_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	8255_init proc near
		mov dx,i8255_base_address
		mov al,1000000b
		inc dx
		inc dx
		inc dx ; Point to command register
		out dx,al
		ret
	8255_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	8259_init proc near
	
		ret
	8259_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	box_init proc near
		mov box1, 00101001b
		mov box2, 00000001b
		mov box3, 00001001b
		mov box4, 00101000b
		mov box5, 00000000b
		mov box6, 00001000b
		mov box7, 00010000b
		mov box8, 00101101b
		mov box9, 00000101b
	   mov box10, 00001101b
	   mov box11, 00000110b
		ret
	box_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	collision proc near
		mov cx, 11
		collision_loop:
			mov al, box1+11-cl
			test box1+11-cl, 10000000b
			jz collision_test_skip
			
			; Put signed x coordinate into ah
			and al, 00111000b
			ror al, 1
			ror al, 1
			ror al, 1 
			mov ah, al
			
			; Put signed y coordinate into al
			and al, 00000111b

			call collision_test ;(ifcollision:al is not equal to 0) func(signed x:ah, signed y:al)
			cmp al,0
			jnz collision_yes
			collision_test_skip
		loop collision_loop
		mov al, 0 ;set al to be 0 if no collision
		collision_yes: 
		ret
	collision endp
	
	collision_test proc near
		call coordinate_relative_to_absolute ;Done
		; next box
		dec al
		call coordinate_absolute_to_LCD ; (x:ah, y:al, cs:bl) func(x:ah, y:al)
		call LCD_read ;(result:al, test:ah) func(x:ah, y:al, cs:bl)
		and al, ah ; test if collision
		ret
	collision_test endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call coordinate_absolute_to_LCD ; (x:ah, y:al, cs:bl) func(x:ah, y:al)
		; x
		mul ah, 4
		dec ah
		
		; y
		mul al, 4
		dec al

		; in cs1 or cs2
		cmp y, 63
		jg coordinate_absolute_to_LCD_cs2 ; is in cs2
			mov bl, 63d
			sub bl, al
			mov al, bl
			mov bl, 0
		jmp coordinate_absolute_to_LCD_cs2_skip
		coordinate_absolute_to_LCD_cs2:
			sub al, 64d
			mov bl, 1d
		coordinate_absolute_to_LCD_cs2_skip:
		ret
	coordinate_absolute_to_LCD endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	coordinate_relative_to_absolute proc near
		; translate x
		mov bh, center_x 
		test ah, 00000100b
		jz coordinate_relative_to_absolute_x_add
		sub bh, ah
		mov ah, bh
		jmp coordinate_relative_to_absolute_x_add_skip
		coordinate_relative_to_absolute_x_add:
		add ah, bh
		coordinate_relative_to_absolute_x_add_skip:
		
		; translate y
		mov bl, center_y
		test al, 00000100b
		jz coordinate_relative_to_absolute_y_add
		sub bl, al
		mov al, bl
		jmp coordinate_relative_to_absolute_y_add_skip
		coordinate_relative_to_absolute_y_add:
		add al, bl
		coordinate_relative_to_absolute_y_add_skip:
		ret
	coordinate_relative_to_LCD endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	delay proc near
	
		ret
	collision endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_clean proc near
		mov dx, i8255_base_address + 1 ; PPI PA
		mov al, 000h ; Reset signal
		mov dx, al
		
		; Reset cs1
		mov dx, lcd_base_address_cs1;
		LCD_clean_wait_cs1: ; Wait for LCD to reset
			in al, dx
			test al, 00010000b
			jnz LCD_clean_wait_cs1
			
		; Reset cs2
		mov dx, lcd_base_address_cs2;
		LCD_clean_wait_cs2 ; Wait for LCD to reset
			in al, dx
			test al, 00010000b
			jnz LCD_clean_wait_cs2
		
		ret
	LCD_clean endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_drop proc near
	
		ret
	LCD_drop endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_elminate proc near
	
		ret
	LCD_elminate endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_init proc near
		call LCD_clean
		call print_border
		ret
	LCD_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_read proc near ; (result:al, test:ah) func(x:ah, y:al, cs:bl)
		or al, 01000000b ; set y address
		mov bh, al ; store y address, y is in bh
		mov al, ah
		mov ah, 0
		mov cx, 8
		div cl ; x is in al, reminder in ah, cs in bl
		test bl, 00000001b ; cs1 or cs2
		jnz LCD_read_cs2
		mov dx, lcd_base_address_cs1
		jmp LCD_read_cs2_skip
		LCD_read_cs2:
		mov dx, lcd_base_address_cs2
		LCD_read_cs2_skip:
		out dx, al
		out dx, bh
		in al, dx ; get data in al
		
		; get test bit
		push cx
		mov cx, ah
		mov ah, 0
		LCD_read_loop:
			inc ah
		loop LCD_read_loop
		pop cx
		ret
	LCD_read endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_update proc near
	
		ret
	LCD_update endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	if_dead proc near
	
		ret
	if_dead endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	print_border proc near
		; Print row
		mov bh, x_base + 6 ; set x
		mov bl, y_base ; set y
		mov al, 001h ; set value
		
		; Print cs1
		mov dx, lcd_base_address_cs1
		call print_boarder_row
		
		; Print cs2
		mov dx, lcd_base_address_cs2
		call print_boarder_row
		
		; Print column (dx is lcd_base_address_cs2 + 1 now)
		; Print cs2
		mov bh, x_base + 6 ; set x
		mov bl, y_base ; set y
		mov al, 0ffh ; set value
		mov dx, lcd_base_address_cs2
		call print_boarder_column
		ret
	print_border endp
	
	print_boarder_row proc near
		out dx, bh ; set x
		out dx, bl ; set y
		mov cx, 64 ; set loop length
		inc dx ; set dx to be lcd_base_address_* + 1
		print_boarder_row_loop:
			out dx, al ; output value
		loop print_boarder_row_loop
		ret
	print_boarder_row endp
	
	print_boarder_column proc near
		mov cx, 8 ; set loop length
		print_boarder_column_loop:
			out dx, bh ; set x
			out dx, bl ; set y
			inc dx ; set dx to be lcd_base_address_* + 1
			out dx, al ; output value
			inc bh ; x += 1
			dec dx ; set dx to be lcd_base_address_*
		loop print_boarder_column_loop
		ret
	print_boarder_row endp
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	random_generator proc near
		; Using formular x1 = ( x0 * a + c ) MOD 2^16 to generate random seed
		mov ax, random_seed 
		mul ax, a
		adc ax, c
		mov random_seed, ax
		
		; Get remainder
		mov cx, 7
		div cx
		mov random_number, dl
		ret
	random_generator endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_init proc near

		ret
	tetris_init endp	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_drop proc near
	
		ret
	tetris_drop endp	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Setup the Reset Vector
	org 07ff0h
	jmp dumst
	code_seg ends
end start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
