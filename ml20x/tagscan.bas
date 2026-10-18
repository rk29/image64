10 rem ****************************************************
20 rem  tagscan "&,16" command - basic usage examples
30 rem ****************************************************
40 rem
50 rem  every sub function of tagscan is reached through
60 rem  its common entry point (entry1/entry2) as:
70 rem    &,16,sub,0,list(0),obj(0),objsize,def(0),defsize
80 rem  plus any extra parameters the sub function needs:
90 rem    sub 0: scanvirt  - apply def recipes
100 rem   sub 1: findobjd  - def for the object in list(x)
110 rem   sub 2: haveobjt  - is a type in the list?
120 rem   sub 3: makelist  - rebuild list from obj table
130 rem  findobjd and haveobjt put their result in a%
140 rem  (0 = not found).  scanvirt and makelist return
150 rem  nothing - their result is the list itself.
160 rem
170 rem  the three tables live in integer arrays.  each
180 rem  array's element 0 holds the entry count:
190 rem    list - 1 element per entry
200 rem    obj  - objsize/2 elements per entry.  with
210 rem           objsize 6 an entry is 3 elements:
220 rem           bits, type, loc.  entry i starts at
230 rem           element 3*i
240 rem    def  - defsize/2 elements per entry.  with
250 rem           defsize 10 an entry is 5 elements:
260 rem           bits, type, piece1, piece2, piece3.
270 rem           entry i starts at element 5*i
280 rem
290 rem  the example world: objects 1-4 are a nail, a
300 rem  board, a hammer and a house (types 1-4).  the
310 rem  nail, board and hammer are at location 10, and
320 rem  one def combines them into the house.
330 rem
340 rem  requires the image64 ml wedge active and the
350 rem  tagscan module loaded ("++ tagscan").  without
360 rem  the wedge, & gives ?syntax error.
370 rem
380 rem  ---------- set up the tables ----------
390 dim li%(8):dim ob%(14):dim df%(9)
400 rem  obj table, 4 objects
410 ob%(0)=4
420 rem  obj 1: nail - bits 0, type 1, loc 10
430 ob%(3)=0:ob%(4)=1:ob%(5)=10
440 rem  obj 2: board
450 ob%(6)=0:ob%(7)=2:ob%(8)=10
460 rem  obj 3: hammer, bit 0 of bits set
470 ob%(9)=1:ob%(10)=3:ob%(11)=10
480 rem  obj 4: house
490 ob%(12)=0:ob%(13)=4:ob%(14)=0
500 rem  def table, 1 def
510 df%(0)=1
520 rem  def 1: bits (unused) 0, builds type 4, pieces
530 rem  are types 1, 2 and 3
540 df%(5)=0:df%(6)=4:df%(7)=1:df%(8)=2:df%(9)=3
550 rem  the list starts empty
560 li%(0)=0
570 rem
580 rem ****************************************************
590 rem  example 1: makelist (sub function 3)
600 rem    &,16,3,0,list(0),obj(0),objsize,def(0),
610 rem            defsize,target,bitmask
620 rem ****************************************************
630 rem  empties the list, then appends every object
640 rem  whose loc equals target and whose bits anded
650 rem  with bitmask are zero.  bitmask 1 leaves out
660 rem  the hammer (bit 0 set); the house is at loc 0:
670 print "makelist: loc 10, bitmask 1"
680 &,16,3,0,li%(0),ob%(0),6,df%(0),10,10,1
690 gosub 9000
700 print "expected: 1 2 (nail, board)"
710 print
720 print "makelist: loc 10, bitmask 0"
730 &,16,3,0,li%(0),ob%(0),6,df%(0),10,10,0
740 gosub 9000
750 print "expected: 1 2 3 (nail, board, hammer)"
760 print
770 rem
780 rem ****************************************************
790 rem  example 2: haveobjt (sub function 2)
800 rem    &,16,2,0,list(0),obj(0),objsize,def(0),
810 rem            defsize,objtyp
820 rem ****************************************************
830 rem  a% = index of the first list entry whose
840 rem  object has the given type, else 0:
850 print "haveobjt: type 2 (board)"
860 &,16,2,0,li%(0),ob%(0),6,df%(0),10,2
870 print "a% =";a%;" (entry 2 is the board)"
880 print "haveobjt: type 4 (house)"
890 &,16,2,0,li%(0),ob%(0),6,df%(0),10,4
900 print "a% =";a%;" (no house in the list)"
910 print
920 rem
930 rem ****************************************************
940 rem  example 3: findobjd (sub function 1)
950 rem    &,16,1,0,list(x),obj(0),objsize,def(0),
960 rem            defsize
970 rem ****************************************************
980 rem  the object number to look up is read from list
990 rem  element x.  list(1) = 1 (the nail).  no def
1000 rem  builds a nail, so a% = 0:
1010 print "findobjd: list(1) = nail"
1020 &,16,1,0,li%(1),ob%(0),6,df%(0),10
1030 print "a% =";a%;" (no def builds a nail)"
1040 print
1050 rem
1060 rem ****************************************************
1070 rem  example 4: scanvirt (sub function 0)
1080 rem    &,16,0,0,list(0),obj(0),objsize,def(0),
1090 rem            defsize
1100 rem ****************************************************
1110 rem  repeatedly applies every def whose three
1120 rem  piece types are all present in the list,
1130 rem  removing the pieces and appending the object
1140 rem  the def builds, until nothing changes.  the
1150 rem  nail, board and hammer become a house:
1160 print "scanvirt"
1170 &,16,0,0,li%(0),ob%(0),6,df%(0),10
1180 gosub 9000
1190 print "expected: 4 (house)"
1200 rem  the same calls as in examples 2 and 3 now
1210 rem  answer differently.  list(1) = 4 (house):
1220 print "findobjd: list(1) = house"
1230 &,16,1,0,li%(1),ob%(0),6,df%(0),10
1240 print "a% =";a%;" (def 1 builds the house)"
1250 print "haveobjt: type 4 (house)"
1260 &,16,2,0,li%(0),ob%(0),6,df%(0),10,4
1270 print "a% =";a%;" (entry 1 is the house)"
1280 print "haveobjt: type 3 (hammer)"
1290 &,16,2,0,li%(0),ob%(0),6,df%(0),10,3
1300 print "a% =";a%;" (the hammer was used up)"
1310 end
1320 rem
9000 rem  ---------- print the list ----------
9010 print "list:";li%(0);" entries:";
9020 for i=1 to li%(0)
9030 print li%(i);
9040 next
9050 print
9060 return
