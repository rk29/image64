;image 2.0 equates

var = $61
chrget = $73
chrgot = $79
ridbe = $29b
ridbs = $29c

; control-codes

dish = $08     ; disable case-shift 
ensh = $09     ; enable case-shift
swlc = $0e     ; switch to lower case
swuc = $8e     ; switch to upper case
carriage_return = 13
cbm_backspace = 20
ascii_backspace = 8
ascii_bel = 7
ascii_escape = 27
ascii_formfeed = 12

cursor_right = $1d
cursor_left =  $9d
cursor_up =    $91
cursor_down =  $11
reverse_on =   $12
reverse_off =  $92
clear_screen = $93
cursor_home = $13
british_pound = $5c

function_key_2 = 137
function_key_5 = $87
function_key_6 = 139
function_key_7 = 136
function_key_8 = 140

cursor_black =    $90
cursor_white =    $05
cursor_red =      $1c
cursor_cyan =     $9f
cursor_purple =   $9c
cursor_green =    $1e
cursor_blue =     $1f
cursor_yellow =   $9e
cursor_orange =   $81
cursor_brown =    $95
cursor_lt_red =   $96
cursor_gray1 =    $97
cursor_gray2 =    $98
cursor_lt_green = $99
cursor_lt_blue =  $9a
cursor_gray3 =    $9b

ten = $dc08
scs = $dc09
min = $dc0a
hrs = $dc0b
;carrier = $dd01

getin = $ffe4
chkout= $ffc9
chrout= $ffd2
clrchn= $ffcc
chkin = $ffc6
setnam= $ffbd
setlfs= $ffba
loadf = $ffd5
savef = $ffd8
readst= $ffb7
romcolors= $e8da
chrin = $ffcf
setmsg= $ff90
openf = $ffc0
closef= $ffc3

poketok= 151
peektok= 194
systok = 158
loadtok= 147
newtok = 162

linkprg=$a533
makerm1=$b475
getbytc=$b79b
ptrget1=$b0e7
synerr =$af08
chrget =$73
getnum =$b7eb
ilqerr =$b248
chrgot =$79
retval =$bc49
parchk =$aef1
getadr =$b7f7
retbyt =$b3a2
gone1 = $a7e7
gone2 = $a7ea
eval1 = $ae8d
frmnum =$ad8a
syscll =$e130
comma = $aefd
getfile=57812
linget = $a96b
error = $a437
chkcom= $aefd

jmptbl = $a000
buffer = $ce77
buf2 = $ce27
fbuf = $ce13

bsnpre = $02fd
bsnval = $02fe

death= $1800
prgstart = $1801

protostart = $c000
protoend = $ca80

mainline = 1000
trapline = 2000
imodline = 2300
immdline = 3000
immdsize = $a00

tdisp=$0400+960
tcolr=$d800+960
sdisp=$0400+920
scolr=$d800+920
ldisp=$0400+640
lcolr=$d800+640
adisp=$0400+880
acolr=$d800+880

fkeybuf = 679 ;32
emptym0 = 711 ;57

cassbuff = 828
loadflag = 829
idlemax =830
datebuf = 831 ;11
daytbl = 842 ;24
tzoneh = 866
tzonem = 867
uzoneh = 868
uzonem = 869
wrapbuf = 870 ;80
wrapflg = 950
modclmn = 951
ptrclmn = 952
wrapind = 953
wrapdmp = 954
ptrclm = 955
modclm = 956
sndtim1 = 957
sndtim2 = 958
sndwav1 = 959
sndwav2 = 960
sndwav3 = 961
sndrept = 962
sndtim1a= 963
sndtim2a= 964
jiffy = 965
blnkflag =966
blnkcntr =967
ptrlin = 968
ptrlinm= 969
usrlin = 970
usrlinm= 971
fredmode= 972
montbl = 973 ; 36
rom0= 1009
timeset= 1010
flag1 = 1011
case1 = 1012
temp3 = 1015
mline = 1016
comm = 1017
flags = 1018
cline = 1019
lines = 1022
modes = 1023

gc = $c000
gchide = $e000
gclen = 4

ecs = $c000
ecshide = $e400
ecslen = 10

;screen parameters

mcolor = 646
mreverse = 199
curptr = 209
scnpos = 211
sline = 214
colptr = 243
undchr = 206
undcol = 647
crsrflg = 204
crsrmode = 207
scnclm = scnpos

