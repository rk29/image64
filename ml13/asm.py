#! /usr/bin/env python

import sys
import string
import traceback

encode_value = 0
address_offset = 0
address = 0

def emit_byte(b):
#	print "%04x: %02x" % (address, b)
	if b < 0 or b > 255:
		raise Exception, "byte value out of range (%s)" % b
	global address
	address = address + 1
	if pass_number == 3:
		outfile.write(chr(b ^ encode_value))

def emit_word(w):
	emit_byte(w & 0xFF)
	emit_byte((w >> 8) & 0xFF)

MODE_RELATIVE = "REL"
MODE_IMPLIED =   "IMP"
MODE_IMMEDIATE = "IMM"
MODE_ABSOLUTE =  "ABS"
MODE_ABSOLUTE_X = "ABSX"
MODE_ABSOLUTE_Y = "ABSY"
MODE_INDIRECT =  "IND"
MODE_INDIRECT_X = "INDX"
MODE_INDIRECT_Y = "INDY"
MODE_ZEROPAGE =   "ZP"
MODE_ZEROPAGE_X = "ZPX"
MODE_ZEROPAGE_Y = "ZPY"

asc_to_cbm = (range(0,64) + [ ord("@") ] +  range(193,224) + [ ord("@") ] + range(65,96)) * 2
cbm_to_scn = range(0,64) + range(0,64) + range(0,64) + range(64,128)

def parse_operand(f):
	tok, value = lex(f)
	if tok == TOK_EOL:
		unlex(tok, value)
		return (MODE_IMPLIED, 0)
	if tok == TOK_LBRACKET:
		mode = MODE_INDIRECT
		tok, operand = parse_expr(f)
		if tok == TOK_STRING:
			if len(operand) != 1:
				raise Exception, "can only convert single character strings"
			operand = ord(operand[0])
			tok = TOK_NUMBER
		tok, value = lex(f)
		if tok == TOK_COMMA:
			ch = getchr(f)
			if ch == "x":
				tok, value = lex(f)
				if tok != TOK_RBRACKET:
					raise Exception, "closing bracket expected"
				return (MODE_INDIRECT_X, operand)
			else:
				raise Exception, "syntax error. (value,x) expected"
		elif tok != TOK_RBRACKET:
			raise Exception, "closing bracket expected"
		tok, value = lex(f)
		if tok != TOK_COMMA:
			unlex(tok, value)
			return (MODE_INDIRECT, operand)
		ch = getchr(f)
		if ch == "y":
			return (MODE_INDIRECT_Y, operand)
		raise Exception, "syntax error. (value),y expected"
	elif tok == TOK_IMMEDIATE:
		tok, operand = parse_expr(f)
		if tok == TOK_STRING:
			if len(operand) != 1:
				raise Exception, "can only convert single character strings"
			operand = ord(operand[0])
			tok = TOK_NUMBER
		return (MODE_IMMEDIATE, operand)
	unlex(tok, value)
	tok, operand = parse_expr(f)
	if tok == TOK_STRING:
		if len(operand) != 1:
			raise Exception, "can only convert single character strings"
		operand = ord(operand[0])
		tok = TOK_NUMBER
	tok, value = lex(f)
	if tok == TOK_COMMA:
		ch = getchr(f)
		if ch == "x":
			return (MODE_ABSOLUTE_X, operand)
		if ch == "y":
			return (MODE_ABSOLUTE_Y, operand)
		raise Exception, "syntax error. value,x or value,y expected"
	else:
		unlex(tok,value)
	return (MODE_ABSOLUTE, operand)
		
def demote_mode(mode):
	if mode == MODE_ABSOLUTE:   return MODE_ZEROPAGE
	if mode == MODE_ABSOLUTE_X: return MODE_ZEROPAGE_X
	if mode == MODE_ABSOLUTE_Y: return MODE_ZEROPAGE_Y
	return mode
	
