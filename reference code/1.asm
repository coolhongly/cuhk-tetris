;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Test Program for COLOR LCD  ;;;;
;;;; The program will keep filling the COLOR LCD with different color
;;;; When SW1 is pressed, it will change the color and keep filling the LCD screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DEVICE ON	LCD	8259	8254    8255-1  8255-2    COLOR_LCD
;   20V8(1)	(pin17) (pin18) (pin19) (pin20) (pin16)    
;		 0cxh	 0dxh    0exh    0fxh    1xh
;;;;;;;;;;;;;;;;;;;
;DEVICE ON	COLOR_LCD
;   20V8(2)	(pin15)
;		 03xh	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lcd_base_address   equ 0f0h ;modify this value
i8259_base_address equ 080h ;modify this value
i8254_base_address equ 070h ;modify this value
i8255_base_address equ 060h ;modify this value
touch_base_address equ 050h
color_base_address equ 040h ;modify this value

stack_seg	segment	at 0
top_of_stack	equ	800h
stack_seg	ends

data_seg	segment at 0
	ptft_cmd		db	?
	ptft_val		dw	?
	ptft_color		dw  ?
	speed dw ?   ;speed indicator
	score dw ?   
	temp db ?    ;for calculate the score
	timer_channel_0_lsb db ?
	timer_channel_0_msb db ?
data_seg	ends

;dummy code segment
dummy_code	segment	at 0f800h
		org 0
dumst		label	far 	;CS:IP for this label will be
				;assigned by the linker
dummy_code ends

;the start of Code Segment
;f8000-fffff for program
code_seg	segment	public 'code'
		extrn	exp7_test:near
		assume	cs:code_seg
;Main Program
start:
	mov	ax,data_seg	;initialize DS
	mov	ds,ax
	assume	ds:data_seg
	mov	ax,stack_seg	;initialize SS
	mov	ss,ax
	assume	ss:stack_seg
	mov	sp,top_of_stack ;initialise SP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      call  ram_test
      call  init_8254
      call  init_8255
	  
;print data to tft
	  call  INIT_TFT
	  call	INIT_TFT_FILL  
	  mov   al,0
	 
	  mov 	ptft_color, 011111b	  
      ;call iLCD_1
	  ;call iLCD_2
	  ;call iLCD_3
	  ;call iLCD_4
	  ;call iLCD_5
	 ; call iLCD_6
	  ;call iLCD_7
	  ;call iLCD_8
	  mov ptft_color,0ffh ;set colour1
	  call LCD_1
	  call LCD_2
	  call LCD_3
	  call LCD_4
	  call LCD_5
	  call LCD_6
	  call LCD_7
	  call LCD_8
	  call  init_LCD
	  init:
	  mov cx,3h    ;set the looping time
 call cal_score
jstart label far
mov cx,3h
 mov score,0h
  mov   al,0
mov speed ,cx
	check5: 
	call check_key1
		jnc check5
astart:	

	   push cx
	   
	   
   cc label far 
   
   
;1

   call b4
   	mov		ptft_val, 0000000000011111b ;0
    call s_LCD  
call eight	
	
   call delay10
   call score0
   call score0
   call score0
   call score0
	call cal_score
   call c5

		mov		ptft_val, 0001001000011111b ;1
	call s_LCD
	   call eight
   call delay10
   call score1
   call score1
   call score1
   call score1
    call cal_score
	
    call b4
    mov	ptft_val, 0010010000011111b ;2
	call s_LCD
		   call eight
	   call eight
   call delay10
   call score2
   call score2
   call score2
   call score2
   call cal_score
   
   
    call a4
    mov		ptft_val, 0011011000011111b ;3
    call s_LCD
    call eight
	   call eight
   call delay10
   call score3
   call score3
   call score3
   call score3
   call cal_score
   
   call g4

 
 
 
 
 
 
 
   		mov		ptft_val, 0100100000011111b ;4
	call s_LCD
call eight
	   call eight
   call delay10
   call score4
   call score4
   call score4
   call score4
call cal_score
   call a4
   		mov		ptft_val, 0101101000011111b ;5
	call s_LCD
	call eight
	   call eight
   call delay10
   call score5
   call score5
   call score5
   call score5
call cal_score

   call b4
   		mov		ptft_val, 0110110000011111b ;6
	call s_LCD
call four

	   call eight
   call delay10
   call score6
   call score6
   call score6
   call score6
call cal_score
;3
call ff4
		mov		ptft_val,  0111111000011111b ;7
	call s_LCD
call eight

	   call eight
   call delay10
   call score7
   call score7
   call score7
   call score7
call cal_score
call g4
		mov		ptft_val, 0110110000011111b ;6
	call s_LCD
call eight

	   call eight
   call delay10
   call score6
   call score6
   call score6
   call score6
call cal_score
call a4
		mov		ptft_val, 0101101000011111b ;5
	call s_LCD
call four

	   call eight
   call delay10
   call score5
   call score5
   call score5
   call score5
call cal_score
call g4
		mov		ptft_val, 0100100000011111b ;4
	call s_LCD
call eight

	   call eight
   call delay10
   call score4
   call score4
   call score4
   call score4
   
call cal_score
call a4
		mov		ptft_val, 0011011000011111b ;3
	call s_LCD
call eight

	   call eight
   call delay10
   call score3
   call score3
   call score3
   call score3
   
call cal_score
call b4
			mov		ptft_val, 0010010000011111b ;2
	call s_LCD
call four
	   call eight
   call delay10
   call score2
   call score2
   call score2
   call score2
call cal_score

;5
call b4
		mov		ptft_val, 0011011000011111b ;3
	call s_LCD
call eight
	   call eight
   call delay10
   call score3
   call score3
   call score3
   call score3
