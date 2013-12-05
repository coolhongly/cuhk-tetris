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
clcd_base				equ 0d0h
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
	padding			db 1024 dup(?)
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
	
	random_seed		db	?
	random_number	db	?
	offset_number	dw	?
	
	center_x		db	?
	center_y		db	?
	
	count			db  ?
	count_max		db  ?
	
	tmp				db	?
	erase_or_print 	db	?
	LCD_print_4x4_tmp	db	?
	LCD_print_4x4_tmp1	db	?
	LCD_drop_tmp		db	?
	LCD_drop_tmp1		db	?
	LCD_drop_tmp2		dw	?
	LCD_drop_tmp3		dw	?
	LCD_eliminate_tmp	db	?
	LCD_erase_4x4_tmp	db	?
	LCD_erase_4x4_tmp1	db	?
	LCD_reprint_tmp		dw	?
	LCD_reprint_tmp1	dw	?
	collision_tmp 		dw	?
	pointer 			db  ?
	start_push				db	?
	score				db	?
	eliminate_test		db	?
	temp_offset			dw	?
	temp_y				db	?
	; int_tmp			db ?
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
	;mov random_seed, 7;mov random_seed, 1011011110000010b
	; mov int_tmp,0 
	mov offset_number, offset integer
	push ax
	mov ax, offset_number
	mov temp_offset, ax
	pop ax
	call i8259_init ; Done
	
	call i8255_init ; Done
	
	stage0:	; Game stage
		call LCD_init ; Done
		;mov cx, 100
		call draw_start0
		;main_delay00:			
			;call delay ; Pending
		;loop main_delay00
		call LCD_init
		
		call INIT_LCD
		call draw_start1
		call INIT_LCD
		mov cx, 100
		main_delay1:			
			call delay111 ; Pending
		loop main_delay1
		call LCD_init
		
		call draw_start2
		call INIT_LCD
		mov cx, 100
		main_delay2:			
			call delay111 ; Pending
		loop main_delay2
		call LCD_init
		
		call draw_start3
		call INIT_LCD
		mov cx, 100
		main_delay3:			
			call delay111 ; Pending
		loop main_delay3
		call LCD_init
		
		call draw_start4
		call INIT_LCD
		mov cx, 100
		main_delay4:			
			call delay111 ; Pending
		loop main_delay4
		call LCD_init
		
		call draw_start5
		call INIT_LCD
		mov cx, 100
		main_delay5:			
			call delay111 ; Pending
		loop main_delay5
		call LCD_init
		
		call draw_start6
		call INIT_LCD
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		call lcd_2x16
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov cx, 100
		main_delay6:			
			call delay111 ; Pending
		loop main_delay6
		mov start_push,0
		sti
		start_check:
		cmp start_push, 1
		je jump_start
		call start_change_sharpI
		cmp start_push, 1
		je jump_start
		call start_change_sharpT
		cmp start_push, 1
		je jump_start
		call start_change_sharpL
		cmp start_push, 1
		je jump_start
		call start_change_sharpJ
		cmp start_push, 1
		je jump_start
		call start_change_sharpZ
		cmp start_push, 1
		je jump_start
		call start_change_sharpS
		cmp start_push, 1
		je jump_start
		call start_change_sharpO
		jmp start_check
		
		jump_start:
		cli
		call LCD_init
		call game_init
		call row_init
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		call lcd_score
		mov score, 0
		call lcd_print_score
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		stage1:	; Life stage
			 ; mov random_number, 0
			 ; call random_generator ; Done
			 ; call tetris_init ; Done		
			 ; mov count, 0
			 
			 ; mov bl, 0
			; call dead ; Pending bl = 1 dead
			; cmp bl, 1
			; je main_dead ; je main_dead 
									
			; call LCD_print
			call random_generator
			dec offset_number
			dec bx
			cmp	 bx, temp_offset
			je   print_next
		                    ; Done
			call tetris_init			
		    mov	 center_x, 5
			mov  center_y, 25
			call LCD_erase

			
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			print_next:
			inc offset_number
			call random_generator ; Done
			call tetris_init			
		    mov	 center_x, 5
			mov  center_y, 25
			
			call LCD_print
			
			mov  center_x, 5
			mov  center_y, 20
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			dec offset_number
			dec offset_number
			call random_generator ; Done
			 call tetris_init ; Done		
			 mov count, 0
			 
			 mov bl, 0
			call dead ; Pending bl = 1 dead
			cmp bl, 1
			je main_dead ; je main_dead 
									
			call LCD_print






			stage2: ; Drop stage
				
				mov bl, 0 ;;
				
				mov cx, 100				
				main_delay:			
					call delay ; Pending
				loop main_delay
				; mov bl, 1											
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
					
					call add_tetris ; Done
					
					
					call fill ; Done R(bl: 0000xxxx, 00001000 box1 line is filled)
					test bl, bl
					jz main_not_fill
					call test_eliminate
					
					;call LCD_flash ; Done P(const bl: 0000xxxx, x=1 line is filled)
					
					call LCD_eliminate ; Done P(const bl: 0000xxxx, x=1 line is filled)
					call LCD_drop ; Done P(bl: 0000xxxx, x=1 line is filled)
					call LCD_reprint ; Done
					; jmp main_test_dead
					main_not_fill:
					
					
					
					jmp stage2_break
				main_collision_happen_skip:
				
				; cmp int_tmp, 1 ;;
				; je main_int ;;
				
			 jmp stage2
			 
			 
			 stage2_break:
			 ; jmp main_test
		 jmp stage1
		
		 main_dead:
			call LCD_init
			call draw_end
			call draw_face
			
			mov start_push,0
			sti
		loop_check1:
		cmp start_push, 1
		je jump_state0
		jmp loop_check1
	
	jump_state0:
	call INIT_LCD
	 jmp stage0
	 
	 ;; For testing
	 ; main_test:
	 ; call LCD_init
	 ; call game_init
	 ; mov cx, 20
	 ; main_test_row:
		; mov bl, cl
		
		; mov ax, cx
		; push cx
		; mov cx, 2
		; mul cl
		; mov di, ax
		
		; mov ax, 0000000000000001b
		; mov cx, 10
		; main_test_column:
			; mov bh, cl
			; test [row1+di-2], ax
			; jz main_test_column_skip
			; call LCD_print_4x4
			; main_test_column_skip:
			; rol ax, 1
			; loop main_test_column
		
		; pop cx
	; loop main_test_row
	; jmp stage1
	

	 ; main_int:
	 ; mov int_tmp,0 
	 ; call LCD_init
	 
	 ; main_test_dead:
	 

	loopend:
	nop
	jmp loopend
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	i8255_init proc near
		mov dx,i8255_base_address
		mov al,1000000b
		inc dx
		inc dx
		inc dx ; Point to command register
		out dx,al
		ret
	i8255_init endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	i8259_init proc near
	push dx
	push cx
	push bx
	push ax

	mov     dx,i8259_base_address       ;point to ICW1
      mov     al,00010011b        ;ICW4 needed,single,edge trigger
      out     dx,al

      inc     dx                       ;point to ICW2
      mov     al,00001000b        ;base address=08h
      out     dx,al

      mov     al,00000011b        ;8088 mode,auto EOI
      out     dx,al

      mov     ax,0
      mov     es,ax               ;ES points to low memory
      mov     di,20h              ;offset of entry for type code 08h
	  
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
	pop bx
	pop cx
	pop dx
		ret
	i8259_init endp
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; int_service_0    proc    near

      ; iret
; int_service_0   endp
; int_service_1   proc    near
      ; iret
; int_service_1   endp
; int_service_2   proc    near
      ; iret
; int_service_2   endp
; int_service_3   proc    near
      ; iret
; int_service_3   endp
; int_service_4   proc    near
	
	; mov int_tmp, 1

      ; iret
	
; int_service_4   endp
; int_service_5   proc    near
      ; iret
; int_service_5   endp
; int_service_6   proc    near

      ; iret
; int_service_6   endp
; int_service_7   proc    near
      ; iret
; int_service_7   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_0 proc near
		cli
			; cmp center_x,3
			; je int_service_0_end
			inc center_x
			call collision
			jnz int_service_0_collision
			
			dec center_x
			call LCD_erase
			inc center_x
			call LCD_print
			
			jmp int_service_0_end
			
			int_service_0_collision:
			dec center_x
			
			int_service_0_end:
		sti
		iret
	int_service_0 endp
	
	int_service_1 proc near
		cli
                push dx
                push cx
				push bx
                push ax
              			
                mov al, box1
				mov box1_tmp1, al
				mov al, box2
				mov box2_tmp1, al
				mov al, box3
				mov box3_tmp1, al
				mov al, box1
				mov box4_tmp1, al
                
			    dec center_y
				dec center_y
				call collision  
				inc center_y
				inc center_y
				cmp bl, 1
				je end_change_jump
cmp random_number, 0
je I
cmp random_number, 1
je T
cmp random_number, 2
je L
cmp random_number, 3
je J
cmp random_number, 4
je Z
cmp random_number, 5
je S
cmp random_number, 6
je O

I:
	
	call change_sharp_I
	jmp end_change_sharp
T:
	
	
	call change_sharp_T
	jmp end_change_sharp
L:
	
	call change_sharp_L
	jmp end_change_sharp
J:
	
	
	call change_sharp_J
	jmp end_change_sharp
Z:
	
	
	call change_sharp_Z
	jmp end_change_sharp
S:
	
	call change_sharp_S
	jmp end_change_sharp
O:
	
	call change_sharp_O
	jmp end_change_sharp