def assemble_op(opcode, mode, operand):
	emit_byte(opcode)
	if mode in [ MODE_IMMEDIATE, MODE_ZEROPAGE, MODE_ZEROPAGE_X, MODE_ZEROPAGE_Y, MODE_INDIRECT_X, MODE_INDIRECT_Y]:
		emit_byte(operand & 0xFF)
	elif mode in [ MODE_ABSOLUTE, MODE_ABSOLUTE_X, MODE_ABSOLUTE_Y, MODE_INDIRECT ]:
		emit_word(operand & 0xFFFF)
	elif mode == MODE_RELATIVE:
		offset = operand - (address + address_offset + 1)
		if (offset < -128) or (offset > 127):
			if (pass_number == 3):
				print address, operand, offset
				raise Exception, "branch out of range %d" % offset
			else:
				offset = 0
		emit_byte(offset & 0xFF)

def assemble(f, op):
	opcodes = ops[op]
	mode, operand = parse_operand(f)
	if operand < 0x100:
		temp = demote_mode(mode)
		if opcodes.has_key(temp):
			mode = temp
	if opcodes.has_key(MODE_RELATIVE) and mode == MODE_ABSOLUTE:
		mode = MODE_RELATIVE
	if opcodes.has_key(mode):
		assemble_op(opcodes[mode], mode, operand)
	else:
		raise Exception, "invalid operation mode (%s) for opcode '%s'" % (mode, op)

def directive_align(f):
	tok, value = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
	
	n = value - (address + address_offset) % value
	if n != value:
		for i in range(n):
			emit_byte(0)

def directive_offset(f):
	tok, value = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
	global address_offset
	address_offset = value
	
def directive_enc(f):
	tok, value = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
		
	global encode_value
	encode_value = value

def directive_include(f):
	tok, value = parse_expr(f)
	if tok != TOK_STRING:
		raise Exception, "type mismatch"
	temp_linenum = line_number
	includefile = open(value, "r")
	parse(includefile)
	includefile.close() 
	global line_number
	line_number = temp_linenum
	
def directive_org(f):

	tok, addr = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
	tok, value = lex(f)
	if tok != TOK_COMMA:
		raise Exception, "comma expected"
	tok, filename = parse_expr(f)
	if tok != TOK_STRING:
		raise Exception, "type mismatch"

	if pass_number == 3:
		global outfile
		outfile = open(filename, "w")
		emit_word(addr)

	global address
	address = addr

	global address_offset
	address_offset = 0
	
def directive_word(f):
	done = 0
	while not done:
		tok, value = parse_expr(f)
		if tok != TOK_NUMBER:
			raise Exception, "type mismatch"
		emit_word(value)
		tok, value = lex(f)
		if tok != TOK_COMMA:
			done = 1
			unlex(tok, value)	
	
def directive_cbm(f):
	done = 0
	while not done:
		tok, value = parse_expr(f)
		if tok == TOK_NUMBER:
			emit_byte(asc_to_cbm[value])
		elif tok == TOK_STRING:
			for ch in value:
				emit_byte(asc_to_cbm[ord(ch)])
		else:
			raise Exception, "type mismatch"
		tok, value = lex(f)
		if tok != TOK_COMMA:
			done = 1
			unlex(tok, value)

def directive_scn(f):
	done = 0
	while not done:
		tok, value = parse_expr(f)
		if tok == TOK_NUMBER:
			emit_byte(cbm_to_scn[asc_to_cbm[value]])
		elif tok == TOK_STRING:
			for ch in value:
				emit_byte(cbm_to_scn[asc_to_cbm[ord(ch)]])
		else:
			raise Exception, "type mismatch"
		tok, value = lex(f)
		if tok != TOK_COMMA:
			done = 1
			unlex(tok, value)

def directive_byte(f):
	done = 0
	while not done:
		tok, value = parse_expr(f)
		if tok == TOK_NUMBER:
			emit_byte(value)
		elif tok == TOK_STRING:
			for ch in value:
				emit_byte(ord(ch))
		else:
			raise Exception, "type mismatch"
		tok, value = lex(f)
		if tok != TOK_COMMA:
			done = 1
			unlex(tok, value)

def directive_dup(f):
	tok, value = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
	tok, comma = lex(f)
	if tok != TOK_COMMA:
		raise Exception, "comma expected"
	tok, count = parse_expr(f)
	if tok != TOK_NUMBER:
		raise Exception, "type mismatch"
	if count < 0:
		print "warning, count value < 0 (%d) in line %d" % (count, line_number)
