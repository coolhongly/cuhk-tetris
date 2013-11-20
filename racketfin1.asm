lcd_base_address1	equ	084h	;address of chip1
lcd_base_address2	equ	088h	;address of chip2
i8254_base_address equ 0e0h
i8255_base_address equ 0f0h
i8259_base_address equ   0c0h
ad_base_address	equ 000h
leftmost_x equ 10111000b
rightmost_x equ 10111111b
top_y equ 01111100b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stack_seg	segment	at 0
top_of_stack	equ	800h
stack_seg	ends
;
data_seg	segment	at 0      
	cur_page db ?
	carry db ?
	override db ?
	speed db ?
	delay db ?
	mode  db ?
	prev db ?
	divider	db ?
	multiplier db ?
	over	db  ?
	x	db  ?
	y	db  ?
	x_inc	db  ?
	y_inc	db  ?
	blocks	db  ?  
	score	db	?
	h_block db  ?
	h_board db  ?
	h_full	db	?
	half	db	?
	pointer db ?
data_seg	ends
;                                                         
dummy_code	segment	at 0f800h
	org 0
dumst	label	far

dummy_code	ends
;
;the start of Code Segment
;f8000-fffff for program
;
code_seg	segment public 'code'
		assume cs:code_seg
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;main program
start:          
	mov	ax,data_seg
	mov	ds,ax
	mov	es,ax
	assume	ds:data_seg, es:data_seg
	mov	ax,stack_seg
	mov	ss,ax
	assume	ss:stack_seg
	mov	sp,top_of_stack
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	call	INIT_8255
	call	INIT_8254
	call	INIT_8259
	call	init_glcd1
	call	init_glcd2
	call	clear_screen
	call	standby
	mov		cx, 0080h
	mov		mode, 0ffh
	mov		prev, 128
	mov		divider, 5d
	mov		multiplier, 4d

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov	over, 0h
	mov	x_inc, 1h
	mov	y_inc, 4h
	mov blocks, 0fh
	mov	score, 0h
	mov h_block, 0h
	mov h_board, 0h
	mov	h_full, 0h
	mov	half, 0h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;print_score
	mov	al, 0h
	mov ah, 01000010b
	call	ps
	mov	al, 1h
	mov ah, 01000010b
	call	pc
	mov	al, 2h
	mov ah, 01000010b
	call	p0
	mov	al, 3h
	mov ah, 01000010b
	call	pr
	mov	al, 4h
	mov ah, 01000010b
	call	pe
	call	print_score
;print the blocks
	push	cx
	mov	al, 0h
	mov	cx, 8
loop_block:
	mov ah, 01111100b
	push	ax
	call	print_block
	pop	ax
	inc	al
	loop	loop_block
	pop	cx
	
	mov	ah, 01000000b		;set Y address
	mov	al, 00000011b		;set X address
	call	print_ball2
	
launch:
	call check_key3
	jnc launch
	call	launch_ball
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov   dx,i8255_base_address+1
    mov   al,110b
    out   dx,al
	sti
nomove:
	cmp		over, 1h
	jnz		live
	cli
	call	dango
live:
	cmp		mode, 0h
	jnz		another
	call	check_acc
	jmp		cont
another:
	call	check_key
cont:
	jnc		nomove

	push	cx
	mov	bh, 01111111b
	and bh, ch
	jz r
	call anime_l
jmp fin
r:
	call anime_r
	jmp fin
fin:
	pop		cx
	
	push	cx
	call	c_rev
	rol		cx,2
	
lp:
	call	delay10
	loop	lp
	pop		cx
	jmp nomove
	
stop:
	nop
	nop
	nop
	nop
	nop
	jmp stop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_key3  proc  near
	mov     dx,i8255_base_address
	in      al,dx
	and     al,00100000b
	jnz     kp2
	call    delay10       ;software debouncing
	mov     dx,i8255_base_address
	in      al,dx
	and     al,00100000b
	jnz     kp2
	stc                     ;key pressed
	ret
kp2:  	
	clc
	ret
	check_key3  endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
anime_l	proc 	near
	mov al, rightmost_x
	mov cur_page, al
	mov carry, 0b
	mov override, 0b
	
move_l:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	;dummy
	call	check_busy1 
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov bh, 1b
	cmp bh, carry
	clc
	jnz rotate1
	stc
rotate1:
	rcr al, 1
	mov override, al
	jnc next_nc1
	
	mov carry, 1b
	jmp next1

next_nc1:
	mov carry, 0b
next1:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page ;
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y
	
	mov cx, 4
draw1:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw1

	dec cur_page
	mov al, cur_page
	cmp al, leftmost_x
	jz last1
	jmp move_l
	
last1:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, leftmost_x
	out dx, al ;set x

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	;dummy
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov ah, 1b
	cmp carry, ah
	clc
	jnz rotate2
	stc
rotate2:
	rcr al, 1
	mov override, al
	jnc fin1
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	mov		cx, 4
draw2:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw2
	
cyc1:

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, rightmost_x
	out dx, al

	;dummy
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov override, al
	add override, 10000000b

	mov al, rightmost_x
	mov cur_page, al
	
fin1:

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	mov		cx, 4
draw4:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw4
	ret

anime_l	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
anime_r	proc 	near
	mov al, leftmost_x
	mov cur_page, al
	mov carry, 0b
	mov override, 0b
	
move_r:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	;dummy
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov bh, 1b
	cmp bh, carry
	clc
	jnz rotate3
	stc
rotate3:
	rcl al, 1
	mov override, al
	jnc next_nc2
	
	mov carry, 1b
	jmp next2

next_nc2:
	mov carry, 0b
next2:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page ;
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y
	
	mov cx, 4
draw5:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw5

	inc cur_page
	mov al, cur_page
	cmp al, rightmost_x
	jz last2
	jmp move_r
	
last2:
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	;dummy
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov ah, 1b
	cmp carry, ah
	clc
	jnz rotate4
	stc
rotate4:
	rcl al, 1
	mov override, al
	jnc fin2
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	mov		cx, 4
draw6:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw6
	
cyc2:

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, leftmost_x
	out dx, al

	;dummy
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	in al, dx ;read d

	mov override, al
	add override, 00000001b

	mov al, leftmost_x
	mov cur_page, al
	
fin2:

	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, cur_page
	out dx, al ;set x
	
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al ;set y

	mov		cx, 4
draw8:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc dx
	mov al, override
	out dx, al ;write d
	loop draw8
	ret

anime_r	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c_rev		proc 	near
	mov	bh,	01111111b
	and bh, ch
	jz	ini2	;right, no need to reverse
ini1:
	mov al,	10000000b
	mov ah, 0
find1:
	inc ah
	ror al, 1
	cmp al, ch
	jnz find1
	jmp res

ini2:
	mov al,	10000000b
	mov ah, 0
find2:
	inc ah
	rol al, 1
	cmp al, cl
	jnz find2
	jmp res
	
res:
	mov al, ah
	mov ah, 0
	mov cx, ax
	ret
c_rev		endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
standby	proc 	near
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, 10111100b
	out dx, al
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al
	mov cx, 4d

half1:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc	dx
	mov	al, 0ffh
	out	dx, al
	loop half1
;
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, 10111011b
	out dx, al
	call	check_busy1
	mov	dx,lcd_base_address1
	mov al, top_y
	out dx, al

	mov cx, 4d
half2:
	call	check_busy1
	mov	dx,lcd_base_address1
	inc	dx
	mov	al, 0ffh
	out	dx, al
	loop half2

	ret
standby	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_glcd1	proc 	near
	call	check_busy1
	mov	al,00111111b		;turn lcd on
	mov	dx,lcd_base_address1
	out	dx,al
	call	check_busy1
	mov	dx,lcd_base_address1
	mov	al,11000000b		;set start line at 0
	out	dx, al
	ret
