global exec:function

section .text:
  ; libc
  extern fork
  extern printf
  extern execvp
  extern waitpid
  extern perror
  extern exit

  exec:
    enter 0x0, 0x0

    sub rsp, 0x30
    mov QWORD [rbp - 0x1c], rdi                  ; (char *)file
    mov QWORD [rbp - 0x14], 0x0                  ; (char **)argv
    mov DWORD [rbp - 0x10], 0x0                  ; wstatus

    call fork                                    ; fork()
    mov r12, rax
    cmp rax, 0x0
    je exec.child
    jmp exec.parent

    .child:                                      ; We're in the child
      mov rdi, [rbp - 0x1c]
      lea rsi, [rbp - 0x1c]

      call execvp                                ; execvp(char *, char **);

      mov rdi, [rbp - 0x1c]
      call perror
      mov rdi, 0x1
      call exit

    .parent:
      mov rdi, r12
      lea rsi, [rbp - 0x10]
      mov rdx, 0x0
      call waitpid                               ; waitpid(pid, &wstatus, 0)

      mov rax, [rbp - 0x10]
      and rax, 0x7f                              ; WIFEXITED(status)

      test rax, rax                              ; exited normally?
      je exec.exited_normally
      jmp exec.exited_signal

    .exited_normally:
      mov rax, [rbp - 0x10]                      ; WEXITSTATUS(wstatus)
      and rax, 0xff00
      sar rax, 0x8

      mov rdi, exited                            ; "ash: %s exited with signal %d.\n"
      mov rsi, [rbp - 0x1c]                      ; Process name
      movzx rdx, al                              ; Exit status

      xor rax, rax                               ; Not using SSE registers

      call printf
      jmp exec.leave

    .exited_signal:
      mov r8, [rbp - 0x10]                       ; WTERMSIG(status)
      and r8, 0x7f

      mov rdi, signaled                          ; "ash: %s terminated by signal %d.\n"
      mov rsi, [rbp - 0x1c]                      ; Process name
      mov rdx, r8                                ; Signal number

      xor rax, rax                               ; Not using SSE registers

      call printf
      jmp exec.leave

    .leave:
      add rsp, 0x30
      leave
      ret


section .data:
  signaled: db "ash: %s terminated by signal %d.", 10, 0
  exited: db "ash: %s exited with status %d.", 10, 0