call cal_score

call c5
		mov		ptft_val,  0111111000011111b ;7
	call s_LCD
call eight

	   call eight
   call delay10
   call score7
   call score7
   call score7
   call score7
call cal_score
call b4
		mov		ptft_val, 0001001000011111b ;1
	call s_LCD
call eight

	   call eight
   call delay10
   call score1
   call score1
   call score1
   call score1
call cal_score

call a4
		mov		ptft_val, 0100100000011111b ;4
	call s_LCD
call eight

	   call eight
   call delay10
   call score4
   call score4
   call score4
   call score4
call cal_score

;6
call g4
		mov		ptft_val, 0011011000011111b ;3
	call s_LCD
call eight
	   call eight
   call delay10
   call score3
   call score3
   call score3
   call score3
call cal_score


call a4
		mov		ptft_val, 0101101000011111b ;5
	call s_LCD
call eight
	   call eight
   call delay10
   call score5
   call score5
   call score5
   call score5
call cal_score


call b4
		mov		ptft_val, 0011011000011111b ;3
	call s_LCD
call four
   call delay10
   call score3
   call score3
   call score3
   call score3
call cal_score


call ff4
		mov		ptft_val, 0001001000011111b ;1
	call s_LCD
call four
   call delay10
   call score1
   call score1
   call score1
   call score1
call cal_score


call b4
		mov		ptft_val,  0111111000011111b ;7
	call s_LCD
call four
   call delay10
   call score7
   call score7
   call score7
   call score7
call cal_score


call ff4
	mov		ptft_val, 0000000000011111b ;0
    call s_LCD
call eight
   call delay10
   call score0
   call score0
   call score0
   call score0
call cal_score


call d4
		mov		ptft_val, 0100100000011111b ;4
	call s_LCD
call eight
   call delay10
   call score4
   call score4
   call score4
   call score4
call cal_score



call d4
		mov		ptft_val, 0110110000011111b ;6
	call s_LCD
call four
   call delay10
   call score6
   call score6
   call score6
   call score6
call cal_score




dec cx

	mov    	dx,lcd_base_address
busy8: 	in     	al,dx
	and    	al,10000000b
	jnz    	busy8
	mov    	al,00000001b    ;clear screen
	out    	dx,al
;display string1
    
	
cmp cx,0h

jne nn
call cal_score
jmp jstart
nn:
jmp cc


 
output_string00 db 'Your score is 0',0dh
output_string1 db 'Your score is 1',0dh 
output_string2 db 'Your score is 2',0dh 
output_string3 db 'Your score is 3',0dh 
output_string4 db 'Your score is 4',0dh 
output_string5 db 'Your score is 5',0dh 
output_string6 db 'Your score is 6',0dh 
output_string7 db 'Your score is 7',0dh 
output_string8 db 'Your score is 8',0dh 
output_string9 db 'Your score is 9',0dh 
output_string10 db 'Your score is 10',0dh 
output_string11 db 'Your score is 11',0dh 
output_string12 db 'Your score is 12',0dh 
output_string13 db 'Your score is 13',0dh 
output_string14 db 'Your score is 14',0dh 
output_string15 db 'Your score is 15',0dh 
output_string16 db 'Your score is 16',0dh 
output_string17 db 'Your score is 17',0dh 
output_string18 db 'Your score is 18',0dh 
output_string19 db 'Your score is 19',0dh 
output_string20 db 'Your score is 20',0dh 
output_string21 db 'Your score is 21',0dh 
output_string22 db 'Your score is 22',0dh 
output_string23 db 'Your score is 23',0dh 
output_string24 db 'Your score is 24',0dh 
output_string25 db 'Your score is 25',0dh 
output_string26 db 'Your score is 26',0dh 
output_string27 db 'Your score is 27',0dh 
output_string28 db 'Your score is 28',0dh 
output_string29 db 'Your score is 29',0dh 
output_string30 db 'Your score is 30',0dh 
output_string31 db 'Your score is 31',0dh 
output_string32 db 'Your score is 32',0dh 
output_string33 db 'Your score is 33',0dh 
output_string34 db 'Your score is 34',0dh 
output_string35 db 'Your score is 35',0dh 
output_string36 db 'Your score is 36',0dh 
output_string37 db 'Your score is 37',0dh 
output_string38 db 'Your score is 38',0dh 
output_string39 db 'Your score is 39',0dh 
output_string40 db 'Your score is 40',0dh 
output_string41 db 'Your score is 41',0dh 
output_string42 db 'Your score is 42',0dh 
output_string43 db 'Your score is 43',0dh 
output_string44 db 'Your score is 44',0dh 
output_string45 db 'Your score is 45',0dh 
output_string46 db 'Your score is 46',0dh 
output_string47 db 'Your score is 47',0dh 
output_string48 db 'Your score is 48',0dh 
output_string49 db 'Your score is 49',0dh 
output_string50 db 'Your score is 50',0dh 
output_string51 db 'Your score is 51',0dh 
output_string52 db 'Your score is 52',0dh 
output_string53 db 'Your score is 53',0dh 
output_string54 db 'Your score is 54',0dh 
output_string55 db 'Your score is 55',0dh 
output_string56 db 'Your score is 56',0dh 
output_string57 db 'Your score is 57',0dh 
output_string58 db 'Your score is 58',0dh 
output_string59 db 'Your score is 59',0dh 
output_string60 db 'Your score is 60',0dh 
output_string61 db 'Your score is 61',0dh 
output_string62 db 'Your score is 62',0dh 
output_string63 db 'Your score is 63',0dh 
output_string64 db 'Your score is 64',0dh 
output_string65 db 'Your score is 65',0dh 
output_string66 db 'Your score is 66',0dh 
output_string67 db 'Your score is 67',0dh 
output_string68 db 'Your score is 68',0dh 
output_string69 db 'Your score is 69',0dh 
output_string70 db 'Your score is 70',0dh 
output_string71 db 'Your score is 71',0dh 
output_string72 db 'Your score is 72',0dh 
output_string73 db 'Your score is 73',0dh 
output_string74 db 'Your score is 74',0dh 
output_string75 db 'Your score is 75',0dh 
output_string76 db 'Your score is 76',0dh 
output_string77 db 'Your score is 77',0dh 
output_string78 db 'Your score is 78',0dh 
output_string79 db 'Your score is 79',0dh 
output_string80 db 'Your score is 80',0dh 
output_string81 db 'Your score is 81',0dh 
output_string82 db 'Your score is 82',0dh 
output_string83 db 'Your score is 83',0dh 
output_string84 db 'Your score is 84',0dh 
output_string85 db 'Your score is 85',0dh 
output_string86 db 'Your score is 86',0dh 
output_string87 db 'Your score is 87',0dh 
output_string88 db 'Your score is 88',0dh 
output_string89 db 'Your score is 89',0dh 
output_string90 db 'Your score is 90',0dh 
output_string91 db 'Your score is 91',0dh 
output_string92 db 'Your score is 92',0dh 
output_string93 db 'Your score is 93',0dh 
output_string94 db 'Your score is 94',0dh 
output_string95 db 'Your score is 95',0dh 
output_string96 db 'Your score is 96',0dh 
output_string97 db 'Your score is 97',0dh 
output_string98 db 'Your score is 98',0dh 
output_string99 db 'Your score is 99',0dh 
output_string100 db 'Your score is 100',0dh 

   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For Color LCD (800x480)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loop1:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	loop1


	  
