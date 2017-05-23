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

%endif
