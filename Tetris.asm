;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Tetris ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Group No.6	LCD		8259	8254    8255
;		   (pin17) (pin18) (pin19) (pin20)
;		 	0c0h	0b0h    0a0h    090h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_base				equ 0c0h
lcd_cs1_control			equ 0c2h
lcd_cs1_data			equ 0c3h
lcd_cs2_control 		equ 0c4h
lcd_cs2_data			equ 0c5h ; LCD

i8255_base_address 		equ 090h ; PPI
i8259_base_address 		equ 0b0h ; Interrupt

x_base  				equ 10111000b
y_base  				equ 01000000b

seed 					equ 1011011110000010b
a 						equ 1101b
c 						equ 1111010100110101b ; Random generator

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
	
	nbox1			db	?
	nbox2			db	?
	nbox3			db	?
	nbox4			db	?
	nbox5			db	?
	nbox6			db	?
	nbox7			db	?
	nbox8			db	?
	nbox9			db	?
	nbox10			db	?
	nbox11			db	?
	
	row1			dw	?
	row2			dw	?
	row3			dw	?
	row4			dw	?
	row5			dw	?
	row6			dw	?
	row7			dw	?
	row8			dw	?
	row9			dw	?
	row10			dw	?
	row11			dw	?
	row12			dw	?
	row13			dw	?
	row14			dw	?
	row15			dw	?
	row16			dw	?
	row17			dw	?
	row18			dw	?
	row19			dw	?
	row20			dw	?
	random_seed		dw	?
	random_number	dw	?
	
	center_x		db	?
	center_y		db	?
	
	count			db  ?
	count_max		db  ?
	
	tmp				db	?
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov random_seed, seed
	
	call 8259_init
	call 8255_init ; Done
	
	stage0:	; Game stage
		call LCD_init ; Done

		stage1:	; Life stage
			call random_generator ; Done
			call box_init ; Done
			call tetris_init ; 

			stage2: ; Drop stage
				 call delay
				 call dead ; al = 1 dead
				
				 dead
				 cmp al, 0
				 jnz dead
				
				 call collision ; Done
				 mov al, bl ; Done bl: collision 1, no collision 0
				 
				 test al, al
				 jnz collision_happen
				
				 call LCD_update ; Done
				 jmp collision_not_happen
				
				 collision_happen:
					 call LCD_elminate
					 call LCD_drop
				 collision_not_happen:

			 jmp stage2
		 jmp stage1
		
		 dead:
		
	 jmp stage0

	loopend:
	nop
	jmp loopend
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	8255_init proc near
		mov dx,i8255_base_address
		mov al,1000000b
		inc dx
		inc dx
		inc dx ; Point to command register
		out dx,al
		ret
	8255_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	8259_init proc near
		push dx
		push cx
		push ax
		
; set ICW1
		mov     dx,i8259_base_address       ;point to ICW1
		mov     al,00010011b        ;ICW4 needed,single,edge trigger
		out     dx,al
; set ICW2
		inc     dx                       ;point to ICW2
		mov     al,00010000b        ;base address=08h
		out     dx,al
; set ICW4
		mov     al,00000011b        ;8088 mode,auto EOI
		out     dx,al
