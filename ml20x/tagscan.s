#import "equat.s"

* = protostart "tagscan.prg"

.label zp1= $71 // pointer

// offset to bits in objlist (ob)
.label obbitoff = 0
// offset to type in objlist (ob)
.label obtypoff = 2
// offset to loc in objlist (ob)
.label oblocoff = 4
// offset to bits in deflist (od)
.label odbitoff = 0
// offset to type in deflist (od)
.label odtypoff = 2
// offset to piece1 in deflist (od)
.label odpc1off = 4
// offset to piece2 in deflist (od)
.label odpc2off = 6
// offset to piece3 in deflist (od)
.label odpc3off = 8

//********************************
//* tagscan - object tag scanner *
//********************************

// implements the "&,16" command of the ml interface.  the & handler
// reads the first three parameters (16 = this module, the sub
// function number, an unused 0) and calls entry1 with the sub
// function number in X.  the remaining parameters are parsed from
// the BASIC text by entry1 and by the individual routines.

// the command works on three tables that live in the data areas of
// BASIC integer arrays.  each array is passed by referencing one of
// its elements (normally element 0, e.g. li%(0)) - the address of
// that element's 2 byte value is taken as the start of the table.
// 16 bit fields are stored high byte first, the same way BASIC
// stores integers.  entry 0 of each table is a header whose first
// word (low byte at offset 1) holds the number of entries that
// follow; the real entries are numbered from 1.

// list (lstptr) - 2 bytes per entry, header word = entry count
//   entry i (1..count) holds the index of an object in the obj
//   table (high byte always 0, so object indexes are 8 bit)

// obj (objptr) - objsiz bytes per entry, header word = entry count
//   +0 obbitoff  bits - 16 bit flag word
//   +2 obtypoff  type - 16 bit type id
//   +4 oblocoff  loc  - 16 bit location id
//   objsiz may be larger than 6, extra bytes are not used here

// def (defptr) - defsiz bytes per entry, header word = entry count
//   +0  odbitoff bits - not used by this module
//   +2  odtypoff type - type of the object this def builds
//   +4  odpc1off piece1 - type of the 1st required piece
//   +6  odpc2off piece2 - type of the 2nd required piece
//   +8  odpc3off piece3 - type of the 3rd required piece
//   a piece type of 0 means that piece is not used

// syntax - sub functions:

// scanvirt: &,16,0,0,list(0),obj(0),objsize,def(0),defsize
//   apply def "recipes": while some def has all of its (non zero)
//   piece types present in the list, and the obj table contains an
//   object of the def's own type, remove those piece objects from
//   the list and append the object the def builds.  passes over
//   the def table are repeated until one completes without
//   changing the list.  the result is left in the list table,
//   nothing is returned in a%

// findobjd: &,16,1,0,list(x),obj(0),objsize,def(0),defsize
//   list(x) holds an object number.  returns in a% the 1 based
//   index of the def whose type matches that object's type, or 0
//   if the object number is invalid or no def matches

// haveobjt: &,16,2,0,list(0),obj(0),objsize,def(0),defsize,objtyp
//   returns in a% the 1 based index of the first list entry whose
//   object has the given 16 bit type, or 0 if there is none

// makelist: &,16,3,0,list(0),obj(0),objsize,def(0),defsize,
//           target,bitmask
//   empties the list, then appends the index of every obj entry
//   whose loc equals target and whose bits have none of bitmask
//   set.  no a% result.  (this sub function takes two 16 bit
//   parameters - the single "usernumber" shown in the original
//   syntax comment was stale)

// &,16 command entry, part 1 - parse the five parameters common
// to all sub functions from the BASIC text
// input
//   X = sub function number (the second & parameter)
//   BASIC text positioned after the first three & parameters
// output
//   func, lstptr, objptr, objsiz, defptr, defsiz
// the & dispatcher calls us with RAM banked in under the BASIC ROM
// (while it reads the jump table), so first restore normal banking
// to make the BASIC ROM expression parser callable.  the dispatcher
// restores the banking itself when we return
// falls through into entry2

entry1:
		lda #r6510_normal
		sta r6510
		stx func
		jsr fnvarx
		stx lstptr
		sty lstptr+1
		jsr fnvarx
		stx objptr
		sty objptr+1
		jsr evalbytx
		stx objsiz
		jsr fnvarx
		stx defptr
		sty defptr+1
		jsr evalbytx
		stx defsiz

