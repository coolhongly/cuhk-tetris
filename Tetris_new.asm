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
	
	box1_tmp1		db	?
	box2_tmp1		db	?
	box3_tmp1		db	?
	box4_tmp1		db	?
	
	box1_tmp2		db	?
	box2_tmp2		db	?
	box3_tmp2		db	?
	box4_tmp2		db	?
	
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
	tmp1			db	?
	erase_or_print 	db	?
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
	
	call 8259_init ; Done
	call 8255_init ; Done
	
	stage0:	; Game stage
		call LCD_init ; Done

		stage1:	; Life stage
			call random_generator ; Done
			call tetris_init ; Done
				
			stage2: ; Drop stage
				call delay ; Pending
				call dead ; Pending al = 1 dead

				cmp bl, 1
		
			    je main_dead 

				dec center_y
				call collision ; Done R(bl: collision 1, no collision 0)
			 	
				test bl, bl
				jnz main_collision_happen

				inc center_y
				call LCD_erase ; Done
				dec center_y
				call LCD_print ; Done
				
				jmp main_collision_happen_skip

				main_collision_happen:
					inc center_y
					
					call add ; Done
					call fill ; Done R(bl: 0000xxxx, x=1 line is filled)
					test bl, bl
					jz main_not_fill
					call LCD_flash ; Done P(const bl: 0000xxxx, x=1 line is filled)
					call LCD_eliminate ; Done P(const bl: 0000xxxx, x=1 line is filled)
					call LCD_drop ; Done P(bl: 0000xxxx, x=1 line is filled)
					call LCD_reprint ; Done
					
					main_not_fill:
				main_collision_happen_skip:

			 jmp stage2
		 jmp stage1
		
		 main_dead:
		
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
	add proc near
		push dx
		push cx
		push ax
		
		mov cx, 4
		add_loop0:
			mov di, cx
			mov ah, DS:[box1+4-di] ; start from box1
			mov bl, cl
			sub bl, 3 ; bl: relative y address
			add bl, 80 ; bl: absolute y address
			mov al, 00000001b
			
			push cx
			mov cx, 4
			add_loop1:
				test ah, al	
				jz add_loop1_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				ad bh, 40 ; bh: absolute x address
				call add_item ; P(bh: absolute x address, const bl: absolute y address)
				rol al, 1
				loop add_loop1
			pop cx
			loop add_loop0
		mov bl, 0
		jmp add_end0
		add_end1: 
			mov bl, 1 
		add_end0: 
		
		pop ax
		pop cx
		pop dx
		ret
	add endp
	
	add_item proc near ; P(bh: absolute x address, const bl: absolute y address)
		push dx
		push cx
		push ax
		
		mov al, bl ; bh: absolute x address, al: absolute y address
		
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		
		mov ax, 0000001000000000b
		mov cx, bh
		dec cx
		add_item_loop0:
			ror ax, 1
			loop add_item_loop0
		or DS:[row1+di-2], ax		
		
		pop ax
		pop cx
		pop dx
		ret
	add_item endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	collision proc near
		push dx
		push cx
		push ax

		mov cx, 4
		collision_loop0:
			mov di, cx
			mov ah, DS:[box1+4-di] ; start from box1
			mov bl, cl
			sub bl, 3 ; bl: relative y address
			add bl, 80 ; bl: absolute y address
			mov al, 00000001b
			
			push cx
			mov cx, 4
			collision_loop1:
				test ah, al	
				jz collision_loop1_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				ad bh, 40 ; bh: absolute x address
				collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
				test bh, bh
				jnz collision_end1
				collision_loop1_continue:
				rol al, 1
				loop collision_loop1
			pop cx
			loop collision_loop0
		mov bl, 0
		jmp collision_end0
		collision_end1: 
			mov bl, 1 
		collision_end0: 
	
		pop ax
		pop cx
		pop dx
		ret
	collision endp
	
	collision_test proc near ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
		push dx
		push cx
		push ax
			
		cmp bh, 1
		jl collision_test_end1
		cmp bh, 10
		jg collision_test_end1
		
		mov al, bl
		cmp al, 1
		jl collision_test_end1
		cmp al, 20
		jg collision_test_end1
		
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax
		mov dx, DS:[row1+di-2] ; dx: value of a row
		
		mov cx, bh
		dec cx
		mov ax, 0000001000000000b
		collision_test_loop0:
			ror ax, 1
			loop collision_test_loop0 ;
		test ax, dx
		jnz collision_test_end1
		mov bh, 0
		jmp collision_test_end0
		collision_test_end1:
			mov bh, 1
		collision_test_end0:
			
		pop ax
		pop cx
		pop dx
		ret
	collision_test endp
	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	delay proc near
	
		ret
	delay endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	dead proc near
		push cx
		push bx
		push ax
	    cmp random_number, 0
		je dead_I
		cmp random_number, 1
		je dead_T
		cmp random_number, 2
		je dead_L
		cmp random_number, 3
		je dead_J
		cmp random_number, 4
		je dead_Z
		cmp random_number, 5
		je dead_S
		cmp random_number, 6
		je dead_O
		
		dead_I:
		mov bh,4
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,7
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		dead_T:
		mov bh,4
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		dead_L:
		mov bh,4
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,4
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		dead_J:
		mov bh,4
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		dead_Z:
		mov bh,4
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		dead_S:
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,4
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
	    dead_O:
		mov bh,5
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,20
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,5
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		
		mov bh,6
		mov bl,19
		call collision
		cmp bh, 1
		je real_dead
		mov bl,0
		jmp end_dead
		
		
		real_dead:
		mov bl, 1
		end_dead:
        pop ax
		pop bx
		pop cx
		ret
	dead endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	fill proc near
		push dx
		push cx
		push ax
		
		mov al, center_y
		inc al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp DS:[row1+di-2], 0000001111111111b
		jne fill_jmp0
		or bl, 00001000b ; 00001000b represents top
		fill_jmp0:
		
		mov al, center_y
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp DS:[row1+di-2], 0000001111111111b
		jne fill_jmp1
		or bl, 00000100b
		fill_jmp1:
		
		mov al, center_y
		dec al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp DS:[row1+di-2], 0000001111111111b
		jne fill_jmp2
		or bl, 00000010b
		fill_jmp2:
		
		mov al, center_y
		dec al
		dec al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp DS:[row1+di-2], 0000001111111111b
		jne fill_jmp3
		or bl, 00000001b
		fill_jmp3:
		
		pop ax
		pop cx
		pop dx
		ret
	fill endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_0 proc near
		cli
		push dx
		push cx
		push ax
		
		mov box1_tmp1, box1
		mov box2_tmp1, box2
		mov box3_tmp1, box3
		mov box4_tmp1, box4

		
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
				mov box1, 00000100b
				mov box2, 00000100b
				mov box3, 00000100b
				mov box4, 00000100b
				jmp int_service_0_end0
				
			int_service_0_I_2:
				mov box1, 00000000b
				mov box2, 00001111b
				mov box3, 00000000b
				mov box4, 00000000b
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
				mov box1, 00000100b
				mov box2, 00001100b
				mov box3, 00000100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_T_2:
				mov box1, 00000100b
				mov box2, 00001110b
				mov box3, 00000000b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_T_3:
				mov box1, 00000100b
				mov box2, 00000110b
				mov box3, 00000100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_T_4:
				mov box1, 00000000b
				mov box2, 00001110b
				mov box3, 00000100b
				mov box4, 00000000b
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
				mov box1, 00001100b
				mov box2, 00000100b
				mov box3, 00000100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_L_2:
				mov box1, 00000010b
				mov box2, 00001110b
				mov box3, 00000000b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_L_3:
				mov box1, 00000100b
				mov box2, 00000100b
				mov box3, 00000110b
				mov box4, 00000000b
				jmp int_service_0_end0
			
			int_service_0_L_4:
				mov box1, 00000000b
				mov box2, 00001110b
				mov box3, 00001000b
				mov box4, 00000000b
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
				mov box1, 00000100b
				mov box2, 00000100b
				mov box3, 00001100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_J_2:
				mov box1, 00001000b
				mov box2, 00001110b
				mov box3, 00000000b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_J_3:
				mov box1, 00000110b
				mov box2, 00000100b
				mov box3, 00000100b
				mov box4, 00000000b
				jmp int_service_0_end0
			
			int_service_0_J_4:
				mov box1, 00000000b
				mov box2, 00001110b
				mov box3, 00000010b
				mov box4, 00000000b
				jmp int_service_0_end0
				
		int_service_0_Z:
			cmp count, 1
			je int_service_0_Z_1
			cmp count, 2
			je int_service_0_Z_2
			int_service_0_Z_1:
				mov box1, 00000010b
				mov box2, 00000110b
				mov box3, 00000100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_Z_2:
				mov box1, 00000000b
				mov box2, 00001100b
				mov box3, 00000110b
				mov box4, 00000000b
				jmp int_service_0_end0
			
		int_service_0_S:
			cmp count, 1
			je int_service_0_S_1
			cmp count, 2
			je int_service_0_S_2
			int_service_0_S_1:
				mov box1, 00000100b
				mov box2, 00000110b
				mov box3, 00000010b
				mov box4, 00000000b
				jmp int_service_0_end0
				
			int_service_0_S_2:
				mov box1, 00000000b
				mov box2, 00000110b
				mov box3, 00001100b
				mov box4, 00000000b
				jmp int_service_0_end0
				
		int_service_0_O:
			jmp int_service_0_end2
		
		jmp int_service_0_end0:
		