RAM_TEST   PROC  NEAR
           MOV   AL,55H
           MOV   BX, 0
RAM_TEST1: MOV   [BX],AL
           MOV   AH,[BX]
           CMP   AL,AH
           JNE   RAM_TEST1
           MOV   AL,0AAH
RAM_TEST2: MOV   [BX],AL
           MOV   AH,[BX]
           CMP   AL,AH
           JNE   RAM_TEST2
           INC   BX
           CMP   BX,400H
           JNE   RAM_TEST1
           RET
RAM_TEST   ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sound_one_second proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
      mov   cx,100
sound_1:   call  delay10
      loop  sound_1
      mov   al,110b
      out   dx,al
      ret
sound_one_second endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;Check key pressed
check_key  proc  near
      mov     dx,i8255_base_address
      in      al,dx
      and     al,10000000b
      jnz     kp1
      call    delay10       ;software debouncing
      mov     dx,i8255_base_address
      in      al,dx
      and     al,10000000b
      jnz     kp1
      stc                     ;key pressed
      ret
kp1:  clc
      ret
check_key  endp
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;initialize LCD
INIT_LCD   PROC  NEAR
;set function
      mov        dx,lcd_base_address
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
	  busy22: 	in     	al,dx
	and    	al,10000000b
	jnz    	busy22
	mov    	al,00000001b    ;clear screen
	out    	dx,al
      ret
INIT_LCD   ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHECK_KEY1
;Check key pressed
check_key1  proc  near

      mov     dx,i8255_base_address
      in      al,dx
      and     al,10000000b
      jnz     kp1
      call    delay10       ;software debouncing
      mov     dx,i8255_base_address
      in      al,dx
      and     al,10000000b
      jnz     kp21
      stc                     ;key pressed
      ret
kp21:  clc
      ret
check_key1  endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;initialize 8254
;       channel 0 at mode 3, 2KHz
INIT_8254  PROC  NEAR
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
;       channel 2 at mode 3, 0.01 sec
timer_channel_2_msb     equ     97
timer_channel_2_lsb     equ     168
      mov     al,10110110B
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
INIT_TFT   PROC  NEAR  ;set dis_page, cont_page, cpy_src, backlight
	mov		ptft_cmd, 05h
	mov		ptft_val, 0001fh
	call 	TFT_CMD
	RET
INIT_TFT   ENDP
INIT_TFT_FILL PROC NEAR	; set fill display area (0,0 - 799,479)
	
	mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;y end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;x end
	mov		ptft_val, 001dfh
	call 	TFT_CMD
	RET
INIT_TFT_FILL ENDP
TFT_FILL	PROC NEAR	
	mov		bx, ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	call 	TFT_CMD
	RET
TFT_FILL	ENDP
TFT_CMD	PROC NEAR
	mov		al, ptft_cmd
	mov		bx, ptft_val
	mov		dx, color_base_address
	out 	dx, al	; command
	inc		dx		
	mov		al, bh	
	out 	dx, al	; high 8 bit
	mov		al, bl	
	out		dx, al	; low 8 bit
	RET
TFT_CMD	ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
INIT_8259  PROC  NEAR
;       set     ICW1
      mov     dx,i8259_base_address       ;point to ICW1
      mov     al,00010011b        ;ICW4 needed,single,edge trigger
      out     dx,al
;       set     ICW2
      inc     dx                       ;point to ICW2
      mov     al,00001000b        ;base address=08h
      out     dx,al
;       set     ICW4
      mov     al,00000011b        ;8088 mode,auto EOI
      out     dx,al
;setup interrupt vector table
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
      RET
INIT_8259  ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
print_string    proc    near
;print string points by bx
;end if character is 0dh
      mov        dx,lcd_base_address
ps0:  in         al,dx
      and        al,10000000b
      jnz        ps0
