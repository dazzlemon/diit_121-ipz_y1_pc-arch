;-----------------------------------------------------------------------------
dseg_interface segment	'data'
	msg_endl			db 0dh, 0ah, '$'
	msg_invite 		db "Input number: ", '$'

	msg_error			db "Wrong input!", 0dh, 0ah, '$'

	msg_invN			db "Input N: ", '$'
	msg_invM			db "Input M: ", '$'

	msg_interrupt	db "Application interrupted because of result overflow!", 0dh, 0ah, '$'

	msg_result		db 0dh, 0ah, "Resulting array:", 0dh, 0ah, '$'

	msg_r1				db "A[", '$'
	msg_r2				db "]= ", '$'
dseg_interface	ends

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

public interface

extrn logic: 		far

;-----------------------------------------------------------------------------
cseg_interface	segment	'code'
		assume  cs:cseg_interface, ds:dseg_common, es:dseg_interface
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;procs
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
interface PROC far
		push ds
		mov ax, dseg_interface
		mov es, ax

		mov ax, dseg_common
		mov ds, ax

		jmp inp_N
		ErrorN:
		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			lea dx, msg_error
			mov ah, 09h
			int 21h

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		inp_N:
		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			lea dx, msg_invN
			mov ah, 09h
			int 21h;invite

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		mov ah, 01h
		int 21h;al = symbol Input

		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			push ax;09h puts '$' to al
			lea dx, msg_endl
			mov ah, 09h
			int 21h;endl
			pop ax;restore

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		cmp al, '3'
		jb ErrorN;if <3
			cmp al, '5'
			ja ErrorN;if >5

		sub al, '0';symbol to digit

		mov N, al;storing N
		dec al
		mov bl, 10
		mul bl;al = n*10
		mov Nr, al

		jmp inp_M
		ErrorM:
		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			lea dx, msg_error
			mov ah, 09h
			int 21h

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		inp_M:
		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			lea dx, msg_invM
			mov ah, 09h
			int 21h;invite

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		mov ah, 01h
		int 21h;al = symbol Input

		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			push ax;09h puts '$' to al
			lea dx, msg_endl
			mov ah, 09h
			int 21h;endl
			pop ax;restore

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx

		cmp al, '3'
		jb ErrorM;if <3
			cmp al, '5'
			ja ErrorM;if >5

		sub al, '0';symbol to digit

		mov M, al;storing M
		dec al
		mov bl, 2
		mul bl;al = M*2
		mov Mr, al

		mov dl, N
		add dl, '0';digit to symbol
		mov ah, 02h;prints N
		int 21h

		mov dl, 'x'
		int 21h;prints 'x'

		mov dl, M
		add dl, '0';digit to symbol
		int 21h;prints M

		push bx
			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds

			push ax;09h puts '$' to al
			lea dx, msg_endl
			mov ah, 09h
			int 21h;endl
			pop ax;restore

			push es
			push ds
			pop bx
			mov es, bx
			pop bx
			mov ds, bx;xchg es, ds
		pop bx


		;lea bx, Array
		;mov dl, N
		;mov dh, M
		;lea di, msg_error
		;call inp_2d_ar

		;push dx
			;lea dx, msg_endl
			;mov ah, 09h
			;int 21h
		;pop dx

		;lea di, msg_endl
		;call print_2d_ar
;-----------------------------------------------------------------------------
		call logic

		jmp print_1d
		carry_interrupt:
			lea dx, msg_interrupt
			mov ah, 09h
			int 21h

			jmp final

		print_1d:;someshit happens

			push bx
				push es
				push ds
				pop bx
				mov es, bx
				pop bx
				mov ds, bx;xchg es, ds

			lea dx, msg_result
			mov ah, 09h
			int 21h

				push es
				push ds
				pop bx
				mov es, bx
				pop bx
				mov ds, bx;xchg es, ds
			pop bx

			xor ch, ch
			mov cl, M
			xor si, si;i from 0 to M
			mov bl, 2

			print_1d_loop:

				push bx
					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds

					lea dx, msg_r1
					mov ah, 09h
					int 21h

					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds
				pop bx

				mov ax, si
				div bl;2i/2 = i = al
				mov dl, al
				add dl, '1';digit+1 to symbol
				mov ah, 02h
				int 21h;prints i

				push bx
					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds

					lea dx, msg_r2
					mov ah, 09h
					int 21h

					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds
				pop bx

				mov ax, newArray[si]
				call num_print_word


				push bx
					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds

					lea dx, msg_endl
					mov ah, 09h
					int 21h;endl

					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds
				pop bx

				add si, 2;i++
			loop print_1d_loop

		final:
		pop ax
		mov es, ax
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
cseg_interface	ends
	end
