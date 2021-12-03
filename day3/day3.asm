SYS_read equ 0
SYS_write equ 1
SYS_exit equ 60
stdin equ 0
stdout equ 1

global _start

_start:

.handle_line:
    xor ebx, ebx
.inner:
    call getchar
    jc .eof
    cmp al, 10
    je .eol
    sub al, "0"
    movzx eax, al
    add [summing_buffer+rbx], eax
    add ebx, 4
    jmp .inner
.eol:
    test ebx, ebx
    jz .handle_line
    shr ebx, 2
    mov [line_length], ebx
    inc dword[num_lines]
    jmp .handle_line
.eof:
    test ebx, ebx
    jz .sum_done
    inc dword[num_lines]
.sum_done:

    mov ecx, [line_length]
    mov rsi, summing_buffer
    mov ebx, [num_lines]
    xor edx, edx
.combine:
    add edx, edx
    lodsd
    add eax, eax
    cmp eax, ebx
    jbe .zero
    inc edx
.zero:
    loop .combine

    mov eax, 1
    mov ecx, [line_length]
    shl eax, cl
    sub eax, edx
    dec eax
    mul edx

    call print_int
    mov al, 32
    call putchar

    mov edi, 0
    mov eax, SYS_exit
    syscall

; returns a character in AL
getchar:
    mov rsi, [bufpos]
    cmp rsi, [bufend]
    jae .refill
    lodsb
    mov [bufpos], rsi
    clc
    ret
.eof:
    stc
    ret
.refill:
    mov eax, SYS_read
    mov rdi, stdin
    mov rsi, input_buffer
    mov rdx, bufsize
    syscall
    test rax, rax
    jz .eof

    add rax, input_buffer
    mov [bufend], rax
    mov qword [bufpos], input_buffer
    jmp getchar

; prints EAX in decimal
print_int:
    mov ebx, 10
    xor edx, edx
    div ebx
    test eax, eax
    jz .skip
    push rdx
    call print_int
    pop rdx
.skip:
    mov eax, edx
    add al, "0"
putchar:
    push rax
    mov eax, SYS_write
    mov rdi, stdout
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rax
    ret


section .bss
bufsize equ 1024
input_buffer: resb bufsize
.end:

summing_buffer: resd 32
num_lines: resd 1
line_length: resd 1

section .data
bufpos: dq input_buffer
bufend: dq input_buffer
