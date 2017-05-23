; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

global process_exec:function

%include "def.inc"
%include "exec.inc"

section .text
  ; libc
  extern fork
  extern printf
  extern execvp
  extern waitpid
  extern perror
  extern exit
  extern wordexp

  ; int process_exec(char *file, char **argv)
  process_exec:
    prologue

    sub rsp, 0x20                                ; expanding stack
    mov QWORD [rbp - 0x1c], rdi                  ; we.wordv
    mov DWORD [rbp - 0x10], 0x0                  ; wstatus

    call fork                                    ; fork()
    mov r12, rax
    cmp rax, 0x0
    je process_exec.child
    jmp process_exec.parent

    .child:
      mov rdi, [rbp - 0x1c]
      mov rdi, [rdi]
      mov rsi, [rbp - 0x1c]
      call execvp                                ; execvp(*we.wordv, we.wordv);

      mov rdi, [rbp - 0x1c]
      mov rdi, [rdi]
      call perror                                ; perror(file)
      mov rdi, 0x1
      call exit                                  ; exit(1)

    .parent:
      mov rdi, r12
      lea rsi, [rbp - 0x10]
      mov rdx, 0x0
      call waitpid                               ; waitpid(pid, &wstatus, 0)

      mov rdi, [rbp - 0x10]
      call process_exited                        ; process_exited(wstatus, file)

    add rsp, 0x30                                ; restoring old stack size

    epilogue
    ret


  ; int process_exited(int wstatus, char *file);
  process_exited:
    mov rax, rdi
    WIFEXITED rax                                ; see 'exec.inc' for all W* macros

    test rax, rax                                ; exited normally?
    je process_exited.normally
    jmp process_exited.signal

    .normally:
      mov rax, rdi
      WEXITSTATUS rax
      movzx rax, al                              ; Returning WEXITSTATUS(wstatus)

      jmp process_exited.leave

    .signal:
      push rdi
      push rdi
      mov rax, rdi                               ; WTERMSIG(wstatus)
      WTERMSIG rax

      lea rdi, [signals]                         ; signals[wstatus * sizeof(char *)]
      imul rax, 0x8
      add rdi, rax
      mov rdi, [rdi]

      xprintf

      pop rdx                                    ; wstatus
      WCOREDUMP rdx

      cmp rdx, 0x0
      jne process_exited.core_dumped

      mov rdi, endl
      xprintf

      pop rax                                    ; Returning signal number
      add rax, 0x80                              ;   + 128

      jmp process_exited.leave

    .core_dumped:
      mov rdi, cdump
      xprintf                                    ; printf("(core dumped)")

      pop rax
      add rax, 0x80
      jmp process_exited.leave

    .leave:
      ret