mjump =$07e8
mresult=$07e9
mspeed =$07ea
mprint =$07eb
;mcolor =$07ec
;mprtr =$07ed
;mreverse=$07ee
mci =$07ef
mdigits=$07f0
carrst =$07f1
tsp1 =$07f2
tsp2 =$07f3
chks =$07f4
readmode=$07f6
filenum =$07f7
tmp5 =$07f8
abtchr =$07f9
clock =$07fa
filetyp =$07fb
tmp1 =$07fc
tmp2 =$07fd
tmp3 =$07fe
tmp4 =$07ff

local =$d000
case =$d001
editor =$d002
;tsr =$d003
llen =$d004
flag =$d005
chat =$d006
inchat =$d007
chatpage=$d008
carrier=$d009
mxor =$d00a
mkolor =$d00b
mupcase =$d00c
irqcount=$d00d
trans =$d00e
index =$d00f

tempscn = $1000 ;$140
tempscn0= tempscn+000
tempscn1= tempscn+040
tempscn2= tempscn+080
tempscn3= tempscn+120
tempscn4= tempscn+160
tempscn5= tempscn+200
tempscn6= tempscn+240
tempscn7= tempscn+280
tempcol = $1140 ;$140
tempcol0= tempcol+000
tempcol1= tempcol+040
tempcol2= tempcol+080
tempcol3= tempcol+120
tempcol4= tempcol+160
tempcol5= tempcol+200
tempcol6= tempcol+240
tempcol7= tempcol+280
emptym3 = $1280 ;96

idlejif=$12e0
idlesec=$12e1
idleten=$12e2
idlemin=$12e3
curdsp =$12e4
bar =$12e5
tsr2 =$12e6
mright =$12e7
mleft =$12e8
cphase =$12e9
key =$12ea
shft =$12eb
ptrlnfd=$12f0
ha577 =$12f1
mask =$12f2
scnmode=$12f3
dflag =$12f4
dstat =$12f5
cytmp =$12f6
interm =$12f7
cxsav =$12f8
len1 =$12f9
passmode=$12fa
scnlock =$12fb
tmp6 =$12fc
tmp7 =$12fd
freq =$12fe

rs232 = $0800
rsinabl = rs232+ $03
rsdisab = rs232+ $06
rsget = rs232+ $09
rsout = rs232+ $0c
rsbaud = rs232+ $0f
rschar = rs232+ $12

chktbl = $1300 ;$10
bartbl = $1310 ;$c0
arryptrs=$13d0 ;$10
daysofm= $13e0 ;$0c
emptym2= $13ec ;$04
sndtbl = $13f0 ;$60
netalrm= $1450 ;$30
tblatc = $1480 ;$80
tblcta = $1500 ;$100
tblcta1= $1600 ;$20
tblcta2= $1620 ;$20
tblcta3= $1640 ;$20
alarmtb= $1660 ;$80
date1 = $16e0 ;$20
lobytes =$1700 ;25
hibytes =$1719 ;25
lobytec =$1732 ;25
hibytec =$174b ;25
emptym4 =$1764 ;28
pmodetbl=$1780 ;$80

ribuf = $0b00
robuf = $0b80

wedgemem= $0c00
trapoff =wedgemem+0
trapon = wedgemem+3
loadprg =wedgemem+6
arraysav=wedgemem+9
arrayres=wedgemem+12
forcegc =wedgemem+15

; interface page jump table

outastrp= $cd00+0
usetbl1= $cd00+3
swapper= $cd00+6
swapagn= $cd00+9
trace= $cd00+12
chkspcl= $cd00+15
convchr= $cd00+18
fnvar= $cd00+21
fnvar1= $cd00+24
evalstr= $cd00+27
evalbyt= $cd00+30
evalint= $cd00+33
evalfil= $cd00+36

d1icr = $dc0d
timblo= $dc06
timbhi= $dc07
ciacrb= $dc0f

ltk_bnkout= $fc4e
ltk_bankin= $fc71
ltk_getprt= $9f03
ltk_driver= $8045
ltk_redbuf= $91e0
ltk_clrhdr= $806c
ltk_fnfile= $804b
ltk_alcont= $807b
ltk_mnsext= $809c
ltk_output= $8048
ltk_activl= $8000
ltk_activu= $8001
ltk_setlun= $8099

hdrblk=$91e0
filnam=hdrblk+$00
filtyp=hdrblk+$18
nbinfl=hdrblk+$10
loadad=hdrblk+$1a
blmilo=hdrblk+$20
nrpblk=hdrblk+$12