ps1:  inc        dx         ;point to data register
      mov        al,CS:[bx]
      cmp        al, 0dh         ;check end of string
      je         end_print
      out        dx,al
      inc        bx
      dec        dx              ;point to instruction register
      jmp   short      ps0
end_print:      ret
print_string    endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Interrupt period=0.01s
;
;variable int_count should be defined in data segment and initialize
;to zero.
;
;Procedure adjust_time should be defined by the user.
;

int_service_0    proc    near
      iret
int_service_0   endp
int_service_1   proc    near
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_CLEAR PROC NEAR	; set fill display area (0,0 - 799,479)
	
	mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 001dfh
	call 	TFT_CMD
	mov		bx,0FFh
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	call 	TFT_CMD
	RET
LCD_CLEAR ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_1 PROC NEAR
	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0000000000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00130d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00199d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop11:
	call 	TFT_FILL
	loop loop11
    pop cx	
	RET
LCD_1 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_2 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0001001000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00200d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00130d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00399d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop22:
	call 	TFT_FILL
	loop loop22
    pop cx	

	RET
LCD_2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_3 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0010010000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00400d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00130d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00599d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop33:
	call 	TFT_FILL
	loop loop33
    pop cx	

	RET
LCD_3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_4 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0011011000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00600d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00130d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00799d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop44:
	call 	TFT_FILL
	loop loop44
    pop cx	

	RET
LCD_4 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_5 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0100100000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00320d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00479d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00199d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop55:
	call 	TFT_FILL
	loop loop55
    pop cx	

	RET
LCD_5 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_6 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0101101000011111b
	call 	TFT_CMD
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00320d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00200d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00479d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00399d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop66:
	call 	TFT_FILL
	loop loop66
    pop cx	

	RET
LCD_6 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_7 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0110110000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00320d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00400d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00479d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00599d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop77:
	call TFT_FILL
	loop loop77
    pop cx	

	RET
LCD_7 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LCD_8 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0111111000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00320d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00600d
	call 	TFT_CMD
	mov		ptft_cmd, 04d			;y end
	mov		ptft_val, 00479d
	call 	TFT_CMD
	mov		ptft_cmd, 03d			;x end
	mov		ptft_val, 00799d
	call 	TFT_CMD
	mov		bx,ptft_color
	mov		ptft_cmd, 02h			;x end
	mov		ptft_val, bx
	push cx
	mov cx,7D00h
	loop88:
	call 	TFT_FILL
	loop loop88
    pop cx	

	RET
LCD_8 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ini_LCD PROC NEAR
   call LCD_1
   call LCD_2
   call LCD_3
   call LCD_4
   call LCD_5
   call LCD_6
   call LCD_7
   call LCD_8
   RET
   
ini_LCD ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s_LCD PROC NEAR
   	mov		ptft_cmd, 05h

	call 	TFT_CMD   

  push cx
  mov cx,speed
  rr:
  push cx
	mov cx,15d
	rr11:
	call delay10
	loop rr11
	pop cx
	loop rr
	pop cx

  
   RET
s_LCD ENDP   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_1 PROC NEAR
	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0000000000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

	 	  mov cx,0480d
      d1:
	  push cx
	  mov cx,800d
	  f1:
	  call TFT_FILL
	  loop f1
	  pop cx
	  loop d1
	RET
iLCD_1 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_2 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0001001000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD
		  mov cx,0480d
      d2:
	  push cx
	  mov cx,800d
	  f2:
	  call TFT_FILL
	  loop f2
	  pop cx
	  loop d2
	 nop
	RET
iLCD_2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_3 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0010010000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000h
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

	 	  mov cx,0480d
      d3:
	  push cx
	  mov cx,800d
	  f3:
	  call TFT_FILL
	  loop f3
	  pop cx
	  loop d3
	RET
iLCD_3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_4 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0011011000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000h
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

	 	  mov cx,0480d
      d44:
	  push cx
	  mov cx,800d
	  f4:
	  call TFT_FILL
	  loop f4
	  pop cx
	  loop d44
	RET
iLCD_4 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_5 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0100100000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 00000h
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

		  mov cx,0480d
      d5:
	  push cx
	  mov cx,800d
	  f5:
	  call TFT_FILL
	  loop f5
	  pop cx
	  loop d5
	RET
iLCD_5 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_6 PROC NEAR	

	mov		ptft_cmd, 05h
	mov		ptft_val, 0101101000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

	 	  mov cx,0480d
      d6:
	  push cx
	  mov cx,800d
	  f6:
	  call TFT_FILL
	  loop f6
	  pop cx
	  loop d6
	RET
iLCD_6 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_7 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0110110000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 000d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

	 	  mov cx,0480d
      d7:
	  push cx
	  mov cx,800d
	  f7:
	  call TFT_FILL
	  loop f7
	  pop cx
	  loop d7
	RET
iLCD_7 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
iLCD_8 PROC NEAR	
	mov		ptft_cmd, 05h
	mov		ptft_val, 0111111000011111b
	call 	TFT_CMD
    mov		ptft_cmd, 00h			;y start
	mov		ptft_val, 000d
	call 	TFT_CMD
	mov		ptft_cmd, 01h			;x start
	mov		ptft_val, 0000d
	call 	TFT_CMD
	mov		ptft_cmd, 03h			;x end
	mov		ptft_val, 0031fh
	call 	TFT_CMD
	mov		ptft_cmd, 04h			;y end
	mov		ptft_val, 001dfh
	call 	TFT_CMD

		  mov cx,0480d
      d8:
	  push cx
	  mov cx,800d
	  f8:
	  call TFT_FILL
	  loop f8
	  pop cx
	  loop d8
	RET
iLCD_8 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note cs4
;
cs4 proc  near
    mov	timer_channel_0_lsb,208d
	mov	timer_channel_0_msb,8d
	call init_8254
	  call delay10
	  ret
