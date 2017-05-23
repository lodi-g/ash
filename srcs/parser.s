; ash - the assembly shell
; written by Gregoire Lodi
; https://github.com/lodi-g

global parse_raw:function

%include "def.inc"

section .text:
  ; libc
  extern wordexp
  extern printf

  parse_raw:
    prologue

    .leave:
      epilogue

    ret
