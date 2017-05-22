; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

global main

section .text
  ; libc
  extern printf

  ; ash
  extern prompt_display
  extern process_exec

  main:
    enter 0x0, 0x0

    sub rsp, 0x14
    mov QWORD [rbp - 0x8], 0x0                   ; readline return value
    mov DWORD [rbp - 0x10], 0x0                  ; last return value

    .loop:
      call prompt_display

      mov [rbp - 0x8], rax

      cmp QWORD [rbp - 0x8], 0x0                 ; EOF / ^D
      je main.leave

      xor rax, rax                               ; Debug
      mov rdi, line_info
      mov rsi, [rbp - 0x8]
      call printf

      mov rdi, [rbp - 0x8]                       ; readline return value
      call process_exec
      mov [rbp - 0x10], rax

      jmp main.loop

    .leave:
      mov rax, [rbp - 0x10]                      ; main returns last return value
      add rsp, 0x14

      leave
      ret


section .data
  line_info: db "Input: '%s'", 10, 0