init_glcd1	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_glcd2	proc 	near
	call	check_busy2
	mov	al,00111111b		;turn lcd on
	mov	dx,lcd_base_address2
	out	dx,al
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al,11000000b		;set start line at 0
	out	dx,al
	ret
init_glcd2	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT_8259
;initialize 8259
INIT_8259  PROC  NEAR
;       set     ICW1
      mov     dx,i8259_base_address       ;point to ICW1
      mov     al,00010011b        ;ICW4 needed,single,edge trigger
      out     dx,al
;       set     ICW2
      inc     dx                       ;point to ICW2
      mov     al,00010000b        ;base address=08h
      out     dx,al
;       set     ICW4
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
      RET
INIT_8259  ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INT_SERVICE_0
;Interrupt period=0.01s
;
;variable int_count should be defined in data segment and initialize
;to zero.
;
;Procedure adjust_time should be defined by the user.
;
int_service_0    proc    near
    cli
	push ax
	push bx
	push cx
	push dx
    call move_ball
	pop dx
	pop cx
	pop bx
	pop ax
	sti
    iret
int_service_0   endp
int_service_1   proc    near
	cli
	not mode
	sti
    iret
int_service_1   endp
int_service_2   proc    near
      iret
int_service_2   endp
int_service_3   proc    near
      iret
int_service_3   endp
int_service_4   proc    near
      iret
int_service_4   endp
int_service_5   proc    near
      iret
int_service_5   endp
int_service_6   proc    near
      iret
int_service_6   endp
int_service_7   proc    near
      iret
int_service_7   endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT_8255
;initialize 8255 in mode 0
;       set PA as input
;       set PB as output
;       set PC as output
;
INIT_8255  PROC  NEAR
      mov dx,i8255_base_address
      mov al,10010000B
      inc dx
      inc dx
      inc dx                  ;point to command register
      out dx,al
      RET
INIT_8255  ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT_8254
;initialize 8254
INIT_8254  PROC  NEAR
;channel 0 at mode 3, 2KHz
      timer_channel_0_msb     equ     4d
      timer_channel_0_lsb     equ     226d
      mov     al,00110110B
      mov     dx,i8254_base_address
      inc     dx
      inc     dx
      inc     dx       ;point to command register
      out     dx,al
      mov     al,timer_channel_0_lsb
      mov     dx,i8254_base_address
      out     dx,al
      mov     al,timer_channel_0_msb
      out     dx,al
;channel 1 at mode 3, 1 ms
      timer_channel_1_msb     equ     9d
      timer_channel_1_lsb     equ     196d
      mov     al,01110110B
      mov     dx,i8254_base_address
      inc     dx
      inc     dx
      inc     dx              ;point to command register
      out     dx,al
      mov     al,timer_channel_1_lsb
      mov     dx,i8254_base_address
      inc     dx
      out     dx,al
      mov     al,timer_channel_1_msb
      out     dx,al

;channel 2 at mode 2, 0.3 sec
      timer_channel_2_msb     equ     1d
      timer_channel_2_lsb     equ     44d
      mov     al,10110100B
      mov     dx,i8254_base_address
      inc     dx
      inc     dx
      inc     dx              ;point to command register
      out     dx,al
      mov     al,timer_channel_2_lsb
      mov     dx,i8254_base_address
      inc     dx
      inc     dx
      out     dx,al
      mov     al,timer_channel_2_msb
      out     dx,al
      RET
INIT_8254  ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CHECK_ACC
;Check tilt
check_acc  proc  near
	mov	al, prev
	mov ah, 0
	div divider
	mov ah, 0
	mul multiplier
	mov prev, al
	mov	dx,ad_base_address
	in	al, dx
	mov ah, 0
	div divider
	add prev,al
	mov al, prev
	
	mov ah, 50d
	cmp ah, al
	jl	left2
	mov ah, 200d
	cmp ah, al
	jl	slow_12
	jmp right2
	
slow_12:
	mov		bh,01111111b
	and		bh,ch
	jz		slow_22
	jmp		right2
slow_22:
	mov		bh,10000000b
	and		bh,cl
	jnz		halt2
	jmp		left2

left2:
	rol		cx, 1                     ;left key pressed
	mov		bh,10000000b
	and		bh,ch
	jz		valid2
	ror		cx, 1
	jmp		valid2
right2:
	ror		cx, 1                  ;right key pressed
	mov		bh,10000000b
	and		bh,ch
	jz		valid2
	rol		cx, 1
	jmp		valid2

valid2:
	mov		bh,10000000b
	and		bh,cl
	jnz		halt2
move2:
	stc
	ret
halt2:
	clc
	ret
	
check_acc endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CHECK_KEY
;Check key pressed
check_key  proc  near
	clc
	mov     dx,i8255_base_address
	in      al,dx
	and     al,10000000b
	jnz     ck
	call    delay10       ;software debouncing
	mov     dx,i8255_base_address
	in      al,dx
	and     al,10000000b
	jnz     ck
	jmp		left

ck:
	mov     dx,i8255_base_address
	in      al,dx
	and     al,01000000b
	jnz     slow_1
	call    delay10       ;software debouncing
	mov     dx,i8255_base_address
	in      al,dx
	and     al,01000000b
	jnz     slow_1
	jmp		right


slow_1:
	mov		bh,01111111b
	and		bh,ch
	jz		slow_2
	jmp		right
slow_2:
	mov		bh,10000000b
	and		bh,cl
	jnz		halt
	jmp		left

left:
	rol		cx, 1                     ;left key pressed
	mov		bh,10000000b
	and		bh,ch
	jz		valid
	ror		cx, 1
	jmp		valid
right:
	ror		cx, 1                  ;right key pressed
	mov		bh,10000000b
	and		bh,ch
	jz		valid
	rol		cx, 1
	jmp		valid

valid:
	mov		bh,10000000b
	and		bh,cl
	jnz		halt
move:
	stc
	ret
halt:
	clc
	ret
check_key endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Delay 10 ms
;
delay10    proc  near
      push  cx
      mov   cx,3ffh
delay_1:   nop
      nop
      loop  delay_1
      pop   cx
      ret
delay10    endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_busy1	proc	near
busy1:
	mov	dx,lcd_base_address1
	in	al,dx
	and	al,10000000b
	jnz	busy1
	ret
	check_busy1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_busy2	proc	near
busy2:
	mov	dx,lcd_base_address2
	in	al,dx
	and	al,10000000b
	jnz	busy2
	ret
	check_busy2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clear_screen	proc	near
;set X and Y address
	mov	dx, lcd_base_address1
	call	check_busy1
	mov	al,01000000b		;set Y address to chip1
	mov	ah,al
	out	dx,al      
	mov	dx, lcd_base_address2
	call	check_busy2
	mov	al,ah				;set Y address to chip2
	out	dx,al
	mov	dx, lcd_base_address1
	call	check_busy1
	mov	al,10111000b		;set X address to chip1
	mov	ah,al
	out	dx,al      
	mov	dx, lcd_base_address2
	call 	check_busy2
	mov	al,ah            	;set X address to chip2
	out	dx,al
;
;set zero to 2 display RAMs
cycle:	
	mov	cx,64
cycle1:	
	mov	dx,lcd_base_address1
	call	check_busy1
	mov	al,0
	inc	dx			;point to display RAM1
	out	dx,al
	mov	dx,lcd_base_address2
	call	check_busy2
	mov	al,0
	inc	dx			;point to display RAM2
	out	dx,al
	loop	cycle1