end_change_jump:
jmp end_change
		end_change_sharp:
				call collision ;R(bl: collision 1, no collision 0)
			    mov al, box1
                mov box1_tmp2, al
				mov al, box2
                mov box2_tmp2, al                
				mov al, box3
                mov box3_tmp2, al				
				mov al, box4
                mov box4_tmp2, al
				
				mov al, box1_tmp1
                mov box1, al
				mov al, box2_tmp1
                mov box2, al                
				mov al, box3_tmp1
                mov box3, al				
				mov al, box4_tmp1
                mov box4, al
				
				; mov bl, 1
				test bl, 1
				jz no_collision
				
				jmp end_change 
				
		no_collision:		
				call lcd_erase
				
				mov al, box1_tmp2
				mov box1, al
                mov al, box2_tmp2
				mov box2, al
				mov al, box3_tmp2
				mov box3, al
				mov al, box4_tmp2
				mov box4, al
				call lcd_print
		end_change:
		
	            pop ax
				pop bx
                pop cx
                pop dx
                sti
                iret
        int_service_1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_I proc near
;

inc count
cmp count, 1
je I1
cmp count, 2
je I2

I1:
	call change_sharp_I1
	jmp end_change_sharp_I
I2:
	call change_sharp_I2
	mov count, 0
	jmp end_change_sharp_I
end_change_sharp_I:
	
	ret
	change_sharp_I endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_I1 proc near
;
                                mov box1, 00000100b
                                mov box2, 00000100b
                                mov box3, 00000100b
                                mov box4, 00000100b
ret
change_sharp_I1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_I2 proc near
;
                                mov box1, 00000000b
                                mov box2, 00001111b
                                mov box3, 00000000b
                                mov box4, 00000000b

ret
change_sharp_I2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_T proc near
;

inc count
cmp count, 1
je T1
cmp count, 2
je T2
cmp count, 3
je T3
cmp count, 4
je T4

T1:
	call change_sharp_T1
	jmp end_change_sharp_T
T2:
	call change_sharp_T2
	jmp end_change_sharp_T
T3:
	call change_sharp_T3
	jmp end_change_sharp_T
T4:
	call change_sharp_T4
	mov count, 0
	jmp end_change_sharp_T

end_change_sharp_T:
	
	ret
	change_sharp_T endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_T1 proc near
;
                                mov box1, 00000100b
                                mov box2, 00001100b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_T1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_T2 proc near
;
                                mov box1, 00000100b
                                mov box2, 00001110b
                                mov box3, 00000000b
                                mov box4, 00000000b
ret
change_sharp_T2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_T3 proc near
;
                                mov box1, 00000100b
                                mov box2, 00000110b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_T3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_T4 proc near
;
                                mov box1, 00000000b
                                mov box2, 00001110b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_T4 endp



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_L proc near
;

inc count
cmp count, 1
je L1
cmp count, 2
je L2
cmp count, 3
je L3
cmp count, 4
je L4

L1:
	call change_sharp_L1
	jmp end_change_sharp_L
L2:
	call change_sharp_L2
	jmp end_change_sharp_L
L3:
	call change_sharp_L3
	jmp end_change_sharp_L
L4:
	call change_sharp_L4
	mov count, 0
	jmp end_change_sharp_L

end_change_sharp_L:
	
	ret
	change_sharp_L endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_L1 proc near
;
                                mov box1, 00001100b
                                mov box2, 00000100b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_L1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_L2 proc near
; 
                                mov box1, 00000010b
                                mov box2, 00001110b
                                mov box3, 00000000b
                                mov box4, 00000000b
ret
change_sharp_L2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_L3 proc near
;
                                mov box1, 00000100b
                                mov box2, 00000100b
                                mov box3, 00000110b
                                mov box4, 00000000b
ret
change_sharp_L3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_L4 proc near
;
                                mov box1, 00000000b
                                mov box2, 00001110b
                                mov box3, 00001000b
                                mov box4, 00000000b
ret
change_sharp_L4 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_J proc near
; 

inc count
cmp count, 1
je J1
cmp count, 2
je J2
cmp count, 3
je J3
cmp count, 4
je J4

J1:
	call change_sharp_J1
	jmp end_change_sharp_J
J2:
	call change_sharp_J2
	jmp end_change_sharp_J
J3:
	call change_sharp_J3
	jmp end_change_sharp_J
J4:
	call change_sharp_J4
	mov count, 0
	jmp end_change_sharp_J

end_change_sharp_J:
	
	ret
	change_sharp_J endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_J1 proc near
;
                                mov box1, 00000100b
                                mov box2, 00000100b
                                mov box3, 00001100b
                                mov box4, 00000000b
ret
change_sharp_J1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_J2 proc near
;
                                mov box1, 00001000b
                                mov box2, 00001110b
                                mov box3, 00000000b
                                mov box4, 00000000b
ret
change_sharp_J2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_J3 proc near
;
                                mov box1, 00000110b
                                mov box2, 00000100b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_J3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_J4 proc near
;
                                mov box1, 00000000b
                                mov box2, 00001110b
                                mov box3, 00000010b
                                mov box4, 00000000b
ret
change_sharp_J4 endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_Z proc near
;

inc count
cmp count, 1
je Z1
cmp count, 2
je Z2

Z1:
	call change_sharp_Z1
	jmp end_change_sharp_Z
Z2:
	call change_sharp_Z2
	mov count, 0
	jmp end_change_sharp_Z
end_change_sharp_Z:
	
	ret
	change_sharp_Z endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_Z1 proc near
;
                                mov box1, 00000010b
                                mov box2, 00000110b
                                mov box3, 00000100b
                                mov box4, 00000000b
ret
change_sharp_Z1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_Z2 proc near
;
                                mov box1, 00000000b
                                mov box2, 00001100b
                                mov box3, 00000110b
                                mov box4, 00000000b
ret
change_sharp_Z2 endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_S proc near
;

inc count
cmp count, 1
je S1
cmp count, 2
je S2

S1:
	call change_sharp_S1
	jmp end_change_sharp_S
S2:
	call change_sharp_S2
	mov count, 0
	jmp end_change_sharp_S
end_change_sharp_S:
	
	ret
	change_sharp_S endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_S1 proc near
;
                                mov box1, 00000100b
                                mov box2, 00000110b
                                mov box3, 00000010b
                                mov box4, 00000000b

ret
change_sharp_S1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_S2 proc near
;
                                mov box1, 00000000b
                                mov box2, 00000110b
                                mov box3, 00001100b
                                mov box4, 00000000b
