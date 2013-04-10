alphabet :: a b 0 1 2 3 4 5 6 7 8 9 # $ @ * ;

void    = # ;
sep     = $ ;
cursor  = @ ;
count   = * ;

special := { #, $, @, * } ;
digit   := { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 } ;
any     := { a, b, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, #, $, @, * } ;

_goto_n ::= loop@[R(#)] [@] [L($)] [L($)] [#] [R] (
  {*} -> [$] [R(@)] [#] &loop ;
  {#}  -> [$] [R(@)] [#] ;
) ;;

_mem_goto_n ::= loop@[R(#)] [@] [L($)] [L($)] [#] [R] (
  {*} -> [$] [R(@)] [#] &loop ;
  {#}  -> [$] [R(@)] [#] ;
) ;;

_io_goto_n ::= [R($)] loop@[R(#)] [@] [L($)] [L($)] [L($)] [#] [R] (
  {*} -> [$] [R($)] [R($)] [R(@)] [#] &loop ;
  {#}  -> [$] [R($)] [R($)] [R(@)] [#] ;
) ;;

; presupune existenta unui cursor la capatul benzii si pozitia capului poate fi oriunde pe banda, dar la stanga cursorului
_expandr_C_ ::= (
  x@<any> -> [@] [R(@)] loop@[L] (
    y@!{@} -> [R] [&y] [L] &loop ;
    {@}    -> [R] [&x] [L] [#] ;
  ) ;
) ;;

; translateaza partea stanga a benzii cu o pozitie la stanga si face loc pentru un # pe pozitia curenta
_expandl_C_ ::= (
  x@<any> -> [@] [L(@)] loop@[R] (
    y@!{@} -> [L] [&y] [R] &loop ;
    {@}    -> [L] [&x] [R] [#] ;
  ) ;
) ;;

_shrinkr_C_ ::= [@] [R] (
  x@<any> -> loop@[R] (
    y@!{@} -> [L] [&y] [R] &loop ;
    {@}    -> [#] [L] [#] [L(@)] [&x] ;
  ) ;
) ;;

_shrinkl_C_ ::= [@] [L] (
  x@<any> -> loop@[L] (
    y@!{@} -> [R] [&y] [L] &loop ;
    {@}    -> [#] [R] [#] [R(@)] [&x] ;
  ) ;
) ;;

_mem_expandl_ ::= (
  x@<any> -> [@] [L($)] [L($)] [L] [@] [R(@)] [&x] [_expandl_C_] ;
) ;;

_mem_expandr_ ::= (
  x@<any> -> [@] [R($)] [R($)] [R] [@] [L(@)] [&x] [_expandr_C_] ;
) ;;
  
_mem_shrinkl_ ::= (
  x@<any> -> [@] [L($)] [L($)] [L] [@] [R(@)] [&x] [_shrinkl_C_] ;
) ;;

_mem_shrinkr_ ::= (
  x@<any> -> [@] [R($)] [R($)] [R] [@] [L(@)] [&x] [_shrinkr_C_] ;
) ;;

_io_expandl_ ::= (
  x@<any> -> [@] [L($)] [L($)] [L($)] [L] [@] [R(@)] [&x] [_expandl_C_] ;
) ;;

_io_expandr_ ::= (
  x@<any> -> [@] [R($)] [R] [@] [L(@)] [&x] [_expandr_C_] ;
) ;;

_io_shrinkl_ ::= (
  x@<any> -> [@] [L($)] [L($)] [L($)] [L] [@] [R(@)] [&x] [_shrinkl_C_] ;
) ;;

_io_shrinkr_ ::= (
  x@<any> -> [@] [R($)] [R] [@] [L(@)] [&x] [_shrinkr_C_] ;
) ;;

_mem_clear_ ::= [R(#)] [L] loop@(
  !{#} -> [_mem_shrinkl_] &loop ;
) ;;

_io_clear_ ::= [R] loop@(
  !{#} -> [_io_shrinkr_] &loop ;
  {#}  -> [L] ;
) ;;

io_memread_nn ::= [_mem_goto_n] [@] [_io_goto_n] [_io_clear_] [R] [@] [L(@)] [#] loop@[R] (
  x@!{#} -> [@] [R(@)] [_io_expandr_] [&x] [L(@)] [&x] &loop ;
  {#}    -> [R(@)] [#] [L($)] [L($)] ;
) ;;
 
mem_iosave_nn ::= [_mem_goto_n] [_mem_clear_] [@] [_io_goto_n] [R(#)] loop@[L] (
  x@!{#} -> [@] [L(@)] [_mem_expandl_] [&x] [R(@)] [&x] &loop ;
  {#}    -> [L(@)] [#] [L($)] ;
) ;;

mem_alloc_n ::= loop@[L($)] [#] [R] (
  {*} -> [$] [R($)] [R] [_mem_expandl_] [L($)] &loop ;
  {#}  -> [$] [R($)] ;
) ;;

mem_free_n ::= loop@[L($)] [#] [R] (
  {*} -> [$] [R($)] [R] [_mem_clear_] [_mem_shrinkr_] [L($)] &loop ;
  {#}  -> [$] [R($)] ;
) ;;

io_alloc_n ::= loop@[L($)] [#] [R] (
  {*} -> [$] [R($)] [R($)] [R] [_io_expandr_] [L($)] [L($)] &loop ;
  {#}  -> [$] [R($)] ;
) ;;

io_free_n ::= loop@[L($)] [#] [R] (
  {*} -> [$] [R($)] [R($)] [R] [_io_clear_] [_io_shrinkr_] [L($)] [L($)] &loop ;
  {#}  -> [$] [R($)] ;
) ;;

_put_ ::= [*] [L] ;;

ctl_put_0 ::= [L($)] [#] [L]                                                         [$] [R($)] ;;
ctl_put_1 ::= [L($)] [#] [L] [_put_]                                                 [$] [R($)] ;;
ctl_put_2 ::= [L($)] [#] [L] [_put_] [_put_]                                         [$] [R($)] ;;
ctl_put_3 ::= [L($)] [#] [L] [_put_] [_put_] [_put_]                                 [$] [R($)] ;;
ctl_put_4 ::= [L($)] [#] [L] [_put_] [_put_] [_put_] [_put_]                         [$] [R($)] ;;
ctl_put_5 ::= [L($)] [#] [L] [_put_] [_put_] [_put_] [_put_] [_put_]                 [$] [R($)] ;;
ctl_put_6 ::= [L($)] [#] [L] [_put_] [_put_] [_put_] [_put_] [_put_] [_put_]         [$] [R($)] ;;
ctl_put_7 ::= [L($)] [#] [L] [_put_] [_put_] [_put_] [_put_] [_put_] [_put_] [_put_] [$] [R($)] ;;

; ####################################################################################################################

Zero ::= [ctl_put_0] [_io_goto_n] [_io_clear_] [_io_expandl_] [0] [L($)] [L($)] ;;

Increment ::= [R($)] [R(#)] [R(#)] loop@[L] (
  {0}      -> [1]  [L($)] [L($)] ;
  {1}      -> [0] &loop ;
  {#} -> [_io_expandl_] [1] [L($)] [L($)] ;
) ;;

Increment_10 ::= [R($)] [R(#)] [R(#)] loop@[L] (
  {0}      -> [1]  [L($)] [L($)] ;
  {1}      -> [2]  [L($)] [L($)] ;
  {2}      -> [3]  [L($)] [L($)] ;
  {3}      -> [4]  [L($)] [L($)] ;
  {4}      -> [5]  [L($)] [L($)] ;
  {5}      -> [6]  [L($)] [L($)] ;
  {6}      -> [7]  [L($)] [L($)] ;
  {7}      -> [8]  [L($)] [L($)] ;
  {8}      -> [9]  [L($)] [L($)] ;
  {9}      -> [0] &loop ;
  {#} -> [_io_expandl_] [1] [L($)] [L($)] ;
) ;;

Decrement ::= [R($)] [R(#)] [R(#)] loop@[L] (
  {0}      -> [1] &loop ;
  {1}      -> [0] [L] (
    {0, 1}   -> [L($)] [L($)] ;
    {#} -> [R] [R] (
      {0, 1}   -> [L] [_io_shrinkl_] [L($)] [L($)] ;
      {#} -> [L($)] [L($)] ;
    ) ;
  ) ;
) ;;

Decrement_10 ::= [R($)] [R(#)] [R(#)] loop@[L] (
  {9} -> [8] [L($)] [L($)] ;
  {8} -> [7] [L($)] [L($)] ;
  {7} -> [6] [L($)] [L($)] ;
  {6} -> [5] [L($)] [L($)] ;
  {5} -> [4] [L($)] [L($)] ;
  {4} -> [3] [L($)] [L($)] ;
  {3} -> [2] [L($)] [L($)] ;
  {2} -> [1] [L($)] [L($)] ;
  {0} -> [9] &loop ;
  {1}      -> [0] [L] (
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9   -> [L($)] [L($)] ;
    {#} -> [R] [R] (
      0, 1, 2, 3, 4, 5, 6, 7, 8, 9   -> [L] [_io_shrinkl_] [L($)] [L($)] ;
      {#} -> [L($)] [L($)] ;
    ) ;
  ) ;
) ;;

Sum ::= [ctl_put_2] [mem_alloc_n]
        [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
        [ctl_put_1] [ctl_put_1] [mem_iosave_nn]
        [ctl_put_1] [io_free_n]
        loop@[ctl_put_0] [_mem_goto_n] [R] (
	  {0} -> [L($)] [ctl_put_0] [ctl_put_1] [io_memread_nn] [ctl_put_2] [mem_free_n] ;
	  {1} -> [L($)] [ctl_put_0] [ctl_put_0] [io_memread_nn] [Decrement] [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
	                    [ctl_put_0] [ctl_put_1] [io_memread_nn] [Increment] [ctl_put_0] [ctl_put_1] [mem_iosave_nn] &loop ;
	) ;;

Product ::= [ctl_put_3] [mem_alloc_n]
            [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
            [ctl_put_1] [ctl_put_1] [mem_iosave_nn]
            [ctl_put_1] [io_free_n]
            [Zero] [ctl_put_0] [ctl_put_2] [mem_iosave_nn]
            loop@[ctl_put_0] [_mem_goto_n] [R] (
	      {0} -> [L($)] [ctl_put_0] [ctl_put_2] [io_memread_nn] 
	                        [ctl_put_3] [mem_free_n] ;
	      {1} -> [L($)] [ctl_put_0] [ctl_put_0] [io_memread_nn]
	                        [Decrement]
	                        [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
	                        [ctl_put_1] [io_alloc_n]
		                [ctl_put_0] [ctl_put_1] [io_memread_nn]
		                [ctl_put_1] [ctl_put_2] [io_memread_nn]
		                [Sum]
		                [ctl_put_0] [ctl_put_2] [mem_iosave_nn] &loop ;
	    ) ;;

Convert_dec2bin ::= 
  [ctl_put_2] [mem_alloc_n]
  [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
  [Zero] [ctl_put_0] [ctl_put_1] [mem_iosave_nn]
  loop@[ctl_put_0] [_mem_goto_n] [R] (
    {0}  -> [L($)] [ctl_put_0] [ctl_put_1] [io_memread_nn]
                       [ctl_put_2] [mem_free_n] ;
    !{0} -> [L($)] [ctl_put_0] [ctl_put_0] [io_memread_nn]
                       [Decrement_10]
                       [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
                       [ctl_put_0] [ctl_put_1] [io_memread_nn]
                       [Increment]
                       [ctl_put_0] [ctl_put_1] [mem_iosave_nn] &loop ;
  ) ;;
	    
Convert_bin2dec ::= 
  [ctl_put_2] [mem_alloc_n]
  [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
  [Zero] [ctl_put_0] [ctl_put_1] [mem_iosave_nn]
  loop@[ctl_put_0] [_mem_goto_n] [R] (
    {0}  -> [L($)] [ctl_put_0] [ctl_put_1] [io_memread_nn]
                       [ctl_put_2] [mem_free_n] ;
    !{0} -> [L($)] [ctl_put_0] [ctl_put_0] [io_memread_nn]
                       [Decrement]
                       [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
                       [ctl_put_0] [ctl_put_1] [io_memread_nn]
                       [Increment_10]
                       [ctl_put_0] [ctl_put_1] [mem_iosave_nn] &loop ;
  ) ;;
	    
Product_10 ::= [ctl_put_2] [mem_alloc_n]
               [ctl_put_0] [ctl_put_0] [mem_iosave_nn]
               [ctl_put_1] [io_free_n]
               [Convert_dec2bin]
               [ctl_put_0] [ctl_put_1] [mem_iosave_nn]
               [ctl_put_0] [ctl_put_0] [io_memread_nn]
               [Convert_dec2bin]
               [ctl_put_1] [io_alloc_n]
               [ctl_put_0] [ctl_put_1] [io_memread_nn]
               [Product]
               [Convert_bin2dec]
               [ctl_put_2] [mem_free_n]
               ;;

