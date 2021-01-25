sseg	segment	stack 'stack'
	db	128 dup(?)
sseg	ends
;-----------------------------------------------------------------------------
dseg	segment	'data'
text_ar						db 80, ?, 80 dup (?);input buffer, 1st(0) byte - max length, 2nd(1) - actual
msg_invite				db "Please input your string: ", '$'
msg_ur_in					db "Your input was: ", '$'
palindrom_amount	db 0
msg_endl					db 0ah, 0dh, '$'
msg_res1					db "In string: ", '$'
msg_spacing				db " ", '$'
msg_res2					db " palindroms", '$'
dseg	ends
;-----------------------------------------------------------------------------
cseg	segment	'code'
	assume  cs:cseg, ds:dseg, ss:sseg

	start:	mov ax, dseg
		mov ds, ax
;text_inp+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;invite out
		lea dx, msg_invite
		mov ah, 09h
		int 21h

;text_ar in
		lea dx, text_ar
		mov ah, 0ah
		int 21h

;line end
		lea dx, msg_endl
		mov ah, 09h
		int 21h

;ur_input out
		lea dx, msg_ur_in
		mov ah, 09h
		int 21h

		xor bx, bx
		mov bl, byte ptr text_ar[1]
		add bx, 2
		mov text_ar[bx], '$';for correct printing
		lea dx, text_ar[2]
		mov ah, 09h
		int 21h

;line end
		lea dx, msg_endl
		mov ah, 09h
		int 21h
;text_ar processing+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		;dh = !palindrom
		;dl = palindrom_amount
		;di = end
		;si = start

		mov text_ar[bx], 20h;space for correct working(will be deleted after)

		xor dl, dl;palindr = 0
		lea si, text_ar[2];start = 0
		lea di, text_ar[2];end = 0
		mov cl, byte ptr text_ar[1]
		inc cl
		xor ch, ch;cx = text_ar lenght

		spacing_check:

			cmp byte ptr [di], 20h
			jne spacing_check_end_iter
				push di
				dec di;making end before space
				xor dh, dh

				palindrom_check:
				cmp dh, 0
				jne palindrom_check_break
				cmp si, di
				jae palindrom_check_break
				mov bl, byte ptr [si]
					cmp bl, byte ptr [di]
					je palindrom_check_end_iter
						inc dh
					palindrom_check_end_iter:
					inc si
					dec di
					jmp palindrom_check
				palindrom_check_break:
				pop di
				mov si, di
				inc si

				cmp dh, 0
				jne spacing_check_end_iter
					inc dl
		spacing_check_end_iter:
		inc di
		loop spacing_check

		mov palindrom_amount, dl

		xor bx, bx
		mov bl, byte ptr text_ar[1]
		add bx, 2
		mov text_ar[bx], '$';for correct printing
;res_out++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;msg_res1
lea dx, msg_res1
mov ah, 09h
int 21h

lea dx, msg_endl
mov ah, 09h
int 21h
;text_ar
lea dx, text_ar[2]
mov ah, 09h
int 21h

lea dx, msg_endl
mov ah, 09h
int 21h
;palindrom_amount
mov dl, palindrom_amount
add dl, 30h;correct printing
mov ah, 02h
int 21h
;msg_spacing
mov dl, msg_spacing
mov ah, 02h
int 21h
;msg_res2
lea dx, msg_res2
mov ah, 09h
int 21h
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		mov ah, 4Ch
		int 21h
cseg	ends
	end	start