ret
change_sharp_S2 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
change_sharp_O proc near
;
ret
change_sharp_O endp
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		int_service_2   proc    near
			cli
			
			 dec center_x
			 call collision
			 jnz int_service_1_collision
			
			inc center_x
			call LCD_erase
			 dec center_x
			 call LCD_print
			
			 jmp int_service_1_end
			
			 int_service_1_collision:
			 inc center_x
			
			 int_service_1_end:
		sti
		iret
		int_service_2   endp
		
		int_service_3   proc    near
		cli
		mov start_push,1
		sti
		iret
		int_service_3   endp
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		int_service_4 proc near
                iret
		int_service_4   endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		int_service_5   proc    near
			; cli
			; call LCD_erase
			; inc center_x
			; call LCD_print
			; sti
		iret
		int_service_5   endp
		int_service_6   proc    near
			; cli
			; call LCD_erase
			; inc center_x
			; call LCD_print
			; sti
		iret
		int_service_6   endp
		int_service_7   proc    near
			; cli
			; call LCD_erase
			; dec center_x
			; call LCD_print
			; sti
		iret
		int_service_7   endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_service_move proc near
		
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
		
		ret
	int_service_move endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	add_tetris proc near
		push dx
		push cx
		push ax
		
		mov bl, center_y
		add bl, 1
		mov al, 00000001b
		mov cx, 4
		add_loop0:
			test box1, al
			jz add_loop0_continue
			mov bh, center_x
			add bh, cl
			sub bh, 2
			call add_item
			add_loop0_continue:
			rol al, 1
			loop add_loop0
			
			
		mov bl, center_y
		mov al, 00000001b
		mov cx, 4
		add_loop1:
			test box2, al
			jz add_loop1_continue
			mov bh, center_x
			add bh, cl
			sub bh, 2
			call add_item
			add_loop1_continue:
			rol al, 1
			loop add_loop1
			
		cmp center_y, 1
		je add_tetris_end
			
		mov bl, center_y
		sub bl, 1
		mov al, 00000001b
		mov cx, 4
		add_loop2:
			test box3, al
			jz add_loop2_continue
			mov bh, center_x
			add bh, cl
			sub bh, 2
			call add_item
			add_loop2_continue:
			rol al, 1
			loop add_loop2
			
		cmp center_y, 2
		je add_tetris_end
			
		mov bl, center_y
		sub bl, 2
		mov al, 00000001b
		mov cx, 4
		add_loop3:
			test box4, al
			jz add_loop3_continue
			mov bh, center_x
			add bh, cl
			sub bh, 2
			call add_item
			add_loop3_continue:
			rol al, 1
			loop add_loop3
		
		add_tetris_end:
			
		pop ax
		pop cx
		pop dx
		ret
	add_tetris endp
	
	add_item proc near ; P(bh: absolute x address, const bl: absolute y address)
		push dx
		push cx
		push ax
		
		mov al, bl ; bh: absolute x address, al: absolute y address
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row

		mov ax, 0000001000000000b
		mov cx, 0
		mov cl, bh
		dec cx
		test cx, cx
		jz add_item_skip
		add_item_loop0:
			ror ax, 1
			loop add_item_loop0
		; mov di, 4
		;or ax, [row1-2+di]
		;or [row1-2+di], ax		
		; or [row1+di-2], ax
		add_item_skip:
		or [row1+di-2], ax
		
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
		
		; mov cx, 1
		; collision_loop0:
			; mov di, cx;mov di, 2
			; mov dl, [box1+4-di] ; box3
			
			; mov bl, center_y ; bl: absolute y address
			; add bl, cl;add bl, 2
			; sub bl, 3
			
			; mov al, 00000001b
			
			; mov collision_tmp, cx
			; mov cx, 4
			; collision_loop1:
				; test dl, al	
				; jz collision_loop1_continue
				; mov bh, cl
				; sub bh, 2 ; bh: relative x address
				; add bh, center_x ; bh: absolute x address
				; call collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
				; test bh, bh
				; jnz collision_end1
				; collision_loop1_continue:
				; rol al, 1
				; loop collision_loop1
			; mov cx, collision_tmp
			; loop collision_loop0
			
		call collision_box1
		test bl, bl
		jnz collision_end1
		call collision_box2
		test bl, bl
		jnz collision_end1
		call collision_box3
		test bl, bl
		jnz collision_end1
		call collision_box4
		test bl, bl
		jnz collision_end1
		
		collision_end1:

		pop ax
		pop cx
		pop dx
		ret
	collision endp
	
	collision_box1 proc near
		push dx
		push cx
		push ax
		
		mov bl, center_y ; bl: absolute y address
		add bl, 1 ; modify
		mov al, 00000001b
		mov cx, 4
		collision_box1_loop:
			test box1, al ; modify
			jz collision_box1_loop_continue
			mov bh, cl
			sub bh, 2 ; bh: relative x address
			add bh, center_x ; bh: absolute x address
			call collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
			test bh, bh
			jnz collision_box1_end1
			collision_box1_loop_continue:
			rol al, 1
			loop collision_box1_loop
				
		mov bl, 0
		jmp collision_box1_end0
		collision_box1_end1: 
			mov bl, 1 
		collision_box1_end0:
		
		pop ax
		pop cx
		pop dx
		ret
	collision_box1 endp
		
	collision_box2 proc near
		push dx
		push cx
		push ax
		
		mov bl, center_y ; bl: absolute y address
		add bl, 0 ; modify
		mov al, 00000001b
		mov cx, 4
		collision_box2_loop:
			test box2, al ; modify
			jz collision_box2_loop_continue
			mov bh, cl
			sub bh, 2 ; bh: relative x address
			add bh, center_x ; bh: absolute x address
			call collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
			test bh, bh
			jnz collision_box2_end1
			collision_box2_loop_continue:
			rol al, 1
			loop collision_box2_loop
				
		mov bl, 0
		jmp collision_box2_end0
		collision_box2_end1: 
			mov bl, 1 
		collision_box2_end0:
		
		pop ax
		pop cx
		pop dx
		ret
	collision_box2 endp
	
	collision_box3 proc near
		push dx
		push cx
		push ax
		
		mov bl, center_y ; bl: absolute y address
		sub bl, 1 ; modify
		mov al, 00000001b
		mov cx, 4
		collision_box3_loop:
			test box3, al ; modify
			jz collision_box3_loop_continue
			mov bh, cl
			sub bh, 2 ; bh: relative x address
			add bh, center_x ; bh: absolute x address
			call collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
			test bh, bh
			jnz collision_box3_end1
			collision_box3_loop_continue:
			rol al, 1
			loop collision_box3_loop
				
		mov bl, 0
		jmp collision_box3_end0
		collision_box3_end1: 
			mov bl, 1 
		collision_box3_end0:
		
		pop ax
		pop cx
		pop dx
		ret
	collision_box3 endp
	
	collision_box4 proc near
		push dx
		push cx
		push ax
		
		mov bl, center_y ; bl: absolute y address
		sub bl, 2 ; modify
		mov al, 00000001b
		mov cx, 4
		collision_box4_loop:
			test box4, al ; modify
			jz collision_box4_loop_continue
			mov bh, cl
			sub bh, 2 ; bh: relative x address
			add bh, center_x ; bh: absolute x address
			call collision_test ; R(bh: 1 for collision, 0 otherwise)-P(bh: absolute x address, const bl: absolute y address)
			test bh, bh
			jnz collision_box4_end1
			collision_box4_loop_continue:
			rol al, 1
			loop collision_box4_loop
				
		mov bl, 0
		jmp collision_box4_end0
		collision_box4_end1: 
			mov bl, 1 
		collision_box4_end0:
		
		pop ax
		pop cx
		pop dx
		ret
	collision_box4 endp
	
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
		mov dx, [row1+di-2] ; dx: value of a row
		
		mov cx, 0
		mov cl, bh
		dec cx
		mov ax, 0000001000000000b
		test cx, cx
		jz collision_test_skip
		
		collision_test_loop0:
			ror ax, 1
			loop collision_test_loop0 ;
		collision_test_skip:
		test ax, dx
		jnz collision_test_end1
		mov bh, 0
		jmp collision_test_end0
		collision_test_end1:
			mov bh, 1
		collision_test_end0:
		
		; mov bh, 0
			
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
		mov cl, 2
		div cl
		inc al
		
		test ah, ah
		jz coordinate_absolute_to_LCD_l
		or al, 00001000b
		coordinate_absolute_to_LCD_l:
		mov bh, al ; store tmp x in bh
		
		mov al, bl
		mov cl, 4
		mul cl
		sub al, 4
		cmp al, 63
		jg coordinate_absolute_to_LCD_cs2
		mov bl, al
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
	delay proc near ; 10 ms
	push dx
	push cx
	push bx
	push ax
	sti
		mov cx, 3ffh;3ffh
		delay_loop: nop
		loop delay_loop
	cli
	pop ax
	pop bx
	pop cx
	pop dx
	ret
	delay endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	delay111 proc near ; 10 ms
	push dx
	push cx
	push bx
	push ax
	
		mov cx, 3ffh;3ffh
		delay_loop1: nop
		loop delay_loop1
	
	pop ax
	pop bx
	pop cx
	pop dx
	ret
	delay111 endp
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	            dead proc near
				push dx
                push cx
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
				call dead_I1
				jmp end_dead
				
				dead_T:
				call dead_T1
				jmp end_dead
				
				dead_L:
				call dead_L1
				jmp end_dead
				
				dead_J:
				call dead_J1
				jmp end_dead
				
				dead_Z:
				call dead_Z1
				jmp end_dead
				
				dead_S:
				call dead_S1
				jmp end_dead
				
				dead_O:
				call dead_O1
				jmp end_dead
				
				end_dead:
				
				pop ax
                pop cx
				pop dx
                ret
            dead endp
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				dead_I1 proc near				
                mov bh,4
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_I
                
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_I
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_I
                
                mov bh,7
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_I
                mov bl,0
				jmp end_dead_I1
				
                real_dead_I:
				mov bl,1
				
				end_dead_I1:
				ret
                dead_I1 endp
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                dead_T1 proc near				
                mov bh,4
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_T
                
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_T
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_T
                
                mov bh,5
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_T
                mov bl,0
                jmp end_dead_T1
				
				real_dead_T:
				mov bl, 1
				
				end_dead_T1:
				ret
				dead_T1 endp											
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                dead_L1 proc near
                mov bh,4
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_L
                
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_L
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_L
                
                mov bh,4
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_L
                mov bl,0
                jmp end_dead_L1
				
				real_dead_L:
				mov bl, 1
				
				end_dead_L1:
				ret
				dead_L1 endp	
				
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                dead_J1 proc near
                mov bh,4
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_J
                
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_J
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_J
                
                mov bh,6
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_J
                mov bl,0
                jmp end_dead_J1
				
				real_dead_J:
				mov bl, 1
				
				end_dead_J1:
				ret
				dead_J1 endp	
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                dead_Z1 proc near
                mov bh,4
                mov bl,20
                call collision
                cmp bl, 1
                je real_dead_Z
                
                mov bh,5
                mov bl,20
                call collision
                cmp bl, 1
                je real_dead_Z
                
                mov bh,5
                mov bl,19
                call collision
                cmp bl, 1
                je real_dead_Z
                
                mov bh,6
                mov bl,19
                call collision
                cmp bl, 1
                je real_dead_Z
				
                mov bl,0
                jmp end_dead_Z1
				
				real_dead_Z:
				mov bl, 1
				
				end_dead_Z1:
				ret
				dead_Z1 endp	
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                dead_S1 proc near
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_S
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_S
                
                mov bh,4
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_S
                
                mov bh,5
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_S
                mov bl,0
                jmp end_dead_S1
				
				real_dead_S:
				mov bl, 1
				
				end_dead_S1:
				ret
				dead_S1 endp	
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            dead_O1 proc near
                mov bh,5
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_O
                
                mov bh,6
                mov bl,20
                call collision
                cmp bh, 1
                je real_dead_O
                
                mov bh,5
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_O
                
                mov bh,6
                mov bl,19
                call collision
                cmp bh, 1
                je real_dead_O
                mov bl,0
                jmp end_dead_O1
                
                real_dead_O:
				mov bl, 1
				
				end_dead_O1:
				ret
				dead_O1 endp	
				;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	fill proc near
		push dx
		push cx
		push ax
		
		mov bl, 0
		
		mov al, center_y
		inc al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp [row1+di-2], 0000001111111111b
		jne fill_jmp0
		or bl, 00001000b ; 00001000b represents top
		fill_jmp0:
		
		mov al, center_y
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp [row1+di-2], 0000001111111111b
		jne fill_jmp1
		or bl, 00000100b
		fill_jmp1:
		
		mov al, center_y
		dec al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp [row1+di-2], 0000001111111111b
		jne fill_jmp2
		or bl, 00000010b
		fill_jmp2:
		
		mov al, center_y
		dec al
		dec al
		mov cl, 2
		mul cl ; al = 2 * absolute y address
		mov di, ax ; DS:[row1+di-2]: value of a row
		cmp [row1+di-2], 0000001111111111b
		jne fill_jmp3
		or bl, 00000001b
		fill_jmp3:
		
		pop ax
		pop cx
		pop dx
		ret
	fill endp

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
		
		mov LCD_drop_tmp, bl
		
		
		test LCD_drop_tmp, 00001000b ; modify
		jz LCD_drop_box1_skip
		mov bl, center_y
		inc bl ; modify
		mov cl, 20
		mov dx, row20
		mov LCD_drop_tmp2, dx
		LCD_drop_box1_loop:
			cmp cl, bl
			je LCD_drop_box1_skip
	
			mov LCD_drop_tmp1, cl
			mov al, LCD_drop_tmp1
			mov cl, 2
			mul cl
			mov di, ax
			
			mov dx, [row1+di-4]
			mov LCD_drop_tmp3, dx
			
			mov dx, LCD_drop_tmp2; mov dx, [row1+di-2]
			mov [row1+di-4], dx
			
			mov dx, LCD_drop_tmp3
			mov LCD_drop_tmp2, dx
			
			mov cl, LCD_drop_tmp1
			loop LCD_drop_box1_loop
		LCD_drop_box1_skip:
		
		test LCD_drop_tmp, 00000100b ; modify
		jz LCD_drop_box2_skip
		mov bl, center_y
		mov cl, 20
		mov dx, row20
		mov LCD_drop_tmp2, dx
		LCD_drop_box2_loop:
			cmp cl, bl
			je LCD_drop_box2_skip
	
			mov LCD_drop_tmp1, cl
			mov al, LCD_drop_tmp1
			mov cl, 2
			mul cl
			mov di, ax
			
			mov dx, [row1+di-4]
			mov LCD_drop_tmp3, dx
			
			mov dx, LCD_drop_tmp2; mov dx, [row1+di-2]
			mov [row1+di-4], dx
			
			mov dx, LCD_drop_tmp3
			mov LCD_drop_tmp2, dx
			
			mov cl, LCD_drop_tmp1
			loop LCD_drop_box2_loop
		LCD_drop_box2_skip:
		
		test LCD_drop_tmp, 00000010b ; modify
		jz LCD_drop_box3_skip
		mov bl, center_y
		sub bl, 1 ; modify
		mov cl, 20
		mov dx, row20
		mov LCD_drop_tmp2, dx
		LCD_drop_box3_loop:
			cmp cl, bl
			je LCD_drop_box3_skip
	
			mov LCD_drop_tmp1, cl
			mov al, LCD_drop_tmp1
			mov cl, 2
			mul cl
			mov di, ax
			
			mov dx, [row1+di-4]
			mov LCD_drop_tmp3, dx
			
			mov dx, LCD_drop_tmp2; mov dx, [row1+di-2]
			mov [row1+di-4], dx
			
			mov dx, LCD_drop_tmp3
			mov LCD_drop_tmp2, dx
			
			mov cl, LCD_drop_tmp1
			loop LCD_drop_box3_loop
		LCD_drop_box3_skip:
		
		test LCD_drop_tmp, 00000001b ; modify
		jz LCD_drop_box4_skip
		mov bl, center_y
		sub bl, 2 ; modify
		mov cl, 20
		mov dx, row20
		mov LCD_drop_tmp2, dx
		LCD_drop_box4_loop:
			cmp cl, bl
			je LCD_drop_box4_skip
	
			mov LCD_drop_tmp1, cl
			mov al, LCD_drop_tmp1
			mov cl, 2
			mul cl
			mov di, ax
			
			mov dx, [row1+di-4]
			mov LCD_drop_tmp3, dx
			
			mov dx, LCD_drop_tmp2; mov dx, [row1+di-2]
			mov [row1+di-4], dx
			
			mov dx, LCD_drop_tmp3
			mov LCD_drop_tmp2, dx
			
			mov cl, LCD_drop_tmp1
			loop LCD_drop_box4_loop
		LCD_drop_box4_skip:
		
		
		; mov bh, 00001000b ; bl: test bit
		; mov cx, 4
		; LCD_drop_loop0:
			; test bl, bh
			; jz LCD_drop_loop0_continue
			; mov al, center_y ;
			; add al, cl
			; sub al, 3 ; al: absolute y
			
			; LCD_drop_jmp0:
			
			; push cx
			; mov cx, 2
			; mul cl ; al: absolute y * 2
			; pop cx
			
			; cmp al, 40
			; je LCD_drop_toprow ; come to top row
			
			; mov di, ax
			; push bx
			; mov bx, DS:[row1 + di]
			; mov DS:[row1 + di -2], bx
			; pop bx
			
			; inc al
			; jmp LCD_drop_jmp0
			; LCD_drop_toprow:
				; mov DS:[row1 + di - 2], 0
			
			; LCD_drop_loop0_continue:
			; ror bh, 1
			; loop LCD_drop_loop0
			
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
		
		mov LCD_eliminate_tmp, bl
		
		test LCD_eliminate_tmp, 00001000b
		jz LCD_eliminate_box1_skip
		mov bl, center_y
		inc bl
		mov cx, 10
		LCD_eliminate_box1_loop:
			mov bh, cl
			call LCD_erase_4x4
			loop LCD_eliminate_box1_loop
		LCD_eliminate_box1_skip:
		
		test LCD_eliminate_tmp, 0000100b
		jz LCD_eliminate_box2_skip
		mov bl, center_y
		mov cx, 10
		LCD_eliminate_box2_loop:
			mov bh, cl
			call LCD_erase_4x4
			loop LCD_eliminate_box2_loop
		LCD_eliminate_box2_skip:
		
		cmp center_y, 1
		je LCD_eliminate_end
		test LCD_eliminate_tmp, 0000010b
		jz LCD_eliminate_box3_skip
		mov bl, center_y
		dec bl
		mov cx, 10
		LCD_eliminate_box3_loop:
			mov bh, cl
			call LCD_erase_4x4
			loop LCD_eliminate_box3_loop
		LCD_eliminate_box3_skip:
		
		cmp center_y, 2
		je LCD_eliminate_end
		test LCD_eliminate_tmp, 00000001b
		jz LCD_eliminate_box4_skip
		mov bl, center_y
		sub bl, 2
		mov cx, 10
		LCD_eliminate_box4_loop:
			mov bh, cl
			call LCD_erase_4x4
			loop LCD_eliminate_box4_loop
		LCD_eliminate_box4_skip:
		
		LCD_eliminate_end:
		
		mov bl, LCD_eliminate_tmp

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
			
			mov bl, 4
			sub bl, 3 ; bl: relative y address
			add bl, center_y ; bl: absolute y address
			mov al, 00000001b
			mov cx, 4
			LCD_erase_loop11:
				test box1, al	
				jz LCD_erase_loop11_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, center_x
				call LCD_erase_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_erase_loop11_continue:
				rol al, 1
				loop LCD_erase_loop11

			mov bl, 3
			sub bl, 3 ; bl: relative y address
			add bl, center_y ; bl: absolute y address
			mov al, 00000001b
			mov cx, 4
			LCD_erase_loop12:
				test box2, al	
				jz LCD_erase_loop12_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, center_x
				call LCD_erase_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_erase_loop12_continue:
				rol al, 1
				loop LCD_erase_loop12
		
		mov bl, 2
			sub bl, 3 ; bl: relative y address
			add bl, center_y ; bl: absolute y address
			mov al, 00000001b
			mov cx, 4
			LCD_erase_loop13:
				test box3, al	
				jz LCD_erase_loop13_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, center_x
				call LCD_erase_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_erase_loop13_continue:
				rol al, 1
				loop LCD_erase_loop13
				
		mov bl, 1
			sub bl, 3 ; bl: relative y address
			add bl, center_y ; bl: absolute y address
			mov al, 00000001b
			mov cx, 4
			LCD_erase_loop14:
				test box4, al	
				jz LCD_erase_loop14_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, center_x
				call LCD_erase_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
				LCD_erase_loop14_continue:
				rol al, 1
				loop LCD_erase_loop14
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_erase endp
	
	LCD_erase_4x4 proc near
		push dx
		push cx
		push ax
		mov LCD_erase_4x4_tmp1, bl
		
		call coordinate_absolute_to_LCD ; R(bh: LCD x coordinate + cs + m or l, bl: LCD y coordinate)-P(bh: absolute x address, const bl: absolute y address)
		
		test bh, 00010000b
		jnz LCD_erase_4x4_cs2
			test bh, 00001000b
			jnz LCD_erase_4x4_cs1_m
			mov LCD_erase_4x4_tmp, 11110000b
			jmp LCD_erase_4x4_cs1_l
			LCD_erase_4x4_cs1_m:
			mov LCD_erase_4x4_tmp, 00001111b
			LCD_erase_4x4_cs1_l:
			
				mov dx, lcd_cs1_control
				
				call LCD_busy_cs1
				and bh, 00000111b
				or bh, 10111000b
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs1
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs1_data
				call LCD_busy_cs1
				in al, dx ; get data
				call LCD_busy_cs1
				in al, dx ; get data
				mov ah, al
				
				mov dx, lcd_cs1_control
				call LCD_busy_cs1
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs1_data
				mov al, ah
				mov cx, 4
				and al, LCD_erase_4x4_tmp
				LCD_erase_4x4_cs1_l_loop:
					call LCD_busy_cs1
					out dx, al ; print
					loop LCD_erase_4x4_cs1_l_loop

				jmp LCD_erase_4x4_end0
		LCD_erase_4x4_cs2:
			test bh, 00001000b
			jnz LCD_erase_4x4_cs2_m
			mov LCD_erase_4x4_tmp, 11110000b
			jmp LCD_erase_4x4_cs2_l
			LCD_erase_4x4_cs2_m:
			mov LCD_erase_4x4_tmp, 00001111b
			LCD_erase_4x4_cs2_l:
				
				mov dx, lcd_cs2_control
				
				call LCD_busy_cs2
				and bh, 00000111b
				or bh, 10111000b
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs2
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs2
				mov dx, lcd_cs2_data
				in al, dx ; get data
				call LCD_busy_cs2
				in al, dx ; get data
				mov ah, al
				
				mov ah, al
				mov dx, lcd_cs2_control
				call LCD_busy_cs2
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs2_data
				mov al, ah
				mov cx, 4
				and al, LCD_erase_4x4_tmp
				LCD_erase_4x4_cs2_l_loop:
					call LCD_busy_cs2
					out dx, al ; print
					loop LCD_erase_4x4_cs2_l_loop
				jmp LCD_erase_4x4_end0
		
		LCD_erase_4x4_end0:

		mov bl, LCD_erase_4x4_tmp1
		
		pop ax
		pop cx
		pop dx
		
		ret
	LCD_erase_4x4 endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_flash proc near ; P(bl: 0000xxxx, x=1 line is filled)
		push dx
		push cx
		push ax
		
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
		out dx, al ; set cs2 start line address

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
		pop ax
		pop cx
		pop dx
		ret
		LCD_init endp
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		game_init proc near
		push dx
		push cx
		push ax
