sseg	segment	stack 'stack'
	db	128 dup(?)
sseg	ends
;-----------------------------------------------------------------------------
dseg	segment	'data'
	Array 				dw 5 dup(?);row1
								dw 5 dup(?);row2
								dw 5 dup(?);row3
								dw 5 dup(?);row4
								dw 5 dup(?);row5

	buffer				db 7, ?, 5 dup(?), '$', '$'
	msg_endl			db 0dh, 0ah, '$'
	msg_invite 		db "Input number: ", '$'

	N							db 'f';amount of rows [1;5]
	M							db 'f';amount of columns [1;5]

	Nr						db ?
	Mr						db ?;for proper comparing



	msg_error			db 0dh, 0ah, "Wrong input!", 0dh, 0ah, '$'

	msg_invN			db "Input N: ", '$'
	msg_invM			db "Input M: ", '$'

	newArray			dw 5 dup(1);array with elements according to each row of 'Array',
;each element is multiple of elements that are bigger
;than their neighbours(virtical and horizontal)

	msg_interrupt	db "Application interrupted because of result overflow!", 0dh, 0ah, '$'

	msg_salute0		db "  This application takes N,M from range [3;5],", 0dh, 0ah, '$'
	msg_salute1		db "  gets input for each element of NxM array in range [-32768;32767],", 0dh, 0ah, '$'
	msg_salute2		db "  and checks each column for elements which are larger", 0dh, 0ah, '$'
	msg_salute3		db "  than their vertical and horizontal neighbours,", 0dh, 0ah, '$'
	msg_salute4		db "  creates Mx1 array elements of which", 0dh, 0ah, '$'
	msg_salute5		db "  are multiples of chosen elements for each column(or (1) if none).", 0dh, 0ah, 0dh, 0ah, '$'

	msg_result		db 0dh, 0ah, "Resulting array:", 0dh, 0ah, '$'

	msg_r1				db "A[", '$'
	msg_r2				db "]= ", '$'
dseg	ends
;-----------------------------------------------------------------------------
cseg	segment	'code'
	assume  cs:cseg, ds:dseg, ss:sseg

	start:	mov ax, dseg
		mov ds, ax
;main+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	lea dx, msg_salute0
	mov ah, 09h
	int 21h

	lea dx, msg_salute1
	int 21h

	lea dx, msg_salute2
	int 21h

	lea dx, msg_salute3
	int 21h

	lea dx, msg_salute4
	int 21h

	lea dx, msg_salute5
	int 21h

	jmp inp_N
	ErrorN:
	lea dx, msg_error
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

	mov N, al;storing N
	dec al
	mov bl, 10
	mul bl;al = n*10
	mov Nr, al

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

	lea dx, msg_endl
	mov ah, 09h
	int 21h;endl


	lea bx, Array
	mov dl, N
	mov dh, M
	lea di, msg_error
	call inp_2d_ar

	push dx
		lea dx, msg_endl
		mov ah, 09h
		int 21h
	pop dx

	lea di, msg_endl
	call print_2d_ar



	xor bx, bx;i = 0
	mov cl, M;i from 0 to M
	xor ch, ch
	new_loop_row:
		xor si, si;j = 0
		mov ax, 1;current element of 'newArray'

		push cx
		mov cl, N;j from 0 to N
		new_loop_column:

			mov dx, Array[bx][si];for checking and multiplying

			cmp bl, 0;if left
			je left
				cmp dx, Array[bx][si - 2];left
				jle break_new_loop_column
			left:

			cmp bl, Mr;if right
			je right
				cmp dx, Array[bx][si + 2];right
				jle break_new_loop_column
			right:

			cmp si, 0;if up
			je up
				cmp dx, Array[bx - 10][si];up
				jle break_new_loop_column
			up:

			push ax
			mov al, Nr
			xor ah, ah

			cmp si, ax;if down
			pop ax
			je down
			cmp dx, Array[bx + 10][si];down
				jle break_new_loop_column
			down:

			imul dx;current_new_element * good_old_element
			jc carry_interrupt;if result > 2bytes

		break_new_loop_column:
			add si, 10;j++
		loop new_loop_column
		pop cx

		mov newArray[bx], ax

		add bx, 2;i++
	loop new_loop_row

	jmp print_1d
	carry_interrupt:
		lea dx, msg_interrupt
		mov ah, 09h
		int 21h

		jmp final


	print_1d:

		lea dx, msg_result
		mov ah, 09h
		int 21h

		xor ch, ch
		mov cl, M
		xor si, si;i from 0 to M
		mov bl, 2

		print_1d_loop:

			lea dx, msg_r1
			mov ah, 09h
			int 21h

			mov ax, si
			div bl;2i/2 = i = al
			mov dl, al
			add dl, '1';digit+1 to symbol
			mov ah, 02h
			int 21h;prints i

			lea dx, msg_r2
			mov ah, 09h
			int 21h

			mov ax, newArray[si]
			call num_print_word

			lea dx, msg_endl
			mov ah, 09h
			int 21h;endl

			add si, 2;i++
		loop print_1d_loop

	final:
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		mov ah, 4Ch
		int 21h
