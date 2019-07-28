global test_reg

extern euron

section .text

test_reg:
	cmp   rdi, 1
	je   test_rbx

	cmp   rdi, 2
	je   test_rbp

	cmp   rdi, 3
	je   test_r12

	cmp   rdi, 4
	je   test_r13

	cmp   rdi, 5
	je   test_r14

	cmp   rdi, 6
	je   test_r15

ret_rbx:
	pop rbx
	xor rax, rax
	ret

ret_rbp:
	pop rbp
	xor rax, rax
	ret

ret_rsp:
	pop rsp
	xor rax, rax
	ret

ret_r12:
	pop r12
	xor rax, rax
	ret

ret_r13:
	pop r13
	xor rax, rax
	ret	

ret_r14:
	pop r14
	xor rax, rax
	ret

ret_r15:
	pop r15
	xor rax, rax
	ret	

test_rbx:
	push  rbx
	mov   rbx, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   rbx, 2137
	je    ret_rbx
	mov   rax, 1
	pop   rbx
	ret

test_rbp:
	push  rbp
	mov   rbp, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   rbp, 2137
	je    ret_rbp
	mov   rax, 1
	pop   rbp
	ret

test_r12:
	push  r12
	mov   r12, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   r12, 2137
	je    ret_r12
	mov   rax, 1
	pop   r12
	ret

test_r13:
	push  r13
	mov   r13, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   r13, 2137
	je    ret_r13
	mov   rax, 1
	pop   r13
	ret

test_r14:
	push  r14
	mov   r14, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   r14, 2137
	je    ret_r14
	mov   rax, 1
	pop   r14
	ret	

test_r15:
	push  r15
	mov   r15, 2137
	mov   rdi, rsi
	mov   rsi, rdx
	call   euron
	cmp   r15, 2137
	je    ret_r15
	mov   rax, 1
	pop   r15
	ret