cs4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note d4
;
d4 proc  near
mov	timer_channel_0_lsb,85d
	mov	timer_channel_0_msb,8d
	call init_8254
	  call delay10
	    ret
d4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note e4
;
e4 proc  near
mov	timer_channel_0_lsb,107d
	mov	timer_channel_0_msb,7d
	call init_8254
	  call delay10
	    ret
e4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note f4
;
ff4 proc  near
mov	timer_channel_0_lsb,254d
	mov	timer_channel_0_msb,6d
	call init_8254
	  call delay10
	    ret
ff4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note fs4
;
fs4 proc  near
mov	timer_channel_0_lsb,157d
	mov	timer_channel_0_msb,6d
	call init_8254
	  call delay10
	    ret
fs4 endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note b4
;
g4 proc  near
mov	timer_channel_0_lsb,58d
	mov	timer_channel_0_msb,6d
	call init_8254
	  call delay10
	    ret
g4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
gs4 proc  near
mov	timer_channel_0_lsb,226d
	mov	timer_channel_0_msb,5d
	call init_8254
	  call delay10
	    ret
gs4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note a4
;
a4 proc  near
mov	timer_channel_0_lsb,140d
	mov	timer_channel_0_msb,5d
	call init_8254
	  call delay10
	    ret
a4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note b4
;
b4 proc  near
mov	timer_channel_0_lsb,243d
	mov	timer_channel_0_msb,4d
	call init_8254
	  call delay10
	    ret
b4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note b4
;
c5 proc  near
mov	timer_channel_0_lsb,171d
	mov	timer_channel_0_msb,4d
	call init_8254
	  call delay10
	    ret
c5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;note cs5
;
cs5 proc  near
mov	timer_channel_0_lsb,104d
	mov	timer_channel_0_msb,4d
	call init_8254
	  call delay10
	    ret
cs5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen first round
;
sixteen_1 proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
	  push cx
      mov   cx,15d	  
sound_11:   
	  call delay10
      loop  sound_11
	  pop cx
      mov   al,110b
      out   dx,al
      ret
sixteen_1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen second round
;
sixteen_2 proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
	  push cx
      mov   cx,13	  
sound_2:   
      call delay10
      loop  sound_2
	  pop cx
      mov   al,110b
      out   dx,al
      ret
sixteen_2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen thind round
;
sixteen_3 proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
	  push cx
      mov   cx,11	  
sound_3:   
      call delay10
      loop  sound_3
	  pop cx
      mov   al,110b
      out   dx,al
      ret
sixteen_3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen fouth round
;
sixteen_4 proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
	  push cx
      mov   cx,8	  
sound_4:   
      call delay10
      loop  sound_4
	  pop cx
      mov   al,110b
      out   dx,al
      ret
sixteen_4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen fifth round
;
sixteen_5 proc  near
      mov   dx,i8255_base_address+1
      mov   al,111b
      out   dx,al
	  push cx
      mov   cx,5	  
sound_5:   
      call delay10
      loop  sound_5
	  pop cx
      mov   al,110b
      out   dx,al
      ret
sixteen_5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;sixteen
;
sixteen proc near

    cmp cx,4h 
	jz sixteen1
	cmp cx,3h
	jz sixteen2
	cmp cx,2h
	jz sixteen3
	cmp cx,1h
	jz sixteen4
	jmp sixteen5
	
sixteen1:
    call sixteen_1
	jmp finish_sixteen
sixteen2:
    call sixteen_2
	jmp finish_sixteen
sixteen3:
    call sixteen_3
	jmp finish_sixteen
sixteen4:
    call sixteen_4
	jmp finish_sixteen
sixteen5:
	call sixteen_5
	jmp finish_sixteen
finish_sixteen:	
      ret
sixteen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;eight
;
eight proc near

    cmp cx,4h 
	jz eight1
	cmp cx,3h
	jz eight2
	cmp cx,2h
	jz eight3
	cmp cx,1h
	jz eight4
	jmp eight5
	
eight1:
    call sixteen_1
	call sixteen_1
	jmp finish_eight
eight2:
    call sixteen_2
	call sixteen_2
	jmp finish_eight
eight3:
    call sixteen_3
	call sixteen_3
	jmp finish_eight
eight4:
    call sixteen_4
	call sixteen_4
	jmp finish_eight
eight5:
    call sixteen_5
	call sixteen_5
	jmp finish_eight
finish_eight:	
      ret
eight endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;eight_half
;
eight_half proc near
    cmp cx,4h 
	jz eight_half1
	cmp cx,3h
	jz eight_half2
	cmp cx,2h
	jz eight_half3
	cmp cx,1h
	jz eight_half4
	jmp eight_half5
	
eight_half1:
    call sixteen_1
	call sixteen_1
	call sixteen_1
	jmp finish_eight_half
eight_half2:
    call sixteen_2
	call sixteen_2
	call sixteen_2
	jmp finish_eight_half
eight_half3:
    call sixteen_3
	call sixteen_3
	call sixteen_3
	jmp finish_eight_half
eight_half4:
    call sixteen_4
	call sixteen_4
	call sixteen_4
	jmp finish_eight_half
eight_half5:
    call sixteen_5
	call sixteen_5
	call sixteen_5
	jmp finish_eight_half
finish_eight_half:	
      ret
eight_half endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;four
;
four proc near

    cmp cx,4h 
	jz four1
	cmp cx,3h
	jz four2
	cmp cx,2h
	jz four3
	cmp cx,1h
	jz four4
	jmp four5
	
four1:
    call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	jmp finish_four
four2:
    call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	jmp finish_four
four3:
    call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	jmp finish_four
