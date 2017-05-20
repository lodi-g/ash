global main

section .text
  ; libc
  extern printf
  extern exit

  ; ash
  extern prompt_display
  extern exec

  main:
    call prompt_display

    cmp rax, 0x0             ; EOF / ^D
    je main.leave

    mov rdi, line_info       ; Debugging
    push rax
    push rax
    pop rsi
    mov rax, 0x0
    call printf

    pop rdi                  ; Executing return of prompt_display
    call exec

    .leave:
      mov rdi, 0x0             ; exit(0)
      call exit


section .data
  line_info: db "Input: '%s'", 10, 0
  progname: db "./retst", 0
