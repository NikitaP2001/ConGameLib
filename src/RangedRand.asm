include RangedRand.inc
option casemap:none
OPTION DOTNAME

.data
maxVal dq -1

RangedRand proc min:QWORD, max:QWORD  
LOCAL rand_val:QWORD

        mov min, rcx
        mov max, rdx
        
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


END