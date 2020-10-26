segment .text
global _avxrank,_avxprerank,_avxthres

section .data
;data1 dd 0, 4, 16, 64 
;data2 dd 256, 2014,4096, 16384

align   16
data1 dd 16384,4096,1024,256
align   16
data2 dd 64,16,4,1
align   16
data3 dd 16776216,1048576,262144 ,65536
strver dd 0,0,0,0,0,0,0,0
align   16
threscpy dd 0,0,0,0,0,0,0,0
blkcnt dd 0
const dd 4
esidum dd 0

_avxrank:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov edi,  [ebp + 8]       ;xmm0 = a
        mov edx , [ebp + 12]
        PREFETCHT0 [data1]
        PREFETCHT0 [data2]
        PREFETCHT0 [data3]
        PREFETCHT0 [edi]
        PREFETCHT0 [edi+16]
        PREFETCHT0 [edi+32]
         cmp edx, 4
        je readlen4
        cmp edx,8
        je readlen8
        cmp edx,12
        je readlen12
        
readlen4:        

        ;Prepare data        
        align 16
        movaps xmm1, [data2]
                      
        ;Get multiplier
        align 16
        movaps xmm2, [edi]        
        pmullw xmm1,xmm2                   

        ;Add    
        PHADDD    xmm1,xmm1
        PHADDD    xmm1,xmm1     
        movd      eax,xmm1
leave
ret
                                   
readlen8:       
        ;Prepare data
       
        VMOVNTDQA xmm0, [data1]      
        VMOVNTDQA xmm1, [data2]
             
        ;Get multiplier       
        VMOVNTDQA xmm2, [edi]
        VMOVNTDQA xmm3, [edi+16]     
        
        ;Multiply
        pmullw xmm0,xmm2 
        pmullw xmm1,xmm3

       
        
        ;Add
        PHADDD    xmm0,xmm0
        PHADDD    xmm1,xmm1
        PHADDD    xmm0,xmm0
        PHADDD    xmm1,xmm1
        
        movd eax, xmm0
        movd ebx, xmm1
        add eax, ebx        
leave
ret
readlen12:
          movaps xmm0,[data1]
          movaps xmm1,[data2]
          movaps xmm2,[data3]
          movaps xmm3,[edi]
          movaps xmm4,[edi+16]
          movaps xmm5,[edi+32]
          
          pmullw xmm0,xmm3
          pmullw xmm1,xmm4
          pmullw xmm2,xmm5
        
          PHADDD    xmm0,xmm0
          PHADDD    xmm1,xmm1
          PHADDD    xmm2,xmm2
          PHADDD    xmm0,xmm0
          PHADDD    xmm1,xmm1        
          PHADDD    xmm2,xmm2
                
        movd eax, xmm0
        movd ebx, xmm1
        movd ecx, xmm2
        add eax,ecx
        add eax, ebx 
leave
ret


_avxprerank:
        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov eax,  [ebp + 8]       ;size
        mov esi,  [ebp + 12]       ;string input
        mov edi,  [ebp + 16]       ;destination array
       
        
repeatavx:
        PREFETCHT0 [esi]
        PREFETCHT0 [edi]   
                     
        cmp eax,0
        je preavxdone
        
        cmp byte [esi],'A'
        je isA
        cmp byte [esi],'C'
        je isC
        cmp byte [esi],'G'
        je isG
        cmp byte [esi],'T'
        je isT
        
isA:        
        mov byte [edi],0
        sub eax,1
         add edi,4
        inc esi
        jmp repeatavx
isC:        
        mov byte [edi],1
        sub eax,1
        add edi,4
        inc esi
        jmp repeatavx
isG:        
        mov byte [edi],2
        sub eax,1
        add edi,4
        inc esi
        jmp repeatavx
isT:        
        mov byte [edi],3
        sub eax,1
        add edi,4
        inc esi
        jmp repeatavx



preavxdone:
leave
ret


_avxthres:

        push ebp           ;create stack frame
        mov ebp, esp       ;save stack
        push ecx
        push esi
        xor eax,eax
        mov eax,  [ebp + 8]       ;threshold
        ;prefetch
        PREFETCHT0 [threscpy]
        PREFETCHT0 [threscpy+4]
        PREFETCHT0 [threscpy+8]
        PREFETCHT0 [threscpy+12] 
        PREFETCHT0 [threscpy+16]  
        PREFETCHT0 [threscpy+20]  
        PREFETCHT0 [threscpy+24]   
        PREFETCHT0 [threscpy+28] 
        mov esi,  [ebp + 12]       ;block scores
        mov edi,  [ebp + 16]       ;destination var
        mov ebx,  [ebp+20]         ;nblk
        sub ebx,1
        mov dword [blkcnt],ebx
       
       ;preprocess    
       mov dword [threscpy],eax 
       mov dword [threscpy+4],eax 
       mov dword [threscpy+8],eax
       mov dword [threscpy+12],eax 
       mov dword [threscpy+16],eax  
       mov dword [threscpy+20],eax   
       mov dword [threscpy+24],eax    
       mov dword [threscpy+28],eax       
       mov dword [esidum],0 
      ;compare scores with thold
      mov ebx,0
loopthres:      
      cmp dword ebx,[blkcnt]
      je done
        PREFETCHT0 [esidum]
        PREFETCHT0 [threscpy]
        PREFETCHT0 [threscpy+16]
        
         mov esi,  [ebp + 12] 
         mov dword eax,[esidum]
         add esi,eax        ;proper index
               
        movups xmm2, [esi]      
        movups xmm3, [esi+16] 

         mov esi,  [ebp + 12] 
         mov dword eax,[esidum]
         add eax,4
         add esi,eax        ;proper index, blk+1
        
        PREFETCHT0 [threscpy+32]
        movups xmm6,[esi]   
        movups xmm7,[esi+16]                                                                                                         
        VPADDQ xmm2,xmm6
        VPADDQ xmm3,xmm7
        movups xmm4, [threscpy]
        movups xmm5, [threscpy+16] 
        PREFETCHT0 [threscpy+48]      

        cmpps xmm2,xmm4,5
        cmpps xmm3,xmm5,5
        
        movups [edi], xmm2
        movups [edi+16],xmm3 

       
        add dword [esidum],32
        add edi,32
        add ebx,1   
                    
        jmp loopthres
done:      
                           
leave
ret