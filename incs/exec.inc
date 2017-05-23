; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%ifndef _EXEC_INC_
%define _EXEC_INC_

; macros W* expects a register as parameter and modify that register

%define WCOREFLAG 0x80

%macro WIFEXITED 1
  and %1, 0x7f
%endmacro

%macro WEXITSTATUS 1
  and %1, 0xff00
  sar %1, 0x8
%endmacro

%macro WTERMSIG 1
  and %1, 0x7f
%endmacro

%macro WCOREDUMP 1
  and %1, WCOREFLAG
%endmacro


section .data
  cdump: db " (core dumped)", 10, 0
  endl: db 10, 0

  ; Signal list
  null: db 0
  hup: db "Hangup", 0
  int: db "Interupt", 0
  quit: db "Quit", 0
  ill: db "Illegal hardware instruction", 0
  trap: db "Trace trap", 0
  abrt: db "Abort", 0
  bus: db "Bus error", 0
  fpe: db "Floating point exception", 0
  kill: db "Filled", 0
  usr1: db "User signal 1", 0
  segv: db "Segmentation Fault", 0
  usr2: db "User signal 2", 0

  signals: dq null, hup, int, quit, ill, trap, abrt, bus, fpe, kill, usr1, segv, usr2

%endif
