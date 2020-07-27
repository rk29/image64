#!/bin/sh

petcat -2 -nh "$1" \
| sed -e "s/^ *//g" \
| cut -f 2- -d " " \
| sed -e "s/:/\n/2g" \
| sed -e "/^ / s/:/\n/g" \
| sed -e "/^ /! s/:/:\n/g" \
| sed -e "s/^ *//g" \
| sed -e "s/^ *;$//g" \
| sed -e "/:/! s/^/\t\t/g" \
| sed -e "s/^\t\t;/;/g" \
| sed -e "s/^\t\t$//g" \
| sed -e "s/stopinput/include/g" -e "s/stopfn/jmp/g" -e "s/stop\*/dex/g" -e "s/stopexp/txa/g" -e "s/stopprint#/asl/g" \
-e "s/stopsqr/tax/g" -e "s/stopsin/tya/g" -e "s/stoplist/lsr/g" -e "s/stoppoke/sta/g" -e "s/stopverify/ora/g" \
-e "s/stoprnd/tay/g" -e "s/stopsave/lda/g" -e "s/stopclose/cpy/g" -e "s/stoprun/beq/g" -e "s/stop\//dey/g" \
-e "s/stoprestore/bne/g" -e "s/stopabs/rts/g" -e "s/stopget/ldx/g" -e "s/stopto/jsr/g" -e "s/stopnew/ldy/g" \
-e "s/stopand/iny/g" -e "s/stop>/pha/g" -e "s/stop</pla/g" -e "s/stop^/inx/g" -e "s/stopusr/sec/g" \
-e "s/stopload/eor/g" -e "s/stopopen/cpx/g" -e "s/stopclr/rol/" -e "s/stoplet/bcc/g" -e "s/stopgoto/bcs/g" \
-e "s/stopprint/dec/g" -e "s/stoptab(/sty/g" -e "s/stopend/byte/g" -e "s/stopcont/inc/g" -e "s/stopwait/cmp/g" \
-e "s/stopnot/clc/g" -e "s/stopstop/adc/g" -e "s/stopcmd/ror/g" -e "s/stopsys/stx/g" -e "s/stopnext/org/g" \
-e "s/stopgosub/bpl/g" -e "s/stopfor/word/g" -e "s/stopif/bmi/g" -e "s/stopdef/sbc/g" -e "s/stopcos/txs/g" -e "s/stoplog/tsx/g" \
-e "s/stopfre/sed/g" -e "s/stop=/php/g" -e "s/stopsgn/plp/g" -e "s/stopstep/cld/g" -e "s/stopor/nop/g" \
-e "s/stopspc(/bit/g" -e "s/stoppos/sei/g" -e "s/stopdim/send/g" -e "s/stop+/cli/g" -e "s/stopmid\\$/dup/g" \
-e "s/stopright\\$/scn/g" -e "s/stopint/rti/g" \
> "$1.new"



