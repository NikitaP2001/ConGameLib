include congame.inc

.code

gotoxy proc uses rbx x:QWORD, y:QWORD
	sub rsp, 28h
        
	mov rbx,rdx
	shl rbx,16
	or rbx,rcx
	invoke SetConsoleCursorPosition,rv(GetStdHandle,STD_OUTPUT_HANDLE ),rbx
	
	ret        
gotoxy endp

SetConsoleCursorState proc State:QWORD
LOCAL ci:CONSOLE_CURSOR_INFO
LOCAL hCons:HANDLE
	sub rsp, 28h		

	invoke GetStdHandle,STD_OUTPUT_HANDLE 
	mov hCons, rax
	
	invoke GetConsoleCursorInfo,hCons,addr ci
	
	cmp State, 0
	jne @Show	
		mov ci.bVisible, 0		
	jmp @end
@Show:			
		mov ci.bVisible, 1	
@end:   
	invoke SetConsoleCursorInfo,hCons,addr ci	
 
	ret
SetConsoleCursorState endp

SetConsoleSize PROC uses rbx wd:QWORD, ht:QWORD
LOCAL srect:SMALL_RECT
LOCAL hCons:HANDLE
        sub rsp, 28h
        mov wd, rcx
        mov ht, rdx

	invoke GetStdHandle,STD_OUTPUT_HANDLE 
        mov hCons, rax
	
        mov (SMALL_RECT ptr srect).Left, 0
        mov (SMALL_RECT ptr srect).Top, 0
        
	mov rax, wd
	dec rax
	mov (SMALL_RECT ptr srect).Right, ax
	mov rax, ht
	dec rax    
	mov (SMALL_RECT ptr srect).Bottom, ax
        
	invoke SetConsoleWindowInfo,hCons,TRUE,addr srect
	
	mov rbx, ht
	shl rbx, 16
	or rbx, wd
	invoke SetConsoleScreenBufferSize,hCons,rbx
        
	ret
SetConsoleSize ENDP

SetConsoleColor proc uses rbx BkgrColor:QWORD, FontColot:QWORD
	sub rsp, 28h        
        
        mov rbx, BkgrColor
        shl rbx, 4
        or rbx, FontColot        
        
	invoke SetConsoleTextAttribute,rv(GetStdHandle,STD_OUTPUT_HANDLE),rbx
	
	ret
SetConsoleColor endp

CheckCursorPosition proc uses rbx x:QWORD, y:QWORD
LOCAL chrNum:QWORD
LOCAL HD:HANDLE
LOCAL sym[2]:BYTE
        sub rsp, 28h
        mov x, rcx
        mov y, rdx
	invoke gotoxy,x,y
	
	mov rbx, y      ;dwReadCoord
	shl rbx, 16
	or rbx, x		

	invoke GetStdHandle,STD_OUTPUT_HANDLE
	mov HD, rax
	
	invoke ReadConsoleOutputCharacterA,HD,addr sym,2,rbx,addr chrNum	
	test rax, rax
	je @Error
	
	movzx rax, byte ptr sym
	jmp @end
	
@Error:
	invoke ErrorMessage,rax,"CheckCursorPosition"
	jmp @end
	
@end:
	ret
CheckCursorPosition endp