;update X address
	inc	ah
	cmp	ah,11000000b
	je	end_clear
	mov	dx, lcd_base_address1
	call	check_busy1
	mov	al,ah			;set X address to chip1
	out	dx,al      
	mov	dx, lcd_base_address2
	call	check_busy2
	mov	al,ah			;set X address to chip2
	out	dx,al 
	jmp	cycle
end_clear: 
	ret
	clear_screen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_ball1	proc	near  
    mov x, al
    mov y, ah
	add	al, 10111000b       ;get X address
	push    ax
	call	check_busy2
	pop ax
	mov	dx,lcd_base_address2
	out	dx, al		;set X address to chip2
	push    ax
	call	check_busy2
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address2
	out	dx, al		;set Y address to chip2
;
	call	check_busy2
	mov	al, 0fh
	mov	dx,lcd_base_address2
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0bh
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0fh
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0fh
	inc	dx
	out	dx, al
	ret
	print_ball1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_ball2	proc	near 
	mov x, al       
	mov y, ah
	add	al, 10111000b       ;get X address
	push    ax
	call	check_busy2
	pop ax
	mov	dx,lcd_base_address2
	out	dx, al		;set X address to chip2
	push    ax
	call	check_busy2
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address2
	out	dx, al		;set Y address to chip2
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0f0h
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0d0h
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 90h
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0f0h
	inc	dx
	out	dx, al
;
	ret
	print_ball2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_block	proc	near
	push	ax
	call	check_busy2
	pop	ax
	mov	dx,lcd_base_address2
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy2
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address2
	out	dx, al				;set Y address
;
	call	check_busy2
	mov	al, 0ffh
	mov	dx,lcd_base_address2
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0ddh
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 99h
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0ffh
	inc	dx
	out	dx, al
	ret
	print_block endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_block1	proc	near  
	add	al, 10111000b       ;get X address
	push    ax
	call	check_busy2
	pop ax
	mov	dx,lcd_base_address2
	out	dx, al		;set X address to chip2
	push    ax
	call	check_busy2
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address2
	out	dx, al		;set Y address to chip2
;
	call	check_busy2
	mov	al, 0fh
	mov	dx,lcd_base_address2
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0dh
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 09h
	inc	dx
	out	dx, al
;
	call	check_busy2
	mov	dx,lcd_base_address2
	mov	al, 0fh
	inc	dx
	out	dx, al
	ret
	print_block1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_board	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;
	call	check_busy1
	mov	al, 0ffh
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	call	check_busy1
	mov	dx,lcd_base_address1
	mov	al, 0ddh
	inc	dx
	out	dx, al
;
	call	check_busy1
	mov	dx,lcd_base_address1
	mov	al, 99h
	inc	dx
	out	dx, al
;
	call	check_busy1
	mov	dx,lcd_base_address1
	mov	al, 0ffh
	inc	dx
	out	dx, al
	ret
	print_board endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_score	proc	near
	push	ax
	push	bx
	mov	bl, score
	cmp	bl, 10d
	jl	p00
	cmp	bl, 20d
	jl	p10
p20:
	mov	al, 6h
	mov ah, 01000010b
	call	p2
	sub	bl, 20d
	jmp	p11
p10:
	mov	al, 6h
	mov ah, 01000010b
	call	p1
	sub	bl, 10d
	jmp	p11
p00:
	mov	al, 6h
	mov ah, 01000010b
	call	p0
p11:
	cmp	bl, 0h
	jz	p_0
	cmp	bl, 1h
	jz	p_1
	cmp	bl, 2h
	jz	p_2
	cmp	bl, 3h
	jz	p_3
	cmp	bl, 4h
	jz	p_4
	cmp	bl, 5h
	jz	p_5
	cmp	bl, 6h
	jz	p_6
	cmp	bl, 7h
	jz	p_7
	cmp	bl, 8h
	jz	p_8
	cmp	bl, 9h
	jz	p_9
p_0:
	mov	al, 7h
	mov ah, 01000010b
	call	p0
	jmp	end_print_score
p_1:
	mov	al, 7h
	mov ah, 01000010b
	call	p1
	jmp	end_print_score
p_2:
	mov	al, 7h
	mov ah, 01000010b
	call	p2
	jmp	end_print_score
p_3:
	mov	al, 7h
	mov ah, 01000010b
	call	p3
	jmp	end_print_score
p_4:
	mov	al, 7h
	mov ah, 01000010b
	call	p4
	jmp	end_print_score
p_5:
	mov	al, 7h
	mov ah, 01000010b
	call	p5
	jmp	end_print_score
p_6:
	mov	al, 7h
	mov ah, 01000010b
	call	p6
	jmp	end_print_score
p_7:
	mov	al, 7h
	mov ah, 01000010b
	call	p7
	jmp	end_print_score
p_8:
	mov	al, 7h
	mov ah, 01000010b
	call	p8
	jmp	end_print_score
p_9:
	mov	al, 7h
	mov ah, 01000010b
	call	p9
end_print_score:
	pop	bx
	pop	ax
	ret
	print_score endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
launch_ball	proc	near
	call	clear_ball
	mov	al, 00000100b
	mov	ah, 01000100b
	call	print_ball1
;
	ret
	launch_ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_ball	proc	near
	push	ax
;get the current position of the ball
	mov	al, x
	mov	ah, y
	call	read_in2
	and	al, 0f0h
	cmp	al, 0f0h
	jz	check_ball2
;
check_ball1:
	call	clear_ball
	cmp	y, 01111100b
	jnz	not_top1
	neg	y_inc
not_top1:
	cmp	y, 01000000b
	jz	bottom1
	call	hit_block1
	cmp	h_block, 1h
	jz	end_move_ball1
	jmp	skip1
bottom1:
	call	hit_board1
	cmp	h_board, 1h
	jz	nothing1
	mov	over, 1h
nothing1:
	jmp	end_move_ball1
skip1:
	cmp	x, 0h
	jz	hit_left
	mov	al, y_inc
	add	y, al			;get Y address
	cmp	x_inc, 1h
	jz	not_dec
	dec	x
not_dec:
	mov	al, x
	mov	ah, y
	call	print_ball2
end_move_ball1:
	jmp	end_move_ball
;
check_ball2:
	call    clear_ball
	cmp	y, 01111100b
	jnz	not_top2
	neg	y_inc
not_top2:
	cmp	y, 01000000b
	jz	bottom2
	call	hit_block2
	cmp	h_block, 1h
	jz	end_move_ball2
	jmp	skip2
bottom2:
	call	hit_board2
	cmp	h_board, 1h
	jz	nothing2
	mov	over, 1h
nothing2:
	jmp	end_move_ball2
skip2:
	cmp	x, 7h
	jz	hit_right
	mov	al, y_inc
	add	y, al			;get Y address
	cmp	x_inc, -1h
	jz	not_inc
	inc	x
not_inc:
	mov	al, x
	mov	ah, y
	call	print_ball1
;
end_move_ball2:
	jmp	end_move_ball
;
hit_left:
	mov	al, y_inc
	add	y, al			;get Y address
	mov	x_inc, 1h
	mov	al, x
	mov	ah, y
	call	print_ball2
	jmp	end_move_ball
;
hit_right:
	mov	al, y_inc
	add	y, al			;get Y address
	mov	x_inc, -1h
	mov	al, x
	mov	ah, y
	call	print_ball1
;
end_move_ball:
	mov	h_block, 0h
	mov	h_board, 0h
	pop	ax
	ret
	move_ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
clear_ball  proc    near
    call    check_busy2
    mov	al, y
    mov dx, lcd_base_address2
    out dx, al          ;set Y address
    call    check_busy2
    mov al, x
    add al, 10111000b
    mov dx, lcd_base_address2
    out dx, al          ;set X address