;setup interrupt vector table
		mov     ax,0
		mov     es,ax               ;ES points to low memory
		mov     di,40h              ;offset of entry for type code 08h
		
		mov     ax,offset int_service_0
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_1
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_2
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_3
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_4
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_5
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_6
		stosw
		mov     ax,cs
		stosw
		mov     ax,offset int_service_7
		stosw
		mov     ax,cs
		stosw
      
		pop ax
		pop cx
		pop dx
		ret
	8259_init endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	check_reset proc near
		mov dx, lcd_cs1_control
		check_reset_loop
		in al, dx
		test al, 00010000b
		jnz check_reset_loop
		ret
	check_reset endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	check_busy proc near
		mov dx, lcd_cs1_control
		check_busy_loop:
		in al, dx
		test al, 10000000b
		jnz check_busy_loop
		ret
	check_busy endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	collision proc near
		push dx
		push cx
		push ax

		mov cx, 11
		collision_loop:
			mov al, DS:[box1+cx-1]
			test al, 01000000b
			jz collision_test_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			cmp al, 1
			jl collision_end0
			cmp al, 40
			jg collision_end0
			cmp ah, 1
			jl collision_end0
			cmp ah, 80
			jg collision_end0
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_read
			mov al, bl ; bl: exist 1, not exist 0 
			
			test al, al
			jnz collision_yes
			collision_test_skip:
			loop collision_loop
		collision_yes: 
			mov bl, al ; bl: collision 1, no collision 0
			jmp collision_end0_skip
		collision_end0:
			mov bl, 1
		collision_end0_skip: nop
		
		pop ax
		pop cs
		pop dx
		ret
	collision endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	coordinate_absolute_to_LCD proc near;
		push dx
		push cx
		push ax
		
		; bh: absolute x coordinate
		; bl: absolute y coordinate
		
		mov al, bh
		mov cl, 4
		mul cl
		dec al
		mov cl, 8
		div cl
		cmp ah, 4
		jl coordinate_absolute_to_LCD_l
		or al, 00001000b
		coordinate_absolute_to_LCD_l: nop
		mov bh, al ; store tmp x in bh
		
		mov al, bl
		mov cl, 4
		mul cl
		dec al
		cmp al, 64
		jg coordinate_absolute_to_LCD_cs2
		mov bl, 63
		sub bl, al
		jmp coordinate_absolute_to_LCD_cs1
		coordinate_absolute_to_LCD_cs2:
		mov bl, al
		sub bl, 64
		or bh, 00010000b
		coordinate_absolute_to_LCD_cs1:
		
		; bh: LCD x coordinate + cs + m or l
		; bl: LCD y coordinate
		
		pop ax
		pop cx
		pop dx
		ret
	coordinate_absolute_to_LCD endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	coordinate_relative_to_absolute proc near
		push dx
		push cx
		push ax
		
		; bh: relative x coordinate
		; bl: relative y coordinate
		
		; translate x
		mov ah, center_x 
		test bh, 00000100b
		jz coordinate_relative_to_absolute_x_add
		sub ah, bh
		jmp coordinate_relative_to_absolute_x_add_skip
		coordinate_relative_to_absolute_x_add:
		add ah, bh
		coordinate_relative_to_absolute_x_add_skip:
		
		; translate y
		mov al, center_y
		test bl, 00000100b
		jz coordinate_relative_to_absolute_y_add
		sub al, bl
		jmp coordinate_relative_to_absolute_y_add_skip
		coordinate_relative_to_absolute_y_add:
		add al, bl
		coordinate_relative_to_absolute_y_add_skip:
		
		mov bh, ah
		mov bl, al
		
		pop ax
		pop cx
		pop dx
		ret
	coordinate_relative_to_absolute endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	delay proc near
	
		ret
	delay endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dead proc near
	
		ret
	dead endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_0 proc near
		cli
		push dx
		push cx
		push ax
		
		mov nbox1, 00101001b
		mov nbox2, 00000001b
		mov nbox3, 00001001b
		mov nbox4, 00101000b
		mov nbox5, 00000000b
		mov nbox6, 00001000b
		mov nbox7, 00010000b
		mov nbox8, 00101101b
		mov nbox9, 00000101b
	   mov nbox10, 00001101b
	   mov nbox11, 00000110b
		
		mov al, 11000000b
		mov ah, 01000000b
		cmp random_number, 0
		je int_service_0_I
		cmp random_number, 1
		je int_service_0_T
		cmp random_number, 2
		je int_service_0_L
		cmp random_number, 3
		je int_service_0_J
		cmp random_number, 4
		je int_service_0_Z
		cmp random_number, 5
		je int_service_0_S
		cmp random_number, 6
		je int_service_0_O
		
		int_service_0_I:
			cmp count, 1
			je int_service_0_I_1
			cmp count, 2
			je int_service_0_I_2
			int_service_0_I_1:
				or nbox2, ah
				or nbox5, ah
				or nbox9, ah
				or nbox11, al
				jmp int_service_0_end0
				
			int_service_0_I_2:
				or nbox4, al
				or nbox5, al
				or nbox6, al
				or nbox7, al
				jmp int_service_0_end0
				
		int_service_0_T:
			cmp count, 1
			je int_service_0_T_1
			cmp count, 2
			je int_service_0_T_2
			cmp count, 3
			je int_service_0_T_3
			cmp count, 4
			je int_service_0_T_4
			int_service_0_T_1:
				or nbox2, ah
				or nbox4, al
				or nbox5, ah
				or nbox6, al
				jmp int_service_0_end0
				
			int_service_0_T_2:
				or nbox2, ah
				or nbox4, al
				or nbox5, al
				or nbox6, al
				jmp int_service_0_end0
				
			int_service_0_T_3:
				or nbox2, ah
				or nbox5, ah
				or nbox6, al
				or nbox9, al
				jmp int_service_0_end0
				
			int_service_0_T_4:
				or nbox4, al
				or nbox5, ah
				or nbox6, al
				or nbox9, al
			    jmp int_service_0_end0
			
		int_service_0_L:
			cmp count, 1
			je int_service_0_L_1
			cmp count, 2
			je int_service_0_L_2
			cmp count, 3
			je int_service_0_L_3
			cmp count, 4
			je int_service_0_L_4
			int_service_0_L_1:
				or nbox1, al
				or nbox2, ah
				or nbox5, ah
				or nbox9, al
				jmp int_service_0_end0
				
			int_service_0_L_2:
				or nbox3, ah
				or nbox4, al
				or nbox5, al
				or nbox6, al
				jmp int_service_0_end0
				
			int_service_0_L_3:
				or nbox2, ah
				or nbox5, ah
				or nbox9, al
				or nbox10, al
				jmp int_service_0_end0
			
			int_service_0_L_4:
				or nbox4, ah
				or nbox5, al
				or nbox6, al
				or nbox8, al
				jmp int_service_0_end0
			
		int_service_0_J:
			cmp count, 1
			je int_service_0_J_1
			cmp count, 2
			je int_service_0_J_2
			cmp count, 3
			je int_service_0_J_3
			cmp count, 4
			je int_service_0_J_4
			int_service_0_J_1:
				or nbox2, ah
				or nbox5, ah
				or nbox8, al
				or nbox9, al
				jmp int_service_0_end0
				
			int_service_0_J_2:
				or nbox1, ah
				or nbox4, al
				or nbox5, al
				or nbox6, al
				jmp int_service_0_end0
				
			int_service_0_J_3:
				or nbox2, ah
				or nbox3, al
				or nbox5, ah
				or nbox9, al
				jmp int_service_0_end0
			
			int_service_0_J_4:
				or nbox4, al
				or nbox5, al
				or nbox6, ah
				or nbox10, al
				jmp int_service_0_end0
				
		int_service_0_Z:
			cmp count, 1
			je int_service_0_Z_1
			cmp count, 2
			je int_service_0_Z_2
			int_service_0_Z_1:
				or nbox3, ah
				or nbox5, ah
				or nbox6, al
				or nbox9, al
				jmp int_service_0_end0
				
			int_service_0_Z_2:
				or nbox4, al
				or nbox5, ah
				or nbox9, al
				or nbox10, al
				jmp int_service_0_end0
			
		int_service_0_S:
			cmp count, 1
			je int_service_0_S_1
			cmp count, 2
			je int_service_0_S_2
			int_service_0_S_1:
				or nbox2, ah
				or nbox5, al
				or nbox6, ah
				or nbox10, al
				jmp int_service_0_end0
				
			int_service_0_S_2:
				or nbox5, ah
				or nbox6, al
				or nbox8, al
				or nbox9, al
				jmp int_service_0_end0
				
		int_service_0_O:
			jmp int_service_0_end1