; test if there is any collision or exceeding the realm
		call collision ;R(bl: collision 1, no collision 0)
			
		test bl, bl
		jnz int_service_0_end1
		
; erase LCD
		mov box1_tmp2, box1
		mov box2_tmp2, box2
		mov box3_tmp2, box3
		mov box4_tmp2, box4

		mov box1, box1_tmp1
		mov box2, box2_tmp1
		mov box3, box3_tmp1
		mov box4, box4_tmp1
		
		call LCD_erase

; print LCD
		mov box1, box1_tmp2
		mov box2, box2_tmp2
		mov box3, box3_tmp2
		mov box4, box4_tmp2
		call LCD_print
			
; update count
		cmp count, count_max
		jne int_service_0_count_add
		mov count, 1
		jmp int_service_0_end1: nop
		int_service_0_count_add:
			inc count
			
		jmp int_service_0_end2
		
		int_service_0_end1: 
			mov box1, box1_tmp1
			mov box2, box2_tmp1
			mov box3, box3_tmp1
			mov box4, box4_tmp1
			
		int_service_0_end2: 
		
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
		call collision ;R(bl: collision 1, no collision 0)
			
		test bl, bl ; test if there is collision
		jnz int_service_move_end0
		
; erase LCD
		cmp tmp, 1
		je int_service_move_right1
		inc center_x
		jmp int_service_move_right1_skip
		int_service_move_right1:
			dec center_x
		int_service_move_right1_skip:
		
		call LCD_erase