four4:
    call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	jmp finish_four
four5:
    call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	jmp finish_four
finish_four:	
      ret
four endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;four_half
;
four_half proc near

    
    cmp cx,4h 
	jz four_half1
	cmp cx,3h
	jz four_half2
	cmp cx,2h
	jz four_half3
	cmp cx,1h
	jz four_half4
	jmp four_half5
	
four_half1:
    call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	jmp finish_four_half
four_half2:
    call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	jmp finish_four_half
four_half3:
    call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	jmp finish_four_half
four_half4:
    call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	jmp finish_four_half
four_half5:
    call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	jmp finish_four_half
finish_four_half:	
      ret
four_half endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;two
;
two proc near

    
    cmp cx,4h 
	jz two1
	cmp cx,3h
	jz two2
	cmp cx,2h
	jz two3
	cmp cx,1h
	jz two4
	jmp two5
	
two1:
    call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	call sixteen_1
	jmp finish_two
two2:
    call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	call sixteen_2
	jmp finish_two
two3:
    call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	call sixteen_3
	jmp finish_two
two4:
    call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	call sixteen_4
	jmp finish_two
two5:
    call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	call sixteen_5
	jmp finish_two
finish_two:	
      ret
two endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;stop_for_sixteen
;
stop_for_sixteen proc near

    cmp cx,4h 
	jz stop_for_sixteen1
	cmp cx,3h
	jz stop_for_sixteen2
	cmp cx,2h
	jz stop_for_sixteen3
	cmp cx,1h
	jz stop_for_sixteen4
	jmp stop_for_sixteen5
	
stop_for_sixteen1:
    push cx
    mov   cx,19	  
stop_for_sound_1:   
    call  delay10
	      call delay10
	  call delay10
    loop  stop_for_sound_1
	pop cx
	jmp finish_stop_for_sixteen
stop_for_sixteen2:
    push cx
    mov   cx,17	  
stop_for_sound_2:   
    call  delay10
	      call delay10
	  call delay10
    loop  stop_for_sound_2
	pop cx
	jmp finish_stop_for_sixteen
stop_for_sixteen3:
    push cx
    mov   cx,15
stop_for_sound_3:   
    call  delay10
	      call delay10
	  call delay10
    loop  stop_for_sound_3
	pop cx
	jmp finish_stop_for_sixteen
stop_for_sixteen4:
    push cx
    mov   cx,13	  
stop_for_sound_4:   
    call  delay10
	      call delay10
	  call delay10
    loop  stop_for_sound_4
	pop cx
	jmp finish_stop_for_sixteen
stop_for_sixteen5:
    push cx
    mov   cx,10	  
stop_for_sound_5:   
    call  delay10
	      call delay10
	  call delay10
    loop  stop_for_sound_5
	pop cx
	jmp finish_stop_for_sixteen
finish_stop_for_sixteen:	
      ret
stop_for_sixteen endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;stop_for_eight
;
stop_for_eight proc near
    call stop_for_sixteen
	call stop_for_sixteen
	
	ret
stop_for_eight endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;stop_for_four
;
stop_for_four proc near
    call stop_for_eight
	call stop_for_eight
	
	ret
stop_for_four endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score0 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,60d
	jb x0
	ret
	x0:
	cmp al,5d
	ja y0
	ret
	y0:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,235d
	jb yy0
	ret
	yy0:
	cmp al,160d
	ja count0
	ret
	count0:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score0 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score1 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,125d
	jb x1
	ret
	x1:
	cmp al,60d
	ja y1
	ret
	y1:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,235d
	jb yy1
	ret
	yy1:
	cmp al,160d
	ja count1
	ret
	count1:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score2 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,185d
	jb x2
	ret
	x2:
	cmp al,125d
	ja y2
	ret
	y2:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,235d
	jb yy2
	ret
	yy2:
	cmp al,160d
	ja count2
	ret
	count2:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score3 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,240d
	jb x3
	ret
	x3:
	cmp al,185d
	ja y3
	ret
	y3:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,235d
	jb yy3
	ret
	yy3:
	cmp al,160d
	ja count3
	ret
	count3:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score4 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,60d
	jb x4
	ret
	x4:
	cmp al,5d
	ja y4
	ret
	y4:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,80d
	jb yy4
	ret
	yy4:
	cmp al,10d
	ja count4
	ret
	count4:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score4 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score5 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,125d
	jb x5
	ret
	x5:
	cmp al,60d
	ja y5
	ret
	y5:
	mov dx,touch_base_address+3  ;y
	in al,dx
	cmp al,80d
	jb yy5
	ret
	yy5:
	cmp al,10d
	ja count5
	ret
	count5:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score6 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,185d
	jb x6
	ret
	x6:
	cmp al,125d
	ja y6
	ret
	y6:
	mov dx,touch_base_address+3  ;y
	in al,dx
    cmp al,80d
	jb yy6
	ret
	yy6:
	cmp al,10d
	ja count6
	ret
	count6:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score6 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
score7 proc near
    mov dx,touch_base_address+1  ;x
	in al,dx
	cmp al,240d
	jb x7
	ret
	x7:
	cmp al,185d
	ja y7
	ret
	y7:
	mov dx,touch_base_address+3  ;y
	in al,dx
    cmp al,80d
	jb yy7
	ret
	yy7:
	cmp al,10d
	ja count7
	ret
	count7:
	push ax
	mov ax,score
	add ax,1d
	mov score,ax
	pop ax
	ret
score7 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cal_score proc near
mov    	dx,lcd_base_address
busy17: 	in     	al,dx
	and    	al,10000000b
	jnz    	busy17
	mov    	al,00000001b    ;clear screen
	out    	dx,al
