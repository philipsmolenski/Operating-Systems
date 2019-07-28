global _start

   SYS_EXIT  equ 60
   SYS_OPEN   equ 2
   NO_ATTACK_NUM   equ 68020
   BUFF_SIZE   equ 4096
   GOOD_SEQUENCE   equ 0110_1000_0000_0010_0000b  ; sekwencja, która na kolejnych czrórkach bitów 
                                                  ; ma liczby 6, 8, 0, 2, 0
   section .rodata

   section .bss align=16
      buffer resb BUFF_SIZE
    
   section .text

exit_error:
   mov   rax, SYS_EXIT
   mov   rdi, 1
   syscall

exit_ok:
   mov   rax, SYS_EXIT
   xor   rdi, rdi
   syscall

_start:
   cmp   qword [rsp], 2
   jne   exit_error
   mov   rdi, [rsp + 16]
   call   open_file
   xor   r8, r8                  ; tu pamiętamy, czy pojawiła się liczba z zakresu 68021-2^31 i sekwencja 6 8 0 2 0
   xor   r10, r10                ; tu trzymamy sumę liczb mod 2^32
   xor   r15, r15                ; na kolejnych czwórkach bitów tego rejestru trzymamy ostatnie 5 liczb
   mov   rsi, buffer
   jmp   read_file

open_file:
   mov   rax, 2                  ; otwieranie pliku
   xor   rsi, rsi                ; read-only
   syscall
   test   rax, rax               ; sprawdzamy, czy otwarty pomyślnie
   js   exit_error
   mov   rdi, rax
   ret

read_file:                  
   xor   rax, rax
   mov   rdx, BUFF_SIZE
   syscall
   cmp   rax, 0
   jl   exit_error               ; błąd w czytaniu
   je   finish
   mov   rdx, rax                ; liczbę wczytanych bajtów trzymamy w rdx
   xor   r9, r9                  ; w r9 trzymamy pozycję w buforze, z której zczytujemy liczbę

read_number:
   cmp   r9, rdx                 ; sprawdzamy, czy doszliśmy do końca bufora
   je   read_file
   mov   rax, rdx
   sub   rax, r9
   cmp   rax, 4                  ; sprawdzamy, czy mamy co najmniej 4 bity do wczytania
   jl   exit_error               ; jeśli nie, to plik ma złą długość
   mov   eax, [buffer + r9]      ; wpp wczytujemy liczbę z bufora
   add   r9, 4

process_number:
   bswap   eax
   add   r10, rax                ; zliczamy sumę w r10
   cmp   eax, NO_ATTACK_NUM      ; sprawdzamy, czy wczytana liczba nie jest równa 68020
   je   exit_error
   jg   check_big_number         ; jeśli jest większa, to zaznaczamy, że taka się już pojawiła
   jmp   sequence 


check_big_number:
   or   r8, 2                    ; jeżeli wystąpiła liczba większa niż 68020 to zaznaczamy w r8 na przedostatnim bicie

sequence:                        ; tu sprawdzamy, czy wystąpiła sekwencja 6, 8, 0, 2, 0
    cmp   rax, 8                 ; dalej będziemy zakładać, że wczytana liczba mieści się na 4 bitach   
    jg   clear_sequence          ; jeśli liczba jest większa od 8 to nie będzie ona zawarta w dobrej sekwencji, rejestr można wyzerować
    shl   r15, 48           
    shr   r15, 44                ; w przeciwnym wypadku przesuwanmy rejestr r15 o 4 miejsca w lewo...
    add   r15, rax               ; ... i na powstałych 4 bitach zapisujemy wczytaną liczbę  
    cmp   r15, GOOD_SEQUENCE     
    je   check_sequence
    jmp  read_number

clear_sequence:
    xor   r15, r15               ; czyszczenie rejestru przechowującego sekwencję
    jmp   read_number

check_sequence:
    or   r8, 1                   ; jeżeli wystąpiła sekwencja 6 8 0 2 0 to zaznaczamy w r8 na ostatnim bicie
    jmp   read_number

finish:
    cmp   r10d, NO_ATTACK_NUM    ; sprawdzamy sumę mod 2^32
    jne   exit_error
    cmp   r8, 3                  ; sprawdzamy, czy wystąpiła liczba z zakresu 68021 - 2^31 oraz sekwencja 6 8 0 2 1
    jne   exit_error         
    jmp   exit_ok    
