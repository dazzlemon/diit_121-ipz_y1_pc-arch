sseg_main	segment	stack 'stack'
	db	128 dup(?)
sseg_main	ends
;-----------------------------------------------------------------------------
dseg_main segment	'data'
msg_salute0	db "  This application takes N,M from range [3;5],", 0dh, 0ah, '$'
msg_salute1	db "  gets input for each element of NxM array in range [-32768;32767],", 0dh, 0ah, '$'
msg_salute2	db "  and checks each column for elements which are larger", 0dh, 0ah, '$'
msg_salute3	db "  than their vertical and horizontal neighbours,", 0dh, 0ah, '$'
msg_salute4	db "  creates Mx1 array elements of which", 0dh, 0ah, '$'
msg_salute5	db "  are multiples of chosen elements for each column(or (1) if none).", 0dh, 0ah, 0dh, 0ah, '$'
dseg_main	ends

extrn interface: far
;-----------------------------------------------------------------------------
cseg_main	segment	'code'
		assume  cs:cseg_main, ds:dseg_main, ss:sseg_main

start:
		mov ax, dseg_main
		mov ds, ax
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;main
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


	call interface

;procs
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		mov ah, 4Ch
		int 21h
cseg_main	ends
	end	start