; print border
; print row
		mov dx, lcd_cs1_control
		
		call LCD_busy_cs1
		mov al, x_base + 1
		out dx, al ; set x address to cs1
		
		call LCD_busy_cs1
		mov al, y_base
		out dx, al ; set y address to cs1
		
		mov dx, lcd_cs2_control
		
		call LCD_busy_cs2
		mov al, x_base + 1
		out dx, al ; set x address to cs2
		
		call LCD_busy_cs2
		mov al, y_base
		out dx, al ; set y address to cs2
		
		mov al, 00001000b ; set data
		mov cx, 64
		LCD_init_loop3:
			mov dx, lcd_cs1_data
			call LCD_busy_cs1
			out dx, al ; set data to cs1
			
			mov dx, lcd_cs2_data
			call LCD_busy_cs2
			out dx, al ; set dat to cs1
			loop LCD_init_loop3
			
; print row2nd
mov dx, lcd_cs1_control
		
		call LCD_busy_cs1
		mov al, x_base + 6
		out dx, al ; set x address to cs1
		
		call LCD_busy_cs1
		mov al, y_base
		out dx, al ; set y address to cs1
		
		mov dx, lcd_cs2_control
		
		call LCD_busy_cs2
		mov al, x_base + 6
		out dx, al ; set x address to cs2
		
		call LCD_busy_cs2
		mov al, y_base
		out dx, al ; set y address to cs2
		
		mov al, 00010000b ; set data
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
		
		mov al, 11111111b ; set data
		mov ah, x_base ; store x address to ah
		mov cx, 8
		LCD_init_loop2:
			mov dx, lcd_cs2_data
			call LCD_busy_cs2
			mov al, 11111111b
			out dx, al ; set data to cs2
			
			inc ah
			mov dx, lcd_cs2_control
			call LCD_busy_cs2
			mov al, ah
			out dx, al ; set x address to cs2	
			
			mov dx, lcd_cs2_control
			call LCD_busy_cs2
			mov al, y_base + 16
			out dx, al ; set y address to cs2	
			loop LCD_init_loop2				
		
		pop ax
		pop cx
		pop dx
		ret
	game_init endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_print proc near
		push dx
		push cx
		push ax
			
		mov cx, 4
		LCD_print_loop0:
			mov dx, 4
			sub dx, cx
			mov di, dx ; set offset
			
			mov bl, cl
			sub bl, 3 ; bl: relative y address
			add bl, center_y ; bl: absolute y address
			mov al, 00000001b
			
			push cx
			mov cx, 4
			LCD_print_loop1:
				test [box1+di], al	
				jz LCD_print_loop1_continue
				mov bh, cl
				sub bh, 2 ; bh: relative x address
				add bh, center_x
				call LCD_print_4x4 ; P(bh: absolute x address, const bl: absolute y address)
				
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
		mov LCD_print_4x4_tmp1, bl
		
		call coordinate_absolute_to_LCD ; R(bh: LCD x coordinate + cs + m or l, bl: LCD y coordinate)-P(bh: absolute x address, const bl: absolute y address)
		
		test bh, 00010000b
		jnz LCD_print_4x4_cs2
			test bh, 00001000b
			jnz LCD_print_4x4_cs1_m
			mov LCD_print_4x4_tmp, 00001111b
			jmp LCD_print_4x4_cs1_l
			LCD_print_4x4_cs1_m:
			mov LCD_print_4x4_tmp, 11110000b
			LCD_print_4x4_cs1_l:
			
				mov dx, lcd_cs1_control
				
				call LCD_busy_cs1
				and bh, 00000111b
				or bh, 10111000b
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs1
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs1_data
				call LCD_busy_cs1
				in al, dx ; get data
				call LCD_busy_cs1
				in al, dx ; get data
				mov ah, al
				
				mov dx, lcd_cs1_control
				call LCD_busy_cs1
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs1_data
				mov al, ah
				mov cx, 4
				or al, LCD_print_4x4_tmp
				LCD_print_4x4_cs1_l_loop:
					call LCD_busy_cs1
					out dx, al ; print
					loop LCD_print_4x4_cs1_l_loop

				jmp LCD_print_4x4_end0
		LCD_print_4x4_cs2:
			test bh, 00001000b
			jnz LCD_print_4x4_cs2_m
			mov LCD_print_4x4_tmp, 00001111b
			jmp LCD_print_4x4_cs2_l
			LCD_print_4x4_cs2_m:
			mov LCD_print_4x4_tmp, 11110000b
			LCD_print_4x4_cs2_l:
				
				mov dx, lcd_cs2_control
				
				call LCD_busy_cs2
				and bh, 00000111b
				or bh, 10111000b
				mov al, bh
				out dx, al ; set x address of cs1
				
				call LCD_busy_cs2
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				call LCD_busy_cs2
				mov dx, lcd_cs2_data
				in al, dx ; get data
				call LCD_busy_cs2
				in al, dx ; get data
				mov ah, al
				
				mov ah, al
				mov dx, lcd_cs2_control
				call LCD_busy_cs2
				or bl, 01000000b
				mov al, bl
				out dx, al ; set y address of cs1
				
				mov dx, lcd_cs2_data
				mov al, ah
				mov cx, 4
				or al, LCD_print_4x4_tmp
				LCD_print_4x4_cs2_l_loop:
					call LCD_busy_cs2
					out dx, al ; print
					loop LCD_print_4x4_cs2_l_loop
				jmp LCD_print_4x4_end0
		
		LCD_print_4x4_end0:

		mov bl, LCD_print_4x4_tmp1
		
		pop ax
		pop cx
		pop dx
		
		ret
	LCD_print_4x4 endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LCD_reprint proc near
		push dx
		push cx
		push ax
			
		call LCD_init
		call game_init
		
		mov cx, 20
	    LCD_reprint_row:
			mov LCD_reprint_tmp, cx
			
			mov bl, cl
			mov ax, cx
			mov cx, 2
			mul cx
			mov di, ax
			mov dx, [row1+di-2]
			mov LCD_reprint_tmp1, dx
			
			call LCD_reprint_1
			call LCD_reprint_2
			call LCD_reprint_3
			call LCD_reprint_4
			call LCD_reprint_5
			call LCD_reprint_6
			call LCD_reprint_7
			call LCD_reprint_8
			call LCD_reprint_9
			call LCD_reprint_10
			
			mov cx, LCD_reprint_tmp
		loop LCD_reprint_row
		
		
		pop ax
		pop cx
		pop dx
		ret
	LCD_reprint endp
			
	LCD_reprint_1 proc near
			test LCD_reprint_tmp1, 0000001000000000b
			jz LCD_reprint_skip1
			mov bh, 1
			call LCD_print_4x4
			LCD_reprint_skip1:
			ret
	LCD_reprint_1 endp
			
	LCD_reprint_2 proc near
			test LCD_reprint_tmp1, 0000000100000000b
			jz LCD_reprint_skip2
			mov bh, 2
			call LCD_print_4x4
			LCD_reprint_skip2:
			ret
	LCD_reprint_2 endp
			
	LCD_reprint_3 proc near
			test LCD_reprint_tmp1, 0000000010000000b
			jz LCD_reprint_skip3
			mov bh, 3
			call LCD_print_4x4
			LCD_reprint_skip3:
			ret
	LCD_reprint_3 endp
			
	LCD_reprint_4 proc near
			test LCD_reprint_tmp1, 0000000001000000b
			jz LCD_reprint_skip4
			mov bh, 4
			call LCD_print_4x4
			LCD_reprint_skip4:
			ret
	LCD_reprint_4 endp
			
	LCD_reprint_5 proc near
			test LCD_reprint_tmp1, 0000000000100000b
			jz LCD_reprint_skip5
			mov bh, 5
			call LCD_print_4x4
			LCD_reprint_skip5:
			ret
	LCD_reprint_5 endp
			
	LCD_reprint_6 proc near
			test LCD_reprint_tmp1, 0000000000010000b
			jz LCD_reprint_skip6
			mov bh, 6
			call LCD_print_4x4
			LCD_reprint_skip6:
			ret
	LCD_reprint_6 endp
			
	LCD_reprint_7 proc near
			test LCD_reprint_tmp1, 0000000000001000b
			jz LCD_reprint_skip7
			mov bh, 7
			call LCD_print_4x4
			LCD_reprint_skip7:
			ret
	LCD_reprint_7 endp
			
	LCD_reprint_8 proc near
			test LCD_reprint_tmp1, 0000000000000100b
			jz LCD_reprint_skip8
			mov bh, 8
			call LCD_print_4x4
			LCD_reprint_skip8:
			ret
	LCD_reprint_8 endp
			
	LCD_reprint_9 proc near
			test LCD_reprint_tmp1, 0000000000000010b
			jz LCD_reprint_skip9
			mov bh, 9
			call LCD_print_4x4
			LCD_reprint_skip9:
			ret
	LCD_reprint_9 endp
			
	LCD_reprint_10 proc near
			test LCD_reprint_tmp1, 0000000000000001b
			jz LCD_reprint_skip10
			mov bh, 10
			call LCD_print_4x4
			LCD_reprint_skip10:
			ret
	LCD_reprint_10 endp
			
		; mov ax, 0000000000000001b
		; mov cx, 10
		; LCD_reprint_column:
			; mov bh, cl
			; mov bl, LCD_reprint_tmp1
			; test [row1+di-2], ax
			; jz LCD_reprint_column_skip
			; call LCD_print_4x4
			; LCD_reprint_column_skip:
			; rol ax, 1
			; loop LCD_reprint_column
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	random_generator proc near
		push dx
		push cx
		push bx
		push ax
		
		; Using formular x1 = ( x0 * a + c ) MOD 2^16 to generate random seed
		
		; mov al, random_seed
		; mov cl, 6
		; mul cl
		; add al, 6
		; mov random_seed, al
		
		; Get remainder
		; mov cl, 7
		; div cl
		; mov random_number, ah
		
		
		mov bx, offset_number
		mov dl, CS:[bx]
		mov random_number, dl
		
		inc bx
		mov offset_number, bx
		
		
		pop ax
		pop bx
		pop cx
		pop dx
		ret
	random_generator endp
	
	row_init proc near
		push dx
		push cx
		push ax
		
		mov cx, 40
		row_init_loop:
			mov di, cx
			mov [row1+di-1],0
			loop row_init_loop
			
		pop ax
		pop cx
		pop dx
		ret
	row_init endp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_init proc near
		push dx
		push cx
		push ax
		
		mov center_x, 5
		mov center_y, 20
		
		cmp random_number, 0
		jne tetris_init_end0
		call tetris_init_pick_I
		tetris_init_end0:
		
		cmp random_number, 1
		jne tetris_init_end1
		call tetris_init_pick_T
		tetris_init_end1:
		
		cmp random_number, 2
		jne tetris_init_end2
		call tetris_init_pick_L
		tetris_init_end2:
		
		cmp random_number, 3
		jne tetris_init_end3
		call tetris_init_pick_J
		tetris_init_end3:
		
		cmp random_number, 4
		jne tetris_init_end4
		call tetris_init_pick_Z
		tetris_init_end4:
		
		cmp random_number, 5
		jne tetris_init_end5
		call tetris_init_pick_S
		tetris_init_end5:
		
		cmp random_number, 6
		jne tetris_init_end6
		call tetris_init_pick_O
		tetris_init_end6:
		
		pop ax
		pop cx
		pop dx
		ret
	tetris_init endp	
	
	
		tetris_init_pick_I proc near
			mov box1, 0
			mov box2, 00001111b
			mov box3, 0
			mov box4, 0
			ret
		tetris_init_pick_I endp
			
		tetris_init_pick_T proc near
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000100b
			mov box4, 0
			ret
		tetris_init_pick_T endp

		tetris_init_pick_L proc near
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00001000b
			mov box4, 0
			ret
		tetris_init_pick_L endp
			
		tetris_init_pick_J proc near
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000010b
			mov box4, 0
			ret
		tetris_init_pick_J endp
		
		tetris_init_pick_Z proc near
			mov box1, 0
			mov box2, 00001100b
			mov box3, 00000110b
			mov box4, 0
			ret
		tetris_init_pick_Z endp
			
		tetris_init_pick_S proc near
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00001100b
			mov box4, 0
			ret
		tetris_init_pick_S endp

		tetris_init_pick_O proc near
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00000110b
			mov box4, 0
			ret
		tetris_init_pick_O endp
		
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	tetris_drop proc near
	
		ret
	tetris_drop endp	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_start0 proc near
    mov	bx, offset pg05
	mov pointer, 10111000b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,1
	start_loop00:
	push cx
	mov cx, 24
	start_loop01:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop01
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop00
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg07
	mov pointer, 10111000b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,1
	start_loop02:
	push cx
	mov cx, 16
	start_loop03:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop03
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop02

	
	ret
	draw_start0 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_start1 proc near
	mov	bx, offset pg04
	mov pointer, 10111000b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop10:
	push cx
	mov cx, 24
	start_loop11:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop11
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop10
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111000b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop12:
	push cx
	mov cx, 16
	start_loop13:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop13
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop12

	
	ret
