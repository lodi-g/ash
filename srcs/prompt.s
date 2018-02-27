; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%include "def.inc"

global prompt:function

section .data
  ps1: db "> ", 0


section .text
  ; readline
  extern readline
  extern add_history

  ; libc
  extern isatty
  extern read
  extern printf
  extern strlen
  extern calloc

  prompt:
    mov rdi, STDIN_FILENO
    call isatty                                  ; isatty(STDIN_FILENO)

    cmp rax, 0x1                                 ; isatty?
    jne prompt.getline
    jmp prompt.readline

    .readline:
      mov rdi, ps1
      call readline                              ; readline(ps1)

      push rax

      cmp rax, 0x0
      je prompt.leave

      mov rdi, rax
      call add_history                           ; add_history(buffer)

      jmp prompt.leave

    .getline:
      mov rdi, 0x400
      mov rsi, 0x1
      call calloc                                ; calloc(1024, sizeof(char))

      mov r12, rax                               ; saving our 'buf' pointer

      mov rdi, STDIN_FILENO
      mov rsi, rax
      mov rdx, 0x3e8
      call read                                  ; read(STDIN_FILENO, buf, 1000)

      cmp rax, 0x0                               ; Read zero bytes?
      je prompt.end

      mov rdi, r12
      call strlen

      mov rdx, r12
      add rdx, rax
      sub rdx, 0x1
      mov BYTE [rdx], 0x0                        ; buffer[strlen(buffer) - 1] = 0

      push r12
      jmp prompt.leave

    .end:
      mov rax, 0x0                               ; Returning NULL
      ret

    .leave:
      pop rax                                    ; Returning buffer
      ret
