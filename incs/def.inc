; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%ifndef _DEF_INC_
%define _DEF_INC_

%define STDIN_FILENO 0x0
%define STDOUT_FILENO 0x1
%define STDERR_FILENO 0x2

%macro prologue 0
  push rbp
  mov rbp, rsp
%endmacro

%macro epilogue 0
  mov rsp, rbp
  pop rbp
%endmacro

%macro xprintf 0
  xor rax, rax                                   ; Not using SSE registers
  call printf
%endmacro

struc wordexp_t
  we_wordc: resq 1
  we_wordv: resq 1
  we_offs: resq 1
endstruc

%endif
