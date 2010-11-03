\ *******************************************************************
\                                                                   *
\    Filename:      see.fth                                         *
\    Date:          10.10.2010                                      *
\    FF Version:    4.7                                             *
\    MCU:           PIC30 PIC24 PIC33                               *
\    Copyright:     Mikael Nordman                                  *
\    Author:        Mikael Nordman                                  *
\ *******************************************************************
\ FlashForth is licensed according to the GNU General Public License*
\ *******************************************************************
\ This file needs ct.fth

-see
marker -see
hex ram
: dup@ ( addr -- addr lo hi ) dup @ ;
: hi@ ( addr -- addr hi ) dup cf@ nip ;
: field@ ( x mask offset -- field )
  rot swap rshift and ;
: u.4 4 u.r ;
: .id ( cfa -- ) c>n c@+ f and type space ;

: u.. decimal <# #s #> type hex ;
: lookup:
  create does> swap cells + @ex ;

\ Register offset
:noname ." [W" u.. ." +Wb]" ;

\ Register offset
:noname ." [W" u.. ." +Wb]" ;

\ Indirect with Pre-Increment
:noname ." [++W" u.. ." ]" ;

\ Indirect with Pre-Decrement
:noname ." [--W" u.. ." ]" ;

\ Indirect with Post-Increment
:noname ." [W" u.. ." ++]" ;

\ Indirect with Post-Decrement
:noname ." [W" u.. ." --]" ;

\ Indirect
:noname ." [W" u.. ." ]" ;

\ Register Direct
:noname ." W" u.. ;

flash lookup: mov.amode , , , , , , , ,


\ take the next cell
:noname cell+ ;
' true

\ return 
:noname ." return" drop false ;
:noname ( addr -- addr f ) hi@ 06 = ;

\ unintialised flash or nop
\ :noname drop false ;
\ :noname ( addr -- addr f ) hi@ $ff = ;

\ goto
:noname ." goto  " dup@ pfl + c>n .id drop false ;
:noname ( addr -- addr f ) hi@ $4 = ;

\ cp0 Wn
:noname ." cp0 " dup@ 
 dup f 0 field@ swap 7 4 field@ mov.amode cell+ ;
:noname hi@ e0 = ;

: .bra ." bra " type dup@ 2* over + 2+ u.4 cell+ ; 

\ bra z
:noname s" z, " .bra ;
:noname ( addr --  addr f ) hi@ 0032 = ;

\ bra nz
:noname s" nz, " .bra ;
:noname ( addr --  addr f ) hi@ 003a = ;

\ bra c
:noname s" c, " .bra ;
:noname ( addr -- addr f ) hi@ 0031 = ;

\ bra unconditionally
:noname s" un, " .bra ;
:noname ( addr -- addr f ) hi@ 0037 = ;

\ sub Wb, #li5, Wd
:noname ." sub W" 
 dup cf@ 7 and 1 lshift swap #15 rshift 1 and + u..
 dup@  ." , " 1f and u.. ." , "
 dup@ f 7 field@  over @ 7 #11 field@ mov.amode
 cell+ ;
:noname hi@ f8 and 50 = ;

\ pop f
:noname ." pop " @+ u. ;
:noname hi@ f9 = ;

\ mov  #16, Wn
:noname ." mov " 
  dup cf@ over fff 4 field@ swap f and #12 lshift or u.
  ." , W" f and u.  cell+ ;
:noname ( addr -- addr f ) hi@ f0 and 20 = ;

\ mov Ws, Wd
:noname ." mov" dup@
  dup 4000 and if s" .b " else s" .w " then type
  dup f 0 field@ over 7 #4 field@ mov.amode 
  [char] , emit space
  dup f 7 field@ swap 7 #11 field@ mov.amode cell+ ;
:noname ( addr -- addr f ) hi@ 1f 3 field@ f = ;

\ rcall
:noname ." rcall " dup@ 2* over + 2+ c>n .id cell+ ;
:noname ( addr -- addr f ) hi@ 07 = ;

\ define a condition table called (see) with 13 elements
flash #13 ct (see)
ram

: see 
  ' cr hex
  begin
    dup u.4
    dup cf@ u.4 u.4  
    (see) cr 
    dup 0=     \ dup and 0= will be optimised away
  until
  drop
;