; test if there is any collision or exceeding the realm
		mov cx, 11
		int_service_0_loop0:
			mov al, DS[nbox1+cx-1]
			test al, 01000000b
			jz int_service_0_loop0_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			cmp al, 1
			jl int_service_0_end1
			cmp al, 40
			jg int_service_0_end1
			cmp ah, 1
			jl int_service_0_end1
			cmp ah, 80
			jg int_service_0_end1
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_read
			mov al, bl ; bl: exist 1, not exist 0 
			
			test al, al
			jnz int_service_0_loop0_collision_yes
			int_service_0_loop0_skip:
			loop int_service_0_loop0
		int_service_0_loop0_collision_yes:  nop
			; al: collision 1, no collision 0
			
		test al, al ; test if there is collision
		jnz int_service_0_end1
		
; erase LCD
		mov cs, 11
		int_service_0_loop1:
			mov al, DS[box1+cs-1]
			test al, 01000000b
			jz int_service_0_loop1_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_erase
			
			int_service_0_loop1_skip:
			loop int_service_0_loop1

; print LCD
		mov cs, 11
		int_service_0_loop2:
			mov al, DS[nbox1+cs-1]
			test al, 01000000b
			jz int_service_0_loop2_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_print
			
			int_service_0_loop2_skip:
			loop int_service_0_loop2
			