#		raise Exception, "illegal count value (%d)" % count
	if count > 0:
		for i in range(count):
			emit_byte(value)

ops = { 
	"bcc" : { "REL" : 0x90 }, 
	"bcs" : { "REL" : 0xB0 }, 
	"beq" : { "REL" : 0xF0 },
	"bmi" : { "REL" : 0x30 }, 
	"bne" : { "REL" : 0xD0 }, 
	"bpl" : { "REL" : 0x10 }, 
	"bvc" : { "REL" : 0x50 }, 
	"bvs" : { "REL" : 0x70 }, 
	"adc" : { "IMM" : 0x69, "ZP" : 0x65, "ZPX" : 0x75,               "ABS" : 0x6D, "ABSX" : 0x7D, "ABSY" : 0x79, "INDX" : 0x61, "INDY" : 0x71 },
	"and" : { "IMM" : 0x29, "ZP" : 0x25, "ZPX" : 0x35,               "ABS" : 0x2D, "ABSX" : 0x3D, "ABSY" : 0x39, "INDX" : 0x21, "INDY" : 0x31 },
	"eor" : { "IMM" : 0x49, "ZP" : 0x45, "ZPX" : 0x55,               "ABS" : 0x4D, "ABSX" : 0x5D, "ABSY" : 0x59, "INDX" : 0x41, "INDY" : 0x51 }, 
	"lda" : { "IMM" : 0xA9, "ZP" : 0xA5, "ZPX" : 0xB5,               "ABS" : 0xAD, "ABSX" : 0xBD, "ABSY" : 0xB9, "INDX" : 0xA1, "INDY" : 0xB1 },
	"ldx" : { "IMM" : 0xA2, "ZP" : 0xA6,               "ZPY" : 0xB6, "ABS" : 0xAE,                "ABSY" : 0xBE }, 
# FIXME check on ldy zp,y. I don't think it exists.
	"ldy" : { "IMM" : 0xA0, "ZP" : 0xA4,               "ZPY" : 0xB4, "ABS" : 0xAC,                "ABSY" : 0xBC }, 
	"ora" : { "IMM" : 0x09, "ZP" : 0x05, "ZPX" : 0x15,               "ABS" : 0x0D, "ABSX" : 0x1D, "ABSY" : 0x19, "INDX" : 0x01, "INDY" : 0x11 }, 
	"sbc" : { "IMM" : 0xE9, "ZP" : 0xE5, "ZPX" : 0xF5,               "ABS" : 0xED, "ABSX" : 0xFD, "ABSY" : 0xF9, "INDX" : 0xE1, "INDY" : 0xF1 }, 
	"sta" : {               "ZP" : 0x85, "ZPX" : 0x95,               "ABS" : 0x8D, "ABSX" : 0x9D, "ABSY" : 0x99, "INDX" : 0x81, "INDY" : 0x91 },
	"stx" : {               "ZP" : 0x86,               "ZPY" : 0x96, "ABS" : 0x8E },
	"sty" : {               "ZP" : 0x84, "ZPX" : 0x94,               "ABS" : 0x8C }, 
	"dec" : {               "ZP" : 0xC6, "ZPX" : 0xD6,               "ABS" : 0xCE, "ABSX" : 0xDE }, 
	"dex" : { "IMP" : 0xCA }, 
	"dey" : { "IMP" : 0x88 }, 
	"inc" : {               "ZP" : 0xE6, "ZPX" : 0xF6,               "ABS" : 0xEE, "ABSX" : 0xFE }, 
	"inx" : { "IMP" : 0xE8 }, 
	"iny" : { "IMP" : 0xC8 }, 
	"asl" : { "IMP" : 0x0A, "ZP" : 0x06, "ZPX" : 0x16,               "ABS" : 0x0E, "ABSX" : 0x1E }, 
	"lsr" : { "IMP" : 0x4A, "ZP" : 0x46, "ZPX" : 0x56,               "ABS" : 0x4E, "ABSX" : 0x5E }, 
	"rol" : { "IMP" : 0x2A, "ZP" : 0x26, "ZPX" : 0x36,               "ABS" : 0x2E, "ABSX" : 0x3E }, 
	"ror" : { "IMP" : 0x6A, "ZP" : 0x66, "ZPX" : 0x76,               "ABS" : 0x6e, "ABSX" : 0x7E }, 
	"cmp" : { "IMM" : 0xC9, "ZP" : 0xC5, "ZPX" : 0xd5,               "ABS" : 0xCD, "ABSX" : 0xDD, "ABSY" : 0xD9 }, 
	"cpx" : { "IMM" : 0xE0, "ZP" : 0xE4,                             "ABS" : 0xEC }, 
	"cpy" : { "IMM" : 0xC0, "ZP" : 0xC4,                             "ABS" : 0xCC }, 
	"jsr" : {                                                        "ABS" : 0x20 }, 
	"jmp" : {                                                        "ABS" : 0x4C, "IND" : 0x6C }, 
	"bit" : {               "ZP" : 0x24,                             "ABS" : 0x2C }, 
	"brk" : { "IMP" : 0x00 }, 
	"clc" : { "IMP" : 0x18 }, 
	"cld" : { "IMP" : 0xD8 }, 
	"cli" : { "IMP" : 0x58 }, 
	"clv" : { "IMP" : 0xB8 }, 
	"nop" : { "IMP" : 0xEA }, 
	"pha" : { "IMP" : 0x48 }, 
	"php" : { "IMP" : 0x08 }, 
	"pla" : { "IMP" : 0x68 }, 
	"plp" : { "IMP" : 0x28 }, 
	"rti" : { "IMP" : 0x40 }, 
	"rts" : { "IMP" : 0x60 }, 
	"sec" : { "IMP" : 0x38 }, 
	"sed" : { "IMP" : 0xF8 }, 
	"sei" : { "IMP" : 0x78 }, 
	"tax" : { "IMP" : 0xAA }, 
	"tay" : { "IMP" : 0xA8 }, 
	"tsx" : { "IMP" : 0xBA }, 
	"txa" : { "IMP" : 0x8A }, 
	"txs" : { "IMP" : 0x9A }, 
	"tya" : { "IMP" : 0x98 }
}

