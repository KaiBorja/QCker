segment .text
global _precheckblk, _checkblkavx
section .data
seed dd 0
align 16
posindexcpy dd 0,0,0,0,0,0,0,0
ans1 dd 0,0,0,0,0,0,0,0
inst dd 0
instcpy dd 0
const dd 4
nblk dd 0
posindex dd 0
ictr dd 0
index dd 0
_checkblkavx:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov eax, [ebp + 8]  ;Number of blocks
        ;inc eax
        mov dword [nblk],eax
        mov eax, [ebp + 16]  ;posindex
        mov dword [posindex],eax
        ;mov esi, [ebp + 12]  ;lowblk
        ;mov esi, [ebp + 20]  ;uppblk
        ;mov esi, [ebp + 24]  ;cntblk 
        ;mov esi, [ebp + 32]  ;pos table
        ;mov esi, [ebp + 36]  ;readsize
        mov eax, [ebp + 28]  ;Number of instances 
        mov dword [inst],eax
        mov dword [instcpy],0
        mov dword ecx,[ebp + 36] ; get the readsize
   
againinst:
        mov dword eax,[inst]
        cmp dword eax,[instcpy]
        je done
        PREFETCHT0 [posindex]
        PREFETCHT0 [instcpy]
        PREFETCHT0 [const]
        
        mov esi, [ebp + 32];place pointer to start of pos table
      
        mov dword ebx,[posindex]; place posindex in ebx
       
        add dword ebx,[instcpy];add posindex with inst [posindex+inst]
        mov eax,ebx
        mul dword [const]; *4 to proper index
        add esi, eax    ;point to proper index
           
        mov dword eax,[esi]    ; pos[posindex+inst]
        PREFETCHT0 [instcpy+1] 
        
        
        ;shr eax,4 ;
        div  ecx            ;pos[posindex+inst]/readlen   
        mul dword [const]   ; *4 to proper index
        
        mov esi, [ebp + 24];point to countblk
        add esi,eax         ;point to proper index

        add dword [esi],1 ;block[pos[posindex+inst]/readlen]++  

        
       inc dword [instcpy]
       jmp againinst        
       
done:
leave
ret



_precheckblk:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov eax, [ebp + 8]  ;number of iterations
        mov ecx, [ebp + 12]  ;blk len
        mov ebx, [ebp + 16]  ;seed size
        mov dword [seed],ebx
        mov esi, [ebp + 20] ; lowblk
        mov edi, [ebp + 24] ; uppblk 
         
        xor ebx,ebx
        xor edx,edx
        ;preupper
        mov  ebx,ecx
        add ebx,ecx
        sub dword ebx,[seed]
        inc ebx
        mov dword [edi],ebx
        ;nextlocation
        add esi,4
        add edi,4
        dec eax
precheckagain:
        
        cmp eax,0
        je doneprecheck
        prefetcht0 [esi]
        prefetcht0 [esi+4]
        prefetcht0 [edi]
        prefetcht0 [edi+4]
        ;lower
        add edx,ecx
        mov dword [esi],edx
        ;upper
        add ebx,ecx
        mov dword [edi],ebx
        
        ;Next Iteration
        dec eax
        add esi,4
        add edi,4
        jmp precheckagain
doneprecheck:
        
leave
ret