; update box
		mov cx, 11
		int_service_0_loop3:
			mov al, DS[nbox1+cs-1]
			mov DS[box1+cs-1], al
			loop int_service_0_loop3
			
; update count
		cmp count, count_max
		jne int_service_0_count_add
		mov count, 1
		jmp int_service_0_end1: nop
		int_service_0_count_add:
			inc count
		
		int_service_0_end1: nop
		
		pop ax
		pop cx
		pop dx
		sti
		iret
	int_service_0 endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_1 proc near
		push dx
		push cx
		push ax
		
		mov bl, 1 bl: 1 indicate move right
		call int_service_move
		
		pop ax
		pop bx
		pop dx
		ret
	int_service_1 endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_move proc near
		push dx
		push cx
		push ax
		
		mov tmp, bl ; store bl in tmp
		
		cmp tmp, 1
		je int_service_move_right0
		dec center_x
		jmp int_service_move_right0_skip
		int_service_move_right0:
			inc center_x
		int_service_move_right0_skip:
		
; test if there is any collision or exceeding the realm
		mov cx, 11
		int_service_move_loop0:
			mov al, DS[box1+cx-1]
			test al, 01000000b
			jz int_service_move_loop0_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			cmp al, 1
			jl int_service_move_end1
			cmp al, 40
			jg int_service_move_end1
			cmp ah, 1
			jl int_service_move_end1
			cmp ah, 80
			jg int_service_move_end1
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_read
			mov al, bl ; bl: exist 1, not exist 0 
			
			test al, al
			jnz int_service_move_loop0_collision_yes
			int_service_move_loop0_skip:
			loop int_service_move_loop0
		int_service_move_loop0_collision_yes:  nop
			; al: collision 1, no collision 0
			
		test al, al ; test if there is collision
		jnz int_service_move_end1
		
; erase LCD
		cmp tmp, 1
		je int_service_move_right1
		inc center_x
		jmp int_service_move_right1_skip
		int_service_move_right1:
			dec center_x
		int_service_move_right1_skip:
		
		mov cs, 11
		int_service_move_loop1:
			mov al, DS[box1+cs-1]
			test al, 01000000b
			jz int_service_move_loop1_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_erase
			
			int_service_move_loop1_skip:
			loop int_service_move_loop1

; print LCD
		cmp tmp, 1
		je int_service_move_right2
		dec center_x
		jmp int_service_move_right2_skip
		int_service_move_right2:
			inc center_x
		int_service_move_right2_skip:
		
		mov cs, 11
		int_service_move_loop2:
			mov al, DS[box1+cs-1]
			test al, 01000000b
			jz int_service_move_loop2_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_print
			
			int_service_move_loop2_skip:
			loop int_service_move_loop2
			
		int_service_move_end1: nop
		
		pop ax
		pop bx
		pop dx
		ret
	int_service_move endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_busy_cs1 proc near
		push dx
		push ax
		mov dx, lcd_cs1_control
	LCD_busy_cs1_jmp:
		in al, dx
		and al, 10000000b
		jnz LCD_busy_cs1_jmp
		pop ax
		pop dx
		ret
	LCD_busy_cs1 endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_busy_cs2 proc near
		push dx
		push ax
		mov dx, lcd_cs2_control
	LCD_busy_cs2_jmp:
		in al, dx
		and al, 10000000b
		jnz LCD_busy_cs2_jmp
		pop ax
		pop dx
		ret
	LCD_busy_cs2 endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_elminate proc near
	
		ret
	LCD_elminate endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_init proc near
		push dx
		push cx
		push ax
		
; turn on LCD
		mov al, 00111111b ; set turn on command
		
		call LCD_busy_cs1
		mov dx, lcd_cs1_control
		out dx, al ; turn cs1 on
		
		call LCD_busy_cs2
		mov dx, lcd_cs2_control
		out dx, al ; turn cs2 on
		
