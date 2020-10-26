global  _getinst
extern _printf    
section .data
prompt1 db "current value is: %i", 13,10,0
ctr dd 0
const dd 4


_getinst:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
;***********************************************
        mov ecx, [ebp + 8] ; index of rank
        mov ebx, [ebp + 12] ; length of array
        mov esi, [ebp + 16] ;pointer to array
        mov edi, [ebp + 16] ;pointer to array              
        xor eax,eax
        
        mov dword [ctr],ecx        
        ;point at the index of rank
        mov dword eax,ecx
        mul dword [const]
        add esi,eax         ;[esi+(ctr*4)],
        add edi,eax  
        ;add esi,4
        
                
again:
        cmp dword [ctr],ebx
        je notfind
        PREFETCHT0 [esi]
        
        
        mov dword eax,[esi] ;value at array
        mov dword edx,[edi]
        PREFETCHT0 [esi+4]
        cmp  edx,eax         ;compare rank to array
        jne finish
        add dword [ctr],1
        add esi,4
        
        jmp again

notfind:
        mov eax,-1 
        leave
        ret       
                        
finish: 
        mov dword eax,[ctr]
        leave
        ret

