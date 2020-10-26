segment .text
global _checkblk2
section .data
inst dd 0
len dd 0
instcpy dd 0
currblk dd 0
boundblk dd 0
cpynblk dd 0
blklen dd 0
nblk dd 0
posindex dd 0
ictr dd 0
postemp dd 0
const dd 4
result dd 0
nitr dd 0
seedsize dd 0
_checkblk2:

        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov ebx, [ebp + 8] ;seed size
        mov dword [seedsize],ebx
        mov ebx, [ebp + 12] ;read size
        mov dword [len],ebx
        mov ebx, [ebp + 16] ;number of instances
        mov dword [inst],ebx
        mov ecx, [ebp + 20] ;number of blocks
        mov dword [nblk],ecx
        mov ecx, [ebp + 24] ;block length
        mov dword [blklen],ecx 
        mov ecx, [ebp + 28] ;pos index
        mov dword [posindex],ecx 
        mov esi, [ebp + 32] ;point to start of countblk??
        mov edi, [ebp +36]  ;point to start of pos table 
        
    
    PREFETCHT0 [ebp +32]
    PREFETCHT0 [ebp +36]
    PREFETCHT0 [nblk]
    PREFETCHT0 [posindex]
    PREFETCHT0 [instcpy]
    PREFETCHT0 [const]
    PREFETCHT0 [postemp]
    PREFETCHT0 [currblk]
    PREFETCHT0 [blklen]
    PREFETCHT0 [seedsize] 
    mov dword [instcpy],0
    ;mov dword [inst],0   
againinst:  
    mov dword eax,[inst]    
    cmp dword eax,[instcpy]
    je done    
    mov dword [currblk],0 
    mov dword [ictr],0 
    mov dword [postemp],0
    
    

againblk:

    mov esi, [ebp +32]; point to countblk
    mov edi, [ebp +36]; point to pos
    mov dword eax,[nblk]
    cmp dword [ictr],eax ;for loop
    je nextinst
    
    mov dword eax,[posindex] ;compute index
    add dword eax,[instcpy]    ;compute index
    mul dword [const]       ;compute index
    add edi, eax            ;compute index pos
    
    mov dword ebx,[edi]         ;getvalue of pos
    mov dword [postemp],ebx    ;getvalue of pos
    mov dword eax,[currblk]
    cmp dword ebx,eax ;    cmp lowblk < pos
    jge next
    jmp proceed 
       
next: 

    mov dword eax, [currblk] ;compute index
    add dword eax,[blklen]   ;compute index
    sub dword eax,[seedsize]
    add eax,1               ;compute index 
    mov dword [nitr],eax      
    cmp dword [postemp],eax ; cmp pos < upperblk
    jl next2
    jmp proceed
    
next2:         
    mov dword eax, [ictr] ;compute what blk 
    mul dword [const]     ;compute what blk
    add esi, eax          ;compute what blk
    add dword [esi],1     ;increment ctrblk
       
proceed:
    mov dword eax,[len]       ;increment blk
    add dword [currblk],eax     ;increment blk
    add dword [ictr],1          ;increment blk
    jmp againblk
         

               
                                             
nextinst:
    add dword [nitr],1           
    add dword [instcpy],1
    jmp againinst
        
done:
   
        mov dword eax,[nitr]
        leave
ret