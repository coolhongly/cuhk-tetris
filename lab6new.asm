 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Experiment 6 ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lcd_base_address 	equ 0c0h
i8259_base_address 	equ 0b0h
i8254_base_address 	equ 0a0h
i8255_base_address 	equ 090h
;
stack_seg segment at 0
top_of_stack equ 800h
stack_seg ends
;
data_seg segment at 0
data_seg ends
;
;dummy code segment
dummy_code segment at 0f800h
org 0
dumst label far ;CS:IP for this label will be
;assigned by the linker
dummy_code ends
;
;the start of Code Segment
;f8000-fffff for program
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
call INIT_8255
call INIT_8254
call INIT_LCD

loop1:

loop2:
call check_key  ;When SW1 is pressed
jnc loop2
call sound_one_second  ;The buzzer would sound

;To print out the name in the first line
mov        dx,lcd_base_address
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

;To print out the student ID in the second line
mov        dx,lcd_base_address
busy4:  in        al,dx
and        al,10000000b
jnz        busy4

;Since the address on the beginning of the second line is 40h
;so we add 10000000b(80h) with 1000000b(40h)=11000000b and put this into al
mov       al,11000000b    ;set display address to 1
out        dx,al
mov        bx, offset output_string2  ;To put the string to be printed out in BX
call        print_string  ;To print our the string

loop3:
call check_key  ;When SW1 is pressed again
jnc loop3
call sound_one_second  ;The buzzer would sound

mov        dx,lcd_base_address
busy5:  in       al,dx
and       al,10000000b
jnz       busy5

mov al, 00000001b   ;clc
out dx, al

mov       al,10000000b    ;set display address to 0
out        dx,al
mov       bx, offset output_string3  ;To put the string to be printed out in BX
call        print_string  ;To print our the string

mov        dx,lcd_base_address
busy6:  in       al,dx
and        al,10000000b
jnz        busy6
mov        al,11000000b    ;set display address to 1
out        dx,al
mov        bx, offset output_string4  ;To put the string to be printed out in BX
call       print_string  ;To print our the string

jmp loop1  ;Jump back to loop1

loopend:
nop
jmp loopend
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
timer_channel_0_msb     equ     4
timer_channel_0_lsb     equ     226
;i8254_base EQU   0B0H
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;initialize LCD
;lcd_base         EQU   0f0H
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
ret
INIT_LCD   ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_string    proc    near
;print string points by bx
;end if character is 0dh
mov        dx,lcd_base_address
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
output_string1 db 'Wu Yang',0dh
output_string2 db '1155001980',0dh
output_string3 db 'Yin Hongli',0dh
output_string4 db '1155002112',0dh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

delay10    proc  near
push  cx
mov   cx,790h    ;old value 3ffh
delay_1:   nop
nop
loop  delay_1
pop   cx
ret
delay10    endp
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Setup the Reset Vector
org 07ff0h
jmp dumst
code_seg ends
end start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	 