;
    call    check_busy2
    mov al, 0h
    mov dx, lcd_base_address2
    inc dx
    out dx, al
;   
    call    check_busy2
    mov al, 0h
    mov dx, lcd_base_address2
    inc dx
    out dx, al
;    
    call    check_busy2
    mov al, 0h
    mov dx, lcd_base_address2
    inc dx
    out dx, al
;    
    call    check_busy2
    mov al, 0h
    mov dx, lcd_base_address2
    inc dx
    out dx, al
;     
    ret
    clear_ball endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hit_block1	proc	near
	push	bx
	cmp	y_inc, 0h
	jl	dropping1_1
;top
	mov ah, y
	add	ah, 4h
	mov al, x
	call	read_in2
;
	mov	bl, al
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block1_1
	mov	al, x
	mov	ah, y
	add	ah, 4h
	jmp	h_top1
;
dropping1_1:
	jmp	dropping1
;top & right
h_block1_1:
	cmp	x_inc, 1h
	jnz	h_block1_3
;
	mov	al, bl
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block1_2
	mov	al, x
	mov	ah, y
	add	ah, 4h
	jmp	h_ntop1
;
;top & half right
h_block1_2:
	cmp	al, 090h
	jnz  end_hit_block1_1
	mov	al, x
	mov	ah, y
	add	ah, 2h
	mov	half, 1h
	jmp	h_ntop1
;
;top & left
h_block1_3:
	mov ah, y
	add	ah, 4h
	mov al, x
	dec	al
	call	read_in2
;
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block1_4
	mov	al, x
	dec	al
	mov	ah, y
	add	ah, 4h
	jmp	h_ntop1
;
;top & half left
h_block1_4:
	cmp	al, 090h
	jnz  end_hit_block1_1
	mov	al, x
	dec	al
	mov	ah, y
	add	ah, 2h
	mov	half, 1h
	jmp	h_ntop1
;
end_hit_block1_1:
	jmp	end_hit_block1
;
dropping1:
;bottom
	mov ah, y
	dec	ah
	mov al, x
	call	read_in2
;
	mov	bl, al
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block1_5
	mov	al, x
	mov	ah, y
	add	ah, -4h
	jmp	h_top1
;
;bottom & right
h_block1_5:
	cmp	x_inc, 1h
	jnz	h_block1_7
;
	mov	al, bl
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block1_6
	mov	al, x
	mov	ah, y
	add	ah, -4h
	jmp	h_ntop1
;
;bottom & half right
h_block1_6:
	cmp	al, 0d0h
	jnz  end_hit_block1_1
	mov	al, x
	mov	ah, y
	add	ah, -2h
	mov	half, 1h
	jmp	h_ntop1
;
;bottom & left
h_block1_7:
	mov ah, y
	dec	ah
	mov al, x
	dec	al
	call	read_in2
;
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block1_8
	mov	al, x
	dec	al
	mov	ah, y
	add	ah, -4h
	jmp	h_ntop1
;
;bottom & half left
h_block1_8:
	cmp	al, 0d0h
	jnz  end_hit_block1_1
	mov	al, x
	dec	al
	mov	ah, y
	add	ah, -2h
	mov	half, 1h
	jmp	h_ntop1
;
;hit not-top block
h_ntop1:
	push	ax
	call    clear_ball
	pop	ax
	mov h_block, 1h
	dec	blocks
	inc	score
	call	print_score
	call	block_d2
	neg	y_inc
	neg	x_inc
	mov al, x
	mov ah, y
	call	print_ball1
	jmp	end_hit_block1
;
;hit top block
h_top1:
	push	ax
	call    clear_ball
	pop	ax
	mov h_block, 1h
	dec	blocks
	inc	score
	call	print_score
	call	block_d1
	neg	y_inc
	mov	al, y_inc
	add	y, al		;get Y address
;
	cmp	x, 0h
	jnz	n_left1
	mov	x_inc, 1h
n_left1:
	cmp	x_inc, 1h
	jz	not_dec1
	dec	x
not_dec1:
	mov al, x
	mov ah, y
	call	print_ball2
end_hit_block1:
	mov	half, 0h
	pop	bx
	ret
	hit_block1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hit_block2	proc	near
	push	bx
	cmp	y_inc, 0h
	jl	dropping2_1
;top
	mov ah, y
	add	ah, 4h
	mov al, x
	call	read_in2
;
	mov	bl, al
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block2_1
	mov	al, x
	mov	ah, y
	add	ah, 4h
	jmp	h_top2
;
dropping2_1:
	jmp	dropping2
;top & left
h_block2_1:
	cmp	x_inc, -1h
	jnz	h_block2_3
;
	mov	al, bl
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block2_2
	mov	al, x
	mov	ah, y
	add	ah, 4h
	jmp	h_ntop2
;
;top & half left
h_block2_2:
	cmp	al, 9h
	jnz  end_hit_block2_1
	mov	al, x
	mov	ah, y
	add	ah, 2h
	mov	half, 1h
	jmp	h_ntop2
;
;top & right
h_block2_3:
	mov ah, y
	add	ah, 4h
	mov al, x
	inc	al
	call	read_in2
;
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block2_4
	mov	al, x
	inc	al
	mov	ah, y
	add	ah, 4h
	jmp	h_ntop2
;
;top & half right
h_block2_4:
	cmp	al, 9h
	jnz  end_hit_block2_1
	mov	al, x
	inc	al
	mov	ah, y
	add	ah, 2h
	mov	half, 1h
	jmp	h_ntop2
;
end_hit_block2_1:
	jmp	end_hit_block2
;
dropping2:
;bottom
	mov ah, y
	dec	ah
	mov al, x
	call	read_in2
;
	mov	bl, al
	and al, 0f0h
	cmp	al, 0f0h
	jnz  h_block2_5
	mov	al, x
	mov	ah, y
	add	ah, -4h
	jmp	h_top2
;
;bottom & left
h_block2_5:
	cmp	x_inc, -1h
	jnz	h_block2_7
;
	mov	al, bl
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block2_6
	mov	al, x
	mov	ah, y
	add	ah, -4h
	jmp	h_ntop2
;
;bottom & half left
h_block2_6:
	cmp	al, 0dh
	jnz  end_hit_block2_1
	mov	al, x
	mov	ah, y
	add	ah, -2h
	mov	half, 1h
	jmp	h_ntop2
;
;bottom & right
h_block2_7:
	mov ah, y
	dec	ah
	mov al, x
	inc	al
	call	read_in2
;
	and al, 0fh
	cmp	al, 0fh
	jnz  h_block2_8
	mov	al, x
	inc	al
	mov	ah, y
	add	ah, -4h
	jmp	h_ntop2
;
;bottom & half right
h_block2_8:
	cmp	al, 0d0h
	jnz  end_hit_block2_1
	mov	al, x
	inc	al
	mov	ah, y
	add	ah, -2h
	mov	half, 1h
	jmp	h_ntop2
;
;hit not-top block
h_ntop2:
	push	ax
	call    clear_ball
	pop	ax
	mov h_block, 1h
	dec	blocks
	inc	score
	call	print_score
	call	block_d1
	neg	y_inc
	neg	x_inc
	mov al, x
	mov ah, y
	call	print_ball2
	jmp	end_hit_block2
;
;hit top block
h_top2:
	push	ax
	call    clear_ball
	pop	ax
	mov h_block, 1h
	dec	blocks
	inc	score
	call	print_score
	call	block_d2
	neg	y_inc
	mov	al, y_inc
	add	y, al		;get Y address
;
	cmp	x, 7h
	jnz	n_right1
	mov	x_inc, -1h
n_right1:
	cmp	x_inc, -1h
	jz	not_inc1
	inc	x
