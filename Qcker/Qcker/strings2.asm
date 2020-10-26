segment .text
global _movstring2, _strcnt2

_movstring2:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov edx, [ebp + 8] ; source array
        mov esi, [ebp + 12] ; source array
        mov eax, [ebp + 16] ; source array
        mov edi, [ebp +20] ;destination array

        add esi,eax
       
       
        sub esi,1
        sub edi,1 
        ;size = 8 char
        
again:
        add esi,1
        add edi,1
        PREFETCHT0 [esi]
        mov dword eax, [esi]
        mov dword [edi], eax
        
        cmp edx,0
        je finish 
        
        sub edx,1
        jmp again
        
finish:
        mov dword eax, 0x00
        mov dword [edi], eax
        
        
        leave
ret



_strcnt2:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov esi, [ebp + 8] ; source array

countmore:
        PREFETCHT0 [esi]
        mov byte bl,[esi]
        cmp bl,0x00
        je done
        add eax,1
        add esi,1
        jmp countmore
        
done:        
       leave
ret