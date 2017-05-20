global prompt_display:function

section .text
  ; readline
  extern readline
  extern add_history

  ; libc
  extern isatty

  prompt_display:
    mov rdi, 0x0
    call isatty

    cmp rax, 0x1             ; isatty?
    jne prompt_display.leave

    mov rdi, prompt          ; print prompt
    call readline

    mov r12, rax             ; save buf

    mov rdi, rax
    call add_history

    mov rax, r12             ; restore buf

    .leave:
      ret


section .data
  prompt: db "> ", 0