not_inc1:
	mov al, x
	mov ah, y
	call	print_ball1
end_hit_block2:
	mov	half, 0h
	pop	bx
	ret
	hit_block2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hit_board1	proc	near
	mov ah, 01111111b
	mov al, x
	call	read_in1
;
	mov	ah, al
	and ah, 0fh
	cmp	ah, 0fh
	jnz  n_full1_1
	mov	h_full, 1h
n_full1_1:
	cmp	x_inc, 1h
	jnz	hit1_0
;
;x_inc = 1h
	cmp	h_full, 1h
	jnz	n_full1_2
	and al, 0f0h
	cmp	al, 0f0h
	jnz  hit1_2_3
	jmp	last
;
n_full1_2:
	cmp	al, 0f0h
	jz  hit1_2_2
	cmp	ah, 8h
	jz  hit1_2_2
	cmp	ah, 0ch
	jz  hit1_2_2
	cmp	ah, 0eh
	jz  hit1_2_2
	cmp	ah, 1h
	jz  hit1_2_3
	cmp	ah, 3h
	jz  hit1_2_3
	cmp	ah, 7h
	jz  hit1_2_3
	jmp	end_hit_board1_1
;
hit1_2_2:
	jmp	hit1_2
hit1_2_3:
	jmp	hit1_2_1
;
;x_inc = -1h
hit1_0:	
	cmp	h_full, 1h
	jnz	n_full1_3
	and al, 0f0h
	cmp	al, 0f0h
	jnz  hit1_2_2
	cmp	x, 0h
	jz	end_hit_board1_1
	jmp	last
n_full1_3:
	cmp	ah, 8h
	jz  hit1_2_3
	cmp	ah, 0ch
	jz  hit1_2_3
	cmp	ah, 0eh
	jz  hit1_2_3
	cmp	ah, 1h
	jz  hit1_2_2
	cmp	ah, 3h
	jz  hit1_2_2
	cmp	ah, 7h
	jz  hit1_2_2
	cmp	x, 0h
	jz	end_hit_board1_1
;
last:
	mov ah, 01111111b
	mov al, x
	dec	al
	call	read_in1
;
	and	al, 0f0h
	cmp	x_inc, 1h
	jnz	hit1_0_1
;
;x_inc = 1h
	cmp	h_full, 1h
	jnz	end_hit_board1_1
	cmp	al, 0f0h
	jnz	hit1_2
	jmp	hit1_1
;
;x_inc = -1h
hit1_0_1:
	cmp	h_full, 1h
	jnz	n_full1_4
	cmp	al, 0f0h
	jnz	hit1_2_1
	jmp	hit1_1
n_full1_4:
	cmp	al, 0f0h
	jz	hit1_2
end_hit_board1_1:
	jmp	end_hit_board1
;
hit1_1:
	mov h_board, 1h
	mov	y_inc, 4h
	mov	al, y_inc
	add	y, al		;get Y address
	jmp	hit1_3
;
hit1_2_1:
	mov h_board, 1h
	mov y_inc, 2h 
	mov	al, y_inc
	add	y, al		;get Y address
	jmp	hit1_3
;
hit1_2:
	mov h_board, 1h
	mov y_inc, 2h 
	mov	al, y_inc
	add	y, al		;get Y address
	neg	x_inc
	jmp	hit1_3
;
hit1_3:
	cmp	x, 0h
	jnz	n_left2
	mov	x_inc, 1h
n_left2:
	cmp	x_inc, 1h
	jz	not_dec2
	dec	x
not_dec2:
    mov al, x
    mov ah, y
	call	print_ball2
	;Turn one of the LEDs off
    mov   al,1100b
    mov   dx,i8255_base_address+2       ;point to PC
    out   dx,al               ;enable LED at PC0
;
end_hit_board1:
	mov	h_full, 0h
	ret
	hit_board1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
hit_board2	proc	near
	mov	ah, 01111111b
	mov	al, x
	call	read_in1
;
	mov	ah, al
	and	ah, 0f0h
	cmp	ah, 0f0h
	jnz	n_full2_1
	mov	h_full, 1h
n_full2_1:
	cmp	x_inc, -1h
	jnz	hit2_0
;
;x_inc = -1h
	cmp	h_full, 1h
	jnz	n_full2_2
	and al, 0fh
	cmp	al, 0fh
	jnz  hit2_2_3
	jmp	next
;
n_full2_2:
	cmp	al, 0fh
	jz	hit2_2_2
	cmp	ah, 10h
	jz	hit2_2_2
	cmp	ah, 30h
	jz	hit2_2_2
	cmp	ah, 70h
	jz	hit2_2_2
	cmp	ah, 80h
	jz	hit2_2_3
	cmp	ah, 0c0h
	jz	hit2_2_3
	cmp	ah, 0e0h
	jz	hit2_2_3
	jmp	end_hit_board2_1
;
hit2_2_2:
	jmp	hit2_2
hit2_2_3:
	jmp	hit2_2_1
;
;x_inc = 1h
hit2_0:
	cmp	h_full, 1h
	jnz	n_full2_3
	and al, 0fh
	cmp	al, 0fh
	jnz  hit2_2_2
	cmp	x, 7h
	jz	end_hit_board2_1
	jmp	next
n_full2_3:
	cmp	ah, 10h
	jz  hit2_2_3
	cmp	ah, 30h
	jz  hit2_2_3
	cmp	ah, 70h
	jz	hit2_2_3
	cmp	ah, 80h
	jz  hit2_2_2
	cmp	ah, 0c0h
	jz  hit2_2_2
	cmp	ah, 0e0h
	jz	hit2_2_2
	cmp	x, 7h
	jz	end_hit_board2_1
;
next:
	mov	ah, 01111111b
	mov	al, x
	inc	al
	call	read_in1
;
	and	al, 0fh
	cmp	x_inc, -1h
	jnz	hit2_0_1
;
;x_inc = -1h
	cmp	h_full, 1h
	jnz	end_hit_board2_1
	cmp	al, 0fh
	jnz	hit2_2
	jmp	hit2_1
;
;x_inc = 1h
hit2_0_1:
	cmp	h_full, 1h
	jnz	n_full2_4
	cmp	al, 0fh
	jnz	hit2_2_1
	jmp	hit2_1
n_full2_4:
	cmp	al, 0fh
	jz	hit2_2
end_hit_board2_1:
	jmp	end_hit_board2
;
hit2_1:
	mov	h_board, 1h
	mov	y_inc, 4h
	mov	al, y_inc
	add	y, al		;get Y address
	jmp	hit2_3
;
hit2_2_1:
	mov	h_board, 1h
	mov	y_inc, 2h 
	mov	al, y_inc
	add	y, al		;get Y address
	jmp	hit2_3
;
hit2_2:
	mov	h_board, 1h
	mov	y_inc, 2h 
	mov	al, y_inc
	add	y, al		;get Y address
	neg	x_inc
	jmp	hit2_3
;
hit2_3:
	cmp	x, 7h
	jnz	n_right2
	mov	x_inc, -1h
n_right2:
	cmp	x_inc, -1h
	jz	not_inc2
	inc	x
not_inc2:
	mov	al, x
	mov	ah, y
	call	print_ball1
	;Turn one of the LEDs off
    mov   al,1100b
    mov   dx,i8255_base_address+2       ;point to PC
    out   dx,al               ;enable LED at PC0
;
end_hit_board2:
	mov	h_full, 0h
	ret
	hit_board2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
block_d1 proc    near
	push	bx
	push	ax
	call	read_in2
	and	al, 0f0h
	cmp	half, 1h
	jnz	not_half1
	cmp	al, 90h
	jz	have1_2
	jmp	have1_3
not_half1:
	cmp	al, 0f0h
	jz	have1_1
