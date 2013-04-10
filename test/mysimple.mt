alphabet :: a b 0 1 2 3 4 5 6 7 8 9 # $ @ * ;

void    = # ;
sep     = $ ;
cursor  = @ ;
count   = * ;

special := { #, $, @, * } ;
digit   := { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } ;
any     := { a, b, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, #, $, @, * } ;


_goto_n ::= loop@[R(<void>)] [<cursor>] [L(<sep>)] [L(<sep>)] [<void>] [R] (
  {<count>} -> [<sep>] [R(<cursor>)] [<void>] &loop ;
  {<void>}  -> [<sep>] [R(<cursor>)] [<void>] ;
) ;;

_mem_goto_n ::= loop@[R(<void>)] [<cursor>] [L(<sep>)] [L(<sep>)] [<void>] [R] (
  {<count>} -> [<sep>] [R(<cursor>)] [<void>] &loop ;
  {<void>}  -> [<sep>] [R(<cursor>)] [<void>] ;
) ;;

_io_goto_n ::= [R(<sep>)] loop@[R(<void>)] [<cursor>] [L(<sep>)] [L(<sep>)] [L(<sep>)] [<void>] [R] (
  {<count>} -> [<sep>] [R(<sep>)] [R(<sep>)] [R(<cursor>)] [<void>] &loop ;
  {<void>}  -> [<sep>] [R(<sep>)] [R(<sep>)] [R(<cursor>)] [<void>] ;
) ;;

; presupune existenta unui cursor la capatul benzii si pozitia capului poate fi oriunde pe banda, dar la stanga cursorului
_expandr_C_ ::= (
  x@<any> -> [<cursor>] [R(<cursor>)] loop@[L] (
    y@!{<cursor>} -> [R] [&y] [L] &loop ;
    {<cursor>}    -> [R] [&x] [L] [<void>] ;
  ) ;
) ;;

; translateaza partea stanga a benzii cu o pozitie la stanga si face loc pentru un # pe pozitia curenta
_expandl_C_ ::= (
  x@<any> -> [<cursor>] [L(<cursor>)] loop@[R] (
    y@!{<cursor>} -> [L] [&y] [R] &loop ;
    {<cursor>}    -> [L] [&x] [R] [<void>] ;
  ) ;
) ;;

_shrinkr_C_ ::= [<cursor>] [R] (
  x@<any> -> loop@[R] (
    y@!{<cursor>} -> [L] [&y] [R] &loop ;
    {<cursor>}    -> [<void>] [L] [<void>] [L(<cursor>)] [&x] ;
  ) ;
) ;;

_shrinkl_C_ ::= [<cursor>] [L] (
  x@<any> -> loop@[L] (
    y@!{<cursor>} -> [R] [&y] [L] &loop ;
    {<cursor>}    -> [<void>] [R] [<void>] [R(<cursor>)] [&x] ;
  ) ;
) ;;

_mem_expandl_ ::= (
  x@<any> -> [<cursor>] [L(<sep>)] [L(<sep>)] [L] [<cursor>] [R(<cursor>)] [&x] [_expandl_C_] ;
) ;;

_mem_expandr_ ::= (
  x@<any> -> [<cursor>] [R(<sep>)] [R(<sep>)] [R] [<cursor>] [L(<cursor>)] [&x] [_expandr_C_] ;
) ;;
  
_mem_shrinkl_ ::= (
  x@<any> -> [<cursor>] [L(<sep>)] [L(<sep>)] [L] [<cursor>] [R(<cursor>)] [&x] [_shrinkl_C_] ;
) ;;

_mem_shrinkr_ ::= (
  x@<any> -> [<cursor>] [R(<sep>)] [R(<sep>)] [R] [<cursor>] [L(<cursor>)] [&x] [_shrinkr_C_] ;
) ;;


_io_exp_mem_shrinkr_ ::= (
  x@<any> -> [<cursor>] [R(<sep>)] [R(<sep>)] [R] [<cursor>] [L(<cursor>)] [&x] [_shrinkr_C_] ;
) ;;andl_ ::= (
  x@<any> -> [<cursor>] [L(<sep>)] [L(<sep>)] [L(<sep>)] [L] [<cursor>] [R(<cursor>)] [&x] [_expandl_C_] ;
) ;;

_io_expandr_ ::= (
  x@<any> -> [<cursor>] [R(<sep>)] [R] [<cursor>] [L(<cursor>)] [&x] [_expandr_C_] ;
) ;;

_io_shrinkl_ ::= (
  x@<any> -> [<cursor>] [L(<sep>)] [L(<sep>)] [L(<sep>)] [L] [<cursor>] [R(<cursor>)] [&x] [_shrinkl_C_] ;
) ;;

_io_shrinkr_ ::= (
  x@<any> -> [<cursor>] [R(<sep>)] [R] [<cursor>] [L(<cursor>)] [&x] [_shrinkr_C_] ;
) ;;

_mem_clear_ ::= [R(<void>)] [L] loop@(
  !{<void>} -> [_mem_shrinkl_] &loop ;
) ;;
