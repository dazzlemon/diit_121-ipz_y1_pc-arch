;-----------------------------------------------------------------------------
dseg_interface segment	'data'
	buffer				db 7, ?, 5 dup(?), '$', '$'
	msg_endl			db 0dh, 0ah, '$'
	msg_invite 		db "Input number: ", '$'

	msg_error			db "Wrong input!", 0dh, 0ah, '$'

	msg_invN			db "Input N: ", '$'
	msg_invM			db "Input M: ", '$'

	msg_interrupt	db "Application interrupted because of result overflow!", 0dh, 0ah, '$'

	msg_result		db 0dh, 0ah, "Resulting array:", 0dh, 0ah, '$'

	msg_r1				db "A[", '$'
	msg_r2				db "]= ", '$'
dseg_interface ends

dseg_common segment para common 'data'
	N							db 0;amount of rows [1;5]
	M							db 0;amount of columns [1;5]

	Nr						db ?
	Mr						db ?;for proper comparing

	newArray			dw 5 dup(1);array with elements according to each row of 'Array',
	;each element is multiple of elements that are bigger
	;than their neighbours(virtical and horizontal)

	Array					dw 5 dup(?);row1
								dw 5 dup(?);row2
								dw 5 dup(?);row3
								dw 5 dup(?);row4
								dw 5 dup(?);row5
dseg_common ends

;public procs
public interface

extrn logic: 		far
;-----------------------------------------------------------------------------
cseg_interface segment	'code'
	assume  cs:cseg_interface, ds:dseg_interface, ss:sseg_interface, es:dseg_common
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;procs
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
interface PROC far

		;in:
		;*Array,*newArray, N, M
		;ax = *Array
		;*newArray = *(Array + 50)

		;out:
		;N, M
		;cl = N
		;ch = M

		push ax

		mov ax, dseg_interface
		mov es, ax

		jmp inp_N
		ErrorN:
		lea dx, es:msg_error
		mov ah, 09h
		int 21h

		inp_N:
		lea dx, msg_invN
		mov ah, 09h
		int 21h;invite

		mov ah, 01h
		int 21h;al = symbol Input

		push ax;09h puts '$' to al
		lea dx, msg_endl
		mov ah, 09h
		int 21h;endl
		pop ax;restore

		cmp al, '3'
		jb ErrorN;if <3
			cmp al, '5'
			ja ErrorN;if >5

		sub al, '0';symbol to digit

		mov cl, al;storing N = cl

		;dec al
		;mov bl, 10
		;mul bl;al = n*10
		;mov Nr, al

		jmp inp_M
		ErrorM:
		lea dx, msg_error
		mov ah, 09h
		int 21h

		inp_M:
		lea dx, msg_invM
		mov ah, 09h
		int 21h;invite

		mov ah, 01h
		int 21h;al = symbol Input

		push ax;09h puts '$' to al
		lea dx, msg_endl
		mov ah, 09h
		int 21h;endl
		pop ax;restore

		cmp al, '3'
		jb ErrorM;if <3
			cmp al, '5'
			ja ErrorM;if >5

		sub al, '0';symbol to digit

		mov ch, al;storing M = ch

		;dec al
		;mov bl, 2
		;mul bl;al = M*2
		;mov Mr, al

		mov dl, cl
		add dl, '0';digit to symbol
		mov ah, 02h;prints N
		int 21h

		mov dl, 'x'
		int 21h;prints 'x'

		mov dl, ch
		add dl, '0';digit to symbol
		int 21h;prints M

		lea dx, msg_endl
		mov ah, 09h
		int 21h;endl

		pop ax
;-----------------------------------------------------------------------------
		call logic

		jmp print_1d
		carry_interrupt:
			lea dx, msg_interrupt
			mov ah, 09h
			int 21h

			jmp final


		print_1d:

			push ax
			lea dx, msg_result
			mov ah, 09h
			int 21h
			pop ax

			mov bx, cx;bh = M, bl = N
			xor ch, ch
			mov cl, bh
			mov di, bx;M*16+N
			xor si, si;i from 0 to M
			mov bx, ax
			add bx, 50

			push ax
			print_1d_loop:

				push ax
				lea dx, msg_r1
				mov ah, 09h
				int 21h

				push bx
				mov ax, si
				mov bl, 2
				div bl;2i/2 = i = al
				mov dl, al
				add dl, '1';digit+1 to symbol
				mov ah, 02h
				int 21h;prints i
				pop bx

				lea dx, msg_r2
				mov ah, 09h
				int 21h

				mov ax, [bx][si]
				call num_print_word

				lea dx, msg_endl
				mov ah, 09h
				int 21h;endl

				add si, 2;i++
			loop print_1d_loop
			pop ax
		final:
