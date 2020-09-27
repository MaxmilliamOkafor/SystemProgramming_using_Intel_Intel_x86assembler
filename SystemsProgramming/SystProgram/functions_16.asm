; Various sub-routines that will be useful to the boot loader code	

; Output Carriage-Return/Line-Feed (CRLF) sequence to screen using BIOS
mov cx,1

Console_Write_CRLF:
	mov 	ah, 0Eh						; Output CR
    mov 	al, 0Dh
    int 	10h
    mov 	al, 0Ah						; Output LF
    int 	10h
    ret

; Write to the console using BIOS.
; 
; Input: SI points to a null-terminated string

HexChars   db '0123456789ABCDEF'

Console_Write_Hex:
	mov		cx,	4
	jmp		HexLoop
	
Console_Write_bits:
	mov 	cx, 2
	rol 	bx, 8
	and 	cx, 000fh

HexLoop:
	rol		bx,	4
	mov		si,	bx
	and		si, 000Fh
	mov		al,	byte [si + HexChars]
	mov		ah, 0Eh
	int		10h
	loop	HexLoop
	
	mov		ah, 0eh
	mov		al ,20h
	int		10h
	ret
	
Console_Write_Int:                                         ;Output the value BX as integer
	mov		si,	intBuffer + 4
	mov		ax, bx

GetDigit:
	xor		dx, dx
	mov		cx, 10
	div		cx
	add		dl, 48
	mov		[si], dl
	dec		si
	cmp		ax, 0 
	jne		GetDigit
	inc		si
	call	Console_Write_16
	ret
	
intBuffer	db	'		', 0


	; Write underscore for values less than 32 to avoid undesired commands
Console_Write_Underscore:
	mov 	ah, 0Eh	
	mov 	al, 5Fh						; Insert underscore		 
	int 	10h				
	ret	

;Console_Write_Hex_16:
	mov		cx,	2
	
Console_Write_16:
	mov 	ah, 0Eh						; BIOS call to output value in AL to screen

Console_Write_16_Repeat:
    mov		al, [si]
	inc     si
    test 	al, al						; If the byte is 0, we are done
	je 		Console_Write_16_Done
	int 	10h							; Output character to screen
	jmp 	Console_Write_16_Repeat

Console_Write_16_Done:
    ret

; Write string to the console using BIOS followed by CRLF
; 
; Input: SI points to a null-terminated string

Console_WriteLine_16:
	call 	Console_Write_16
	call 	Console_Write_CRLF
	ret

Console_Write:
	mov		ah, 0Eh							; Output CR
	mov		al,	byte[si]
	cmp		al, 32
	jbe		Console_Write_Underscore
	int		10h
	ret