; print LCD
		cmp tmp, 1
		je int_service_move_right2
		dec center_x
		jmp int_service_move_right2_skip
		int_service_move_right2:
			inc center_x
		int_service_move_right2_skip:
		
		call LCD_print
		
		jmp int_service_move_end1
		
		int_service_move_end0: 
			cmp tmp, 1
			je int_service_move_right3
			inc center_x
			jmp int_service_move_right3_skip
			int_service_move_right3:
				dec center_x
			int_service_move_right3_skip:
			
		int_service_move_end1:
		
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
	LCD_drop proc near ; P(bl: 0000xxxx)
		push dx
		push cx
		push ax
		
		mov bh, 00001000b ; bl: test bit
		mov cx, 4
		LCD_drop_loop0:
			test bl, bh
			jz LCD_drop_loop0_continue
			mov al, center_y ;
			add al, cx
			sub al, 3 ; al: absolute y
			
			LCD_drop_jmp0:
			
			push cx
			mov cx, 2
			mul cl ; al: absolute y * 2
			pop cx
			
			cmp al, 40
			je LCD_drop_toprow ; come to top row
			
			mov di, ax
			push bx
			mov bx, DS[row1 + di]
			mov DS[row1 + di -2], bx
			pop bx
			
			inc al
			jmp LCD_drop_jmp0
			LCD_drop_toprow:
				mov DS[row1 + di - 2], 0
			
			LCD_drop_loop0_continue:
			ror bh, 1
			loop LCD_drop_loop0
			
		pop ax
		pop cx
		pop dx
		ret
	LCD_drop endp
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_eliminate proc near ; P(bl: 0000xxxx)
		push dx
		push cx
		push ax
		
		mov cx, 4
		mov al, 00000001b
		LCD_eliminate_loop0:
			test bl, al
			jnz LCD_eliminate_loop0_break
			rol al, 1
			loop LCD_eliminate_loop0
		LCD_eliminate_loop0_break:
		mov al, 2
		sub al, cx ; al stores relative y to start
		
		push bx ; protect bl
		
		add al, center_y ; al stores absolute y to start
		sub al, 
		mov cl, 2
		mul cl
		mov di, al ; row1+di-2, row to start
		
		mov cx, 20
		sub cx, al
		inc cx ; cx denotes # of loop to eliminate
		LCD_eliminate_loop1:
			push cx
			mov cx, 10
			LCD_eliminate_loop2:
				mov bh, cl
				mov bl, al
				call LCD_erase_4x4
				loop LCD_eliminate_loop2
			pop cx
			inc al
			loop LCD_eliminate_loop1
			
		pop bx

		pop ax
		pop cx
		pop dx
		ret
	LCD_eliminate endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_erase proc near
		push dx
		push cx
		push ax
		
		mov cx, 4
		LCD_erase_loop0:
			mov di, cx
			mov ah, DS:[box1+4-di] ; start from box1
			mov bl, cl
			sub bl, 3 ; bl: relative y address
			add bl, 80 ; bl: absolute y address
			mov al, 00000001b
			
			push cx
			mov cx, 4
			LCD_erase_loop1:
				test ah, al	
				jz LCD_erase_loop1_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, 40 ; bl: absolute x address
				LCD_erase_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_erase_loop1_continue:
				rol al, 1
				loop LCD_erase_loop1
			pop cx
			loop LCD_erase_loop0
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_erase endp
	
	LCD_erase_4x4 proc near
		push dx
		push cx
		push ax
		mov tmp1, bl
		
		call coordinate_absolute_to_LCD ; R(bh: LCD x coordinate + cs + m or l, bl: LCD y coordinate)-P(bh: absolute x address, const bl: absolute y address)
		
		test bh, 00010000b
		jnz LCD_erase_4x4_cs2
			test bh, 00001000b
			jnz LCD_erase_4x4_cs1_m
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
				
				mov cx, 4
				LCD_erase_4x4_cs1_l_loop
					call LCD_busy_cs1
					and al, 11110000b
					out dx, al ; erase
					loop LCD_erase_4x4_cs1_l_loop
				
				jmp LCD_erase_4x4_end0
			LCD_erase_4x4_cs1_m:
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
				
				mov cx, 4
				LCD_erase_4x4_cs1_m_loop
					call LCD_busy_cs1
					and al, 00001111b
					out dx, al ; erase
					loop LCD_erase_4x4_cs1_m_loop
				
				jmp LCD_erase_4x4_end0
		LCD_erase_4x4_cs2:
			test bh, 00001000b
			jnz LCD_erase_4x4_cs2_m
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
				
				mov cx, 4
				LCD_erase_4x4_cs2_l_loop
					call LCD_busy_cs2
					and al, 11110000b
					out dx, al ; erase
					loop LCD_erase_4x4_cs2_l_loop
				
				jmp LCD_erase_4x4_end0
			LCD_erase_4x4_cs2_m:
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
				
				mov cx, 4
				LCD_erase_4x4_cs2_m_loop
					call LCD_busy_cs2
					and al, 00001111b
					out dx, al ; erase
					loop LCD_erase_4x4_cs2_m_loop
				
				jmp LCD_erase_4x4_end0
		
		LCD_erase_4x4_end0:

		mov bl, tmp1
		pop ax
		pop cx
		pop dx
	LCD_erase_4x4 endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_flash proc near ; P(bl: 0000xxxx, x=1 line is filled)
		push dx
		push cx
		push ax

		mov cx, 4
		LCD_flash_loop0:
			
		L1_full:
		mov cx, 3
		push cx
		test bl, 00000001b
		jnz flash_L1
		L2_full:
		test bl, 00000010b
		jnz flash_L2
		L3_full:
		test bl, 00000100b
		jnz flash_L3
		L4_full:
		test bl, 00001000b
		jnz flash_L4
		jmp end_LCD_flash
		
		flash_L1:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y-2
        L1_increase_bh:
		inc bh
		call LCD_erase_4x4
		loop L1_increase_bh
		pop bl
		jmp L2_full
		
		flash_L2:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y-1
        L2_increase_bh:
		inc bh
		call LCD_erase_4x4
		loop L2_increase_bh
		pop bl
		jmp L3_full
		
		flash_L3:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y
        L3_increase_bh:
		inc bh
		call LCD_erase_4x4
		loop L3_increase_bh
		pop bl
		jmp L4_full
		
		flash_L4:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y
        L4_increase_bh:
		inc bh
		call LCD_erase_4x4
		loop L4_increase_bh
	    pop bl
		
		L1_full_print:
		test bl, 00000001b
		jnz print_L1
		L2_full_print:
		test bl, 00000010b
		jnz print_L2
		L3_full_print:
		test bl, 00000100b
		jnz print_L3
		L4_full_print:
		test bl, 00001000b
		jnz print_L4
		jmp end_LCD_flash
		
		print_L1:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y-2
        print_L1_increase_bh:
		inc bh
		call LCD_print_4x4
		loop print_L1_increase_bh
		pop bl
		jmp L2_full_print
		
		print_L2:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y-1
        print_L2_increase_bh:
		inc bh
		call LCD_print_4x4
		loop print_L2_increase_bh
		pop bl
		jmp L3_full_print
		
		print_L3:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y
        print_L3_increase_bh:
		inc bh
		call LCD_print_4x4
		loop print_L3_increase_bh
		pop bl
		jmp L4_full_print
		
		print_L4:
		push bl
		mov cx, 10
		mov bh, 0
		mov bl, center_y
        print_L4_increase_bh:
		inc bh
		call LCD_print_4x4
		loop print_L4_increase_bh
	    pop bl
		pop cx
		
		loop L1_full

	    end_LCD_flash:
		pop ax
		pop cx
		pop dx
		ret
	LCD_flash endp	
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
	LCD_print proc near
		push dx
		push cx
		push ax
		
		mov cx, 4
		LCD_print_loop0:
			mov di, cx
			mov ah, DS:[box1+4-di] ; start from box1
			mov bl, cl
			sub bl, 3 ; bl: relative y address
			add bl, 80 ; bl: absolute y address
			mov al, 00000001b
			
			push cx
			mov cx, 4
			LCD_print_loop1:
				test ah, al	
				jz LCD_print_loop1_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, 40 ; bl: absolute x address
				LCD_print_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_print_loop1_continue:
				rol al, 1
				loop LCD_print_loop1
			pop cx
			loop LCD_print_loop0
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_print endp
	
	LCD_print_4x4 proc near
		push dx
		push cx
		push ax
		mov tmp1, bl
		
		call coordinate_absolute_to_LCD ; R(bh: LCD x coordinate + cs + m or l, bl: LCD y coordinate)-P(bh: absolute x address, const bl: absolute y address)
		
		test bh, 00010000b
		jnz LCD_print_4x4_cs2
			test bh, 00001000b
			jnz LCD_print_4x4_cs1_m
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
				
				mov cx, 4
				LCD_print_4x4_cs1_l_loop
					call LCD_busy_cs1
					or al, 00001111b
					out dx, al ; print
					loop LCD_print_4x4_cs1_l_loop
				
				jmp LCD_print_4x4_end0
			LCD_print_4x4_cs1_m:
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
				
				mov cx, 4
				LCD_print_4x4_cs1_m_loop
					call LCD_busy_cs1
					or al, 11110000b
					out dx, al ; print
					loop LCD_print_4x4_cs1_m_loop
				
				jmp LCD_print_4x4_end0
		LCD_print_4x4_cs2:
			test bh, 00001000b
			jnz LCD_print_4x4_cs2_m
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
				
				mov cx, 4
				LCD_print_4x4_cs2_l_loop
					call LCD_busy_cs2
					or al, 00001111b
					out dx, al ; print
					loop LCD_print_4x4_cs2_l_loop
				
				jmp LCD_print_4x4_end0
			LCD_print_4x4_cs2_m:
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
				
				mov cx, 4
				LCD_print_4x4_cs2_m_loop
					call LCD_busy_cs2
					or al, 11110000b
					out dx, al ; print
					loop LCD_print_4x4_cs2_m_loop
				
				jmp LCD_print_4x4_end0
		
		LCD_print_4x4_end0:

		mov bl, tmp1
		pop ax
		pop cx
		pop dx
	LCD_print_4x4 endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_reprint proc near
		push dx
		push cx
		push ax
		
		mov cx, 20
		inc cx ; cx denotes # of loop to eliminate
		LCD_reprint_loop0:
			push cx
			mov cx, 10
			LCD_reprint_loop0:
				mov bh, cl ; bh: absolute x
				mov bl, al ; bl: absolute y
				mov ah, bh
				mov al, bl
				call collision
				test bh, bh
				jz LCD_reprint_continue
				mov bh, ah
				mov bl, al
				call LCD_print_4x4
				LCD_reprint_continue:
				loop LCD_reprint_loop0
			pop cx
			inc al
			loop LCD_reprint_loop0
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_reprint endp
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
		
		tetris_init_pick_I:
			mov box1, 0
			mov box2, 00001111b
			mov box3, 0
			mov box4, 0
			mov cout_max, 2
			jmp tetris_init_end
			
		tetris_init_pick_T:
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000100b
			mov box4, 0
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_L:
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00001000b
			mov box4, 0
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_J:
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000010b
			mov box4, 0
			mov count_max, 4
			jmp tetris_init_end
			
		tetris_init_pick_Z:
			mov box1, 0
			mov box2, 00001100b
			mov box3, 00000110b
			mov box4, 0
			mov count_max, 2
			jmp tetris_init_end
			
		tetris_init_pick_S:
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00001100b
			mov box4, 0
			mov count_max, 2
			jmp tetris_init_end

		tetris_init_pick_O:
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00000110b
			mov box4, 0
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
