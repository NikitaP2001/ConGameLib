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

HideConsoleCursor proc
LOCAL ci:CONSOLE_CURSOR_INFO
LOCAL hCons:HANDLE
        sub rsp, 28h

	invoke GetStdHandle,STD_OUTPUT_HANDLE 
	mov hCons, rax
	
	invoke GetConsoleCursorInfo,hCons,addr ci
	mov ci.bVisible, 0
	
	invoke SetConsoleCursorInfo,hCons,addr ci
        
	ret
HideConsoleCursor endp

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

SetConsoleColor proc cref:QWORD
	sub rsp, 28h        
        
	invoke SetConsoleTextAttribute,rv(GetStdHandle,STD_OUTPUT_HANDLE),rcx
	
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
	
	invoke ReadConsoleOutputCharacterA,0,addr sym,2,rbx,addr chrNum	
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
	invoke ExitProcess,dwerror

	ret
ErrorMessage EndP


END