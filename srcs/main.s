; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

global main

%include "def.inc"

section .text
  ; libc
  extern printf
  extern exit

  ; ash
  extern prompt_display
  extern process_exec
  extern parse_raw

  main:
    prologue

    sub rsp, 0x20
    mov QWORD [rbp - 0x8], 0x0                   ; binary
    mov QWORD [rbp - 0x10], 0x0                  ; arguments
    mov DWORD [rbp - 0x18], 0x0                  ; last return value

    .loop:
      call prompt_display

      cmp rax, 0x0                               ; EOF / ^D
      je main.leave

      mov [rbp - 0x8], rax
      
      mov rdi, [rbp - 0x8]
      mov rsi, [rbp - 0x10]
      call parse_raw

      mov rdi, [rbp - 0x8]                       ; binary
      mov rsi, [rbp - 0x10]                      ; arguments
      call process_exec
      mov [rbp - 0x18], rax

      jmp main.loop

    .leave:
      mov rax, [rbp - 0x18]                      ; main returns last return value
      add rsp, 0x20

      epilogue
      ret


section .data
  line_info: db "Input: '%s'", 10, 0
