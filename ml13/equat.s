var = $61
chrget = $73
chrgot = $79
scnclm = 2
ridbe = $29b
ridbs = $29c
scnpos = 2
;

; control-codes

dish = $08     ; disable case-shift 
ensh = $09     ; enable case-shift
swlc = $0e     ; switch to lower case

cursor_right = $1d
cursor_left =  $9d
cursor_up =    $91
cursor_down =  $11
reverse_on =   $12
reverse_off =  $92
clear_screen = $93
cursor_home = $13

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

;
ten = $dc08
scs = $dc09
min = $dc0a
hrs = $dc0b
carrier = $dd01
;
getin = $ffe4
chkout = $ffc9
chrout = $ffd2
clrchn = $ffcc
chkin = $ffc6
setnam = $ffbd
setlfs = $ffba
loadf = $ffd5
savef = $ffd8
readst = $ffb7
romcolors = $e8da
chrin = $ffcf
setmsg = $ff90
;
linkprg = $a533
makerm1 = $b475
getbytc = $b79b
ptrget1 = $b0e7
;
usetbl1 = $cd03
buffer = $ce77
buf2 = $ce27
;
prgstart = $0801
bmpstart = $1001
mmpstart = $2001
lmpstart = $3001
prgend = $4000
imstart = $4601
protostart = $c000
protoend = $cb00
;
rs232 = $4300
rsinabl = rs232 + $03
rsdisab = rs232 + $06
rsget = rs232 + $09
rsout = rs232 + $0c
rsbaud = rs232 + $0f
rschar = rs232 + $12
;
swapper = $ca80
swapagn = $ca88
;
trapline = 2000
immdline = 3000
;
tempbott = $4000
tempbotc = $4050
pmodetbl = $40a0
;
light = $04f0
;
tempscn = $4100 ;$f0
tempcol = $41f0 ;$f0
fkeybuf = $42e0 ;$20
;
basintr = $2a7
sizintr = 83
tsr = basintr + 0
llen = basintr+1
scnmode = basintr+2
mask = basintr+3
mci = basintr+4
local = basintr+5
clock = basintr+6
carrst = basintr+7
mxor = basintr+8
modclmn = basintr+9
ptrclmn = basintr+10
mjump = basintr+11
chatpage = basintr+12
readmode = basintr+13
case = basintr+14
editor = basintr+15
mupcase = basintr+16
wrapflg = basintr+17
flag = basintr+18
idlemax = basintr+19
modes = basintr+20
lines = basintr+21
cline = basintr+22
flags = basintr+23
mline = basintr+24
mresult = basintr+25
mspeed = basintr+26
mprint = basintr+27
mcolor = basintr+28
mprtr = basintr+29
mreverse = basintr+30
mdigits = basintr+31
;
filetyp = basintr+32
curdsp = basintr+33
interm = basintr+34
idlejif = basintr+35
idlesec = basintr+36
idleten = basintr+37
idlemin = basintr+38
tsr2 = basintr+39
undchr = basintr+40
undcol = basintr+41
cphase = basintr+42
key = basintr+43
shft = basintr+44
dflag = basintr+45
dstat = basintr+46
cytmp = basintr+47
cxsav = basintr+48
chat = basintr+49
inchat = basintr+50
interm = basintr+51
access = basintr+52
mkolor = basintr+53
irqcount = basintr+54
wrapind = basintr+55
wrapdmp = basintr+56
ptrclm = basintr+57
modclm = basintr+58
;scnclm = basintr+59
comm = basintr+60
temp3 = basintr+61
case1 = basintr+62
flag1 = basintr+63
sndtim1 = basintr+64
sndtim2 = basintr+65
sndwav1 = basintr+66
sndwav2 = basintr+67
sndwav3 = basintr+68
sndrept = basintr+69
sndtim1a = basintr+70
sndtim2a = basintr+71
scnlock = basintr+72
bar = basintr+73
passmode = basintr+74
filenum = basintr+75
len1 = basintr+76
jiffy = basintr+77
ptrlnfd = basintr+78
blnkflag = basintr+79
blnkcntr = basintr+80
outadjs = basintr+81
oldtsr = basintr+82
;
tmp1 = $d000
tmp2 = $d001
tmp3 = $d002
tmp4 = $d003
tmp5 = $d004
tmp6 = $d005
tmp7 = $d006
;
trans = $d00e
index = $d00f
;
datebuf = 828 ;$0b
date1 = 839 ;$1c
wrapbuf = 867 ;$50
;
gc = $c000
gchide = $e000
gclen = 4
;
ecs = $c000
ecshide = $e400
ecslen = 10
;
;
bsnpre = $02fd
bsnval = $02fe

; FIXME unknown value
nchk1 = $00