// &,16 command entry, part 2 - read the entry counts from the
// three table headers, validate the sub function number and
// dispatch through table with a self modifying jmp
// input
//   func    sub function number 0-3
//   lstptr  list table base - objnum becomes the value of the list
//           element that was passed: the entry count (list(0)) or
//           an object number (findobjd's list(x))
//   objptr  obj table base  - objcnt = entry count from obj[0]
//   defptr  def table base  - defcnt = entry count from def[0]
// output
//   objnum, objcnt, defcnt
//   control is transferred to the selected routine; its rts
//   returns directly to the & dispatcher.  an out of range sub
//   function number goes to abort and does nothing

entry2:
		lda lstptr
		sta varbuf
		lda lstptr+1
		sta varbuf+1
		ldy #1
		lda (varbuf),y
		sta objnum // low byte of list[0] (or list[x] for findobjd)

		lda objptr
		sta varbuf
		lda objptr+1
		sta varbuf+1
		ldy #1
		lda (varbuf),y
		sta objcnt // low byte of obj[0]

		lda defptr
		sta varbuf
		lda defptr+1
		sta varbuf+1
		ldy #1
		lda (varbuf),y
		sta defcnt // low byte of def[0]

		lda func
		cmp #4
		bcs abort // sub function must be 0-3
		asl // x2 for word index into table
		tax
		lda table,x
		sta jump+1
		lda table+1,x
		sta jump+2
jump:
		jmp abort // operand patched above from table
abort:
		rts

// sub function dispatch table, indexed by func*2

table:
		.word scanvirt //0
		.word findobjd //1
		.word haveobjt //2
		.word makelist //3

// return a result to the BASIC caller
// input
//   X = result value 0-255
// output
//   a% = result (ml variable index 30)
// the value is staged in varbuf as a high byte first integer
// (varbuf = high byte 0, varbuf+1 = low byte X) then interface
// function 30 (putvar) copies the 5 byte descriptor into a%.
// the jmp is a tail call - the eventual rts unwinds back to the
// & command handler

putint:
		stx varbuf+1
		lda #0
		sta varbuf
		ldx #var_a_integer
putvar:
		lda #30
		jmp usetbl1

//****************************
//* tagscan working storage *
//****************************

func: // sub function number (X on entry to entry1)
		.byte 0

lstptr: // address of the passed list element = list table base
		.word 0
target: // makelist: loc value objects must have (high, +1 = low)
		.word 0
bitval: // makelist: bits objects must not have (high, +1 = low)
		.word 0

defptr: // address of the passed def element = def table base
		.word 0
defsiz: // bytes per def table entry
		.byte 0
defcnt: // number of def table entries (from def[0])
		.byte 0
defnum: // scanvirt: def entry number being processed
		.byte 0

objptr: // address of the passed obj element = obj table base
		.word 0
objsiz: // bytes per obj table entry
		.byte 0
objtyp: // 16 bit type being matched, in table byte order:
        // objtyp = first (high) byte, objtyp+1 = second (low) byte.
        // used as a work field by findobjd, checkdef and checkpc
		.word 0
objnum: // findobjd: the object number from list(x).
        // others: number of entries in the list (updated by addpc
        // and scandel)
		.byte 0
objcnt: // number of obj table entries (from obj[0])
		.byte 0

piece1: // list entry index that matched def piece 1 (0 = none)
		.byte 0
piece2: // list entry index that matched def piece 2
		.byte 0
piece3: // list entry index that matched def piece 3
		.byte 0

deltmp: // scandel: number of entries kept, plus 1
		.byte 0
scatmp: // scanlst: list entry number being checked
		.byte 0

change: // scanvirt: 1 = a def was applied this pass
		.byte 0

// parse the next parameter as a variable or array element
// reference (e.g. li%(0)) and return the address of its value
// input
//   BASIC text positioned at the comma before the parameter
// output
//   X = low byte, Y = high byte of the value address
// chkcom consumes the comma (syntax error if missing), then the
// BASIC ROM routine at $b08b parses the reference - evaluating any
// array subscript - and leaves the address of the variable's value
// in $47/$48.  for an integer array element that is the address of
// its 2 byte value, which is exactly the table base the callers
// need

