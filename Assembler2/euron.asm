global euron

extern get_value, put_value

section .bss align=16
    sem: resq N*N   ;tablica semaforow 
    num: resq N     ;tablca wartosci, ktore dany euron ma do przekazania innemu

section .text


euron:
  push  rbp  
  mov   rbp, rsp  
  push r15        ;obecna pozycja z wczytywanego napisu
  push r14        ;licznik wysokosci stosu
  push r13        ;wczytany napis
  push r12        ;numer euronu
  push rbx
  mov r12, rdi
  mov r13, rsi


  mov r15, -1
  xor r14, r14

loop:
  xor rdx, rdx
  add r15, 1

  mov   dl, [r13 + r15]
  cmp dl, 0
  je end
  cmp   dl, '+'
  je _add
  cmp   dl, '*'
  je _mul
  cmp   dl, '-'
  je _sub
  cmp   dl, 'n'
  je _n
  cmp   dl, 'B'
  je _B
  cmp   dl, 'C'
  je _C
  cmp   dl, 'D'
  je _D
  cmp   dl, 'E'
  je _E
  cmp   dl, 'G'
  je _G
  cmp   dl, 'P'
  je _P
  cmp   dl, 'S'
  je _S
  jmp liczba

_add:
  pop r8
  pop r9
  add r8, r9
  push r8
  dec r14
  jmp loop

_mul:
  pop r8
  pop r9
  imul r8, r9
  push r8
  dec r14
  jmp loop

_sub:
  pop r8
  xor r9, r9
  sub r9, r8
  push r9
  jmp loop

liczba:
  mov r8, rdx
  sub r8, 48
  push r8
  inc r14
  jmp loop

_n:
  push r12
  inc r14
  jmp loop

_B:
  pop r8
  pop r9
  cmp r9, 0
  je dontMove
  add r15, r8
  dontMove:
  push r9
  dec r14
  jmp loop

_C:
  pop r8
  dec r14
  jmp loop

_D:
  pop r8
  push r8
  push r8
  inc r14
  jmp loop

_E:
  pop r8
  pop r9
  push r8
  push r9
  jmp loop

_G:
  mov rdi, r12
  push rbx
  mov rbx, rsp
  and rsp, -16
  add rsp, 1
  call get_value
  mov rsp, rbx
  pop rbx
  push rax
  inc r14
  jmp loop

_P:
  pop r8
  mov rdi, r12
  mov rsi, r8
  call put_value
  dec r14
  jmp loop

sem_open:
  mov rax, 1
  mov r9, r12
  imul r9, N
  add r9, r8
  imul r9, 8
  xchg rax, [sem + r9]
  cmp rax, 0
  jne sem_open
  ret


sem_close:
  mov rax, 0
  mov r9, r8
  imul r9, N
  add r9, r12
  imul r9, 8
  xchg rax, [sem + r9]
  cmp rax, 1
  jne sem_close
  ret

_S:
  pop r8                ;numer euronu na ktory czekamy
  pop r9
  mov r11, r12
  imul r11, 8
  mov [num + r11], r9
  call sem_open
  call sem_close
  mov r11, r8
  imul r11, 8
  mov r10, [num + r11]
  push r10
  dec r14
  call sem_open
  call sem_close
  jmp loop


end:
  pop rax
  loop2:
  pop rdx
  dec r14
  cmp r14, 0
  jne loop2
  mov rdx, rbx
  pop r12
  pop r13
  pop r14
  pop r15
  mov rsp, rbp
  pop rbp
  ret