directives = {
	"org" : directive_org,
	"word" : directive_word,
	"byte" : directive_byte,
	"dup" : directive_dup,
	"cbm" : directive_cbm,
	"scn" : directive_scn,
	"include" : directive_include,
	"enc" : directive_enc,
	"offset" : directive_offset,
	"align" : directive_align
}

symbols = { }
unget = None
line_number = 1
pass_number = 1

def getchr(f):
	global unget
	
	if unget is not None:
		ch = unget
		unget = None
		return ch

	ch = f.read(1)
	
	if ch == "\n":
		global line_number
		line_number = line_number + 1
	return ch
	
def ungetchr(f, ch):
	global unget
	unget = ch
	
ident_start = "_abcdefghijklmnopqrstuvwxyz"
ident_chars = ident_start + "0123456789"
whitespace = " \r\t"
hexnums = "0123456789abcdef"
digits = "0123456789"

TOK_EOF = 0
TOK_IDENT = 1
TOK_EQUAL = 2
TOK_COLON = 3
TOK_OP = 4
TOK_NUMBER = 5
TOK_PLUS = 6
TOK_MINUS = 7
TOK_LBRACKET = 8
TOK_RBRACKET = 9
TOK_COMMA = 10
TOK_IMMEDIATE = 11
TOK_EOL = 12
TOK_DIRECTIVE = 13
TOK_STRING = 14
TOK_LESS_THAN = 15
TOK_GREATER_THAN = 16
TOK_ASTERISK = 17
TOK_OPEN_PAREN = 18
TOK_CLOSE_PAREN = 19
TOK_DIVIDE = 20
TOK_NOT = 21
TOK_OR = 22

tokens = {
	"+" : TOK_PLUS,
	"-" : TOK_MINUS,
	"=" : TOK_EQUAL,
	":" : TOK_COLON,
	"[" : TOK_LBRACKET,
	"]" : TOK_RBRACKET,
	"," : TOK_COMMA,
	"#" : TOK_IMMEDIATE,
	">" : TOK_GREATER_THAN,
	"<" : TOK_LESS_THAN,
	"*" : TOK_ASTERISK,
	"(" : TOK_OPEN_PAREN,
	")" : TOK_CLOSE_PAREN,
	"/" : TOK_DIVIDE,
	"\n" : TOK_EOL,
	"not" : TOK_NOT,
	"or" : TOK_OR
}

