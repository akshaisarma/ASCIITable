assume cs:asciitable
proj1 segment 'code'
org 100h

START:jmp RealStart

;Data Section
ScrBuff db 4000 dup (?)
Msg db "Press PGUP/PGDWN to switch pages. ESC to Quit",0
HexL db "0123456789ABCDEF",0
heading db "ASCII   HEX   CHAR", 0

RealStart: call SaveScreen
;Setting Text Mode
mov ax, 03h
int 10h
;Killing Cursor
mov ah, 01h
mov cx, 2D0Eh
int 10h
P1:
call ClearScreen
call page1
KeyListen:
mov ah, 0h
int 16h
cmp al, 1Bh; if ESC was pressed
je Quit
cmp ah,49h; if PGUP was pressed
je P4
cmp ah,51h; if PGDW was pressed
je P2
jmp KeyListen; None of the above pressed

P2:
call ClearScreen
call page2
KeyListen1:
mov ah, 0h
int 16h
cmp al, 1Bh
je Quit
cmp ah,51h; if PGDW was pressed
je P3
cmp ah,49h; if PGUP was pressed
je P1
jmp KeyListen1; None of the above pressed

P3:
call ClearScreen
call page3
KeyListen2:
mov ah, 0h
int 16h
cmp al, 1Bh
je Quit
cmp ah,51h; if PGDW was pressed
je P4
cmp ah, 49h; if PGUP was pressed
je P2
jmp KeyListen2; None of the above pressed

P4:
call ClearScreen
call page4
KeyListen3:
mov ah, 0h
int 16h
cmp al, 1Bh
je Quit
cmp ah,51h; if PGDW was pressed
je P1
cmp ah, 49h; if PGUP was pressed
je P3
jmp KeyListen3; None of the above pressed

Quit:
call RestoreScreen
int 20h 

;Procedure Section
page1:
call DrawFrame
mov bx, 284 
mov cx, 4
mov dx, 0
L9:	
add bx, 38
push bx
push cx
mov cx, 21
	L10: push bx
	call PrintA
	add bx, 12
	call PrintH
	add bx, 10
	mov es:[bx], dl; Char
	pop bx
	add bx, 160
	inc dx
	Loop L10
pop cx
pop bx	
Loop L9
ret

page2:
call DrawFrame
mov bx, 284 
mov cx, 4	
mov dx, 84
L11:
add bx, 38
push bx
push cx
mov cx, 21
	L12: push bx
	call PrintA
	add bx, 12
	call PrintH
	add bx, 10
	mov es:[bx], dl; Char
	pop bx
	add bx, 160
	inc dx
	Loop L12
pop cx
pop bx	
Loop L11
ret

page3:
call DrawFrame
mov bx, 284 
mov cx, 4	
mov dx, 168
L13:
add bx, 38
push bx
push cx
mov cx, 21
	L14: push bx
	call PrintA
	add bx, 12
	call PrintH
	add bx, 10
	mov es:[bx], dl; Char
	pop bx
	add bx, 160
	inc dx
	Loop L14
pop cx
pop bx
Loop L13
ret

page4:
call DrawFrame
mov bx, 284 
mov dx, 252
add bx, 38
push bx
mov cx, 4
L15: push bx
call PrintA
add bx, 12
call PrintH
add bx, 10
mov es:[bx], dl; Char
pop bx
add bx, 160
inc dx
Loop L15
pop bx	
ret

PrintA:
;First Digit
push cx
mov cx,0
mov ax,dx
Lbl: cmp ax,100 
jl P5
sub ax,100
inc cx
jge Lbl
P5:
add cx,48; Char 0
mov es:[bx], cl
inc bx
inc bx
;Second Digit 
mov cx, 0
Lbl1: cmp ax, 10
jl P6
sub ax, 10
inc cx
jge Lbl1
P6:
add cx, 48
mov es:[bx],cl
inc bx
inc bx
; Third Digit
add ax, 48
mov es:[bx], al
pop cx
ret

PrintH:
mov al, dl
shr al,4; Most Sig Dig
call HexD
mov al, dl
and al, 00001111b ; Least sig dig
call HexD
ret

HexD:
sub si, si
mov ah, 0
mov si, ax
mov ah, HexL[si]
mov es:[bx], ah
inc bx
inc bx
ret


SaveScreen: 
mov ax, 0b800h
mov es, ax
mov cx, 4000
sub bx,bx
L:mov al, es:[bx] 
mov ScrBuff[bx],al
inc bx
Loop L
ret

ClearScreen:
mov cx, 2000
sub bx, bx
L1: mov ax, 7220h ; green on white
mov es:[bx], ax
inc bx
inc bx
Loop L1
ret

RestoreScreen: 
mov cx, 4000
sub bx, bx
L2: mov al,ScrBuff[bx]
mov es:[bx], al
inc bx
Loop L2
ret

;Procedure DrawFrame
DrawFrame:
sub bx,bx
mov byte ptr es:[bx], 0C9h
call Vdraw
sub bx,bx
call Hdraw
mov bx, 38
mov byte ptr es:[bx], 0CBh
call Vdraw
mov bx, 38
call Hdraw
mov bx, 76
mov byte ptr es:[bx], 0CBh
call Vdraw
mov bx, 76		
call Hdraw
mov bx, 114
mov byte ptr es:[bx], 0CBh
call Vdraw
mov bx, 114
call Hdraw
mov bx, 152
mov byte ptr es:[bx], 0BBh
call Vdraw
mov bx, 3680
mov byte ptr es:[bx], 0C8h
call Hdraw
mov bx, 3718
mov byte ptr es:[bx], 0CAh
call Hdraw
mov bx, 3756
mov byte ptr es:[bx], 0CAh
call Hdraw
mov bx, 3794
mov byte ptr es:[bx], 0CAh
call Hdraw
mov bx, 3832
mov byte ptr es:[bx], 0BCh
mov cx, 45; print message
sub si,si
mov bx, 3840
mov al, msg[si]
L6: mov es:[bx], al
inc si
mov al, msg[si]
inc bx
inc bx
Loop L6
mov cx,4; draw heading
mov bx, 160
L8:
push cx
mov cx, 18
add bx, 2
sub si,si
	L7: mov al, heading[si]
	inc si
	mov es:[bx], al
	inc bx
	inc bx
	Loop L7
pop cx
Loop L8
ret

;procedure Vertical Line Draw
Vdraw:
mov cx, 22
L4: add bx, 160
mov byte ptr es:[bx], 0BAh
Loop L4
ret

;procedure Horizontal Line Draw
Hdraw:
mov cx, 19
L5: inc bx
inc bx
mov byte ptr es:[bx], 0CDh
Loop L5
ret

proj1 ends
end START


