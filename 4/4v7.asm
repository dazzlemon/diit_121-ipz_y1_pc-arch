sseg	segment	stack 'stack'
	db	128 dup(?)
sseg	ends
;--------------------------------------------------------------------------------------------------
dseg	segment	'data'
msg_neg		db "-", '$'
msg_xy		db "(x;y) coordinats for the point are:", 0Dh, 0Ah, '$'
msg_x		db "x=", '$'
msg_y		db "y=", '$'
msg_endl 	db 0Dh, 0Ah, '$'
x 		db -1
y 		db -1
msg_t		db "True, point belongs to IIIrd or IVth Quadrant", 0Dh, 0Ah, '$'
msg_f		db "False, point doesn't belong to IIIrd or IVth Quadrant", 0Dh, 0Ah, '$'
dseg	ends	
;--------------------------------------------------------------------------------------------------
cseg	segment	'code'
	assume  cs:cseg, ds:dseg, ss:sseg

	start:	mov ax, dseg
		mov ds, ax
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		out_xy:		lea dx, msg_xy
				mov ah, 09h
				int 21h
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		out_x_msg:	lea dx, msg_x
				mov ah, 09h
				int 21h

		process_x:	cmp x, 0
				jge out_x_pos
				neg x;making -x +x to output it with ascii
				jmp out_x_neg

		out_x_pos:	mov dl, x
				add dl, 30h
				mov ah, 02h
				int 21h
					
				lea dx, msg_endl
				mov ah, 09h
				int 21h
				jmp out_y_msg

		out_x_neg:	lea dx, msg_neg
				mov ah, 09h
				int 21h

				mov dl, x
				add dl, 30h
				mov ah, 02h
				int 21h
					
				lea dx, msg_endl
				mov ah, 09h
				int 21h

				neg x;making +x back -x, for future processing
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		out_y_msg:	lea dx, msg_y
				mov ah, 09h
				int 21h

		process_y:	cmp y, 0
				jge out_y_pos
				neg y;making -y +y to output it with ascii
				jmp out_y_neg

		out_y_pos:	mov dl, y
				add dl, 30h
				mov ah, 02h
				int 21h
					
				lea dx, msg_endl
				mov ah, 09h
				int 21h
				jmp if_xz_yz

		out_y_neg:	lea dx, msg_neg
				mov ah, 09h
				int 21h

				mov dl, y
				add dl, 30h
				mov ah, 02h
				int 21h
					
				lea dx, msg_endl
				mov ah, 09h
				int 21h

				neg y;making +y back -y, for future processing
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if_xz_yz:	cmp x, 0
				je out_f
				cmp y,0
				je out_f; testing x and y for =0

		if_yn:		cmp y, 0
				jg out_f; testing y for <0
				
		out_t:		lea dx, msg_t
				mov ah, 09h
				int 21h
				jmp end_
		
		out_f:		lea dx, msg_f
				mov ah, 09h
				int 21h
		end_:
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
		mov ah, 4Ch
		int 21h
cseg	ends
	end	start