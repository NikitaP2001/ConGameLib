IFNDEF CONGAME_INC
CONGAME_INC EQU CONGAME_INC

OPTION DOTNAME
option casemap:none 

include \masm32\include64\win64.inc
include \masm32\macros64\vasily.inc
include \masm32\macros64\macros64.inc

; windows-api header files

include \masm32\include64\kernel32.inc
include \masm32\include64\user32.inc
include \masm32\include64\ntdll.inc

; windows-api lib files

includelib \masm32\lib64\kernel32.lib
includelib \masm32\lib64\user32.lib
includelib \masm32\lib64\ntdll.lib

; other masm32 libraries header files

include \masm32\include64\msvcrt.inc

; other masm32 libraries lib files

includelib \masm32\lib64\msvcrt.lib


SetConsoleSize          PROTO wd:QWORD, ht:QWORD

SetConsoleCenterScreen 	PROTO hwndInsertAfter:HWND
SetConsoleCursorState 		PROTO State:QWORD
gotoxy                  PROTO x:QWORD, y:QWORD
SetConsoleColor         PROTO BkgrColor:QWORD, FontColot:QWORD
CheckCursorPosition     PROTO x:QWORD, y:QWORD

; console text color codes
        cBlack           = 0
        cGray            = 8
        cBlue            = 1
        cLightBlue       = 9
        cGreen           = 2
        cLightGreen      = 10
        cAqua            = 3        
        cLightAqua       = 11
        cRed             = 4
        cLightRed        = 12
        cPurple          = 5
        cLightPurple     = 13
        cYellow          = 6
        cLightYellow     = 14
        cWhite           = 7
        cBrightWhite     = 15
		
; Returns TRUE on success
ErrorMessage PROTO DWErrorCode:DWORD,lpszFunction:PTR BYTE

SHOW_ERROR MACRO func_name

	ifdef DEBUG
		
		invoke GetLastError
		
		invoke ErrorMessage,rax,func_name
		
		int 3
		
	endif	
	xor rax, rax
	
ENDM

RangedRand PROTO min:QWORD, max:QWORD  

OBJECT STRUCT

        x       QWORD ?
        y       QWORD ?
        xstart  QWORD ?
        ystart  QWORD ?

OBJECT ENDS

; GameObject class

GAME_OBJECT STRUCT
        
        obj             OBJECT <>
        speed           QWORD ?
        vspeed          QWORD ?
        hspeed          QWORD ?
        gravity         QWORD ?
        direction       BYTE ?
        lives           BYTE ?
        health          BYTE ?
        sprite          BYTE ?

GAME_OBJECT ENDS

        putchar MACRO sym
        
                invoke vc_putchar,sym
        
        ENDM

; GameObject constructor

CreateObject PROTO lpObj:PTR GAME_OBJECT, x:QWORD, y:QWORD, speed:QWORD, \
vspeed:QWORD, hspeed:QWORD, gravity:QWORD, direction:BYTE, lives:BYTE, \
health:BYTE, sprite:BYTE


ENDIF