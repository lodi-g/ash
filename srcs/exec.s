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
    push rbp
    mov rbp, rsp                                 ; function prologue

    sub rsp, 0x30                                ; expanding stack
    mov QWORD [rbp - 0x1c], rdi                  ; (char *)file
    mov QWORD [rbp - 0x14], rsi                  ; (char **)argv
    mov DWORD [rbp - 0x10], 0x0                  ; wstatus

    call fork                                    ; fork()
    mov r12, rax
    cmp rax, 0x0
    je process_exec.child
    jmp process_exec.parent

    .child:
      mov rdi, [rbp - 0x1c]
      lea rsi, [rbp - 0x1c]

      call execvp                                ; execvp(file, argv);

      mov rdi, [rbp - 0x1c]
      call perror                                ; perror(file)
      mov rdi, 0x1
      call exit                                  ; exit(1)

    .parent:
      mov rdi, r12
      lea rsi, [rbp - 0x10]
      mov rdx, 0x0
      call waitpid                               ; waitpid(pid, &wstatus, 0)

      mov rdi, [rbp - 0x10]
      mov rsi, [rbp - 0x1c]
      call process_exited                        ; process_exited(wstatus, file)

    add rsp, 0x30                                ; restoring old stack size

    mov rsp, rbp                                 ; function epilogue
    pop rbp

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

      movzx rax, al                              ; Returning WEXITSTATUS(wstatus)

      jmp process_exited.leave

    .signal:
      mov rax, rdi                               ; WTERMSIG(wstatus)
      and rax, 0x7f                              ;   wstatus & 0x7f

      push rax                                   ; Saving to return it

      lea rdi, [signals]                         ; signals[wstatus * sizeof(char *)]
      imul rax, 0x8
      add rdi, rax
      mov rdi, [rdi]

      xor rax, rax                               ; Not using SSE registers

      call printf                                ; printf(signal)

      pop rax                                    ; Returning signal number
      add rax, 0x80                              ;   + 128

      jmp process_exited.leave

    .leave:
      ret


section .data:
  ; Signal list
  null: db 0
  hup: db "Hangup", 10, 0
  int: db "Interupt", 10, 0
  quit: db "Quit", 10, 0
  ill: db "Illegal hardware instruction", 10, 0
  trap: db "Trace trap", 10, 0
  abrt: db "Abort", 10, 0
  bus: db "Bus error", 10, 0
  fpe: db "Floating point exception", 10, 0
  kill: db "Filled", 10, 0
  usr1: db "User signal 1", 10, 0
  segv: db "Segmentation Fault", 10, 0
  usr2: db "User signal 2", 10, 0

  signals: dq null, hup, int, quit, ill, trap, abrt, bus, fpe, kill, usr1, segv, usr2
