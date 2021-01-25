sseg	segment	stack 'stack'
	db	128 dup(?)
sseg	ends
;-----------------------------------------------------------------------------
dseg	segment	'data'
	N 		dw 256
	N_n_d		db ?;amount of digits for base10 N
	N_d_mas		db 5 dup (?);array for digits of base10 N
	N_d_m3		db 0;amount of multiples of 3 in array N_d_mas
	ten		dw 10;for idiv
	msg_res1 	db "In decimal number N = ", '$'
	msg_res2	db " ,multiples of 3 are ", '$'
	msg_res3	db " digits", '$'
	msg_endl	db 0Dh, 0Ah, '$'
	msg_neg		db "-", '$'
	N_posflag	db 1; =1 if N>0, =0 if N<0
dseg	ends	
;-----------------------------------------------------------------------------
cseg	segment	'code'
	assume  cs:cseg, ds:dseg, ss:sseg

	start:	mov ax, dseg
		mov ds, ax
;N_n_d++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		cmp N, 0
		jge dig

		neg N
		mov N_posflag, 0

	dig:	cmp N, 10000;checking how many digits N has
		jg N_n_d_5

		cmp N, 1000
		jg N_n_d_4

		cmp N, 100
		jg N_n_d_3

		cmp N, 10
		jg N_n_d_2

		mov N_n_d, 1

	N_n_d_5:mov N_n_d, 5
		jmp end_N_n_d

	N_n_d_4:mov N_n_d, 4
		jmp end_N_n_d

	N_n_d_3:mov N_n_d, 3
		jmp end_N_n_d

	N_n_d_2:mov N_n_d, 2
		jmp end_N_n_d

	end_N_n_d:
;N_d_mas++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		mov cx, N_n_d
		mov si, 0
		mov [dx:ax], N

	d_loop:	idiv ten
		mov N_d_mas[si], dx
		cwd;[dx:ax] = ax
		inc si
		loop d_loop
;N_d_m3+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		mov cx, N_n_d
		mov si, 0

	m3_loop:
		mov ax, N_d_mas[si]
		div 3
		cmp ah, 0;checking if remainder =0 (N_d_mas[si] % 3 == 0)
		jne end_iter_m3_loop

		inc N_d_m3
	end_iter_m3_loop:
		inc si
		loop m3_loop	
;out++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	;print msg_res1
		lea dx, msg_res1
		mov ah, 09h
		int 21h
	;print msg_neg if N<0(N_posflag=0)
		cmp N_posflag, 0
		je print_neg
		jmp print_N
	print_neg:
		mov dl, msg_neg
		add dl, 30h
		mov ah, 02h
		int 21h
	print_N:
		mov cx, N_n_d
		mov si, 0
	print_N_loop:
		mov dl, N_d_mas[si]
		add dl, 30h
		mov ah, 02h
		int 21h

		inc si
		loop print_N_loop
	;print msg_res2
		lea dx, msg_res2
		mov ah, 09h
		int 21h
	;print N_d_m3
		mov dl, N_d_m3
		mov ah, 02h
		int 21h
	;print msg_res3
		lea dx, msg_res3
		mov ah, 09h
		int 21h
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
		mov ah, 4Ch
		int 21h
cseg	ends
	end	start
