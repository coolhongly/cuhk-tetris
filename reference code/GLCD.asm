;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Test Program for Experiment 7 ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Group No.	LCD	8259	8254    8255-1  8255-2
;		(pin17) (pin18) (pin19) (pin20) (pin16)
;		 0cxh	 0dxh    0exh    0fxh    1xh
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

lcd_base_address   equ 0c0h ;modify this value
i8259_base_address equ 0b0h ;modify this value
i8254_base_address equ 0a0h ;modify this value
i8255_base_address equ 090h ;modify this value
lcd_base_address1  equ 0c2h  ;modify the address
lcd_base_address2  equ 0c4h  ;to fit your own one

stack_seg	segment	at 0
top_of_stack	equ	800h
stack_seg	ends

data_seg	segment at 0
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
loop1:	mov	ax,i8254_base_address
	mov	bx,i8255_base_address
	mov	cx,i8259_base_address
	mov	dx,lcd_base_address
	call	exp7_test	;to test subroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; For Graphical LCD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov   dx, lcd_base_address1
busy1:           in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   busy1      
           mov   al,00111111b          ; turn display1 ON
           out   dx,al      
           mov   dx,lcd_base_address2  
busy2:           in    al,dx
           and   al,10000000b
           jnz   busy2            ;check bysy flag 2
           mov   al,00111111b          ; turn display2 ON
           out   dx,al
;
;clear the display
;
           mov   dx, lcd_base_address1
busy3:           in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   busy3
           mov   al,01000000b          ;set Y address to display1
           out   dx,al      
           mov   dx, lcd_base_address2
busy4:           in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   busy4
           mov   al,01000000b          ;set Y address to display2
           out   dx,al
           mov   dx, lcd_base_address1
busy5:           in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   busy5
           mov   al,10111000b          ;set X address to display1
           mov   ah,al
           out   dx,al      
           mov   dx, lcd_base_address2
busy6:           in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   busy6
           mov   al,ah            ;set X address to display2
           out   dx,al 
           mov   dx, lcd_base_address1
busy7:           in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   busy7
           mov   al,11000000b          ;set start line address1 at 0c0h
           out   dx,al      
           mov   dx, lcd_base_address2
busy8:           in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   busy8
           mov   al,11000000b          ;set start line address2 at 0c0h
           out   dx,al 
;send zero to display RAM
cl_1:      mov   cx,64
cl0:       mov   dx,lcd_base_address1
cl1:       in    al,dx
           and   al,10000000b
           jnz   cl1
           mov   al,0
           inc   dx               ;point to display RAM1
           out   dx,al
           mov   dx,lcd_base_address2
cl2:       in    al,dx
           and   al,10000000b
           jnz   cl2
           mov   al,0
           inc   dx               ;point to display RAM2
           out   dx,al
           loop  cl0
;update X_address
           inc   ah
           cmp   ah,11000000b
           je    end_clear
           mov   dx, lcd_base_address1
cl3:       in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   cl3
           mov   al,ah      ;set X address to display1
           mov   ah,al
           out   dx,al      
           mov   dx, lcd_base_address2
cl4:       in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   cl4
           mov   al,ah            ;set X address to display2
           out   dx,al 
           jmp   cl_1
end_clear: nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;print a 8X8 black square on both sides and 
;scroll up one after the other
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           mov   dx, lcd_base_address1
print1:          in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   print1
           mov   al,01000000b          ;set Y address to display1
           out   dx,al 
print2:          in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   print2
           mov   al,10111000b          ;set X address to display1
           out   dx,al
           mov   cx,8
print3:          in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   print3
           mov   al,11111111b          ;set data
           inc   dx
           out   dx,al
           mov   dx,lcd_base_address1
           loop  print3
           mov   dx, lcd_base_address2
print11:   in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   print11
           mov   al,01000000b          ;set Y address to display2
           out   dx,al 
print12:   in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   print12
           mov   al,10111000b          ;set X address to display2
           out   dx,al
           mov   cx,8
print13:   in    al,dx            ;check busy flag 2
           and   al,10000000b
           jnz   print13
           mov   al,11111111b          ;set data
           inc   dx
           out   dx,al
           mov   dx,lcd_base_address2
           loop  print13
;end_loop: nop
;          jmp end_loop
;
;scroll up
;
re_print:  mov   dx,lcd_base_address1  
           mov   ah,11000000b
print4:          in    al,dx
           and   al,10000000b
           jnz     print4
           mov   al,ah
           out   dx,al            ; set new line address
           call  delay
           inc   ah
           jnz   print4
           mov   dx,lcd_base_address2  
           mov   ah,11000000b
print14:   in    al,dx
           and   al,10000000b
           jnz     print14
           mov   al,ah
           out   dx,al            ; set new line address
           call  delay
           inc   ah
           jnz   print14
           jmp   re_print   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay      proc  near
           push  cx
           push  dx
           push  ax
;
;both LCD should always be set on state

                 mov   dx, lcd_base_address1
busy11:          in    al,dx            ;check busy flag 1
           and   al,10000000b
           jnz   busy11           
           mov   al,00111111b          ; turn display1 ON
           out   dx,al      
           mov   dx,lcd_base_address2  
busy12:          in    al,dx
           and   al,10000000b
           jnz   busy12                ;check bysy flag 2
           mov   al,00111111b          ; turn display2 ON
           out   dx,al
           mov   cx,3fffh
delay1:          nop
           nop
           nop
           nop
           loop  delay1
           pop   ax
           pop   dx
           pop   cx
           ret
delay      endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	jmp	loop1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Setup the Reset Vector
	org	07ff0h
	jmp	dumst

	code_seg ends

		end	start