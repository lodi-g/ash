; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

%ifndef _BUILTINS_INC_
%define _BUILTINS_INC_


section .data
  cd: dq "cd", 0
  setenv: dq "setenv", 0
  unsetenv: dq "unsetenv", 0

  builtins: dq cd, setenv, unsetenv
  builtins_fptr: dq bi_cd, bi_setenv, bi_unsetenv
  builtins_nb: dq 3

%endif