draw_start1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_start2 proc near
	mov	bx, offset pg04
	mov pointer, 10111001b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop20:
	push cx
	mov cx, 24
	start_loop21:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop21
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop20
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111001b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop22:
	push cx
	mov cx, 16
	start_loop23:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop23
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop22

	
	ret
draw_start2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_start3 proc near
	mov	bx, offset pg01
	mov pointer, 10111000b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,1
	picture_loop30:
	push cx
	mov cx, 48
	picture_loop31:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop31
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop picture_loop30
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg03
	mov pointer, 10111000b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
	
	mov cx,1
	picture_loop32:
	push cx
	mov cx, 32
	picture_loop33:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop33
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
    loop picture_loop32
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
mov	bx, offset pg04
	mov pointer, 10111010b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop34:
	push cx
	mov cx, 24
	start_loop35:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop35
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop34
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111010b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop36:
	push cx
	mov cx, 16
	start_loop37:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop37
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop36

	
	ret
draw_start3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_start4 proc near
	mov	bx, offset pg00
	mov pointer, 10111000b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,2
	picture_loop40:
	push cx
	mov cx, 48
	picture_loop41:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop41
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop picture_loop40
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg02
	mov pointer, 10111000b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
	
	mov cx,2
	picture_loop42:
	push cx
	mov cx, 32
	picture_loop43:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop43
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
    loop picture_loop42
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
mov	bx, offset pg04
	mov pointer, 10111011b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop44:
	push cx
	mov cx, 24
	start_loop45:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop45
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop44
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111011b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop46:
	push cx
	mov cx, 16
	start_loop47:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop47
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop46

	
	ret