;2d_array_processing++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;in:
;bx = pointer to array
;N = dl
;M = dh

;out: -

;bx = array pointer(later poinet to row)
;si = pointer to column
;di - *msg_endl

;uses ax, bx, cx, dx, si, di

print_2d_ar PROC near

push ax
push bx
push cx
push dx
push si
push di;storing

	mov cl, dl
	xor ch, ch;i = N
	loop_i:
		xor si, si
		push cx;store outer counter to use cx for inner counter

		mov cl, dh
		xor ch, ch;j = M

		loop_j:
			push dx
			mov ax, [bx][si];array[i][j]
			call num_print_word;prints array[i][j]

			mov dl, ' '
			mov ah, 02h
			int 21h
			pop dx

			add si, 2;j++(2bytes)
		loop loop_j

		pop cx;restore outer clock after inner clock fadeout

		push dx
		mov dx, di
		mov ah, 09h
		int 21h
		pop dx

		add bx, 10;i++, 10 = 5(actualsize)*2(bytes)
	loop loop_i

pop di
pop si
pop dx
pop cx
pop bx
pop ax;restoring

RET
print_2d_ar ENDP
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
;2d_array_inp++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;in:
;bx = *Array
;di = *msg_endl
;N = dl
;M = dh

;out: -

;bx = array pointer(later pointer to row)
;si = pointer to column


;uses ax, bx, cx, dx, si, di

inp_2d_ar PROC near

push ax
push bx
push cx
push dx
push si
push di;storing

	mov ax, bx;ax = *Array
	mov cl, dl
	xor ch, ch;i = N
	loop_i1:
		xor si, si
		push cx;store outer counter to use cx for inner counter

		mov cl, dh
		xor ch, ch;j = M

		loop_j1:

			push dx
			push bx
			push ax
				mov dl, '['
				mov ah, 02h
				int 21h

				mov ax, bx
				pop bx;bx = *Array
				push bx;storing *Array
				sub ax, bx
				mov bl, 10
				div bl;al = i

				mov dl, al
				add dl, '1';digit+1 to symbol
				mov ah, 02h
				int 21h

				mov dl, ']'
				int 21h

				mov dl, '['
				int 21h

				mov ax, si
				mov bl, 2
				div bl;al = j

				mov dl, al
				add dl, '1';digit+1 to symbol
				mov ah, 02h
				int 21h

				mov dl, ']'
				int 21h
			pop ax
			pop bx
			push ax

			mov dl, '.'
			mov ah, 02h
			int 21h


			pop dx;dx = *Array
			push dx;storing *Array
			add dx, 50

			call num_input_word;ax = input
			mov word ptr [bx][si], ax;Array[i][j] = input
			pop ax;ax = *Array(restored)
			pop dx

			add si, 2;j++(2bytes)
		loop loop_j1

		pop cx;restore outer clock after inner clock fadeout

		add bx, 10;i++, 10 = 5(actualsize)*2(bytes)
	loop loop_i1

pop di
pop si
pop dx
pop cx
pop bx
pop ax;restoring

RET
inp_2d_ar ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cseg	ends
	end	start