score01: 
cmp score,1 
 jne score02 
 mov bx,offset output_string1 
 call print_string
 ret 
score02: 
cmp score,2 
 jne score03 
 mov bx,offset output_string2 
 call print_string
 ret 
score03: 
cmp score,3 
 jne score04 
 mov bx,offset output_string3 
 call print_string
 ret 
score04: 
cmp score,4 
 jne score05 
 mov bx,offset output_string4 
 call print_string
 ret 
score05: 
cmp score,5 
 jne score06 
 mov bx,offset output_string5 
 call print_string
 ret 
score06: 
cmp score,6 
 jne score07 
 mov bx,offset output_string6 
 call print_string
 ret 
score07: 
cmp score,7 
 jne score08 
 mov bx,offset output_string7 
 call print_string
 ret 
score08: 
cmp score,8 
 jne score9 
 mov bx,offset output_string8 
 call print_string
 ret 
score9: 
cmp score,9 
 jne score10 
 mov bx,offset output_string9 
 call print_string
 ret 
score10: 
cmp score,10 
 jne score11 
 mov bx,offset output_string10 
 call print_string
 ret 
score11: 
cmp score,11 
 jne score12 
 mov bx,offset output_string11 
 call print_string
 ret 
score12: 
cmp score,12 
 jne score13 
 mov bx,offset output_string12 
 call print_string
 ret 
score13: 
cmp score,13 
 jne score14 
 mov bx,offset output_string13 
 call print_string
 ret 
score14: 
cmp score,14 
 jne score15 
 mov bx,offset output_string14 
 call print_string
 ret 
score15: 
cmp score,15 
 jne score16 
 mov bx,offset output_string15 
 call print_string
 ret 
score16: 
cmp score,16 
 jne score17 
 mov bx,offset output_string16 
 call print_string
 ret 
score17: 
cmp score,17 
 jne score18 
 mov bx,offset output_string17 
 call print_string
 ret 
score18: 
cmp score,18 
 jne score19 
 mov bx,offset output_string18 
 call print_string
 ret 
score19: 
cmp score,19 
 jne score20 
 mov bx,offset output_string19 
 call print_string
 ret 
score20: 
cmp score,20 
 jne score21 
 mov bx,offset output_string20 
 call print_string
 ret 
score21: 
cmp score,21 
 jne score22 
 mov bx,offset output_string21 
 call print_string
 ret 
score22: 
cmp score,22 
 jne score23 
 mov bx,offset output_string22 
 call print_string
 ret 
score23: 
cmp score,23 
 jne score24 
 mov bx,offset output_string23 
 call print_string
 ret 
score24: 
cmp score,24 
 jne score25 
 mov bx,offset output_string24 
 call print_string
 ret 
score25: 
cmp score,25 
 jne score26 
 mov bx,offset output_string25 
 call print_string
 ret 
score26: 
cmp score,26 
 jne score27 
 mov bx,offset output_string26 
 call print_string
 ret 
score27: 
cmp score,27 
 jne score28 
 mov bx,offset output_string27 
 call print_string
 ret 
score28: 
cmp score,28 
 jne score29 
 mov bx,offset output_string28 
 call print_string
 ret 
score29: 
cmp score,29 
 jne score30 
 mov bx,offset output_string29 
 call print_string
 ret 
score30: 
cmp score,30 
 jne score31 
 mov bx,offset output_string30 
 call print_string
 ret 
score31: 
cmp score,31 
 jne score32 
 mov bx,offset output_string31 
 call print_string
 ret 
score32: 
cmp score,32 
 jne score33 
 mov bx,offset output_string32 
 call print_string
 ret 
score33: 
cmp score,33 
 jne score34 
 mov bx,offset output_string33 
 call print_string
 ret 
score34: 
cmp score,34 
 jne score35 
 mov bx,offset output_string34 
 call print_string
 ret 
score35: 
cmp score,35 
 jne score36 
 mov bx,offset output_string35 
 call print_string
 ret 
score36: 
cmp score,36 
 jne score37 
 mov bx,offset output_string36 
 call print_string
 ret 
score37: 
cmp score,37 
 jne score38 
 mov bx,offset output_string37 
 call print_string
 ret 
score38: 
cmp score,38 
 jne score39 
 mov bx,offset output_string38 
 call print_string
 ret 
score39: 
cmp score,39 
 jne score40 
 mov bx,offset output_string39 
 call print_string
 ret 
score40: 
cmp score,40 
 jne score41 
 mov bx,offset output_string40 
 call print_string
 ret 
score41: 
cmp score,41 
 jne score42 
 mov bx,offset output_string41 
 call print_string
 ret 
score42: 
cmp score,42 
 jne score43 
 mov bx,offset output_string42 
 call print_string
 ret 
score43: 
cmp score,43 
 jne score44 
 mov bx,offset output_string43 
 call print_string
 ret 
score44: 
cmp score,44 
 jne score45 
 mov bx,offset output_string44 
 call print_string
 ret 
score45: 
cmp score,45 
 jne score46 
 mov bx,offset output_string45 
 call print_string
 ret 
score46: 
cmp score,46 
 jne score47 
 mov bx,offset output_string46 
 call print_string
 ret 
score47: 
cmp score,47 
 jne score48 
 mov bx,offset output_string47 
 call print_string
 ret 
score48: 
cmp score,48 
 jne score49 
 mov bx,offset output_string48 
 call print_string
 ret 
score49: 
cmp score,49 
 jne score50 
 mov bx,offset output_string49 
 call print_string
 ret 
score50: 
cmp score,50 
 jne score51 
 mov bx,offset output_string50 
 call print_string
 ret 
score51: 
cmp score,51 
 jne score52 
 mov bx,offset output_string51 
 call print_string
 ret 
