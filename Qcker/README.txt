-Change dir and pos file depending on q size and length of read reference
-Change seedsize variable accordingy  

Copy in command prompt:


nasm -fwin32 -o getinst.o getinst.asm
nasm -fwin32 -o newcheckblkasm.o newcheckblkasm.asm
nasm -fwin32 -o avxrank.o avxrank.asm
nasm -fwin32 -o strings.o strings.asm
nasm -fwin32 -o checkblk1.o checkblk1.asm
nasm -fwin32 -o index1.o index1.asm

nasm -fwin32 -o getinst2.o getinst2.asm
nasm -fwin32 -o newcheckblkasm2.o newcheckblkasm2.asm
nasm -fwin32 -o avxrank2.o avxrank2.asm
nasm -fwin32 -o strings2.o strings2.asm
nasm -fwin32 -o checkblk2.o checkblk2.asm
nasm -fwin32 -o index2.o index2.asm
gcc -c filterc3.c
gcc index1.o filterc3.o   checkblk2.o strings.o strings2.o index2.o checkblk1.o avxrank.o avxrank2.o newcheckblkasm.o newcheckblkasm2.o getinst.o getinst2.o -o filterc3.out  -lpthreadGC2
filterc3.out