def lex_ident(f, ch):
	ident = ""
	while ch in ident_chars:
		ident = ident + ch
		ch = getchr(f)
	ungetchr(f, ch)
	if ops.has_key(ident):
		return (TOK_OP, ident)
	if directives.has_key(ident):
		return (TOK_DIRECTIVE, ident)
	if tokens.has_key(ident):
		return (tokens[ident], ident)
	return (TOK_IDENT, ident)

def convert_hex(ch):
	if ch in digits:
		return ord(ch) - ord("0")
	if ch in "abcdef":
		return ord(ch) - ord("a") + 10
	raise Exception, "invalid hex digit '%c'" % ch
	
def lex_hexnum(f):
	value = 0
	ch = getchr(f)
	while ch in hexnums:
		value = value * 16 + convert_hex(ch)
		ch = getchr(f)
	ungetchr(f, ch)
	return (TOK_NUMBER, value)

def convert_dec(ch):
	if ch in digits:
		return ord(ch) - ord("0")
	raise Exception, "invalid digit '%c'" % ch

def lex_decimal(f, ch):
	value = convert_dec(ch)
	ch = getchr(f)
	while ch in digits:
		value = value * 10 + convert_dec(ch)
		ch = getchr(f)
	ungetchr(f, ch)
	return (TOK_NUMBER, value)

def lex_string(f):
	value = ""
	ch = getchr(f)
	while (ch != "") and (ch != '"'):
		if ch == "\n":
			raise Exception, "unterminated string"
		value = value + ch
		ch = getchr(f)
	return (TOK_STRING, value)
	
unlex_buffer = None

def unlex(tok, value):
	global unlex_buffer
	unlex_buffer = (tok, value)	


def lex0(f):
	global unlex_buffer
	if unlex_buffer != None:
		temp = unlex_buffer
		unlex_buffer = None
		return temp
	ch = getchr(f)
	while ch != "":
		if ch in ident_start:
			return lex_ident(f, ch)
		elif tokens.has_key(ch):
			return (tokens[ch], ch)
		elif ch == ";":
			ch = getchr(f)
			while (ch != "\n") and (ch != ""):
				ch = getchr(f)
			if ch == "\n":
				ungetchr(f, ch)
		elif ch in whitespace:
			pass
		elif ch == "$":
			return lex_hexnum(f)
		elif ch in digits:
			return lex_decimal(f, ch)
		elif ch == '"':
			return lex_string(f)
		else:
			raise Exception, "unexpected character '%c'" % ch
		ch = getchr(f)
	return (TOK_EOF, ch)

def lex(f):
	result = lex0(f)
#	print result
	return result

def parse_expr3(f):
	tok, value = lex(f)
	if tok == TOK_NUMBER:
		return (TOK_NUMBER, value)
	if tok == TOK_IDENT:
		if symbols.has_key(value):
			return symbols[value]
		if pass_number == 1:
			return (TOK_NUMBER, 0)
		raise Exception, "symbol not found '%s'" % value
	if tok == TOK_STRING:
		return (TOK_STRING, value)
	if tok == TOK_ASTERISK:
		return (TOK_NUMBER, address + address_offset)	
	if tok == TOK_OPEN_PAREN:
		tok1, value1 = parse_expr(f)
		tok, value = lex(f)
		if tok != TOK_CLOSE_PAREN:
			raise Exception, "parenthesis mismatch"
		return (tok1, value1)
	raise Exception, "unexpected input (%s,%s)" % (tok, value)

def parse_expr2(f):
	tok, value = lex(f)
	if tok == TOK_LESS_THAN:
		tok, value = parse_expr3(f)
		if tok != TOK_NUMBER:
			raise Exception, "type mismatch"
		return (tok, value & 0xFF)
	if tok == TOK_GREATER_THAN:
		tok, value = parse_expr3(f)
		if tok != TOK_NUMBER:
			raise Exception, "type mismatch"
		return (tok, (value >> 8) & 0xFF)
	if tok == TOK_NOT:
		tok, value = parse_expr2(f)
		if tok != TOK_NUMBER:
			raise Exception, "type mismatch"
		return (tok, ~value)
	unlex(tok, value)
	return parse_expr3(f)

