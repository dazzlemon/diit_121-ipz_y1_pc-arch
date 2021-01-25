;NAME CODE OPERAND

;сегмент стека
sseg	segment	stack	'stack'	
	db		128 dup(?)
sseg	ends

; DATA WRITING TO SEGMENT
dseg	segment	'data'	

; текст

text db "Don't bite off more than you can chew.";38bytes(0-37)

numbers dd -193758;0 offset
        db 222;4 bytes offset
        dw 45005;5 bytes offset

ef_ad dd ?;physical address components of 222 in numbers*
A dd ?;new number1
B dw ?;new number3
C dw ?;new number3v2

dseg	ends ;DATA WRITING END

;CODE SEGMENT
cseg	segment	'code'		
assume	cs:cseg, ds:dseg, ss:sseg

;мітка початку програми з ім’ям start 
start:	mov	ax, dseg
	mov	ds, ax

;body
push word ptr [text+17];"re" to stack
push word ptr [text+15];"mo" to stack
push word ptr [text+22];"an" to stack
push word ptr [text+20];"th" to stack

pop word ptr [text+15];"th" to A+15
pop word ptr [text+17];"an" to A+17
pop word ptr [text+20];"mo" to A+20
pop word ptr [text+22];"re" to A+22 ~end of task1

lea ax, [numbers+2];/effective address of 222 in numbers/ to ax
mov word ptr [ef_ad], ds
mov word ptr [ef_ad+2], ax

push dword ptr [numbers]
push dword ptr [numbers+2]
pop dword ptr [A]
pop dword ptr [A+2]; end of task 3.1

mov al, byte ptr [numbers+5]
mov ah, byte ptr [numbers+6]
mov byte ptr [B+1], al
mov byte ptr [B], ah; end of task 3.2

mov ax, word ptr [numbers+5]
xchg al, ah
mov C, ax; end of task 3.3

;повернення керування ОС 
	mov	ah, 4Ch
	int	21h
cseg	ends
	end	start	;END