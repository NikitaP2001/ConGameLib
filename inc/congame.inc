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

; windows-api lib files

includelib \masm32\lib64\kernel32.lib
includelib \masm32\lib64\user32.lib

; other masm32 libraries header files

include \masm32\include64\msvcrt.inc

; other masm32 libraries lib files

includelib \masm32\lib64\msvcrt.lib


SetConsoleSize          PROTO wd:QWORD, ht:QWORD
HideConsoleCursor       PROTO
gotoxy                  PROTO x:QWORD, y:QWORD
SetConsoleColor         PROTO cref:QWORD
CheckCursorPosition     PROTO x:QWORD, y:QWORD

ErrorMessage PROTO DWErrorCode:DWORD,lpszFunction:PTR BYTE

ENDIF