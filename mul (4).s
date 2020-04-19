SYSEXIT = 1
SYSREAD = 3
SYSWRITE = 4
STDIN = 0
STDOUT = 1
EXIT_SUCCESS = 0

MULTIPLICAND=8
MULTIPLIER=8
FINAL=512
LAST_LOOP=1


.align 64

.macro exit code
movl $SYSEXIT, %eax
movl \code, %ebx
int $0x80
.endm

.macro write str, len
movl $SYSWRITE, %eax
movl $STDOUT, %ebx
movl \str, %ecx
movl \len, %edx
int $0x80
.endm


.data
number1:
 .space MULTIPLICAND
number2:
 .space MULTIPLIER
return:
 .zero FINAL


.text
.global _start
_start:

read:
movl $SYSREAD, %eax
movl $STDIN, %ebx
movl $number1, %ecx
movl $MULTIPLICAND, %edx
int $0x80

movl $SYSREAD, %eax
movl $STDIN, %ebx
movl $number2, %ecx
movl $MULTIPLIER, %edx
int $0x80

cmpl $0, %eax
je ex
movl $-1, %edi #licznik mnoznej number1
movl $0, %ebx #rejestr na przechowywanie przeniesienia z eax 

multiplicand: #petla mnoznej
incl %edi #petla mnoznej 
cmpl $(MULTIPLICAND/4), %edi
jge ex

movl %edi, %esi #petla mnoznika
movl $0, %ebp #licznik do pobierania kolejnych cyfr mnoznika
movl number1(,%edi,4), %ecx
clc
pushf

multiplier: #petla mnoznika
cmpl $(MULTIPLICAND/4),%ebp
jge multiplicand 

movl number2(,%ebp,4), %eax
mul %ecx

cmpl $LAST_LOOP, %ebp
jge test # musi byc nie tylko ostatnia petla mnoznej ale i mnoznika

sum_up:
popf
adcl %eax, return(,%esi,4)
pushf
incl %esi
cmp $1, %ebx
je set_CF
clc
jmp add 

add:
addl %edx, return(,%esi,4)
jc save_CF
movl $0, %ebx
jmp dalej

dalej:
incl %ebp
jmp multiplier

test:
cmpl $LAST_LOOP, %edi
jge last_one
jmp sum_up

set_CF:
stc
jmp add

save_CF:
movl $1, %ebx
jmp dalej

last_one: #ostatnia petla mnoznej gdyby na ostatnim dodawaniu wyszlo przenisienie
addl %eax, return(,%esi,4)
incl %esi
cmpl $1, %ebx
je with_flag
adcl %edx, return(,%esi,4)
adcl $0, return(,%esi,4)
jmp ex

with_flag:
stc
adcl %edx, return(,%esi,4)
adcl $0,return (,%esi,4) 
jmp ex

ex:
write $return, $32
exit $0
