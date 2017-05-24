; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%include "def.inc"

global main:function

section .text
  ; libc
  extern printf
  extern exit
  extern wordexp

  ; ash
  extern prompt
  extern process_exec
  extern is_builtin

  main:
    prologue

    sub rsp, 0x20
    mov QWORD [rbp - 0x8], 0x0                   ; raw buffer
    mov DWORD [rbp - 0x18], 0x0                  ; last return value

    .loop:
      call prompt

      cmp rax, 0x0                               ; EOF / ^D
      je main.leave

      mov [rbp - 0x8], rax                       ; Save buffer to the stack

      movzx rdx, BYTE [rax]
      movsx rdx, dl
      cmp rdx, 0x0                               ; if (*buffer == 0)
      je main.loop

      mov rdi, [rbp - 0x8]
      lea rsi, [we]
      xor rdx, rdx
      call wordexp

      mov rdi, [we + 0x8]
      call is_builtin                            ; is_builtin(we.wordv)

      cmp rax, 0x0
      je main.loop                               ; it was a builtin

      mov rdi, [we + 0x8]
      call process_exec

      mov [rbp - 0x18], rax                      ; save return status to the stack

      jmp main.loop

    .leave:
      mov rax, [rbp - 0x18]                      ; main returns last return value
      add rsp, 0x20

      epilogue
      ret


section .data
; wordexp_t we
  we:
    istruc wordexp_t
      at we_wordc, dq 0
      at we_wordv, dq 0
      at we_offs, dq 0
    iend