fnvarx:
		jsr chkcom
		jsr $b08b
		ldx $47
		ldy $48
		rts

// parse the next parameter as a numeric expression, value 0-255
// input
//   BASIC text positioned at the comma before the parameter
// output
//   X = value
// chkcom consumes the comma and $0079 (chrgot) re-reads the
// current character; $b79e is the tail of the BASIC ROM byte
// expression evaluator (frmnum plus integer conversion) - values
// outside 0-255 raise ?ILLEGAL QUANTITY via BASIC

evalbytx:
		jsr chkcom
		jsr $0079
		jmp $b79e

// parse the next parameter as a 16 bit numeric expression
// input
//   BASIC text positioned at the comma before the parameter
// output
//   X = low byte, Y = high byte
// frmnum ($ad8a) evaluates the expression into FAC and getadr
// ($b7f7) converts it to an unsigned 16 bit value in $14 (low)
// and $15 (high)

getword:
		jsr chkcom
		jsr $ad8a
		jsr $b7f7
		ldx $14
		ldy $15
		rts

// address of a list table entry
// input
//   X = entry index
// output
//   A = low byte, Y = high byte of the entry address
//   C = 0: index is in 1..objnum, address is valid
//   C = 1: index is 0 or > objnum, entry does not exist
// computes lstptr + 2*X.  entry 0 is the header, so valid entry
// indexes run from 1 up to the entry count held in objnum

calclst:
		lda lstptr
		ldy lstptr+1
		cpx #0
		beq calclst3
		cpx objnum
		beq calclst1
		bcs calclst3
calclst1:
		clc
		adc #2
		bcc calclst2
		iny
calclst2:
		dex
		bne calclst1
		clc
calclst3:
		rts

// does the list contain an object of type objtyp?
// checks list entries 1..objnum: each entry's low byte is an
// object index, and the type field of that obj entry (obtypoff)
// is compared with objtyp/objtyp+1 byte for byte
// input
//   objtyp/objtyp+1 = type to find, in table byte order
//   lstptr, objnum, objptr, objsiz, objcnt
// output
//   C = 0: found, X = 1 based index of the list entry
//   C = 1: not found, X = objnum
// memory
//   varbuf+4/+5 = list scan cursor (overlaps the FAC - safe here
//   because no BASIC arithmetic is done while it is live)
//   varbuf/+1   = address of the current obj entry
//   scatmp      = list entry number being checked
// entries holding an invalid object index (0 or > objcnt) are
// skipped by the calcobj carry test

scanlst:
		lda lstptr
		sta varbuf+4
		lda lstptr+1
		sta varbuf+5
		ldx #0
		stx scatmp
scanlst1:
		inc scatmp
		clc
		lda varbuf+4
		adc #2
		sta varbuf+4
		bcc scanlst2
		inc varbuf+5
scanlst2:
		ldy #1
		lda (varbuf+4),y
		tax
		jsr calcobj
		sta varbuf
		sty varbuf+1
		ldx scatmp
		bcs scanlst3
		ldy #obtypoff
		lda (varbuf),y
		iny
		cmp objtyp
		bne scanlst3
		lda (varbuf),y
		cmp objtyp+1
		beq scanlst4
scanlst3:
		cpx objnum
		bne scanlst1
		sec
		rts
scanlst4:
		clc
		rts

// address of an obj table entry
// input
//   X = object index
// output
//   A = low byte, Y = high byte of the entry address
//   C = 0: index is in 1..objcnt, C = 1: index 0 or > objcnt
// computes objptr + objsiz*X

calcobj:
		lda objptr
		ldy objptr+1
		cpx #0
		beq calcobj3
		cpx objcnt
		beq calcobj1
		bcs calcobj3
calcobj1:
		clc
		adc objsiz
		bcc calcobj2
		iny
calcobj2:
		dex
		bne calcobj1
		clc
calcobj3:
		rts

// find an obj table entry with type objtyp
// scans entries 1..objcnt (entry 0, the header, is skipped) and
// compares each entry's type field (obtypoff) with objtyp/+1
// input
//   objtyp/objtyp+1, objptr, objsiz, objcnt
// output
//   C = 0: found, X = 1 based object index
//   C = 1: not found, X = objcnt
// memory
//   varbuf/+1 = table cursor