draw_start4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

draw_start5 proc near
	mov	bx, offset pg00
	mov pointer, 10111001b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,2
	picture_loop50:
	push cx
	mov cx, 48
	picture_loop51:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop51
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop picture_loop50
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg02
	mov pointer, 10111001b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
	
	mov cx,2
	picture_loop52:
	push cx
	mov cx, 32
	picture_loop53:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop53
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
    loop picture_loop52
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
mov	bx, offset pg04
	mov pointer, 10111100b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop54:
	push cx
	mov cx, 24
	start_loop55:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop55
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop54
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111100b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop56:
	push cx
	mov cx, 16
	start_loop57:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop57
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop56

	
	ret
draw_start5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_start6 proc near
	mov	bx, offset pg00
	mov pointer, 10111010b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,2
	picture_loop60:
	push cx
	mov cx, 48
	picture_loop61:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop61
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop picture_loop60
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg02
	mov pointer, 10111010b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
	
	mov cx,2
	picture_loop62:
	push cx
	mov cx, 32
	picture_loop63:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop picture_loop63
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01001000b
	out dx, al
    loop picture_loop62
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
mov	bx, offset pg04
	mov pointer, 10111101b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
	
	mov cx,2
	start_loop64:
	push cx
	mov cx, 24
	start_loop65:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop65
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01101000b
	out dx, al
    loop start_loop64
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg06
	mov pointer, 10111101b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,2
	start_loop66:
	push cx
	mov cx, 16
	start_loop67:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop start_loop67
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop start_loop66

	
	ret
draw_start6 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_end proc near
mov	bx, offset pg08
	mov pointer, 10111010b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,2
	end_loop0:
	push cx
	mov cx, 24
	end_loop1:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop end_loop1
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop end_loop0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	mov	bx, offset pg10
	mov pointer, 10111101b

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
	
	mov cx,2
	end_loop00:
	push cx
	mov cx, 32
	end_loop01:
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop end_loop01
	pop cx
	inc pointer
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs1
	mov	dx,lcd_cs1_control
	mov al, 01010000b
	out dx, al
    loop end_loop00
	
	ret
	draw_end endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
draw_face proc near
	mov	bx, offset pg20
	mov pointer, 10111001b

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al

	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
	
	mov cx,5
	face_loop00:
	push cx
	mov cx, 41
	face_loop01:
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop face_loop01
	pop cx
	inc pointer
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, pointer
	out dx, al
	
	call	LCD_busy_cs2
	mov	dx,lcd_cs2_control
	mov al, 01000000b
	out dx, al
    loop face_loop00

	ret
	draw_face endp
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



start_change_sharpI proc near
		
		
		mov center_x, 8
		mov center_y, 6
		
	
			mov box1, 0
			mov box2, 00001111b
			mov box3, 0
			mov box4, 0
		call LCD_print
		
		ret
start_change_sharpI endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
start_change_sharpT proc near
		mov cx, 100
				

				main_delay01:
			
					call delay ; Pending
				loop main_delay01
		call LCD_erase
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000100b
			mov box4, 0
			call LCD_print
			
			ret
start_change_sharpT endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
			
start_change_sharpL proc near		
		
		mov cx, 100				
				main_delay02:
			
					call delay ; Pending
				loop main_delay02
		call LCD_erase
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00001000b
			mov box4, 0
		call LCD_print
		
		ret
start_change_sharpL endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
start_change_sharpJ proc near		
		mov cx, 100
				

				main_delay03:
			
					call delay ; Pending
				loop main_delay03
		call LCD_erase
			mov box1, 0
			mov box2, 00001110b
			mov box3, 00000010b
			mov box4, 0
		call LCD_print
		
		ret
start_change_sharpJ endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
start_change_sharpZ proc near		
		mov cx, 100
				

				main_delay04:
			
					call delay ; Pending
				loop main_delay04
		call LCD_erase
			mov box1, 0
			mov box2, 00001100b
			mov box3, 00000110b
			mov box4, 0
		call LCD_print
		
		ret
