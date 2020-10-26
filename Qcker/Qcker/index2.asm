global  _getindex2
extern _printf    
; source: https://montcs.bloomu.edu/Information/LowLevel/Assembly/asm-c-calling.html
section .data
prompt1 db "current value is: %i", 13,10,0
ctr dd 0
copyctr dd 0
total dd 0
len dd 0
const dd 4
;_getindex
tofind dd 0



_getindex2:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
;***********************************************
        mov ecx, [ebp + 8] ; rank to find
        mov ebx, [ebp + 12] ; length of array
        mov esi, [ebp + 16] ;pointer to array            
        xor eax,eax

again:
    cmp ebx,0
    je notfind
        prefetcht0 [esi]
        
        mov edx,[esi] 
        cmp ecx,edx
        je finish
        add eax,1
        add esi,4
        prefetcht0 [esi+4]
        sub ebx,1
        jmp again        

notfind:
        mov eax,-1 
        leave
        ret       
                        
finish:
        mov eax,eax        
       
        leave
        ret