; set up LCD addresses
		mov al, y_base ; set y address
		
		call LCD_busy_cs1
		mov dx, lcd_cs1_control
		out dx, al ; set cs1 y address
		
		call LCD_busy_cs2
		mov dx, lcd_cs2_control
		out dx, al ; set cs1 y address
		
		mov al, x_base ; set x address
		
		call LCD_busy_cs1
		mov dx, lcd_cs1_control
		out dx, al ; set cs1 x address
		
		call LCD_busy_cs2
		mov dx, lcd_cs2_control
		out dx, al ; set cs1 x address
		
		mov al, 11000000b ; set start line address
		
		call LCD_busy_cs1
		mov dx, lcd_cs1_control
		out dx, al ; set cs1 start line address
		
		call LCD_busy_cs2
		mov dx, lcd_cs2_control
		out dx, al ; set cs1 start line address

; send zero to display RAM
		mov ah, x_base ; ah: store x address
		LCD_init_jmp0:
			mov al, 0
			mov cx, 64
			LCD_init_loop0:
				mov dx, lcd_cs1_data
				call LCD_busy_cs1
				out dx, al ; set cs1 data 0
				
				mov dx, lcd_cs2_data
				call LCD_busy_cs2
				out dx, al ; set cs2 data 0
				
				loop LCD_init_loop0
				
			inc ah
			cmp ah, 11000000b
			je LCD_init_end0
			
			call LCD_busy_cs1
			mov dx, lcd_cs1_control
			mov al, ah
			out dx, al ; set x address of cs1
			
			call LCD_busy_cs2
			mov dx, lcd_cs2_control
			mov al, ah
			out dx, al ; set x address of cs2
			
			jmp LCD_init_jmp0
		LCD_init_end0: nop
		
; print border
; print row
		mov dx, lcd_cs1_control
		
		call LCD_busy_cs1
		mov al, x_base + 5
		out dx, al ; set x address to cs1
		
		call LCD_busy_cs1
		mov al, y_base
		out dx, al ; set y address to cs1
		
		mov dx, lcd_cs2_control
		
		call LCD_busy_cs2
		mov al, x_base + 5
		out dx, al ; set x address to cs2
		
		call LCD_busy_cs2
		mov al, y_base
		out dx, al ; set y address to cs2
		
		mov al, 00000001b ; set data
		mov cx, 64
		LCD_init_loop1:
			mov dx, lcd_cs1_data
			call LCD_busy_cs1
			out dx, al ; set data to cs1
			
			mov dx, lcd_cs2_data
			call LCD_busy_cs2
			out dx, al ; set data to cs1
			loop LCD_init_loop1
			
; print column
		mov dx, lcd_cs2_control
		
		call LCD_busy_cs2
		mov al, x_base
		out dx, al ; set x address to cs2
		
		call LCD_busy_cs2
		mov al, y_base + 16
		out dx, al ; set y address to cs2
		
		mov al, 11111111 ; set data
		mov ah, x_base ; store x address to ah
		mov cx, 8
		LCD_init_loop2:
			mov dx, lcd_cs2_data
			call LCD_busy_cs2
			out dx, al ; set data to cs2
			
			inc ah
			call LCD_busy_cs2
			mov al, x_base
			out dx, al ; set x address to cs2	
			loop LCD_init_loop2		
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_read proc near ;
		push dx
		push cx
		push ax
		
		; bh: LCD x coordinate + cs + m or l
		; bl: LCD y coordinate
		
		test bh, 00010000b
		jnz LCD_read_cs2
			test bh, 00001000b
			jnz LCD_read_m
				; cs1 l
				and bh, 00000111b
				or bh, 10111000b
				mov dx, lcd_cs1_control
				
				call LCD_busy_cs1
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs1
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs1
				mov dx, lcd_cs1_data
				in al, dx ; get data
				
				and al, 00000001b 
				jnz LCD_read_exist
				jmp LCD_read_notexist
			LCD_read_m:
				; cs1 m
				and bh, 00000111b
				or bh, 10111000b
				mov dx, lcd_cs1_control
				
				call LCD_busy_cs1
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs1
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs1
				mov dx, lcd_cs1_data
				in al, dx ; get data
				
				and al, 00010000b 
				jnz LCD_read_exist
				jmp LCD_read_notexist
		LCD_read_cs2:
			test bh, 00001000b
			jnz LCD_read_m
				; cs2 l
				and bh, 00000111b
				or bh, 10111000b
				mov dx, lcd_cs2_control
				
				call LCD_busy_cs2
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs2
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs2
				mov dx, lcd_cs2_data
				in al, dx ; get data
				
				and al, 00000001b 
				jnz LCD_read_exist
				jmp LCD_read_notexist
			LCD_read_m:
				; cs2 m
				and bh, 00000111b
				or bh, 10111000b
				mov dx, lcd_cs2_control
				
				call LCD_busy_cs2
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs2
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs2
				mov dx, lcd_cs2_data
				in al, dx ; get data
				
				and al, 00010000b 
				jnz LCD_read_exist
				jmp LCD_read_notexist
		LCD_read_exist:
			mov bl, 00000001b
			jmp LCD_read_exist_end
		LCD_read_notexist:
			mov bl, 0
		LCD_read_exist_end:
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_read endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_update proc near
		push dx
		push cx
		push ax
		