start_change_sharpZ endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
start_change_sharpS proc near		
		mov cx, 100
				

				main_delay05:
			
					call delay ; Pending
				loop main_delay05
		call LCD_erase
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00001100b
			mov box4, 0
		call LCD_print
		ret
start_change_sharpS endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start_change_sharpO proc near		
		mov cx, 100
				

				main_delay06:
			
					call delay ; Pending
				loop main_delay06
		call LCD_erase
			mov box1, 0
			mov box2, 00000110b
			mov box3, 00000110b
			mov box4, 0
		call LCD_print	
				
		mov cx, 100
				

				main_delay07:
			
					call delay ; Pending
				loop main_delay07
		call LCD_erase
	
		ret
start_change_sharpO endp
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lcd_2x16 proc near
mov        dx,clcd_base
busy3:  in       al,dx
and        al,10000000b
jnz        busy3

mov al, 00000001b   ;clc
out dx, al
;
mov        al,10000000b    ;set display address to 0
out         dx,al
mov        bx, offset output_string1  ;To put the string to be printed out in BX
call         print_string  ;To print our the string

mov        dx,clcd_base
busy4:  in        al,dx
and        al,10000000b
jnz        busy4

;Since the address on the beginning of the second line is 40h
;so we add 10000000b(80h) with 1000000b(40h)=11000000b and put this into al
mov       al,11000000b    ;set display address to 1
out        dx,al
mov        bx, offset output_string2  ;To put the string to be printed out in BX
call        print_string
ret
lcd_2x16 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lcd_score proc near
mov        dx,clcd_base
busy5:  in       al,dx
and        al,10000000b
jnz        busy5

mov al, 00000001b   ;clc
out dx, al
;
mov        al,10000000b    ;set display address to 0
out         dx,al
mov        bx, offset output_string3  ;To put the string to be printed out in BX
call         print_string  ;To print our the string
ret
lcd_score endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lcd_print_score proc near
mov        dx,clcd_base
busy6:  in        al,dx
and        al,10000000b
jnz        busy6

;Since the address on the beginning of the second line is 40h
;so we add 10000000b(80h) with 1000000b(40h)=11000000b and put this into al
mov       al,11000000b    ;set display address to 1
out        dx,al
;test;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp		score, 0
jne     score_1
call		score0
call 		print_string
jmp			end_lcd_print_score
score_1:
cmp		score, 1
jne score_2
call		score1
call 		print_string
jmp			end_lcd_print_score
score_2:
cmp		score, 2
jne score_3
call		score2
call 		print_string
jmp			end_lcd_print_score
score_3:
cmp		score, 3
jne     score_4
call		score3
call 		print_string
jmp			end_lcd_print_score
score_4:
cmp		score, 4
jne     score_5
call		score4
call 		print_string
jmp			end_lcd_print_score
score_5:
cmp		score, 5
jne     score_6
call		score5
call 		print_string
jmp			end_lcd_print_score
score_6:
cmp		score, 6
jne     score_7
call		score6
call 		print_string
jmp			end_lcd_print_score
score_7:
cmp		score, 7
jne     score_8
call		score7
call 		print_string
jmp			end_lcd_print_score
score_8:
cmp		score, 8
jne     score_9
call	score8
call 		print_string
jmp			end_lcd_print_score
score_9:
cmp		score, 9
jne	  score_10
call		score9
call 		print_string
jmp			end_lcd_print_score
score_10:
cmp		score, 10
jne	  score_11
call		score10
call        print_string

end_lcd_print_score:
jmp end_lcd_print_score0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

score_11:
cmp		score, 11
jne score_12
call		score11
call 		print_string
jmp			end_lcd_print_score0
score_12:
cmp		score, 12
jne score_13
call		score12
call 		print_string
jmp			end_lcd_print_score0
score_13:
cmp		score, 13
jne     score_14
call		score13
call 		print_string
jmp			end_lcd_print_score0
score_14:
cmp		score, 14
jne     score_15
call		score14
call 		print_string
jmp			end_lcd_print_score0
score_15:
cmp		score, 15
jne     score_16
call		score15
call 		print_string
jmp			end_lcd_print_score0
score_16:
cmp		score, 16
jne     score_17
call		score16
call 		print_string
jmp			end_lcd_print_score0
score_17:
cmp		score, 17
jne     score_18
call		score17
call 		print_string
jmp			end_lcd_print_score0
score_18:
cmp		score, 18
jne     score_19
call	score18
call 		print_string
jmp			end_lcd_print_score0
score_19:
cmp		score, 19
jne	  score_20
call		score19
call 		print_string
jmp			end_lcd_print_score0
score_20:
cmp		score, 20
jne	  end_lcd_print_score0
call		score20
call        print_string
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


end_lcd_print_score0:
ret
lcd_print_score endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score0 proc near
mov        bx, offset output_string00  
ret;To put the string to be printed out in BX
score0 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score1 proc near
mov        bx, offset output_string01  ;To put the string to be printed out in BX
ret
score1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score2 proc near
mov        bx, offset output_string02  ;To put the string to be printed out in BX
ret
score2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score3 proc near
mov        bx, offset output_string03  ;To put the string to be printed out in BX
ret
score3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score4 proc near
mov        bx, offset output_string04  ;To put the string to be printed out in BX
ret
score4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score5 proc near
mov        bx, offset output_string05  ;To put the string to be printed out in BX
ret
score5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score6 proc near
mov        bx, offset output_string06  ;To put the string to be printed out in BX
ret
score6 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score7 proc near
mov        bx, offset output_string07  ;To put the string to be printed out in BX
ret
score7 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score8 proc near
mov        bx, offset output_string08  ;To put the string to be printed out in BX
ret
score8 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score9 proc near
mov        bx, offset output_string09 ;To put the string to be printed out in BX
ret
score9 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score10 proc near
mov        bx, offset output_string10 ;To put the string to be printed out in BX
ret
score10 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score11 proc near
mov        bx, offset output_string11  ;To put the string to be printed out in BX
ret
score11 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score12 proc near
mov        bx, offset output_string12  ;To put the string to be printed out in BX
ret
score12 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score13 proc near
mov        bx, offset output_string13  ;To put the string to be printed out in BX
ret
score13 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score14 proc near
mov        bx, offset output_string14  ;To put the string to be printed out in BX
ret
score14 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score15 proc near
mov        bx, offset output_string15  ;To put the string to be printed out in BX
ret
score15 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score16 proc near
mov        bx, offset output_string16  ;To put the string to be printed out in BX
ret
score16 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score17 proc near
mov        bx, offset output_string17  ;To put the string to be printed out in BX
ret
score17 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score18 proc near
mov        bx, offset output_string18  ;To put the string to be printed out in BX
ret
score18 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score19 proc near
mov        bx, offset output_string19 ;To put the string to be printed out in BX
ret
score19 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score20 proc near
mov        bx, offset output_string20 ;To put the string to be printed out in BX
ret
score20 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;initialize LCD
;clcd_base         EQU   0f0H
INIT_LCD   PROC  NEAR
;set function
mov        dx,clcd_base
mov        al,00111000b     ;8-bit, 2-line
out        dx,al
busy1:  in       al,dx       ;check busy flag
and        al,10000000b
jnz        busy1
;set display mode
mov        al,00001100b     ;on, no cursor, no blink
out        dx,al
busy2:  in       al,dx      ;check busy flag
and        al,10000000b
jnz        busy2
;set cursor mode
mov        al,00000110b     ;cursor shift
out        dx,al
ret
INIT_LCD   ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_string    proc    near
;print string points by bx
;end if character is 0dh
mov        dx,clcd_base
ps0:    in       al,dx
and        al,10000000b
jnz        ps0
ps1:    inc      dx         ;point to data register
mov        al,CS:[bx]
cmp        al, 0dh         ;check end of string
je         end_print
out        dx,al
inc        bx
dec        dx              ;point to instruction register
jmp   short      ps0
end_print:      ret
print_string    endp

;We define our names and student IDs here
output_string1 db 'Please Push',0dh
output_string2 db 'Start Button',0dh
output_string3 db 'Your Score',0dh
output_string00 db 'is 00',0dh
output_string01 db 'is 01',0dh
output_string02 db 'is 02',0dh
output_string03 db 'is 03',0dh
output_string04 db 'is 04',0dh
output_string05 db 'is 05',0dh
output_string06 db 'is 06',0dh
output_string07 db 'is 07',0dh
output_string08 db 'is 08',0dh
output_string09 db 'is 09',0dh
output_string10 db 'is 10',0dh
output_string11 db 'is 11',0dh
output_string12 db 'is 12',0dh
output_string13 db 'is 13',0dh
output_string14 db 'is 14',0dh
output_string15 db 'is 15',0dh
output_string16 db 'is 16',0dh
output_string17 db 'is 17',0dh
output_string18 db 'is 18',0dh
output_string19 db 'is 19',0dh
output_string20 db 'is 20',0dh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test_eliminate proc mear
                    mov eliminate_test, bl
					cmp bl, 00000001b
					je add1
					cmp bl, 00000010b
					je add1
					cmp bl, 00000100b
					je add1
					cmp bl, 00001000b
					je add1
					
					cmp bl, 00000011b
					je add2
					cmp bl, 00000101b
					je add2
					cmp bl, 00001001b
					je add2
					cmp bl, 00000110b
					je add2
					cmp bl, 00001010b
					je add2
					cmp bl, 00001100b
					je add2
																				
				    cmp bl, 00000111b
					je add3					
					cmp bl, 00001110b
					je add3
					
					cmp bl, 00001111b
					je add4
					
					add1:
					inc score
					call lcd_print_score
					jmp go_eliminate
					
					add2:
					inc score
					inc score
					call lcd_print_score
					jmp go_eliminate
					
					add3:
					inc score
					inc score
					inc score
					call lcd_print_score
					jmp go_eliminate
					
					add4:
					inc score
					inc score
					inc score
					inc score
					call lcd_print_score
