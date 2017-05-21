global main

section .text
  ; libc
  extern printf
  extern exit

  ; ash
  extern prompt_display
  extern exec

  main:
    push rbp
    mov rbp, rsp

    sub rsp, 0x10
    mov QWORD [rbp - 0x8], 0x0

    .loop:
      call prompt_display

      mov [rbp - 0x8], rax

      cmp QWORD [rbp - 0x8], 0x0   ; EOF / ^D
      je main.leave

      xor rax, rax           ; Debugging
      mov rdi, line_info
      mov rsi, [rbp - 0x8]
      call printf

      mov rdi, [rbp - 0x8]   ; Executing return of prompt_display
      call exec

      jmp main.loop

    .leave:
      mov rdi, 0x0           ; exit(0)
      call exit


section .data
  line_info: db "Input: '%s'", 10, 0
  progname: db "./retst", 0