score52: 
cmp score,52 
 jne score53 
 mov bx,offset output_string52 
 call print_string
 ret 
score53: 
cmp score,53 
 jne score54 
 mov bx,offset output_string53 
 call print_string
 ret 
score54: 
cmp score,54 
 jne score55 
 mov bx,offset output_string54 
 call print_string
 ret 
score55: 
cmp score,55 
 jne score56 
 mov bx,offset output_string55 
 call print_string
 ret 
score56: 
cmp score,56 
 jne score57 
 mov bx,offset output_string56 
 call print_string
 ret 
score57: 
cmp score,57 
 jne score58 
 mov bx,offset output_string57 
 call print_string
 ret 
score58: 
cmp score,58 
 jne score59 
 mov bx,offset output_string58 
 call print_string
 ret 
score59: 
cmp score,59 
 jne score60 
 mov bx,offset output_string59 
 call print_string
 ret 
score60: 
cmp score,60 
 jne score61 
 mov bx,offset output_string60 
 call print_string
 ret 
score61: 
cmp score,61 
 jne score62 
 mov bx,offset output_string61 
 call print_string
 ret 
score62: 
cmp score,62 
 jne score63 
 mov bx,offset output_string62 
 call print_string
 ret 
score63: 
cmp score,63 
 jne score64 
 mov bx,offset output_string63 
 call print_string
 ret 
score64: 
cmp score,64 
 jne score65 
 mov bx,offset output_string64 
 call print_string
 ret 
score65: 
cmp score,65 
 jne score66 
 mov bx,offset output_string65 
 call print_string
 ret 
score66: 
cmp score,66 
 jne score67 
 mov bx,offset output_string66 
 call print_string
 ret 
score67: 
cmp score,67 
 jne score68 
 mov bx,offset output_string67 
 call print_string
 ret 
score68: 
cmp score,68 
 jne score69 
 mov bx,offset output_string68 
 call print_string
 ret 
score69: 
cmp score,69 
 jne score70 
 mov bx,offset output_string69 
 call print_string
 ret 
score70: 
cmp score,70 
 jne score71 
 mov bx,offset output_string70 
 call print_string
 ret 
score71: 
cmp score,71 
 jne score72 
 mov bx,offset output_string71 
 call print_string
 ret 
score72: 
cmp score,72 
 jne score73 
 mov bx,offset output_string72 
 call print_string
 ret 
score73: 
cmp score,73 
 jne score74 
 mov bx,offset output_string73 
 call print_string
 ret 
score74: 
cmp score,74 
 jne score75 
 mov bx,offset output_string74 
 call print_string
 ret 
score75: 
cmp score,75 
 jne score76 
 mov bx,offset output_string75 
 call print_string
 ret 
score76: 
cmp score,76 
 jne score77 
 mov bx,offset output_string76 
 call print_string
 ret 
score77: 
cmp score,77 
 jne score78 
 mov bx,offset output_string77 
 call print_string
 ret 
score78: 
cmp score,78 
 jne score79 
 mov bx,offset output_string78 
 call print_string
 ret 
score79: 
cmp score,79 
 jne score80 
 mov bx,offset output_string79 
 call print_string
 ret 
score80: 
cmp score,80 
 jne score81 
 mov bx,offset output_string80 
 call print_string
 ret 
score81: 
cmp score,81 
 jne score82 
 mov bx,offset output_string81 
 call print_string
 ret 
score82: 
cmp score,82 
 jne score83 
 mov bx,offset output_string82 
 call print_string
 ret 
score83: 
cmp score,83 
 jne score84 
 mov bx,offset output_string83 
 call print_string
 ret 
score84: 
cmp score,84 
 jne score85 
 mov bx,offset output_string84 
 call print_string
 ret 
score85: 
cmp score,85 
 jne score86 
 mov bx,offset output_string85 
 call print_string
 ret 
score86: 
cmp score,86 
 jne score87 
 mov bx,offset output_string86 
 call print_string
 ret 
score87: 
cmp score,87 
 jne score88 
 mov bx,offset output_string87 
 call print_string
 ret 
score88: 
cmp score,88 
 jne score89 
 mov bx,offset output_string88 
 call print_string
 ret 
score89: 
cmp score,89 
 jne score90 
 mov bx,offset output_string89 
 call print_string
 ret 
score90: 
cmp score,90 
 jne score91 
 mov bx,offset output_string90 
 call print_string
 ret 
score91: 
cmp score,91 
 jne score92 
 mov bx,offset output_string91 
 call print_string
 ret 
score92: 
cmp score,92 
 jne score93 
 mov bx,offset output_string92 
 call print_string
 ret 
score93: 
cmp score,93 
 jne score94 
 mov bx,offset output_string93 
 call print_string
 ret 
score94: 
cmp score,94 
 jne score95 
 mov bx,offset output_string94 
 call print_string
 ret 
score95: 
cmp score,95 
 jne score96 
 mov bx,offset output_string95 
 call print_string
 ret 
score96: 
cmp score,96 
 jne score97 
 mov bx,offset output_string96 
 call print_string
 ret 
score97: 
cmp score,97 
 jne score98 
 mov bx,offset output_string97 
 call print_string
 ret 
score98: 
cmp score,98 
 jne score99 
 mov bx,offset output_string98 
 call print_string
 ret 
score99: 
cmp score,99 
 jne score100 
 mov bx,offset output_string99 
 call print_string
 ret 
score100: 
cmp score,100 
 jne score00
 mov bx,offset output_string100 
 call print_string
 ret 
score00:
 mov bx,offset output_string00 
 call print_string
ret
cal_score endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Setup the Reset Vector
	org	07ff0h
	jmp	dumst

	code_seg ends

		end	start