def parse_expr1(f):
	tok1, value1 = parse_expr2(f)
	
	while 1:
		tok, value = lex(f)
		if tok == TOK_ASTERISK:
			tok2, value2 = parse_expr2(f)
			if tok2 != tok1:
				raise Exception, "type mismatch"
			if tok1 != TOK_NUMBER:
				raise Exception, "invalid math operation"
			value1 = value1 * value2
		elif tok == TOK_DIVIDE:
			tok2, value2 = parse_expr2(f)
			if tok1 != tok2:
				raise Exception, "type mismatch"
			if tok1 != TOK_NUMBER:
				raise Exception, "invalid math operation"
			value1 = value1 / value2
		else:
			unlex(tok, value)
			return (tok1, value1)

def parse_expr0(f):
	tok1, value1 = parse_expr1(f)
	
	while 1:
		tok, value = lex(f)
		if tok == TOK_PLUS:
			tok2, value2 = parse_expr1(f)
			if tok2 != tok1:
				raise Exception, "type mismatch"
			value1 = value1 + value2
		elif tok == TOK_MINUS:
			tok2, value2 = parse_expr1(f)
			if tok1 != tok2:
				raise Exception, "type mismatch"
			if tok1 != TOK_NUMBER:
				raise Exception, "invalid math operation"
			value1 = value1 - value2
		else:
			unlex(tok, value)
			return (tok1, value1)

def parse_expr(f):
	tok1, value1 = parse_expr0(f)
	
	tok, value = lex(f)
	if (tok == TOK_OP) and (value == "and"):
		tok2, value2 = parse_expr0(f)
		if tok2 != tok1:
			raise Exception, "type mismatch"
		if tok1 != TOK_NUMBER:
			raise Exception, "invalid math operation"
		result = value1 & value2
		return (tok1, result)
	if tok == TOK_OR:
		tok2, value2 = parse_expr0(f)
		if tok1 != tok2:
			raise Exception, "type mismatch"
		if tok1 != TOK_NUMBER:
			raise Exception, "invalid math operation"
		result = value1 | value2
		return (tok1, result)
	unlex(tok, value)
	return (tok1, value1)

def parse_eol(f):
	tok, value = lex(f)
	if tok != TOK_EOL:
		raise Exception, "extra input on end of line (%s,%s)" % (tok, value)

def parse(f):
	tok, value  = lex(f)
	while tok != TOK_EOF:
		if tok == TOK_IDENT:
			name = value
			tok, value = lex(f)
			if tok == TOK_COLON:
				symbols[name] = (TOK_NUMBER, address + address_offset)
			elif tok == TOK_EQUAL:
				value = parse_expr(f)
				symbols[name] = value
				parse_eol(f)
			else:
				raise Exception, "syntax error"
		elif tok == TOK_DIRECTIVE:
			directives[value](f)
			parse_eol(f)
		elif tok == TOK_OP:
			assemble(f, value)
			parse_eol(f)
		elif tok != TOK_EOL:
			raise Exception, "unexpected (%s,%s)" % (tok,value)
		tok, value = lex(f)

def dump_symbols():
	symbol_list = symbols.keys()
	symbol_list.sort()
	for symbol in symbol_list:
		tok, value = symbols[symbol]
		if tok == TOK_NUMBER:
			print "%-20s $%04x" % (symbol, value)
		elif tok == TOK_STRING:
			print "%-20s '%s'" % (symbol, value)
		else:
			print "%-20s ? type=%d value=%s" % (symbol, tok, value)

if __name__ == "__main__":

	outfile = None
	
	if len(sys.argv) != 2:
		print "usage: asm.py <filename>"
		sys.exit(1)

	rc = 0
	f = open(sys.argv[1], "r")
	try:
		for pass_number in range(1,4):
			line_number = 1
			f.seek(0)
			parse(f)
	except Exception, msg:
		traceback.print_exc()
		print "line", line_number
		rc = 1
	f.close()

	if outfile is not None:
		outfile.close()

	sys.exit(rc)
	
#	dump_symbols()