go_eliminate:
mov bl, eliminate_test
ret				
test_eliminate endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
integer db 2,	6,	3,	1,	6,	6,	3,	5,	4,	3,	3,	6,	6,	5,	5,	6,	4,	6,	2,	4,	2,	1,	6,	1,	0,	5,	2,	0,	1,	2,	3,	0,	2,	4,	6,	2,	2,	2,	5
integer1 db 4,	1,	1,	0,	5,	0,	6,	6,	1,	1,	3,	1,	5,	5,	3,	0,	6,	6,	4,	0,	1,	2,	3,	1,	0,	0,	1,	1,	3,	6,	1,	6,	4,	5,	2,	2,	6,	4,	4,	6,	2,	4,	3,	3,	2,	1,	5,	3,	4,	1,	2,	1,	6,	2,	0,	6,	4,	6,	3,	1,	2,	3,	5,	1,	3,	4,	4,	1,	2,	5,	4,	5,	3,	6,	0,	5,	1,	2,	1,	1,	4,	6,	4,	2,	2,	3,	3,	0,	0,	1,	0,	0,	2,	0,	2,	0,	3,	2,	1,	0,	2,	0,	4,	4,	2,	5,	3,	2,	1,	6,	6,	0,	5,	2,	3,	2,	4,	4,	2,	5,	6,	2,	1,	3,	1,	5,	5,	5,	1,	4,	3,	3,	2,	5,	5,	1,	0,	2,	5,	4,	3,	4,	5,	3,	2,	3,	4,	6,	3,	4,	2,	0,	2,	2,	0,	5,	6,	4,	2,	5,	3,	5,	6,	5,	3,	4,	6,	6,	3,	1,	4,	6,	4,	1,	1,	5,	6,	3,	6,	1,	1,	1,	3,	4,	1,	6,	2,	4,	4,	5,	2,	5,	2,	4,	3,	5,	3	
integer2 db 4,	0,	5,	6,	1,	1,	3,	4,	3,	5,	4,	5,	1,	4,	5,	1,	2,	6,	4,	0,	4,	3,	6,	5,	6,	5,	6,	0,	2,	5,	2,	1,	5,	0,	3,	0,	6,	4,	0,	0,	6,	3,	1,	1,	0,	2,	3,	1,	4,	1,	2,	2,	0,	5,	1,	3,	1,	4,	6,	6,	4,	4,	6,	4,	5,	2,	1,	6,	1,	1,	5,	0,	1,	0,	1,	5,	0,	6,	2,	4,	3,	5,	3,	4,	5,	2,	5,	0,	2,	1,	1,	1,	0,	3,	4,	4,	4,	2,	6,	0,	2,	0,	4,	1,	3,	3,	2,	0,	2,	2,	2,	4,	0,	4,	5,	0,	6,	4,	2,	5,	5,	6,	6,	2,	5,	4,	2,	1,	1,	6,	5,	6,	4,	3,	4,	4,	4,	6,	1,	3,	4,	1,	3,	5,	5,	6,	3,	0,	1,	3,	6,	1,	6,	0,	3,	6,	1,	5,	5,	3,	3,	0,	5,	2,	3,	1,	1,	2,	1,	1,	6,	4,	2,	1,	6,	1,	5,	3,	3,	1,	6,	2,	1,	6,	1,	0,	5,	5,	2,	5,	6,	4,	5,	2,	2,	4,	2
integer3 db 5	,6,	0,	3,	0,	6,	6,	5,	6,	2,	1,	1,	0,	1,	0,	2,	2,	0,	4,	5,	2,	2,	1,	6,	2,	3,	3,	0,	3,	5,	1,	2,	5,	5,	2,	5,	2,	3,	5,	0,	4,	0,	2,	1,	1,	4,	6,	5,	4,	5,	4,	0,	0,	5,	0,	1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pg00 DB 01Ch,01Ch,004h,0FCh,0FCh,004h,01Ch,000h,004h,0FCh,0FCh,084h,0E4h,0ECh,01Ch,000h,01Ch,01Ch,004h,0FCh,0FCh,004h,01Ch,000h,0FCh,0FCh,0FCh,084h,084h,0FCh,07Ch,000h,000h,000h,004h,0FCh,0FCh,004h,000h,000h,038h,07Ch,0FCh,0C4h,084h,08Ch,01Ch,000h
pg01 db 000h,020h,020h,03Fh,03Fh,020h,020h,000h,020h,03Fh,03Fh,020h,023h,033h,03Ch,000h,000h,020h,020h,03Fh,03Fh,020h,020h,000h,03Fh,03Fh,03Fh,023h,00Fh,03Fh,038h,000h,000h,020h,020h,03Fh,03Fh,020h,020h,000h,01Ch,03Ch,030h,020h,021h,033h,03Fh,000h
pg02 db 0F0h,0FCh,03Ch,004h,004h,00Ch,01Ch,000h,000h,000h,0F0h,0FCh,0FCh,0F8h,000h,000h,0FCh,0FCh,0FCh,0E0h,0FCh,0FCh,0FCh,000h,004h,0FCh,0FCh,084h,0E4h,0ECh,01Ch,000h
pg03 db 00Fh,01Fh,03Ch,020h,021h,03Fh,01Fh,000h,030h,03Fh,02Fh,002h,027h,03Fh,03Fh,020h,03Fh,03Fh,03Fh,01Fh,03Fh,03Fh,03Fh,000h,020h,03Fh,03Fh,020h,023h,033h,03Ch,000h
pg04 db 038h,07Ch,0FCh,0C4h,084h,08Ch,01Ch,000h,01Ch,01Ch,004h,0FCh,0FCh,004h,01Ch,000h,000h,000h,0F0h,0FCh,0FCh,0F8h,000h,000h
pg05 db 01Ch,03Ch,030h,020h,021h,033h,03Fh,000h,000h,020h,020h,03Fh,03Fh,020h,020h,000h,030h,03Fh,02Fh,002h,027h,03Fh,03Fh,000h
pg06 db 0FCh,0FCh,0FCh,084h,084h,0FCh,07Ch,000h,01Ch,01Ch,004h,0FCh,0FCh,004h,01Ch,01Ch
pg07 db 03Fh,03Fh,03Fh,023h,00Fh,03Fh,038h,000h,000h,020h,020h,03Fh,03Fh,020h,020h,000h
pg08 db 004h,03Ch,0FCh,0F4h,0E0h,0FCh,03Ch,000h,0F0h,0FCh,03Ch,004h,004h,03Ch,0FCh,000h,004h,0FCh,0FCh,004h,000h,0FCh,0FCh,000h
pg09 db 000h,020h,03Fh,03Fh,03Fh,020h,000h,000h,00Fh,01Fh,03Ch,020h,020h,03Ch,01Fh,000h,000h,01Fh,03Fh,030h,020h,03Fh,01Fh,000h
pg10 db 004h,0FCh,0FCh,004h,000h,000h,000h,000h,0F0h,0FCh,03Ch,004h,004h,03Ch,0FCh,000h,038h,07Ch,0FCh,0C4h,084h,08Ch,01Ch,000h,004h,0FCh,0FCh,084h,0E4h,0ECh,01Ch,01Ch
pg11 db 020h,03Fh,03Fh,020h,020h,030h,038h,000h,00Fh,01Fh,03Ch,020h,020h,03Ch,01Fh,000h,01Ch,03Ch,030h,020h,021h,033h,03Fh,000h,020h,03Fh,03Fh,020h,023h,033h,03Ch,03Ch

pg20 DB  000h,000h,080h,0F0h,038h,00Ch,00Ch,0EEh,02Eh,03Eh,01Ah,01Ah,01Bh,0FBh,0EBh,00Fh
pg21 DB  00Fh,00Fh,00Fh,077h,0B7h,09Fh,09Fh,09Fh,09Fh,09Fh,0BDh,0BFh,07Bh,07Bh,073h,023h
pg22 DB  006h,00Ch,038h,0E0h,080h,000h,000h,000h,000h,0FCh,0BEh,0FFh,0DFh,01Ah,0FAh,0FAh
pg23 DB  032h,033h,0B7h,097h,0C7h,0E7h,07Fh,03Eh,006h,002h,080h,082h,0E7h,06Fh,0C5h,0E6h
pg24 DB  047h,04Fh,05Fh,09Bh,09Fh,09Fh,0DAh,0DFh,06Ah,07Ch,0FEh,0CFh,0CEh,0FBh,0F3h,0FEh
pg25 DB  09Ch,0F8h,000h,007h,0FFh,001h,0FFh,0FFh,0FFh,0FFh,0F6h,0FDh,0ECh,0ECh,0EDh,0FFh
pg26 DB  0EEh,0EFh,0EDh,0FDh,0EDh,065h,067h,077h,07Eh,0FAh,0BBh,03Bh,099h,0DDh,0FFh,07Fh
pg27 DB  03Eh,01Eh,007h,003h,080h,0E0h,07Bh,00Eh,007h,003h,001h,000h,0FEh,0FFh,000h,030h
pg28 DB  063h,0DFh,0B7h,0A7h,0AEh,0EFh,0FFh,0FCh,0FFh,0FFh,0FCh,05Ch,05Fh,06Fh,06Ch,064h
pg29 DB  0B6h,0B6h,0F7h,05Bh,07Fh,07Dh,02Fh,03Eh,01Fh,00Eh,00Eh,006h,003h,001h,000h,000h
pg30 DB  000h,000h,000h,000h,000h,000h,001h,003h,006h,004h,00Ch,00Ch,00Ch,00Ch,00Ch,00Ch
pg31 DB  00Ch,004h,006h,006h,002h,002h,003h,003h,003h,001h,000h,000h,000h,000h,000h,000h
pg32 DB  000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Setup the Reset Vector
	org 07ff0h
	jmp dumst
	code_seg ends
end start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;