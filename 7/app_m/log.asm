;-----------------------------------------------------------------------------
dseg_logic segment	'data'
	msg_endl			db 0dh, 0ah, '$'
	msg_invite 		db "Input number: ", '$'

	msg_error			db 0dh, 0ah, "Wrong input!", 0dh, 0ah, '$'
	buffer				db 7, ?, 5 dup(?), '$', '$'
dseg_logic	ends

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

public logic

;-----------------------------------------------------------------------------
cseg_logic segment	'code'
	assume  cs:cseg_logic, ds:dseg_common, es:dseg_logic
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;procs
logic PROC far
		push es
		mov ax, dseg_logic
		mov es, ax

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


		xor bx, bx
		xor si, si
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

	carry_interrupt:;make flag register
		pop ax
		mov es, ax
		RET
logic ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;2d_array_inp++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;in:
;bx = *Array
;di = *buffer**********************
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

	mov ax, bx;ax = *Array in ds
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
			;lea dx, buffer;;;;;;;;;;;;;;;;;;;;;;;;;;;

			call num_input_word;ax = input
			mov word ptr ds:[bx][si], ax;Array[i][j] = input

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
;2d_array_processing++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;in:
;bx = pointer to array
;N = dl
;M = dh
;di - *msg_endl

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
				mov ax, ds:[bx][si];array[i][j]
				call num_print_word;prints array[i][j]

				mov dl, ' '
				mov ah, 02h
				int 21h
			pop dx

			add si, 2;j++(2bytes)
		loop loop_j

		pop cx;restore outer clock after inner clock fadeout

		mov dl, 0dh
		mov ah, 02h
		int 21h
		mov dl, 0ah
		int 21h;endl

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
		add dl, '0';ascii
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
;*buffer  = dx; in ds
;*msg_invite = ;in es
;*msg_error = di;in es

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
				push bx
					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds

					;mov dl, 0dh
					;mov ah, 02h
					;int 21h
					;mov dl, 0ah
					;int 21h;endl

					lea dx, msg_invite;;;;;;;;;;;;
					mov ah, 09h
					int 21h;prints message

					push es
					push ds
					pop bx
					mov es, bx
					pop bx
					mov ds, bx;xchg es, ds
				pop bx
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

push ax
	mov dl, 0dh
	mov ah, 02h
	int 21h
	mov dl, 0ah
	int 21h;endl
pop ax

pop di
pop si
pop dx
pop cx
pop bx;restoring

RET
num_input_word ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cseg_logic	ends
	end