; erase LCD
		mov cs, 11
		LCD_update_loop1:
			mov al, DS[box1+cs-1]
			test al, 01000000b
			jz LCD_update_loop1_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_erase
			
			LCD_update_loop1_skip:
			loop LCD_update_loop1

; drop tetris
		dec center_y
		
; print LCD
		mov cs, 11
		LCD_update_loop2:
			mov al, DS[box1+cs-1]
			test al, 01000000b
			jz LCD_update_loop2_skip
			
			; Put signed x coordinate into ah
			mov ah, al
			and ah, 00111000b
			ror ah, 1
			ror ah, 1
			ror ah, 1 
			
			; Put signed y coordinate into al
			and al, 00000111b

			mov bh, ah ; bh: relative x coordinate
			mov bl, al ; bl: relative y coordinate
			call coordinate_relative_to_absolute
			mov ah, bh ; bh: absolute x coordinate
			mov al, bl ; bl: absolute y coordinate
			
			mov bh, ah ; bh: absolute x coordinate
			mov bl, al ; bl: absolute y coordinate
			call coordinate_absolute_to_LCD
			mov ah, bh ; bh: LCD x coordinate + cs + m or l
			mov al, bl ; bl: LCD y coordinate
			
			mov bh, ah ; bh: LCD x coordinate + cs + m or l
			mov bl, al ; bl: LCD y coordinate
			call LCD_print
			
			LCD_update_loop2_skip:
			loop LCD_update_loop2
			
		pop ax
		pop cx
		pop dx
		ret
	LCD_update endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	random_generator proc near
		push dx
		push cx
		push ax
		
		; Using formular x1 = ( x0 * a + c ) MOD 2^16 to generate random seed
		mov ax, random_seed
		mov cx, a
		mul cx
		adc ax, c
		mov random_seed, ax
		
		; Get remainder
		mov cx, 7
		div cx
		mov random_number, dx
		
		pop ax
		pop cx
		pop dx
		ret
	random_generator endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_init proc near
		push dx
		push cx
		push ax
		
		cmp random_number, 0
		je pick_I
		cmp random_number, 1
		je pick_T
		cmp random_number, 2
		je pick_L
		cmp random_number, 3
		je pick_J
		cmp random_number, 4
		je pick_Z
		cmp random_number, 5
		je pick_S
		cmp random_number, 6
		je pick_O
		
		mov al, 11000000b
		mov ah, 01000000b
		
		tetris_init_pick_I:
			or box4, al
			or box5, al
			or box6, al
			or box7, al
			mov count, 2
			jmp tetris_init_end
			
		tetris_init_pick_T:
			or box4, al
			or box5, ah
			or box6, al
			or box9, al
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_L:
			or box4, ah
			or box5, al
			or box6, al
			or box8, al
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_J:
			or box4, al
			or box5, al
			or box6, ah
			or box10, al
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_Z:
			or box4, al
			or box5, ah
			or box9, al
			or box10, al
			mov count_max, 2
			jmp tetris_init_end
			
		tetris_init_pick_S:
			or box6, al
			or box5, ah
			or box8, al
			or box9, al
			mov count_max, 2
			jmp tetris_init_end

		tetris_init_pick_O:
			or box9, al
			or box5, ah
			or box6, ah
			or box10, al
			jmp tetris_init_end
			
		tetris_init_end:
		
		mov count, 1
	
		pop ax
		pop cx
		pop dx
		ret
	tetris_init endp	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_drop proc near
	
		ret
	tetris_drop endp	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Setup the Reset Vector
	org 07ff0h
	jmp dumst
	code_seg ends
end start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
