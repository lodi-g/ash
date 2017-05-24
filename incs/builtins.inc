; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%ifndef _BUILTINS_INC_
%define _BUILTINS_INC_


section .data
  cd: dq "cd", 0

  builtins: dq cd
  builtins_fptr: dq bi_cd
  builtins_nb: dq 1

%endif