;
;single block
	pop	ax
	mov	bl, x
	mov	bh, y
	mov	x, al
	mov	y, ah
	push	bx
	call	clear_ball
	pop	bx
	mov	x, bl
	mov	y, bh
	jmp	end_block_d1
;
;double blocks
have1_1:
	pop	ax
	mov	bl, x
	mov	bh, y
	mov	x, al
	mov	y, ah
	push	bx
	call	print_ball2
	pop	bx
	mov	x, bl
	mov	y, bh
	jmp	end_block_d1
;
;rising half
have1_2:
	call    check_busy2
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address2
	out	dx, al          ;set X address
	push	ax
	call    check_busy2
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address2
	out	dx, al          ;set Y address
;
	call    check_busy2
	mov	al, 90h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0f0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
	jmp	end_block_d1
;
;dropping half
have1_3:
	call    check_busy2
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address2
	out	dx, al          ;set X address
	push	ax
	call    check_busy2
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address2
	out	dx, al          ;set Y address
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0f0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0d0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
end_block_d1:  
	pop	bx
	ret
	block_d1 endp                      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
block_d2 proc    near
	push	bx
	push	ax
	call	read_in2
	and	al, 0fh
	cmp	half, 1h
	jnz	not_half2
	cmp	al, 0fh
	jz	have2_2
	jmp	have2_3
not_half2:
	cmp	al, 0fh
	jz	have2_1
;
;single block
	pop	ax
	mov	bl, x
	mov	bh, y
	mov	x, al
	mov	y, ah
	push	bx
	call	clear_ball
	pop	bx
	mov	x, bl
	mov	y, bh
	jmp	end_block_d2
;
;double blocks
have2_1:
	pop	ax
	call	print_block1
	jmp	end_block_d2
;
;rising half
have2_2:
	call    check_busy2
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address2
	out	dx, al          ;set X address
	push	ax
	call    check_busy2
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address2
	out	dx, al          ;set Y address
;
	call    check_busy2
	mov	al, 0fh
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0fh
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
	jmp	end_block_d2
;
;dropping half
have2_3:
	call    check_busy2
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address2
	out	dx, al          ;set X address
	push	ax
	call    check_busy2
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address2
	out	dx, al          ;set Y address
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0h
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0fh
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
	call    check_busy2
	mov	al, 0bh
	mov	dx, lcd_base_address2
	inc	dx
	out	dx, al
;
end_block_d2:  
	pop	bx
	ret
	block_d2 endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_in1	proc	near	
	push	ax
	call    check_busy1
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address1
	out	dx, al          ;set X address
	push	ax
	call    check_busy1
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address1
	out	dx, al          ;set Y address
;
	call    check_busy1
	mov	dx, lcd_base_address1
	inc	dx
	in	al, dx
	call    check_busy1
	mov dx, lcd_base_address1
	inc dx
	in	al, dx
	ret
	read_in1 endp	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
read_in2	proc	near	
	push	ax
	call    check_busy2
	pop	ax
	add	al, 10111000b
	mov	dx, lcd_base_address2
	out	dx, al          ;set X address
	push	ax
	call    check_busy2
	pop	ax
	mov	al, ah
	mov	dx, lcd_base_address2
	out	dx, al          ;set Y address
;
	call    check_busy2
	mov	dx, lcd_base_address2
	inc	dx
	in	al, dx
	call    check_busy2
	mov dx, lcd_base_address2
	inc dx
	in	al, dx
	ret
	read_in2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p1	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy2
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 01111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 00011110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00011100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p2	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 01111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00001100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100010b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p3	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100010b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100010b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p4	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01111111b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00110011b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00110110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 00111000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p5	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100010b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p6	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 000111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p6 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p7	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00011000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00110000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 01111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p7 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p8	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p8 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p9	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 01111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p9 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
p0	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	p0 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ps	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01100010b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 01100000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	ps endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pc	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 00111000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01000100b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111000b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	pc endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pr	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 11000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00110110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00011110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01100110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	pr endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pe	proc	near
	push	ax
	call	check_busy1
	pop	ax
	mov	dx,lcd_base_address1
	add	al, 10111000b
	out	dx, al				;set X address
	push	ax
	call	check_busy1
	pop	ax
	mov	al, ah
	mov	dx,lcd_base_address1
	out	dx, al				;set Y address
;1
	call	check_busy1
	mov	al, 01111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;2
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;3
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;4
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;5
	call	check_busy1
	mov	al, 00111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;6
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;7
	call	check_busy1
	mov	al, 00000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;8
	call	check_busy1
	mov	al, 01000110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;9
	call	check_busy1
	mov	al, 01111110b
	mov	dx,lcd_base_address1
	inc	dx
	out	dx, al
;
	ret
	pe endp	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
draw_miku proc near
	mov	bx, offset pg00
	mov pointer, 10111101b

	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, pointer
	out dx, al

	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, 01000000b
	out dx, al
	
	mov cx, 3d
draw00:
	push cx
	mov cx, 64d
draw01:
	call	check_busy2
	mov	dx,lcd_base_address2
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop draw01
	pop cx
	inc pointer
	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, pointer
	out dx, al
	loop draw00

again:
	mov	bx, offset pg10
	mov pointer, 10111000b
	
	mov cx, 6
shake:
	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, pointer
	out dx, al

	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, 01000000b
	out dx, al
	
	push cx
	mov cx, 5d
draw10:
	push cx
	mov cx, 64d
draw11:
	call	check_busy2
	mov	dx,lcd_base_address2
	inc	dx
	mov	al, cs:[bx]
	out	dx, al
	inc bx
	loop draw11
	
	pop cx
	inc pointer
	
	call	check_busy2
	mov	dx,lcd_base_address2
	mov al, pointer
	out dx, al
	
	loop draw10
	
;	push cx
;	mov cx, 50
;dly:
;	call delay10
;	loop dly
;	pop cx
	
	inc	bx
	mov pointer, 10111000b
	pop cx
	loop shake
	
	jmp again
	ret