ErrorMessage PROC uses rbx DWErrorCode:DWORD,lpszFunction:PTR BYTE
LOCAL lpMsgBuf:LPVOID
LOCAL lpDisplayBuf:LPVOID
LOCAL dwerror:DWORD
        sub rsp, 30h
        mov DWErrorCode, ecx
        mov lpszFunction, rdx

	call GetLastError
	mov dwerror, eax
	
	mov rbx,FORMAT_MESSAGE_ALLOCATE_BUFFER
	or rbx,FORMAT_MESSAGE_FROM_SYSTEM
	or rbx,FORMAT_MESSAGE_IGNORE_INSERTS
	
	invoke FormatMessage,rbx,0,dwerror,0,addr lpMsgBuf,0,0
	
	invoke vc__mbstrlen,lpszFunction
	mov rbx, rax
	invoke vc__mbstrlen,lpMsgBuf
	add rbx, rax
	add rbx,80
	
	invoke LocalAlloc,LMEM_ZEROINIT,rbx
	mov lpDisplayBuf, rax
	
	invoke vc_strcpy,lpDisplayBuf,lpszFunction
	
	invoke vc_strcat,lpDisplayBuf," failed with error "
	
	invoke vc__mbstrlen,lpDisplayBuf
	add rax,lpDisplayBuf
	invoke vc__itoa,dwerror,rax,10
	
	invoke vc__mbstrlen,lpDisplayBuf
	add rax,lpDisplayBuf
	mov byte ptr[rax], ':'
	mov byte ptr[rax+1], ' '
	mov byte ptr[rax+2], 0
	
	invoke vc_strcat,lpDisplayBuf,lpMsgBuf
	
	invoke MessageBoxA,0,lpDisplayBuf,"Error",MB_OK+MB_ICONERROR
	
	invoke LocalFree,lpMsgBuf
	invoke LocalFree,lpDisplayBuf

	ret
ErrorMessage EndP

RangedRand proc min:QWORD, max:QWORD  
LOCAL rand_val:QWORD
LOCAL maxVal:QWORD        
        mov min, rcx
        mov max, rdx
        mov maxVal, -1
        
@@:
        rdrand rax
        jnc @B
        mov rand_val, rax
        
        mov rcx, max        
        sub rcx, min
        xor rdx, rdx
        mov rax, rand_val
        div rcx
        add rdx, min
        
        mov rax, rdx        
        ret
RangedRand endp

CreateObject proc lpObj:PTR GAME_OBJECT, x:QWORD, y:QWORD, speed:QWORD, \
vspeed:QWORD, hspeed:QWORD, gravity:QWORD, direction:BYTE, lives:BYTE, \
health:BYTE, sprite:BYTE
        sub rsp, 30h        
        
        mov rax, x
        mov (GAME_OBJECT ptr lpObj).obj.x, rax
        mov (GAME_OBJECT ptr lpObj).obj.xstart, rax
        mov rax, y
        mov (GAME_OBJECT ptr lpObj).obj.y, rax
        mov (GAME_OBJECT ptr lpObj).obj.ystart, rax
        mov rax, speed
        mov (GAME_OBJECT ptr lpObj).speed, rax
        mov rax, vspeed
        mov (GAME_OBJECT ptr lpObj).vspeed, rax
        mov rax, hspeed
        mov (GAME_OBJECT ptr lpObj).hspeed, rax
        mov rax, gravity
        mov (GAME_OBJECT ptr lpObj).gravity, rax
        mov al, direction
        mov (GAME_OBJECT ptr lpObj).direction, al
        mov al, lives
        mov (GAME_OBJECT ptr lpObj).lives, al
        mov al, health
        mov (GAME_OBJECT ptr lpObj).health, al
        mov al, sprite
        mov (GAME_OBJECT ptr lpObj).sprite, al
        
        ret
CreateObject endp

SetConsoleCenterScreen proc hwndInsertAfter:HWND
LOCAL hWCons:HWND
LOCAL WndRect:RECT
	mov hwndInsertAfter, rcx
	sub rsp, 28h
	and rsp, -10h

	invoke GetConsoleWindow
	mov hWCons, rax
	
	invoke GetWindowRect,hWCons,addr WndRect
	
	; console width
	mov esi, (RECT ptr WndRect).right
	sub esi, (RECT ptr WndRect).left
	
	; console height
	mov edi, (RECT ptr WndRect).bottom
	sub edi, (RECT ptr WndRect).top
	
	invoke GetSystemMetrics, SM_CXSCREEN
	sub eax, esi
	shr eax, 1
	mov esi, eax	
	
	invoke GetSystemMetrics, SM_CYSCREEN
	sub eax, edi
	shr eax, 1
	mov edi, eax

	invoke SetWindowPos,hWCons,hwndInsertAfter,esi,edi,0,0, \
	1h + 40h
	
	ret
SetConsoleCenterScreen endp


END