; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%include "def.inc"
%include "builtins.inc"

global is_builtin:function

section .data
  HOME: db "HOME", 0
  no_home: db "cd: No home directory accessible.", 10, 0


section .text
  ; libc
  extern strcmp
  extern chdir
  extern dprintf
  extern perror
  extern getenv

  is_builtin:
    prologue

    xor rcx, rcx

    sub rsp, 0x40
    mov QWORD [rbp - 0x8], rdi
    mov QWORD [rbp - 0x10], builtins
    mov rcx, [builtins_nb]
    mov QWORD [rbp - 0x18], rcx
    mov QWORD [rbp - 0x20], builtins_fptr

    xor rcx, rcx

    .loop:
      cmp rcx, [rbp - 0x18]
      je is_builtin.not_found

      mov rdi, [rbp - 0x8]
      mov rdi, [rdi]

      mov rax, rcx
      imul rax, 0x8
      mov rsi, [rbp - 0x10]
      add rsi, rax
      mov rsi, [rsi]

      push rcx

      call strcmp                                ; strcmp(rdi, builtins[rcx * sizeof(char *)])

      pop rcx

      cmp rax, 0x0
      je is_builtin.found

      inc rcx
      jmp is_builtin.loop

    .not_found:
      mov rax, 0x1
      jmp is_builtin.leave

    .found:
      mov rax, rcx
      imul rax, 0x8
      mov rbx, [rbp - 0x20]
      add rbx, rax
      mov rbx, [rbx]
      mov rdi, [rbp - 0x8]
      call rbx                                   ; call the function pointer corresponding to the builtin
      mov rax, 0x0
      jmp is_builtin.leave

    .leave:
      add rsp, 0x40
      epilogue

    ret


  bi_cd:
    prologue

    sub rsp, 0x10
    mov QWORD [rbp - 0x8], rdi

    add rdi, 0x8
    mov rdi, [rdi]
    cmp rdi, 0x0                                 ; No arguments = cd ~
    je bi_cd.home

    call chdir                                   ; chdir(rdi)
    cmp rax, 0x0
    jne bi_cd.err
    jmp bi_cd.end

    .home:
      mov rdi, HOME
      call getenv                                ; getenv("HOME")

      cmp rax, 0x0
      je bi_cd.home_err

      mov rdi, rax
      call chdir                                 ; chdir(getenv("HOME"))
      cmp rax, 0x0
      jne bi_cd.err
      jmp bi_cd.end

    .home_err:
      mov rdi, STDERR_FILENO
      mov rsi, no_home
      xor rax, rax
      call dprintf                               ; dprintf(2, "No home...");

      jmp bi_cd.end

    .err:
      mov rdi, [rbp - 0x8]
      mov rdi, [rdi]
      call perror                                ; perror("cd")
      jmp bi_cd.end

    .end:
      add rsi, 0x10

    epilogue

    ret

  bi_setenv:
    ret

  bi_unsetenv:
    ret
