; Second stage of the boot loader

BITS 16

ORG 9000h
	jmp 	start

%include "bpb.asm"						; A copy of the BIOS Parameter Block (i.e. information about the disk format)
%include "floppy16.asm"					; Routines to access the floppy disk drive
%include "fat12.asm"					; Routines to handle the FAT12 file system
%include "functions_16.asm"
%include "a20.asm"


; Used to store the number of the boot device

boot_device	  db  0				

;	Start of the second stage of the boot loader
	
Second_Stage:
    mov		[boot_device], dl		; Boot device number is passed in from first stage in DL. Save it to pass to kernel later.

    mov 	si, second_stage_msg	; Output our greeting message
    call 	Console_WriteLine_16

	call	Enable_A20
	
	push 	dx							; Save the number containing the mechanism used to enable A20
	mov		si, dx						; Display the appropriate message that indicates how the A20 line was enabled
	add		si, dx
	mov		si, [si + a20_message_list]
	call	Console_WriteLine_16
	pop		dx											; Retrieve the number	

	
start:								
	mov 	si, inputmessage							; Output our greeting message
	call 	Console_Write_16

	xor		bx,bx										;to clear the bx registers
	xor		cx, cx										;to clear the cx registers
	xor		ax, ax										;to clear the ax registers
	mov		dx, 10

read:
	xor 	ah, ah
	int 	16h												; would get keystroke into al		

	
	cmp 	al, 0dh								
	je 		readsect
	
	;error handling
	cmp  	al, '0'										; to keep number above "0"
	jb   	read
	cmp  	al, '9'										; to keep number below "9"
	ja   	read
	
	mov  	ah, 0eh
	int 	10h
	
	xor 	ah, ah
	sub 	al, 30h

	cmp 	cx,0

	jg 		convert
	inc 	cx
	push 	ax
	xor 	ax, ax
	jmp 	read

convert:
	mov		bx, ax
	pop		ax
	inc 	cx
	push 	dx
	mul		dx
	pop		dx
	add 	ax, bx
	push 	ax
	xor 	ax, ax

readsect:	
	pop		ax
	mov		cx, 1										;amount of sector to read
	mov		bx,	0D000h									;buffer to read
	call	ReadSectors
	call	Console_Write_CRLF
	xor		dx, dx
	mov		dl, byte[0d000h]
	mov     si, 0d000h									;sets si to memory location
	mov		cx, 2
	
	
myloop2:	
	push	cx
	mov		cx,	16
	
	
myloop1:
    push 	cx
	
	
Sector_Offset:											; Offset into the sector

	mov		dx, si                                  	;move si into dx
	sub		dx, 0d000h									;goes to the current offset
	push	si
	mov		bx,	dx										;prepare for printing
	push	si
	push	cx
	call	Console_Write_Hex							;prints sector offset
	pop		cx
	pop		si
	push	cx
	mov		cx, 16

Sector_HexDigits:										;print the bytes pairs
	mov		bx, [si]									;will get current byte in si
	push	cx											
	push	si
	call    Console_Write_bits							;printing byte at current position in the hex
	pop		si
	pop		cx
	inc 	si											;moves to next byte
	loop	Sector_HexDigits
	pop		cx
	pop		si
	mov		cx, 16
	
	
Sector_ASCI:											;prints ASCII char for the sector 
	push	si
	call	Console_Write								;prints bytes at current position in ASCII
	pop  	si
	inc		si											;then moves to next byte
	loop 	Sector_ASCI
	call	Console_Write_CRLF
	pop		cx
	loop	myloop1
	push 	si
	mov 	si, continuemssg							; enter key to continue
	call 	Console_Write_16
	call	Console_Write_CRLF
	pop  	si
	push 	si

	xor 	ah, ah								
	int 	16h
	
	cmp 	dx, 496
	

	jge		Complete							
	

	cmp 	al, 0dh											;loop back to read the rest of sector
	je 		myloop2

Complete:												;when it complete, it jumps here

	hlt													; For now, we just stop
	
	
	
	
%include "messages.asm"

	times 3584-($-$$) db 0	