scanobj:
		lda objptr
		sta varbuf
		lda objptr+1
		sta varbuf+1
		ldx #0
scanobj1:
		inx
		clc
		lda varbuf
		adc objsiz
		sta varbuf
		bcc scanobj2
		inc varbuf+1
scanobj2:
		ldy #obtypoff
		lda (varbuf),y
		cmp objtyp
		bne scanobj3
		iny
		lda (varbuf),y
		cmp objtyp+1
		beq scanobj4
scanobj3:
		cpx objcnt
		bne scanobj1
		sec
		rts
scanobj4:
		clc
		rts

// address of a def table entry
// input
//   X = def index
// output
//   A = low byte, Y = high byte of the entry address
//   C = 0: index is in 1..defcnt, C = 1: index 0 or > defcnt
// computes defptr + defsiz*X

calcdef:
		lda defptr
		ldy defptr+1
		cpx #0
		beq calcdef3
		cpx defcnt
		beq calcdef1
		bcs calcdef3
calcdef1:
		clc
		adc defsiz
		bcc calcdef2
		iny
calcdef2:
		dex
		bne calcdef1
		clc
calcdef3:
		rts

// find a def table entry with type objtyp
// scans entries 1..defcnt (entry 0, the header, is skipped) and
// compares each entry's type field (odtypoff) with objtyp/+1
// input
//   objtyp/objtyp+1, defptr, defsiz, defcnt
// output
//   C = 0: found, X = 1 based def index
//   C = 1: not found, X = defcnt
// memory
//   varbuf/+1 = table cursor

scandef:
		lda defptr
		sta varbuf
		lda defptr+1
		sta varbuf+1
		ldx #0
scandef1:
		inx
		clc
		lda varbuf
		adc defsiz
		sta varbuf
		bcc scandef2
		inc varbuf+1
scandef2:
		ldy #odtypoff
		lda (varbuf),y
		iny
		cmp objtyp
		bne scandef3
		lda (varbuf),y
		cmp objtyp+1
		beq scandef4
scandef3:
		cpx defcnt
		bne scandef1
		sec
		rts
scandef4:
		clc
		rts

// sub function 1 - find the def for an object
// the object number is in objnum (the value of the list(x)
// parameter).  look up that object's type in the obj table, then
// find the def table entry with the same type
// input
//   objnum, objptr, objsiz, objcnt, defptr, defsiz, defcnt
// output
//   a% = 1 based index of the matching def entry, or 0 if the
//        object number is invalid or no def matches (putint)
// memory
//   objtyp/objtyp+1 = the object's type, as a work field

findobjd:
		ldx objnum
		jsr calcobj
		bcs findobj1
		sta varbuf
		sty varbuf+1
		ldy #obtypoff
		lda (varbuf),y
		lda (varbuf),y // redundant - reloads the same byte
		iny
		sta objtyp
		lda (varbuf),y
		sta objtyp+1
		jsr scandef
		bcc findobj2
findobj1:
		ldx #0
findobj2:
		jmp putint

// sub function 0 - apply all applicable defs until nothing
// changes.  makes passes over the def table (entries 1..defcnt)
// calling checkdef for each entry; whenever a def gets applied the
// list changes, so the whole scan restarts from the top.  it ends
// when a full pass applies nothing (change stays 0)
// input
//   lstptr, objnum, objptr, objsiz, objcnt, defptr, defsiz, defcnt
// output
//   the list table (and objnum) - no a% result
// memory
//   varbuf+2/+3 = def table cursor, defptr + defsiz*defnum
//                 (overlaps the FAC - safe, no arithmetic is done
//                 while it is live)
//   defnum = def entry number being processed
//   change = 1 if any def was applied this pass

scanvirt:
		lda #0
		sta change
		lda defptr
		sta varbuf+2
		lda defptr+1
		sta varbuf+3
		lda #0
		sta defnum
scanvir1:
		inc defnum
		clc
		lda varbuf+2
		adc defsiz
		sta varbuf+2
		bcc scanvir2
		inc varbuf+3
scanvir2:
		jsr checkdef
		lda defnum
		cmp defcnt
		bne scanvir1
		lda change
		bne scanvirt // restart if a def was applied
		rts