RET
interface ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;word_print_proc++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;prints signed number from ax
;uses ax, bx, cx, dx

;in: ax - number

;out: -

num_print_word PROC near

push ax
push bx
push cx
push dx;storing

	mov cx, 5;max 5 digits in 2byte number
	mov bx, 10;for dividing

	cmp ax, 0
	jge additive_stack
		push ax;int 21h, ah = 02h, returns last printed char to al

		mov dl, '-'
		mov ah, 02h
		int 21h;prints '-'

		pop ax

		neg ax
	additive_stack:
		xor dx, dx;dx:ax = ax
		div bx;ax = dx:ax/10, dx = dx:ax % 10
		push dx;storing dx with first digit from right

	loop additive_stack

	mov cx, 5

	print:

		pop dx;dl= symbol to print
		add dl, 30h;ascii
		mov ah, 02h
		int 21h;prints i-th digit from left

	loop print

pop dx
pop cx
pop bx
pop ax;restoring

	RET
num_print_word ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;num_input_word+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;inputs symbolic to buffer
;and transforms it into
;2byte signed numeric value in ax

;si - adress of buffer(9 bytes)
;1st - max size(7 to check if input is correct [-32768;32767] c Z)
;2nd - actual size(if length = 7, input.fail)
;3rd - + or - sign, or digit
;4th-7th - actual digits left to rigt
;8th, 9th - '$', if after inputs its not $entinel, input.fail

;uses:
;si, ax, bx, cx, dx
;si - pointer to string(later to Nth digit)
;ax - number
;bx -
;cx - counter

;in:
;*buffer  = dx
;*msg_endl = *(buffer) + 9
;*msg_invite = *(msg_endl) + 3 = *(buffer) + 12
;*msg_error = di

;out:
;ax = number

num_input_word PROC near
	push bx
	push cx
	push dx
	push si
	push di;storing

	xor ch, ch;cx = cl
	xor bh, bh;bx = bl

	jmp input
	error_inw:
	push dx
		mov dx, di
		mov ah, 09h
		int 21h;error
	pop dx

	input:
		mov si, dx;si points to buffer

		push dx;store
			add dx, 09h
			mov ah, 09h
			;int 21h;std::endl

			add dx, 03h
			int 21h;prints message
		pop dx;restore
		mov ah, 0ah
		int 21h;input string to buffer

		xor ax, ax;number = 0
		mov cl, [si + 1];i = actual length of buffer
		add si, 2;si = pointer to first actual element of string

		cmp byte ptr [si], '-';checking if first element is SIGN(-)
		jne number_assembly
			inc si;first actual element of element after '-'
			dec cx;one iteration less
		number_assembly:

			mov bl, [si];just for checking

			cmp bl, '0'
			jb error_inw
				cmp bl, '9'
				ja error_inw
					sub bl, '0';making digit from symbol

					push dx;store
					push di
					mov di, 10
					mul di;moving current state of number to left to add new digit
					pop di
					pop dx;restore

					jc error_inw;if larger than 2 bytes
						add ax, bx
						jc error_inw
							inc si;next digit
		loop number_assembly

		cmp ax, 32768
		ja error_inw
			mov bx, dx
			add bx, 2
			cmp byte ptr [bx], '-'
			jne pos_
				neg ax;n *= -1;
				jmp end_
			pos_:
				cmp ax, 32767
				ja error_inw
				end_:

push dx
push ax
	add dx, 9
	mov ah, 09h
	int 21h;endl
pop ax
pop dx

pop di
pop si
pop dx
pop cx
pop bx;restoring

RET
num_input_word ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cseg_interface	ends
	end
