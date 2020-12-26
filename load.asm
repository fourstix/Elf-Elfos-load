; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

           org     8000h
           lbr     0ff00h
           db      'load',0
           dw      9000h
           dw      endrom+1400h
           dw      7c00h
           dw      endrom-7c00h
           dw      7c00h
           db      0

           org     7c00h
           br      start

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:
           lda     ra                  ; move past any spaces
           smi     ' '
           lbz     start
           dec     ra                  ; move back to non-space character
           ghi     ra                  ; copy argument address to rf
           phi     rf
           glo     ra
           plo     rf
loop1:     lda     rf                  ; look for first less <= space
           smi     33
           lbdf    loop1
           dec     rf                  ; backup to char
           ldi     0                   ; need proper termination
           str     rf
           ghi     ra                  ; back to beginning of name
           phi     rf
           glo     ra
           plo     rf
           ldn     rf                  ; get byte from argument
           lbnz    good                ; jump if filename given
           sep     scall               ; otherwise display usage message
           dw      f_inmsg
           db      'Usage: load filename',10,13,0
           sep     sret                ; and return to os
good:      ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     0                   ; flags for open
           plo     r7
           sep     scall               ; attempt to open file
           dw      o_open
           lbnf    opened              ; jump if file was opened
           ldi     high errmsg         ; get error message
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall               ; display it
           dw      o_msg
           lbr     o_wrmboot           ; and return to os
opened:    ldi     high buffer         ; buffer to rettrieve data
           phi     rf
           ldi     low buffer
           plo     rf
           ldi     0                   ; need to read 6 byte header
           phi     rc
           ldi     6
           plo     rc
           sep     scall               ; read the header
           dw      o_read
           ldi     high buffer         ; point to header
           phi     r9
           ldi     low buffer
           plo     r9
           lda     r9                  ; get load address
           phi     rf
           lda     r9
           plo     rf
           lda     r9                  ; get size
           phi     rc
           lda     r9
           plo     rc
           sep     scall               ; read rest of file
           dw      o_read
           sep     scall               ; close the file
           dw      o_close
           ldi     high buffer
           phi     r9
           ldi     low buffer
           plo     r9
           ldi     high outbuf
           phi     rf
           ldi     low outbuf
           plo     rf
           lda     r9
           phi     rd
           lda     r9
           plo     rd
           sep     scall
           dw      f_hexout4
           ldi     32
           str     rf
           inc     rf
           lda     r9
           phi     rd
           lda     r9
           plo     rd
           sep     scall
           dw      f_hexout4
           ldi     13
           str     rf
           inc     rf
           ldi     10
           str     rf
           inc     rf
           ldi     0
           str     rf
           inc     rf
           ldi     high outbuf
           phi     rf
           ldi     low outbuf
           plo     rf
           sep     scall
           dw      o_msg
           sep     sret                ; return to os

errmsg:    db      'File not found',10,13,0
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

buffer:    ds      10
outbuf:    dw      80

dta:       ds      512