// apply one def entry (the recipe) if possible - called from
// scanvirt with the def cursor already on the entry
// input
//   varbuf+2/+3 = address of the def table entry
//   list and obj table globals
// behavior
//   - a def whose three pieces are all zero is ignored
//   - every non zero piece type must be the type of some object
//     in the list (checkpc); the matching 1 based list entry
//     indexes are saved in piece1-3.  a zero piece passes with
//     index 0, which deletpc later ignores
//   - the obj table must contain an object of the def's own type
//     (scanobj)
//   - if all of that holds: append that object to the list (addpc),
//     delete the three used entries (deletpc), compact the list
//     (scandel) and set change
// output
//   change = 1 and the list table updated if the def was applied,
//   otherwise nothing
// memory
//   objtyp/objtyp+1 = work field (def type, then piece types)

checkdef:
		ldy #odpc1off
		lda (varbuf+2),y
		iny
		ora (varbuf+2),y
		bne checkd1
		ldy #odpc2off
		lda (varbuf+2),y
		iny
		ora (varbuf+2),y
		bne checkd1
		ldy #odpc3off
		lda (varbuf+2),y
		iny
		ora (varbuf+2),y
		bne checkd1
checkd0: // all pieces zero - nothing to do
		rts
checkd1:
		ldy #odpc1off
		jsr checkpc
		bcs checkd0 // piece not in the list - def cannot apply
		stx piece1
		ldy #odpc2off
		jsr checkpc
		bcs checkd0
		stx piece2
		ldy #odpc3off
		jsr checkpc
		bcs checkd0
		stx piece3
		ldy #odtypoff
		lda (varbuf+2),y
		sta objtyp
		iny
		lda (varbuf+2),y
		sta objtyp+1
		jsr scanobj
		bcs checkd0 // no object of the def's type
		jsr addpc // add the object the def builds
		ldx piece1
		jsr deletpc // remove the used pieces
		ldx piece2
		jsr deletpc
		ldx piece3
		jsr deletpc
checkd7:
		jsr scandel // compact the list over the holes
		lda #1
		sta change
		rts

// mark a list entry deleted by zeroing both of its bytes
// input
//   X = 1 based list entry index
// output
//   the entry is zeroed if the index is valid (C = 0 from
//   calclst).  the entry count is not changed and the entry is not
//   removed yet - scandel compacts the list and fixes the count
//   afterwards.  a zeroed entry counts as empty for scandel
// memory
//   varbuf/+1 = entry address

deletpc:
		jsr calclst
		bcs deletpc1
		sta varbuf
		sty varbuf+1
		lda #0
		tay
		sta (varbuf),y
		iny
		sta (varbuf),y
deletpc1:
		rts

// append an object index to the list
// input
//   X = object index to add, stored as the low byte of a new list
//       entry (high byte 0)
// output
//   the entry count (low byte of list[0]) is incremented and
//   copied to objnum, and the new entry is written at index objnum
//   (calclst computes its address - X equals objnum on that call)
//   A = the object index, Y = 1 on return
// memory
//   varbuf/+1 = list[0] address, then the new entry address

addpc:
		txa
		pha
		lda lstptr
		sta varbuf
		lda lstptr+1
		sta varbuf+1
		ldy #1
		lda (varbuf),y // current entry count
		tax
		inx // new count
		txa
		sta (varbuf),y // store it back
		stx objnum
		jsr calclst // X = objnum = index of the new entry
		sta varbuf
		sty varbuf+1
		ldy #0
		tya
		sta (varbuf),y // entry high byte = 0
		pla
		tax
		iny
		sta (varbuf),y // entry low byte = object index
		rts

// compact the list after deletions
// walks entries 1..objnum with two cursors: entries whose two
// bytes are both zero (deleted by deletpc) are dropped, all other
// entries are copied down to consecutive slots, and the entry
// count is updated
// input
//   lstptr, objnum (current count, including deleted entries)
// output
//   objnum and the low byte of list[0] = number of entries kept.
//   entries past the new count are left as stale data - the count
//   governs and they are never read
// memory
//   varbuf/+1 = write cursor, zp1 ($71) = read cursor
//   deltmp = entries kept + 1 (the count stored is deltmp-1)
//   X = entry number being examined, Y = byte index in an entry

