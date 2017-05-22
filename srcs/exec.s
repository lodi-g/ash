; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

global process_exec:function

section .text:
  ; libc
  extern fork
  extern printf
  extern execvp
  extern waitpid
  extern perror
  extern exit

  ; int process_exec(char *file, char **argv)
  process_exec:
    enter 0x0, 0x0

    sub rsp, 0x30                                ; expanding stack
    mov QWORD [rbp - 0x1c], rdi                  ; (char *)file
    mov QWORD [rbp - 0x14], 0x0                  ; (char **)argv
    mov DWORD [rbp - 0x10], 0x0                  ; wstatus

    call fork                                    ; fork()
    mov r12, rax
    cmp rax, 0x0
    je process_exec.child
    jmp process_exec.parent

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

      mov rdi, [rbp - 0x10]                      ; wstatus
      mov rsi, [rbp - 0x1c]                      ; file
      call process_exited

    add rsp, 0x30                                ; restoring old stack size

    leave
    ret


  ; int process_exited(int wstatus, char *file);
  process_exited:
    mov rax, rdi

    and rax, 0x7f                                ; WIFEXITED(status)

    test rax, rax                                ; exited normally?
    je process_exited.normally
    jmp process_exited.signal

    .normally:
      mov rax, rdi                               ; WEXITSTATUS(wstatus)
      and rax, 0xff00                            ;   wstatus & 0xff00
      sar rax, 0x8                               ;   wstatus >> 8

      push rax                                   ; Saving to return it

      mov rdi, exited                            ; "ash: %s exited with signal %d.\n"
      mov rsi, [rbp - 0x1c]                      ;   Process name
      movzx rdx, al                              ;   Exit status

      xor rax, rax                               ; Not using SSE registers

      call printf

      pop rax                                    ; Returning last value

      jmp process_exited.leave

    .signal:
      mov rax, rdi                               ; WTERMSIG(wstatus)
      and rax, 0x7f                              ;   wstatus & 0x7f

      push rax                                   ; Saving to return it

      mov rdi, signaled                          ; "ash: %s terminated by signal %d.\n"
      mov rsi, [rbp - 0x1c]                      ;   Process name
      mov rdx, rax                               ;   Signal number

      xor rax, rax                               ; Not using SSE registers

      call printf

      pop rax                                    ; Returning signal number
      add rax, 0x80                              ; + 128

      jmp process_exited.leave

    .leave:
      ret


section .data:
  signaled: db "ash: %s terminated by signal %d.", 10, 0
  exited: db "ash: %s exited with status %d.", 10, 0
