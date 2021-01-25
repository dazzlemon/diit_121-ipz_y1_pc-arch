sseg	segment	stack 'stack'
	db	128 dup(?)
sseg	ends
;--------------------------------------------------------------------------------------------------
dseg	segment	'data'
x 	db 1
y 	db 1
msg_t	db "True, point belongs to IIIrd or IVth Quadrant", 0Dh, 0Ah, '$'
msg_f	db "False, point doesn't belong to IIIrd or IVth Quadrant", 0Dh, 0Ah, '$'
dseg	ends	
;--------------------------------------------------------------------------------------------------
cseg	segment	'code'
	assume  cs:cseg, ds:dseg, ss:sseg

	start:	mov ax, dseg
		mov ds, ax
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if_xz_yz:	test x
				jz out_f
				test y
				jz out_f; testing x and y for =0

		if_yn:		cmp y, 0
				jg out_f; testing y for <0
				
		out_t:		lea dx, msg_t
				mov ah, 09h
				int 21h
				jmp end
		
		out_f:		lea dx, msg_f
				mov ah, 09h
				int 21h
		end:
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
		mov ah, 4Ch
		int 21h
cseg	ends
	end	start