draw_miku endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dango proc near  
call gate2en
star:
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call delayair
call CC
call delay60
call G
call delay60
call delayair
call draw_miku
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call CC
call delay120
call delayair
call draw_miku
;;;;;;;;;;;;
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call delayair
call draw_miku
call CC
call delay60
call G
call delay60
call delayair
call draw_miku
call A
call delay30
call delayair
call draw_miku
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call CC
call delay240
call delayair
call draw_miku
;;;;;;;;;;;;
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call CC
call delay60
call G
call delay60
call delayair
call draw_miku
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call CD
call delay120
call delayair
call draw_miku
;;;;;;;;;;;;
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CD
call delay60
call CE
call delay60
call CC
call delay60
call G
call delay60
call delayair
call draw_miku
call A
call delay30
call G
call delay30
call CC
call delay60
call delayair
call draw_miku
call CC
call delay60
call CD
call delay60
call delayair
call draw_miku
call CC
call delay120
call G
call delay120
call delayair
call draw_miku
;;;;;;;;;;;;
;;;;;;;;;;;;
call CF
call delay30
call CE
call delay30
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call A
call delay30
call delayair
call draw_miku
call CC
call delay60
call G
call delay60
call A
call delay60
call CC
call delay60
call delayair
call draw_miku
call CF
call delay30
call CE
call delay30
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call A
call delay30
call delayair
call draw_miku
call CC
call delay240
call delayair
call draw_miku
;;;;;;;;;;;;
call CF
call delay30
call CE
call delay30
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call A
call delay30
call delayair
call draw_miku
call CC
call delay60
call G
call delay60
call A
call delay60
call CC
call delay30
call G
call delay30
call G
call delay80
call CC
call delay30
call F
call delay80
call delayair
call draw_miku
call F
call delay30
call delayair
call draw_miku
call G
call delay30
call F
call delay30
call G
call delay30
call F
call delay30
call D
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
;;;;;;;;;;;;
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call CE
call delay30
call CG
call delay30
call CD
call delay30
call CE
call delay60
call CC
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CD
call delay30
call CC
call delay30
call CG
call delay30
call CE
call delay120
call D
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
;;;;;;;;;;;;
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call CE
call delay30
call CG
call delay30
call CD
call delay30
call CE
call delay60
call CC
call delay60
call B
call delay60
call A
call delay120
call B
call delay60
call CC
call delay30
call B
call delay30
call B
call delay30
call CC
call delay30
call C
call delay30
call G
call delay30
call D
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
;;;;;;;;;;;;
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call CE
call delay30
call CG
call delay30
call CD
call delay30
call CE
call delay60
call CC
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CD
call delay30
call CC
call delay30
call CG
call delay30
call CE
call delay120
call D
call delay30
call G
call delay30
call CC
call delay30
call CD
call delay30
call delayair
call draw_miku
;;;;;;;;;;;;
call CD
call delay60
call CC
call delay30
call A
call delay30
call A
call delay30
call CC
call delay30
call CD
call delay30
call CE
call delay30
call CG
call delay30
call CD
call delay30
call CE
call delay60
call CC
call delay60
call B
call delay60
call A
call delay120
call B
call delay60
call CC
call delay30
call B
call delay30
call B
call delay30
call CC
call delay30
call CC
call delay60
call CC
call delay120
call draw_miku
call draw_miku
call draw_miku
;;;;;;;;;;;;
jmp star
call gate2di
ret      
dango endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MOD_8254
;initialize 8254 counter 2 by value of BX
MOD_8254  PROC  NEAR
	  push ax
	  push dx

      mov     al,10110110B
      mov     dx,i8254_base_address
      inc     dx
      inc     dx
      inc     dx		;point to command register
      out     dx,al
      
      mov     al,bl		;LSB of counter 2
      mov     dx,i8254_base_address
      out     dx,al
      mov     al,bh		;MSB of counter 2
      out     dx,al
     
      pop dx
      pop ax
      RET
MOD_8254  ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delayair         proc    near
	call	gate2di
	push	cx
	mov	cx,3ffh*5
delay_air:	nop
	nop
	nop
	loop	delay_air
	pop	cx
	call	gate2en
	ret
delayair	endp

delay10    proc  near
      push  cx
      mov   cx,790h
delay_1:   nop
      nop
      loop  delay_1
      pop   cx
      ret
delay10    endp

delay15 proc near
      push cx
      mov cx,15
delay_15:
      call delay10
      loop delay_15
      pop   cx
      ret
delay15    endp  

delay20 proc near
      push cx
      mov cx,20
delay_20:
      call delay10
      loop delay_20
      pop   cx
      ret
delay20    endp

delay25 proc near
      push cx
      mov cx,25
delay_25:
      call delay10
      loop delay_25
      pop   cx
      ret
delay25    endp 

delay30 proc near
      push cx
      mov cx,30
delay_30:
      call delay10
      loop delay_30
      pop   cx
      ret
delay30    endp    

delay40 proc near
      push cx
      mov cx,40
delay_40:
      call delay10
      loop delay_40
      pop   cx
      ret
delay40    endp

delay50 proc near
      push cx
      mov cx,50
delay_50:
      call delay10
      loop delay_50
      pop   cx
      ret
delay50    endp   

delay60 proc near
      push cx
      mov cx,60
delay_60:
      call delay10
      loop delay_60
      pop   cx
      ret
delay60    endp 

delay80 proc near
      push cx
      mov cx,80
delay_80:
      call delay10
      loop delay_80
      pop   cx
      ret
delay80    endp

delay120 proc near
      push cx
      mov cx,120
delay_120:
      call delay10
      loop delay_120
      pop   cx
      ret
delay120    endp    

delay240 proc near
      push cx
      mov cx,240
delay_240:
      call delay10
      loop delay_240
      pop   cx
      ret
delay240    endp 

delay1s    proc  near
      push  cx
      mov   cx,100
delay_1s:   
      call delay10
      loop  delay_1s
      pop   cx
      ret
delay1s    endp

delay2s  proc near
      push  cx
      mov   cx,200
delay_2s:   
      call delay10
      loop  delay_2s
      pop   cx
      ret
delay2s    endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gate2en proc near		
	mov dx, i8255_base_address + 1
	mov al, 00000111b
	out dx, al		; Enable Counter 2 of 8254
ret
gate2en endp		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
C proc near
					mov bx, 4778        ; Play 261.63Hz -- C4
					call MOD_8254
					ret
          C endp
D proc near
					mov bx,  4257        ; Play 293.66Hz -- D4
					call MOD_8254
					ret
          D endp
E proc near
					mov bx,  3792       ; Play 329.63Hz -- E4
					call MOD_8254
					ret
          E endp
F proc near
					mov bx,  3579       ; Play 349.23Hz -- F4
					call MOD_8254
					ret
          F endp
G proc near
					mov bx,   3189     ; Play 392.00Hz -- G4
					call MOD_8254
					ret
G endp
A proc near
					mov bx,    2841          ; Play 440.00Hz -- A4
					call MOD_8254
					ret
 A endp
B proc near
					mov bx,   2531          ; Play 493.88Hz -- B4
					call MOD_8254
					ret
          B endp
CC proc near		
					mov bx,   2389          ; Play 523.25Hz --  C5
					call MOD_8254
					ret
CC endp
CD proc near		
					mov bx,   2128          ; Play 587.33Hz --  D5
					call MOD_8254
					ret
CD endp
CE proc near		
					mov bx,   1896          ; Play 659,26Hz --  E5
					call MOD_8254
					ret
CE endp
CF proc near		
					mov bx,   1790          ; Play 698.46Hz --  F5
					call MOD_8254
					ret
CF endp
CG proc near		
					mov bx,   1594          ; Play 783.99Hz --  G5
					call MOD_8254
					ret
CG endp
CA proc near		
					mov bx,   1420          ; Play 880.00Hz --  A5
					call MOD_8254
					ret
CA endp
CB proc near		
					mov bx,   1265          ; Play 987.77Hz --  B5
					call MOD_8254
					ret
CB endp
CCC proc near	
					mov bx,   1194          ; Play 1046.50Hz --  C6
					call MOD_8254
					ret
CCC endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gate2di proc near
	mov dx,i8255_base_address+1
   	 mov al,00000000B		
    	out dx,al
	ret
gate2di endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pg00 db 4  dup (000h), 016h, 01fh, 3 dup (0ffh), 0efh, 5 dup (0e7h), 0f7h, 0f7h, 096h, 077h, 4 dup (0ffh), 0e7h,  083h, 093h, 081h, 083h, 047h, 076h, 046h, 0c4h, 065h, 09fh, 0bfh, 0efh, 0eeh, 0d8h, 0f0h, 03fh, 4 dup (022h), 03ch, 3 dup (000h), 0c1h, 041h, 060h, 061h, 0f2h, 074h, 053h, 054h,  0d8h, 020h, 003h, 01fh, 0e2h, 3 dup (000h)
pg01 db 5  dup (000h), 001h, 3 dup (003h), 9 dup (007h), 016h, 2 dup (07fh), 4 dup (0ffh), 3 dup (07fh), 2 dup (03fh), 3 dup (01fh), 019h, 3 dup (010h), 011h, 011h, 01eh, 01ch, 038h, 070h, 4 dup (0f0h), 0b6h, 094h, 09bh, 09eh, 089h, 0c4h, 0e4h, 072h, 079h, 07ch, 038h, 0e8h, 047h, 4 dup (000h)
pg02 db 3  dup (000h), 040h, 3 dup (0c0h), 0e0h, 0e0h, 0f0h, 0d8h, 2 dup (0cch), 2 dup (0c4h), 086h , 084h, 085h, 2 dup (087h), 3 dup (083h), 087h, 086h, 2 dup (084h), 2 dup (004h), 3 dup (02ch), 2 dup (06ch), 068h, 3 dup (028h), 03ch, 034h, 034h, 3 dup (094h), 05bh, 04bh, 06bh, 02bh, 025h, 2 dup (011h), 3 dup (010h), 004h, 006h, 002h, 001h, 6 dup (000h)  

