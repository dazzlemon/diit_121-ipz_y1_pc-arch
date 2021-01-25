;-----------------------------------------------------------------------------
dseg_logic segment	'data'
	msg_endl			db 0dh, 0ah, '$'

	msg_error			db 0dh, 0ah, "Wrong input!", 0dh, 0ah, '$'
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

;public procs
public logic
;-----------------------------------------------------------------------------
cseg_logic segment	'code'
	assume  cs:cseg_logic, ds:dseg_logic, ss:sseg_main, es:dseg_common
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;procs
logic PROC far

		lea bx, ds:Array
		mov dl, ds:N
		mov dh, ds:M
		lea di, es:msg_error
		call inp_2d_ar

		push dx
			lea dx, es:msg_endl
			mov ah, 09h
			int 21h
		pop dx

		lea di, es:msg_endl
		call print_2d_ar


		mov di, ds:newArray
		xor si, si
		mov cl, ds:M;i from 0 to M
		xor ch, ch
		new_loop_row:
			xor si, si;j = 0
			mov ax, 1;current element of 'newArray'

			push cx
			mov cl, ds:N;j from 0 to N
			new_loop_column:

				mov dx, [bx][si];for checking and multiplying

				cmp bl, 0;if left
				je left
					cmp dx, [bx][si - 2];left
					jle break_new_loop_column
				left:

				cmp bl, ds:Mr;if right
				je right
					cmp dx, [bx][si + 2];right
					jle break_new_loop_column
				right:

				cmp si, 0;if up
				je up
					cmp dx, [bx - 10][si];up
					jle break_new_loop_column
				up:

				push ax
				mov al, ds:Nr
				xor ah, ah

				cmp si, ax;if down
				pop ax
				je down
				cmp dx, [bx + 10][si];down
					jle break_new_loop_column
				down:

				imul dx;current_new_element * good_old_element
				jc carry_interrupt;if result > 2bytes

			break_new_loop_column:
				add si, 10;j++
			loop new_loop_column
			pop cx

			mov [di][bx], ax

			add bx, 2;i++
		loop new_loop_row

	carry_interrupt:
RET
logic ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
inp_2d_ar PROC near
	mov ah, 02h
	mov dl, '*'
	int 21h;test
inp_2d_ar ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
print_2d_ar PROC near
	mov ah, 02h
	mov dl, '*'
	int 21h;test
print_2d_ar ENDP
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
cseg_logic	ends
	end