scandel:
		lda lstptr
		sta varbuf
		sta zp1
		lda lstptr+1
		sta varbuf+1
		sta zp1+1
		ldx #0
		stx deltmp
scandel1:
		inc deltmp
		clc
		lda varbuf
		adc #2
		sta varbuf
		bcc scandel2
		inc varbuf+1
scandel2:
		cpx objnum
		beq scandel5 // all entries examined
		inx
		clc
		lda zp1
		adc #2
		sta zp1
		bcc scandel3
		inc zp1+1
scandel3:
		ldy #0
		lda (zp1),y
		iny
		ora (zp1),y
		beq scandel2 // empty entry - advance read cursor only
scandel4:
		lda (zp1),y // copy the 2 byte entry down to the
		sta (varbuf),y // next kept slot
		dey
		bpl scandel4
		jmp scandel1
scandel5:
		lda lstptr
		sta varbuf
		lda lstptr+1
		sta varbuf+1
		ldy #1
		lda deltmp
		sec
		sbc #1
		sta (varbuf),y // new entry count into list[0]
		sta objnum
		rts

// check one def piece type against the list
// input
//   Y = offset of the 16 bit piece field within the def entry
//   varbuf+2/+3 = address of the def table entry
// output
//   C = 0, X = 0    the piece is 0 (no piece) - treated as
//                   "present" so the def can still apply, but it
//                   matches no list entry
//   C = 0, X = 1..  the list holds an object of that type, X is
//                   its 1 based list entry index (scanlst)
//   C = 1           no object in the list has that type
// memory
//   objtyp/objtyp+1 = overwritten with the piece type (work field,
//   in table byte order)

checkpc:
		ldx #0
		clc
		lda (varbuf+2),y
		sta objtyp
		iny
		lda (varbuf+2),y
		sta objtyp+1
		ora objtyp
		beq checkpc1 // piece is 0 - "found" with index 0
		jsr scanlst
checkpc1:
		rts

// sub function 2 - is an object of a given type in the list?
// input
//   the next parameter is the 16 bit type to look for (getword:
//   high byte to objtyp, low byte to objtyp+1)
//   lstptr, objnum, objptr, objsiz, objcnt
// output
//   a% = 1 based index of the first list entry whose object has
//        that type, or 0 if there is none (scanlst / putint)

haveobjt:
		jsr getword
		sty objtyp
		stx objtyp+1
		jsr scanlst
		bcc haveobj1
		ldx #0
haveobj1:
		jmp putint

// sub function 3 - rebuild the list from the obj table
// input
//   the next two parameters are 16 bit values (getword):
//     target - the loc value an object must have
//     bitval - bits an object must not have set
//   lstptr, objptr, objsiz, objcnt
// behavior
//   the list is emptied (both bytes of list[0] zeroed, so the
//   count becomes 0), then obj entries 1..objcnt are scanned and
//   the index of every entry whose loc equals target and whose
//   bits ANDed with bitval give zero is appended (addpc)
// output
//   the list table (and objnum) - no a% result
// memory
//   varbuf/+1   = list[0] address while emptying the list
//   varbuf+2/+3 = obj table cursor (overlaps the FAC - safe, no
//                 arithmetic is done while it is live)
//   target, bitval

makelist:
		jsr getword
		sty target
		stx target+1
		jsr getword
		sty bitval
		stx bitval+1
		lda lstptr
		sta varbuf
		lda lstptr+1
		sta varbuf+1
		ldy #0
		lda #0
		sta (varbuf),y
		iny
		sta (varbuf),y // empty the list
		lda objptr
		sta varbuf+2
		lda objptr+1
		sta varbuf+3
		ldx #0
makelst1:
		inx
		clc
		lda varbuf+2
		adc objsiz
		sta varbuf+2
		bcc makelst2
		inc varbuf+3
makelst2:
		ldy #oblocoff
		lda (varbuf+2),y
		iny
		cmp target
		bne makelst3
		lda (varbuf+2),y
		cmp target+1
		bne makelst3 // loc must equal target
		ldy #obbitoff
		lda (varbuf+2),y
		iny
		and bitval
		bne makelst3
		lda (varbuf+2),y
		and bitval+1
		bne makelst3 // bits must not overlap bitval
		jsr addpc
makelst3:
		cpx objcnt
		bcc makelst1
		rts