pg10 db 46 dup (000h), 038h, 0ffh, 0ffh, 0c0h, 080h, 0e0h, 060h, 11 dup (000h)
pg11 db 46 dup (000h), 0c0h, 03fh, 0dfh, 03fh, 007h, 001h, 12 dup (000h)
pg12 db 42 dup (000h), 080h, 060h, 090h, 06fh, 010h, 01fh, 16 dup (000h)
pg13 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 091h, 0dah, 0fah, 0fah, 092h, 054h, 0bah, 0bah, 0c8h, 0e8h, 0e8h, 0f0h, 0d0h, 0d0h ,0e0h, 0f8h, 0feh, 0ffh, 0feh, 0ffh, 0feh, 0f8h, 0f0h, 17 dup (000h)
pg14 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0fdh, 0f7h, 0e7h, 0e7h, 0edh, 0ffh, 0dfh, 08fh, 087h, 005h, 084h, 00fh, 01fh, 01fh, 03bh, 073h, 0ffh, 03fh, 03fh, 01fh, 01fh, 01fh, 01eh, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)

pg20 db 64 dup (000h)
pg21 db 56 dup (000h), 080h, 0c0h, 0e0h, 0e0h, 0f0h, 070h, 030h, 000h
pg22 db 44 dup (000h), 080h, 4 dup (040h), 020h, 0a0h, 090h, 050h, 058h, 03ch, 4 dup (01fh), 3 dup (00ch), 2 dup (000h) 
pg23 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 091h, 0dah, 0fah, 0fah, 092h, 054h, 0bah, 0bah, 048h, 048h, 0e8h, 0f8h, 0fch, 0fch ,0feh, 0feh, 0feh, 0fdh, 0fdh, 0fdh, 0a2h, 0c2h, 5 dup (001h), 13 dup (000h) 
pg24 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0fdh, 0f7h, 0e7h, 0e7h, 0edh, 0ffh, 0dfh, 08fh, 087h, 005h, 084h, 00fh, 01fh, 01fh, 03bh, 073h, 0ffh, 03fh, 03fh, 01fh, 01fh, 01fh, 01eh, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)

pg30 db 48 dup (000h), 080h, 0f0h, 0e0h, 000h, 080h, 0c0h, 0e0h, 0f0h,060h, 7 dup (000h)
pg31 db 45 dup (000h), 0c0h, 020h, 09ch, 07fh, 01fh, 01fh, 00fh, 007h, 003h, 001h, 9 dup (000h)
pg32 db 40 dup (000h), 080h, 060h, 090h, 0c8h, 034h, 00bh, 004h, 003h, 16 dup (000h)
pg33 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 091h, 0dah, 0fah, 0fah, 092h, 054h, 0bah, 0bah, 0b4h, 0f8h, 0f8h, 0fch, 0fch ,0feh, 0feh, 0ffh, 0fch, 0ffh, 0fch, 030h, 0c0h ,080h, 18 dup (000h) 
pg34 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0fdh, 0f7h, 0e7h, 0e7h, 0edh, 0ffh, 0dfh, 08fh, 087h, 005h, 084h, 00fh, 01fh, 01fh, 03bh, 073h, 0ffh, 03fh, 03fh, 01fh, 01fh, 01fh, 01eh, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)

pg40 db 34 dup (000h), 0fch, 0fch, 0f0h, 0f0h, 0fch, 07fh, 01fh, 001h, 22 dup (000h)
pg41 db 32 dup (000h), 0e0h, 030h, 0efh, 027h, 01fh, 003h, 26 dup (000h)
pg42 db 32 dup (000h), 00fh, 070h, 0cfh, 070h, 080h, 27 dup (000h)
pg43 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 091h, 0dah, 0fah, 0fah, 092h, 054h, 0bah, 0bah, 0feh, 0ffh, 0ffh, 0feh, 0ffh, 0fch ,098h, 0b0h, 0a0h, 040h, 040h, 080h, 080h, 19 dup (000h)
pg44 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0fdh, 0f7h, 0e7h, 0e7h, 0edh, 0ffh, 0dfh, 08fh, 0bfh, 07fh, 0bfh, 03fh, 3 dup (00fh), 048h, 0fbh, 03bh, 01bh, 019h, 012h, 01bh, 013h, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)

pg50 db 22 dup (000h), 018h, 078h, 0e0h, 0e0h, 0ffh, 0ffh, 07ch, 35 dup (000h)
pg51 db 24 dup (000h), 001h, 01fh, 0e7h, 01fh, 0e0h, 35 dup (000h)
pg52 db 26 dup (000h), 001h, 00eh, 011h, 026h, 058h, 0a0h, 040h, 080h, 30 dup (000h)
pg53 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 091h, 0dah, 0fah, 0fah, 3 dup (0feh), 0ffh, 0feh, 0ffh, 0feh, 0fch, 0f8h, 050h ,050h, 0b0h, 0b0h, 060h, 040h, 080h, 080h, 19 dup (000h)
pg54 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0fdh, 0f7h, 0e7h, 0e7h, 0efh, 0ffh, 0dfh, 0bfh, 0bfh, 07fh, 0bfh, 03fh, 3 dup (00fh), 048h, 0fbh, 03bh, 01bh, 019h, 012h, 01bh, 013h, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)

pg60 db 15 dup (000h), 0f0h, 0e0h, 0c0h, 46 dup (000h)
pg61 db 13 dup (000h), 00ch, 00ch, 018h, 039h, 07fh, 2 dup (0ffh), 0e0h, 43 dup (000h)
pg62 db 18 dup (000h), 003h, 005h, 009h, 00ah, 012h, 024h, 058h, 0b0h, 2 dup (040h), 080h, 35 dup (000h)
pg63 db 7  dup (000h), 060h, 0d0h, 098h, 0fch, 0fch, 09ah, 0dah, 0aah, 04eh, 05dh, 0edh, 049h, 031h, 4 dup (053h), 0b1h, 0fbh, 0ffh, 0feh, 0feh, 0ffh, 0feh, 0ffh, 0feh, 0ffh, 0feh, 0fch, 0f8h, 050h ,050h, 0b0h, 0b0h, 060h, 040h, 080h, 080h, 19 dup (000h)
pg64 db 6  dup (000h), 4 dup (080h), 0c0h, 0c1h, 0c3h, 0c6h, 0cch, 0cdh, 0cdh, 04fh, 00fh, 0dch, 0fdh, 0ffh, 0f7h, 0fdh, 0ffh, 0ffh, 0e7h, 0e7h, 0efh, 0ffh, 0dfh, 0bfh, 0bfh, 07fh, 0bfh, 03fh, 3 dup (00fh), 048h, 0fbh, 03bh, 01bh, 019h, 012h, 01bh, 013h, 096h, 07eh, 0fch, 02ch, 0fch, 0dch, 0fch, 098h, 038h, 070h, 0e0h, 060h, 0c0h, 5 dup (000h)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;setup the reset vector
	org 07ff0h
	jmp dumst
code_seg ends
	end start