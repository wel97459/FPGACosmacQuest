CALL    MACRO address
        SEP R4
		dw address
        ENDM

RETURN  MACRO
        SEP R5
        ENDM

SERIAL_B MACRO address
		B2 address
		ENDM

SERIAL_BN MACRO address
		BN2 address
		ENDM
		
KB_B MACRO address
		B3 address
		ENDM

KB_BN MACRO address
		BN3 address
		ENDM

R0		EQU		0		;REGISTER DEFINITION
R1		EQU		1		;REGISTER DEFINITION
R2		EQU		2		;REGISTER DEFINITION
R3		EQU		3		;REGISTER DEFINITION
R4		EQU		4		;REGISTER DEFINITION
R5		EQU		5		;REGISTER DEFINITION
R6		EQU		6		;REGISTER DEFINITION
R7		EQU		7		;REGISTER DEFINITION
R8		EQU		8		;REGISTER DEFINITION
R9		EQU		9		;REGISTER DEFINITION
RA		EQU		10		;REGISTER DEFINITION
RB		EQU		11		;REGISTER DEFINITION
RC		EQU		12		;REGISTER DEFINITION
RD		EQU		13		;REGISTER DEFINITION
RE		EQU		14		;REGISTER DEFINITION
RF		EQU		15		;REGISTER DEFINITION

addr0000:        lbr addr0100      ; Long branch
addr0003:        lbr 8000      ; Long branch
addr0006:        sep R0         ; Set P=R0 as program counter
addr0007:        idl            ; Idle or wait for interrupt or DMA request

TVXY:            
                 DB       0Fh   ; DISPLAY CURSOR LOCATION
                 DB       00h
                 DB       00h   ;BIT LOCATION OF CURSOR
                 DB       00h
MASK:            
                 DB     14     ;E0
TIME_:           
                 DB       9Ah
                 DB       27h
                 DB       3Ah
                 DB       00h
                 DB       00h
                 DB       00h
BS:              
                 DB       08h
CAN:             
                 DB       1Bh
PAD:             
                 DB       00h
TAPEMODE:        
                 DB       00h
SPARE:           
                 DB       19h
XEQ:            
                 DB       19h
LEND:            
                 DB       34h
AEPTR:           
                 DB       80h
TTYCC:           
                 DB       00h
NXA:             
                 DW       0773h
AIL:             
                 DW       0766h
BASIC:           
                 DW       0F40h     ;LOWEST ADD. FOR PROGRAM
STACK:           
                 DW       3FF7h     ;HIGHEST ADD. FOR PROGRAM
MEND:            
                 DW       109Bh     ;PROGRAM END + STACK RESERVE
TOPS:            
                 DW       3FF7h     ;TOP OF GOSUB STACK
LINO:            
                 DW       00AAh     ;CURRENT BASIC LINE NUMBER
WORK:            
                 DW       1083h
                 DW       0034h
SP:              
                 DW       0033h
LINE:            
                 DW       0000h     ;INPUT LINE BUFFER

                 org      0080h
addr0080:        DW       0000h  ; RANDOM NUMBER GEN.
addr0082:        DW       0000h  ; VAR. A
addr0084:        DW       0000h  ; VAR. B
addr0086:        DW       0000h  ; VAR. C
addr0088:        DW       0000h  ; VAR. D
addr008a:        DW       0000h  ; VAR. E
addr008c:        DW       0000h  ; VAR. F
addr008e:        DW       0000h  ; VAR. G
addr0090:        DW       0000h  ; VAR. H
addr0092:        DW       0000h  ; VAR. I
addr0094:        DW       0000h  ; VAR. J
addr0096:        DW       0000h  ; VAR. K
addr0098:        DW       0000h  ; VAR. L
addr009a:        DW       0000h  ; VAR. M
addr009c:        DW       0000h  ; VAR. N
addr009e:        DW       0000h  ; VAR. O
addr00a0:        DW       0000h  ; VAR. P
addr00a2:        DW       0000h  ; VAR. Q
addr00a4:        DW       0000h  ; VAR. R
addr00a6:        DW       0000h  ; VAR. S
addr00a8:        DW       0000h  ; VAR. T
addr00aa:        DW       0000h  ; VAR. U
addr00ac:        DW       0000h  ; VAR. V
addr00ae:        DW       0000h  ; VAR. W
addr00b0:        DW       0000h  ; VAR. X
addr00b2:        DW       0000h  ; VAR. Y
addr00b4:        DW       0000h  ; VAR. Z

addr00b6:        plo R7         ; Put low register R7
addr00b7:        lbdf  addr021a     ; Long branch on DF=1
addr00ba:        ghi RD         ; Get high register RD
addr00bb:        KB_B  addr00e1        ; Short branch on EF3=1
addr00bd:        SERIAL_B  addr00bb        ; Short branch on EF4=1
addr00bf:        KB_B  addr00e1        ; Short branch on EF3=1
addr00c1:        SERIAL_BN  addr00bf      ; Short branch on EF4=0
addr00c3:        seq            ; Set Q=1
addr00c4:        plo RE         ; Put low register RE
addr00c5:        ldi  08h        ; Load D immediate
addr00c7:        smi  01h        ; Substract D,DF to value
addr00c9:        bnz  addr00c7       ; Short branch on D!=0
addr00cb:        glo RE         ; Get low register RE
addr00cc:        adi  02h        ; Add D,DF with value
addr00ce:        bnq  addr00d3       ; Short branch on Q=0
addr00d0:        SERIAL_B  addr00c4        ; Short branch on EF4=1
addr00d2:        req            ; Reset Q=0
addr00d3:        SERIAL_BN  addr00c4       ; Short branch on EF4=0
addr00d5:        nop            ; No operation
addr00d6:        nop            ; No operation
addr00d7:        smi  01h        ; Substract D,DF to value
addr00d9:        SERIAL_BN  addr00de       ; Short branch on EF4=0
addr00db:        bnz  addr00d3+1       ; Short branch on D!=0
addr00dd:        inc RE         ; Increment (RE)
addr00de:        glo RE         ; Get low register RE
addr00df:        smi  06h        ; Substract D,DF to value
addr00e1:        phi RE         ; Put high register RE
addr00e2:        ldi  0ch        ; Load D immediate
addr00e4:        CALL   addr0a83    ; Set P=R4 as program counter
addr00e7:        lbr  addr0204      ; Long branch
addr00ea:        adi  00h        ; Add D,DF with value
addr00ec:        ghi RE         ; Get high register RE
addr00ed:        bnz  addr00f2       ; Short branch on D!=0
addr00ef:        KB_BN  addr00ff       ; Short branch on EF3=0
addr00f1:        lskp           ; Long skip
addr00f2:        SERIAL_B  addr00ff        ; Short branch on EF4=1
addr00f4:        smi  00h        ; Substract D,DF to value
addr00f6:        ghi RE         ; Get high register RE
addr00f7:        ani 254        ;  feh Logical AND D with value
-                plo RE         ; Put low register RE
addr00fa:        lsz            ; Long skip on D=0
addr00fb:        dec RE         ; Decrement (RE)
addr00fc:        glo RE         ; Get low register RE
addr00fd:        bnz   -       ; Short branch on D!=0
addr00ff:        RETURN         ; Set P=R5 as program counter

addr0100:        nop            ; No operation
addr0101:        br   COLD        ; Short branch
addr0103:        lbr  addr01ed      ; Long branch
addr0106:        lbr  addr0a5a      ; Long branch
addr0109:        lbr  addr0a83      ; Long branch
addr010c:        lbr  addr00ea      ; Long branch
addr010f:        ldn R8         ; Load D with (R8)
addr0110:        inc RB         ; Increment (RB)
addr0111:        idl            ; Idle or wait for interrupt or DMA request
addr0112:        idl            ; Idle or wait for interrupt or DMA request
addr0113:        inc R9         ; Increment (R9)
addr0114:        br  +          ; Short branch
addr0116:        idl            ; Idle or wait for interrupt or DMA request
addr0117:        idl            ; Idle or wait for interrupt or DMA request
addr0118:        str R8         ; Store D to (R8)
addr0119:        RETURN         ; Set P=R5 as program counter

addr011a:        ldn R7         ; Load D with (R7)
addr011b:        out 6          ; Output (R(X)); Increment R(X), N=110
addr011c:        ldn RF         ; Load D with (RF)
addr011d:        lda R0         ; Load D from (R0), increment R0
addr011e:        smbi  00h       ; Substract memory toh borrow, immediate
addr0120:        lda R8         ; Load D from (R8), increment R8
addr0121:        skp            ; Skip next byte
+                ghi RD         ; Get high register RD
addr0123:        phi RA         ; Put high register RA
addr0124:        lda R8         ; Load D from (R8), increment R8
addr0125:        RETURN         ; Set P=R5 as program counter

addr0126:        lbr  addr0751      ; Long branch
-                sep R3         ; Set P=R3 as program counter
addr012a:        phi RF         ; Put high register RF
addr012b:        sex R2         ; Set P=R2 as datapointer
addr012c:        glo R6         ; Get low register R6
addr012d:        stxd           ; Store via X and devrement
addr012e:        ghi R6         ; Get high register R6
addr012f:        stxd           ; Store via X and devrement
addr0130:        glo R3         ; Get low register R3
addr0131:        plo R6         ; Put low register R6
addr0132:        ghi R3         ; Get high register R3
addr0133:        phi R6         ; Put high register R6
addr0134:        lda R6         ; Load D from (R6), increment R6
addr0135:        phi R3         ; Put high register R3
addr0136:        lda R6         ; Load D from (R6), increment R6
addr0137:        plo R3         ; Put low register R3
addr0138:        ghi RF         ; Get high register RF
addr0139:        br  -        ; Short branch
-                sep R3         ; Set P=R3 as program counter
addr013c:        phi RF         ; Put high register RF
addr013d:        sex R2         ; Set P=R2 as datapointer
addr013e:        ghi R6         ; Get high register R6
addr013f:        phi R3         ; Put high register R3
addr0140:        glo R6         ; Get low register R6
addr0141:        plo R3         ; Put low register R3
addr0142:        inc R2         ; Increment (R2)
addr0143:        lda R2         ; Load D from (R2), increment R2
addr0144:        phi R6         ; Put high register R6
addr0145:        ldn R2         ; Load D with (R2)
addr0146:        plo R6         ; Put low register R6
addr0147:        ghi RF         ; Get high register RF
addr0148:        br  -          ; Short branch
-                sep R3         ; Set P=R3 as program counter
addr014b:        lda R3         ; Load D from (R3), increment R3
addr014c:        plo RD         ; Put low register RD
addr014d:        ldi  00h        ; Load D immediate
addr014f:        phi RD         ; Put high register RD
addr0150:        lda RD         ; Load D from (RD), increment RD
addr0151:        sex RD         ; Set P=RD as datapointer
addr0152:        br  -          ; Short branch
                 DW       0298h  ;BACK
                 DW       02A0h  ;HOP
                 DW       031Fh  ;MATCH
                 DW       02DDh  ;TSTV
                 DW       02F0h  ;TSTN
                 DW       02D4h  ;TEND
                 DW       0581h  ;RTN
                 DW       0349h  ;HOOK
                 DW       01EDh  ;WARM
                 DW       054Eh  ;XINIT
                 DW       0204h  ;CLEAR
                 DW       06A2h  ;INSRT
                 DW       02D3h  ;RETN
                 DW       02D3h  ;RETN
                 DW       05AAh  ;GETLN
                 DW       02D3h  ;RETN
                 DW       02D3h  ;RETN
                 DW       03C5h  ;STRNG
                 DW       03D5h  ;CRLF
                 DW       0403h  ;TAB
                 DW       0379h  ;PRS
                 DW       0418h  ;PRN
                 DW       063Ch  ;LIST
                 DW       02D3h  ;RETN
                 DW       0529h  ;NXT
                 DW       046Ch  ;CMPR
                 DW       04CBh  ;IDIV
                 DW       04A7h  ;IMUL
                 DW       0498h  ;ISUB
                 DW       049Bh  ;IADD
                 DW       050Eh  ;INEG
                 DW       0560h  ;XFER
                 DW       056Dh  ;RSTR
                 DW       0681h  ;SAV
                 DW       02B6h  ;STORE
                 DW       0367h  ;IND
                 DW       0448h  ;RSBP
                 DW       044Bh  ;SVBP
                 DW       02D3h  ;RETN
                 DW       02D3h  ;RETN
                 DW       02C9h  ;BPOP
                 DW       02C5h  ;APOP
                 DW       034Eh  ;DUPS
                 DW       0344h  ;LITN
                 DW       0341h  ;LIT1
                 DW       02D3h  ;RETN

COLD:            ldi  0b3h        ; Load D immediate
addr01b2:        plo R3         ; Put low register R3
addr01b3:        ldi  01h        ; Load D immediate
addr01b5:        phi R3         ; Put high register R3
addr01b6:        sep R3         ; Set P=R3 as program counter
addr01b7:        phi RA         ; Put high register RA
addr01b8:        ldi  1ch        ; Load D immediate
addr01ba:        plo RA         ; Put low register RA
addr01bb:        lda RA         ; Load D from (RA), increment RA
addr01bc:        phi R2         ; Put high register R2
addr01bd:        lda RA         ; Load D from (RA), increment RA
addr01be:        plo R2         ; Put low register R2
addr01bf:        lda RA         ; Load D from (RA), increment RA
addr01c0:        phi RD         ; Put high register RD
addr01c1:        ldi  0ffh        ; Load D immediate
addr01c3:        plo RD         ; Put low register RD
addr01c4:        ldn RD         ; Load D with (RD)
addr01c5:        phi RF         ; Put high register RF
-                sex R2         ; Set P=R2 as datapointer
addr01c7:        inc R2         ; Increment (R2)
addr01c8:        ldx            ; Pop stack. Place value in D register
addr01c9:        plo RF         ; Put low register RF
addr01ca:        xri  0ffh        ; Logical XOR D with value
addr01cc:        str R2         ; Store D to (R2)
addr01cd:        xor            ; Logical exclusive OR  D with (R(X))
addr01ce:        sex RD         ; Set P=RD as datapointer
addr01cf:        lsnz           ; Long skip on D!=0
addr01d0:        ghi RF         ; Get high register RF
addr01d1:        xor            ; Logical exclusive OR  D with (R(X))
addr01d2:        adi  0ffh        ; Add D,DF with value
addr01d4:        glo RF         ; Get low register RF
addr01d5:        str R2         ; Store D to (R2)
addr01d6:        bnf  -      ; Short branch on DF=0
addr01d8:        dec R2         ; Decrement (R2)
addr01d9:        ldn RA         ; Load D with (RA)
addr01da:        phi RD         ; Put high register RD
addr01db:        ldi  23h        ; Load D immediate
addr01dd:        plo RD         ; Put low register RD
addr01de:        glo R2         ; Get low register R2
addr01df:        stxd           ; Store via X and devrement
addr01e0:        ghi R2         ; Get high register R2
addr01e1:        stxd           ; Store via X and devrement
addr01e2:        dec RA         ; Decrement (RA)
-                dec RA         ; Decrement (RA)
addr01e4:        ldn RA         ; Load D with (RA)
addr01e5:        stxd           ; Store via X and devrement
addr01e6:        glo RD         ; Get low register RD
addr01e7:        xri  12h       ; Logical XOR D with value
addr01e9:        bnz  -       ; Short branch on D!=0
addr01eb:        shr            ; Shift right D
addr01ec:        lskp           ; Long skip
addr01ed:        smi  00h        ; Substract D,DF to value
addr01ef:        ldi  0f2h        ; Load D immediate
addr01f1:        plo R3         ; Put low register R3
addr01f2:        ldi  01h        ; Load D immediate
addr01f4:        phi R3         ; Put high register R3
addr01f5:        sep R3         ; Set P=R3 as program counter
addr01f6:        phi R4         ; Put high register R4
addr01f7:        phi R5         ; Put high register R5
addr01f8:        phi R7         ; Put high register R7
addr01f9:        ldi  2ah        ; Load D immediate
addr01fb:        plo R4         ; Put low register R4
addr01fc:        ldi  3ch        ; Load D immediate
addr01fe:        plo R5         ; Put low register R5
addr01ff:        ldi  4bh        ; Load D immediate
addr0201:        lbr  addr00b6      ; Long branch
addr0204:        sep R7         ; Set P=R7 as program counter
addr0205:        dec R0         ; Decrement (R0)
addr0206:        phi RB         ; Put high register RB
addr0207:        lda RD         ; Load D from (RD), increment RD
addr0208:        plo RB         ; Put low register RB
addr0209:        ghi RD         ; Get high register RD
addr020a:        str RB         ; Store D to (RB)
addr020b:        inc RB         ; Increment (RB)
addr020c:        str RB         ; Store D to (RB)
addr020d:        sep R7         ; Set P=R7 as program counter
addr020e:        inc R6         ; Increment (R6)
addr020f:        glo RB         ; Get low register RB
addr0210:        add            ; Add D: D,DF= D+(R(X))
addr0211:        phi RF         ; Put high register RF
addr0212:        sep R7         ; Set P=R7 as program counter
addr0213:        dec R4         ; Decrement (R4)
addr0214:        ghi RF         ; Get high register RF
addr0215:        stxd           ; Store via X and devrement
addr0216:        ghi RB         ; Get high register RB
addr0217:        adci  00h       ; Add with carry immediate
addr0219:        stxd           ; Store via X and devrement
addr021a:        sep R7         ; Set P=R7 as program counter
addr021b:        dec R2         ; Decrement (R2)
addr021c:        phi R2         ; Put high register R2
addr021d:        lda RD         ; Load D from (RD), increment RD
addr021e:        plo R2         ; Put low register R2
addr021f:        sep R7         ; Set P=R7 as program counter
addr0220:        dec R6         ; Decrement (R6)
addr0221:        glo R2         ; Get low register R2
addr0222:        stxd           ; Store via X and devrement
addr0223:        ghi R2         ; Get high register R2
addr0224:        stxd           ; Store via X and devrement
addr0225:        CALL   addr03cc    ; Set P=R4 as program counter
addr0228:        sep R7         ; Set P=R7 as program counter
addr0229:        inc RE         ; Increment (RE)
addr022a:        phi R9         ; Put high register R9
addr022b:        lda RD         ; Load D from (RD), increment RD
addr022c:        plo R9         ; Put low register R9
addr022d:        sex R2         ; Set P=R2 as datapointer
addr022e:        lda R9         ; Load D from (R9), increment R9
addr022f:        smi  30h        ; Substract D,DF to value
addr0231:        bdf  +   ; Short branch on DF=1
addr0233:        sdi  0d7h        ; Substract D,DF from value
addr0235:        bdf  addr0285  ; Short branch on DF=1
addr0237:        shl            ; Shift left D
addr0238:        adi  0b0h        ; Add D,DF with value
addr023a:        plo R6         ; Put low register R6
addr023b:        ldi  2dh        ; Load D immediate
addr023d:        dec R2         ; Decrement (R2)
addr023e:        dec R2         ; Decrement (R2)
addr023f:        stxd           ; Store via X and devrement
addr0240:        ghi R3         ; Get high register R3
addr0241:        stxd           ; Store via X and devrement
addr0242:        ghi R7         ; Get high register R7
addr0243:        phi R6         ; Put high register R6
addr0244:        lda R6         ; Load D from (R6), increment R6
addr0245:        str R2         ; Store D to (R2)
addr0246:        lda R6         ; Load D from (R6), increment R6
addr0247:        plo R6         ; Put low register R6
addr0248:        ldx            ; Pop stack. Place value in D register
addr0249:        phi R6         ; Put high register R6
addr024a:        RETURN         ; Set P=R5 as program counter

+                smi  10h        ; Substract D,DF to value
addr024d:        bnf  addr026a       ; Short branch on DF=0
addr024f:        plo R6         ; Put low register R6
addr0250:        ani  1fh        ; Logical AND D with value
addr0252:        bz  addr025c        ; Short branch on D=0
addr0254:        str R2         ; Store D to (R2)
addr0255:        glo R9         ; Get low register R9
addr0256:        add            ; Add D: D,DF= D+(R(X))
addr0257:        stxd           ; Store via X and devrement
addr0258:        ghi R9         ; Get high register R9
addr0259:        adci  00h       ; Add with carry immediate
addr025b:        skp            ; Skip next byte
addr025c:        stxd           ; Store via X and devrement
addr025d:        stxd           ; Store via X and devrement
addr025e:        glo R6         ; Get low register R6
addr025f:        shr            ; Shift right D
addr0260:        shr            ; Shift right D
addr0261:        shr            ; Shift right D
addr0262:        shr            ; Shift right D
addr0263:        ani  0feh        ; Logical AND D with value
addr0265:        adi  54h        ; Add D,DF with value
addr0267:        plo R6         ; Put low register R6
addr0268:        br  addr0242        ; Short branch
addr026a:        adi  08h        ; Add D,DF with value
addr026c:        ani  07h        ; Logical AND D with value
addr026e:        phi R6         ; Put high register R6
addr026f:        lda R9         ; Load D from (R9), increment R9
addr0270:        plo R6         ; Put low register R6
addr0271:        bdf  addr027a       ; Short branch on DF=1
addr0273:        glo R9         ; Get low register R9
addr0274:        stxd           ; Store via X and devrement
addr0275:        ghi R9         ; Get high register R9
addr0276:        stxd           ; Store via X and devrement
addr0277:        CALL   addr0337    ; Set P=R4 as program counter
addr027a:        sep R7         ; Set P=R7 as program counter
addr027b:        inc RE         ; Increment (RE)
addr027c:        glo R6         ; Get low register R6
addr027d:        add            ; Add D: D,DF= D+(R(X))
addr027e:        plo R9         ; Put low register R9
addr027f:        ghi R6         ; Get high register R6
addr0280:        dec RD         ; Decrement (RD)
addr0281:        adc            ; Add with carry
addr0282:        phi R9         ; Put high register R9
addr0283:        br  addr022d        ; Short branch
addr0285:        sdi  07h        ; Substract D,DF from value
addr0287:        str R2         ; Store D to (R2)
addr0288:        sep R7         ; Set P=R7 as program counter
addr0289:        inc RA         ; Increment (RA)
addr028a:        plo RD         ; Put low register RD
addr028b:        sex R2         ; Set P=R2 as datapointer
addr028c:        add            ; Add D: D,DF= D+(R(X))
addr028d:        plo R6         ; Put low register R6
addr028e:        ghi RD         ; Get high register RD
addr028f:        phi R6         ; Put high register R6
addr0290:        ldn RD         ; Load D with (RD)
addr0291:        str R2         ; Store D to (R2)
addr0292:        ldn R6         ; Load D with (R6)
addr0293:        str RD         ; Store D to (RD)
addr0294:        ldn R2         ; Load D with (R2)
addr0295:        str R6         ; Store D to (R6)
addr0296:        br  addr022d        ; Short branch
addr0298:        glo R6         ; Get low register R6
addr0299:        smi  20h        ; Substract D,DF to value
addr029b:        plo R6         ; Put low register R6
addr029c:        ghi R6         ; Get high register R6
addr029d:        smbi  00h       ; Substract memory toh borrow, immediate
addr029f:        skp            ; Skip next byte
addr02a0:        ghi R6         ; Get high register R6
addr02a1:        lbz  addr037f      ; Long branch on D=0
addr02a4:        phi R9         ; Put high register R9
addr02a5:        glo R6         ; Get low register R6
addr02a6:        plo R9         ; Put low register R9
addr02a7:        br  addr022d        ; Short branch
-                inc RB         ; Increment (RB)
addr02aa:        ldn RB         ; Load D with (RB)
addr02ab:        smi  20h        ; Substract D,DF to value
addr02ad:        bz   -         ; Short branch on D=0
addr02af:        smi  10h        ; Substract D,DF to value
addr02b1:        lsnf           ; Long skip on DF=0
addr02b2:        sdi  09h        ; Substract D,DF from value
addr02b4:        ldn RB         ; Load D with (RB)
addr02b5:        RETURN         ; Set P=R5 as program counter

addr02b6:        CALL   addr02c5    ; Set P=R4 as program counter
addr02b9:        lda RD         ; Load D from (RD), increment RD
addr02ba:        plo RD         ; Put low register RD
addr02bb:        ghi RA         ; Get high register RA
addr02bc:        str RD         ; Store D to (RD)
addr02bd:        inc RD         ; Increment (RD)
addr02be:        glo RA         ; Get low register RA
addr02bf:        str RD         ; Store D to (RD)
addr02c0:        br   +        ; Short branch
addr02c2:        CALL   addr02c5    ; Set P=R4 as program counter
addr02c5:        CALL   addr02c9    ; Set P=R4 as program counter
addr02c8:        phi RA         ; Put high register RA
+                sep R7         ; Set P=R7 as program counter
addr02ca:        inc RA         ; Increment (RA)
addr02cb:        dec RD         ; Decrement (RD)
addr02cc:        adi  01h        ; Add D,DF with value
addr02ce:        str RD         ; Store D to (RD)
addr02cf:        plo RD         ; Put low register RD
addr02d0:        dec RD         ; Decrement (RD)
addr02d1:        lda RD         ; Load D from (RD), increment RD
addr02d2:        plo RA         ; Put low register RA
addr02d3:        RETURN         ; Set P=R5 as program counter

addr02d4:        CALL   addr02aa    ; Set P=R4 as program counter
addr02d7:        xri  0dh        ; Logical XOR D with value
addr02d9:        bz  addr022d        ; Short branch on D=0
addr02db:        br  addr02a0        ; Short branch
addr02dd:        CALL   addr02aa    ; Set P=R4 as program counter
addr02e0:        smi  41h        ; Substract D,DF to value
addr02e2:        bnf   addr02a0       ; Short branch on DF=0
addr02e4:        smi  1ah        ; Substract D,DF to value
addr02e6:        bdf   addr02a0       ; Short branch on DF=1
addr02e8:        inc RB         ; Increment (RB)
addr02e9:        ghi RF         ; Get high register RF
addr02ea:        shl            ; Shift left D
addr02eb:        CALL   addr0359    ; Set P=R4 as program counter
addr02ee:        br  addr022d        ; Short branch
addr02f0:        CALL   addr02aa    ; Set P=R4 as program counter
addr02f3:        bnf  addr02a0       ; Short branch on DF=0
addr02f5:        ghi RD         ; Get high register RD
addr02f6:        phi RA         ; Put high register RA
addr02f7:        plo RA         ; Put low register RA
addr02f8:        CALL   addr0354    ; Set P=R4 as program counter
addr02fb:        lda RB         ; Load D from (RB), increment RB
addr02fc:        ani  0fh        ; Logical AND D with value
addr02fe:        plo RA         ; Put low register RA
addr02ff:        ghi RD         ; Get high register RD
addr0300:        phi RA         ; Put high register RA
addr0301:        ldi  0ah        ; Load D immediate
addr0303:        plo RF         ; Put low register RF
addr0304:        sex RD         ; Set P=RD as datapointer
addr0305:        inc RD         ; Increment (RD)
addr0306:        glo RA         ; Get low register RA
addr0307:        add            ; Add D: D,DF= D+(R(X))
addr0308:        plo RA         ; Put low register RA
addr0309:        ghi RA         ; Get high register RA
addr030a:        dec RD         ; Decrement (RD)
addr030b:        adc            ; Add with carry
addr030c:        phi RA         ; Put high register RA
addr030d:        dec RF         ; Decrement (RF)
addr030e:        glo RF         ; Get low register RF
addr030f:        bnz  addr0305       ; Short branch on D!=0
addr0311:        ghi RA         ; Get high register RA
addr0312:        str RD         ; Store D to (RD)
addr0313:        inc RD         ; Increment (RD)
addr0314:        glo RA         ; Get low register RA
addr0315:        stxd           ; Store via X and devrement
addr0316:        CALL   addr02aa    ; Set P=R4 as program counter
addr0319:        lbdf  addr02fb     ; Long branch on DF=1
addr031c:        lbr  addr022d      ; Long branch
addr031f:        ghi RB         ; Get high register RB
addr0320:        phi RA         ; Put high register RA
addr0321:        glo RB         ; Get low register RB
addr0322:        plo RA         ; Put low register RA
addr0323:        CALL   addr02aa    ; Set P=R4 as program counter
addr0326:        inc RB         ; Increment (RB)
addr0327:        str R2         ; Store D to (R2)
addr0328:        lda R9         ; Load D from (R9), increment R9
addr0329:        xor            ; Logical exclusive OR  D with (R(X))
addr032a:        bz  addr0323        ; Short branch on D=0
addr032c:        xri  80h        ; Logical XOR D with value
addr032e:        bz  addr031c        ; Short branch on D=0
addr0330:        ghi RA         ; Get high register RA
addr0331:        phi RB         ; Put high register RB
addr0332:        glo RA         ; Get low register RA
addr0333:        plo RB         ; Put low register RB
addr0334:        lbr  addr02a0      ; Long branch
addr0337:        sep R7         ; Set P=R7 as program counter
addr0338:        dec R4         ; Decrement (R4)
addr0339:        glo R2         ; Get low register R2
addr033a:        sd             ; Substract D: D,DF=(R(X))-D
addr033b:        dec RD         ; Decrement (RD)
addr033c:        ghi R2         ; Get high register R2
addr033d:        sdb            ; Substract D with borrow
addr033e:        bdf  addr037f       ; Short branch on DF=1
addr0340:        RETURN         ; Set P=R5 as program counter

addr0341:        lda R9         ; Load D from (R9), increment R9
addr0342:        br  addr0359        ; Short branch
addr0344:        lda R9         ; Load D from (R9), increment R9
addr0345:        phi RA         ; Put high register RA
addr0346:        lda R9         ; Load D from (R9), increment R9
addr0347:        br  addr0355        ; Short branch
addr0349:        CALL   addr0625    ; Set P=R4 as program counter
addr034c:        br  addr0355        ; Short branch
addr034e:        CALL   addr02c5    ; Set P=R4 as program counter
addr0351:        CALL   addr0354    ; Set P=R4 as program counter
addr0354:        glo RA         ; Get low register RA
addr0355:        CALL   addr0359    ; Set P=R4 as program counter
addr0358:        ghi RA         ; Get high register RA
addr0359:        str R2         ; Store D to (R2)
addr035a:        sep R7         ; Set P=R7 as program counter
addr035b:        inc R9         ; Increment (R9)
addr035c:        sm             ; Substract memory: DF,D=D-(R(X))
addr035d:        bdf  addr037f       ; Short branch on DF=1
addr035f:        ldi  01h        ; Load D immediate
addr0361:        sd             ; Substract D: D,DF=(R(X))-D
addr0362:        str RD         ; Store D to (RD)
addr0363:        plo RD         ; Put low register RD
addr0364:        ldn R2         ; Load D with (R2)
addr0365:        str RD         ; Store D to (RD)
addr0366:        RETURN         ; Set P=R5 as program counter

addr0367:        CALL   addr02c9    ; Set P=R4 as program counter
addr036a:        plo RD         ; Put low register RD
addr036b:        lda RD         ; Load D from (RD), increment RD
addr036c:        phi RA         ; Put high register RA
addr036d:        lda RD         ; Load D from (RD), increment RD
addr036e:        br  addr0355        ; Short branch
addr0370:        xri  2fh        ; Logical XOR D with value
addr0372:        bz  addr0366        ; Short branch on D=0
addr0374:        xri  22h        ; Logical XOR D with value
addr0376:        CALL   addr03f4    ; Set P=R4 as program counter
addr0379:        lda RB         ; Load D from (RB), increment RB
addr037a:        xri  0dh        ; Logical XOR D with value
addr037c:        bnz  addr0370       ; Short branch on D!=0
addr037e:        dec R9         ; Decrement (R9)
addr037f:        sep R7         ; Set P=R7 as program counter
addr0380:        inc R8         ; Increment (R8)
addr0381:        phi R8         ; Put high register R8
addr0382:        CALL   addr03cc    ; Set P=R4 as program counter
addr0385:        ldi  21h        ; Load D immediate
addr0387:        CALL   addr03f4    ; Set P=R4 as program counter
addr038a:        sep R7         ; Set P=R7 as program counter
addr038b:        inc RE         ; Increment (RE)
addr038c:        glo R9         ; Get low register R9
addr038d:        sm             ; Substract memory: DF,D=D-(R(X))
addr038e:        plo RA         ; Put low register RA
addr038f:        ghi R9         ; Get high register R9
addr0390:        dec RD         ; Decrement (RD)
addr0391:        smb            ; Substract memory with borrow
addr0392:        phi RA         ; Put high register RA
addr0393:        CALL   addr0415    ; Set P=R4 as program counter
addr0396:        ghi R8         ; Get high register R8
addr0397:        bz  addr03a9        ; Short branch on D=0
addr0399:        ldi  0bdh        ; Load D immediate
addr039b:        plo R9         ; Put low register R9
addr039c:        ghi R3         ; Get high register R3
addr039d:        phi R9         ; Put high register R9
addr039e:        CALL   addr03c5    ; Set P=R4 as program counter
addr03a1:        sep R7         ; Set P=R7 as program counter
addr03a2:        dec R8         ; Decrement (R8)
addr03a3:        phi RA         ; Put high register RA
addr03a4:        lda RD         ; Load D from (RD), increment RD
addr03a5:        plo RA         ; Put low register RA
addr03a6:        CALL   addr0415    ; Set P=R4 as program counter
addr03a9:        ldi  07h        ; Load D immediate
addr03ab:        CALL   addr0109    ; Set P=R4 as program counter
addr03ae:        CALL   addr03d5    ; Set P=R4 as program counter
addr03b1:        sep R7         ; Set P=R7 as program counter
addr03b2:        inc RA         ; Increment (RA)
addr03b3:        ghi RD         ; Get high register RD
addr03b4:        str RD         ; Store D to (RD)
addr03b5:        sep R7         ; Set P=R7 as program counter
addr03b6:        dec R6         ; Decrement (R6)
addr03b7:        phi R2         ; Put high register R2
addr03b8:        lda RD         ; Load D from (RD), increment RD
addr03b9:        plo R2         ; Put low register R2
addr03ba:        lbr  addr0228      ; Long branch
addr03bd:        dec R0         ; Decrement (R0)
addr03be:        lda R1         ; Load D from (R1), increment R1
addr03bf:        str R4         ; Store D to (R4)
addr03c0:        dec R0         ; Decrement (R0)
addr03c1:        plo R3         ; Put low register R3
addr03c2:        CALL   addr03f2    ; Set P=R4 as program counter
addr03c5:        lda R9         ; Load D from (R9), increment R9
addr03c6:        adi  80h        ; Add D,DF with value
addr03c8:        bnf  addr03c2       ; Short branch on DF=0
addr03ca:        br   addr03f2        ; Short branch
addr03cc:        sep R7         ; Set P=R7 as program counter
addr03cd:        inc R9         ; Increment (R9)
addr03ce:        ldi  80h        ; Load D immediate
addr03d0:        stxd           ; Store via X and devrement
addr03d1:        ghi RD         ; Get high register RD
addr03d2:        stxd           ; Store via X and devrement
addr03d3:        stxd           ; Store via X and devrement
addr03d4:        lskp           ; Long skip
addr03d5:        sep R7         ; Set P=R7 as program counter
addr03d6:        inc RB         ; Increment (RB)
addr03d7:        shl            ; Shift left D
addr03d8:        bdf  addr0366       ; Short branch on DF=1
addr03da:        sep R7         ; Set P=R7 as program counter
addr03db:        inc R5         ; Increment (R5)
addr03dc:        plo RA         ; Put low register RA
addr03dd:        ldi  0dh        ; Load D immediate
addr03df:        CALL   addr0109    ; Set P=R4 as program counter
addr03e2:        sep R7         ; Set P=R7 as program counter
addr03e3:        inc RA         ; Increment (RA)
addr03e4:        glo RA         ; Get low register RA
addr03e5:        shl            ; Shift left D
addr03e6:        bz  addr03ef        ; Short branch on D=0
addr03e8:        dec RA         ; Decrement (RA)
addr03e9:        ghi RD         ; Get high register RD
addr03ea:        lsnf           ; Long skip on DF=0
addr03eb:        ldi  0ffh        ; Load D immediate
addr03ed:        br  addr03df        ; Short branch
addr03ef:        stxd           ; Store via X and devrement
addr03f0:        ldi  8ah        ; Load D immediate
addr03f2:        smi  80h        ; Substract D,DF to value
addr03f4:        phi RF         ; Put high register RF
addr03f5:        sep R7         ; Set P=R7 as program counter
addr03f6:        inc RB         ; Increment (RB)
addr03f7:        dec RD         ; Decrement (RD)
addr03f8:        adi  81h        ; Add D,DF with value
addr03fa:        adi  80h        ; Add D,DF with value
addr03fc:        bnf  addr0366       ; Short branch on DF=0
addr03fe:        str RD         ; Store D to (RD)
addr03ff:        ghi RF         ; Get high register RF
addr0400:        lbr  addr0109      ; Long branch
addr0403:        ldi  20h        ; Load D immediate
addr0405:        CALL   addr03f4    ; Set P=R4 as program counter
addr0408:        sep R7         ; Set P=R7 as program counter
addr0409:        inc RB         ; Increment (RB)
addr040a:        ani  07h        ; Logical AND D with value
addr040c:        bnz  addr0403       ; Short branch on D!=0
addr040e:        RETURN         ; Set P=R5 as program counter

addr040f:        CALL   addr03f4    ; Set P=R4 as program counter
addr0412:        dec RA         ; Decrement (RA)
addr0413:        br  addr040a        ; Short branch
addr0415:        CALL   addr0354    ; Set P=R4 as program counter
addr0418:        sep R7         ; Set P=R7 as program counter
addr0419:        inc RA         ; Increment (RA)
addr041a:        plo RD         ; Put low register RD
addr041b:        CALL   addr0513    ; Set P=R4 as program counter
addr041e:        bnf  addr0425       ; Short branch on DF=0
addr0420:        ldi  2dh        ; Load D immediate
addr0422:        CALL   addr03f4    ; Set P=R4 as program counter
addr0425:        ghi RD         ; Get high register RD
addr0426:        stxd           ; Store via X and devrement
addr0427:        phi RA         ; Put high register RA
addr0428:        ldi  0ah        ; Load D immediate
addr042a:        CALL   addr0355    ; Set P=R4 as program counter
addr042d:        inc RD         ; Increment (RD)
addr042e:        CALL   addr04e3    ; Set P=R4 as program counter
addr0431:        glo RA         ; Get low register RA
addr0432:        shr            ; Shift right D
addr0433:        ori  30h        ; Logical OR D with value
addr0435:        stxd           ; Store via X and devrement
addr0436:        inc RD         ; Increment (RD)
addr0437:        lda RD         ; Load D from (RD), increment RD
addr0438:        sex RD         ; Set P=RD as datapointer
addr0439:        or             ; Logical OR  D with (R(X))
addr043a:        dec RD         ; Decrement (RD)
addr043b:        dec RD         ; Decrement (RD)
addr043c:        bnz  addr042e       ; Short branch on D!=0
addr043e:        inc R2         ; Increment (R2)
addr043f:        ldn R2         ; Load D with (R2)
addr0440:        lbz  addr02c2      ; Long branch on D=0
addr0443:        CALL   addr03f4    ; Set P=R4 as program counter
addr0446:        br  addr043e        ; Short branch
addr0448:        sep R7         ; Set P=R7 as program counter
addr0449:        dec RE         ; Decrement (RE)
addr044a:        skp            ; Skip next byte
addr044b:        ghi RB         ; Get high register RB
addr044c:        xri  00h        ; Logical XOR D with value
addr044e:        bnz  addr045e       ; Short branch on D!=0
addr0450:        glo RB         ; Get low register RB
addr0451:        str R2         ; Store D to (R2)
addr0452:        ldx            ; Pop stack. Place value in D register
addr0453:        smi  80h        ; Substract D,DF to value
addr0455:        bdf  addr045e       ; Short branch on DF=1
addr0457:        sep R7         ; Set P=R7 as program counter
addr0458:        dec RE         ; Decrement (RE)
addr0459:        glo RB         ; Get low register RB
addr045a:        stxd           ; Store via X and devrement
addr045b:        ghi RB         ; Get high register RB
addr045c:        str RD         ; Store D to (RD)
addr045d:        RETURN         ; Set P=R5 as program counter

addr045e:        sep R7         ; Set P=R7 as program counter
addr045f:        dec RE         ; Decrement (RE)
addr0460:        phi R8         ; Put high register R8
addr0461:        ldn RD         ; Load D with (RD)
addr0462:        plo R8         ; Put low register R8
addr0463:        glo RB         ; Get low register RB
addr0464:        stxd           ; Store via X and devrement
addr0465:        ghi RB         ; Get high register RB
addr0466:        str RD         ; Store D to (RD)
addr0467:        ghi R8         ; Get high register R8
addr0468:        phi RB         ; Put high register RB
addr0469:        glo R8         ; Get low register R8
addr046a:        plo RB         ; Put low register RB
addr046b:        RETURN         ; Set P=R5 as program counter

addr046c:        CALL   addr02c5    ; Set P=R4 as program counter
addr046f:        ghi RA         ; Get high register RA
addr0470:        xri  80h        ; Logical XOR D with value
addr0472:        stxd           ; Store via X and devrement
addr0473:        glo RA         ; Get low register RA
addr0474:        stxd           ; Store via X and devrement
addr0475:        CALL   addr02c9    ; Set P=R4 as program counter
addr0478:        plo RF         ; Put low register RF
addr0479:        CALL   addr02c5    ; Set P=R4 as program counter
addr047c:        inc R2         ; Increment (R2)
addr047d:        glo RA         ; Get low register RA
addr047e:        sm             ; Substract memory: DF,D=D-(R(X))
addr047f:        plo RA         ; Put low register RA
addr0480:        inc R2         ; Increment (R2)
addr0481:        ghi RA         ; Get high register RA
addr0482:        xri  80h        ; Logical XOR D with value
addr0484:        smb            ; Substract memory with borrow
addr0485:        str R2         ; Store D to (R2)
addr0486:        bnf  addr0492       ; Short branch on DF=0
addr0488:        glo RA         ; Get low register RA
addr0489:        or             ; Logical OR  D with (R(X))
addr048a:        bz  addr048f        ; Short branch on D=0
addr048c:        glo RF         ; Get low register RF
addr048d:        shr            ; Shift right D
addr048e:        skp            ; Skip next byte
addr048f:        glo RF         ; Get low register RF
addr0490:        shr            ; Shift right D
addr0491:        skp            ; Skip next byte
addr0492:        glo RF         ; Get low register RF
addr0493:        shr            ; Shift right D
addr0494:        lsnf           ; Long skip on DF=0
addr0495:        nop            ; No operation
addr0496:        inc R9         ; Increment (R9)
addr0497:        RETURN         ; Set P=R5 as program counter

addr0498:        CALL   addr050e    ; Set P=R4 as program counter
addr049b:        CALL   addr02c5    ; Set P=R4 as program counter
addr049e:        sex RD         ; Set P=RD as datapointer
addr049f:        inc RD         ; Increment (RD)
addr04a0:        glo RA         ; Get low register RA
addr04a1:        add            ; Add D: D,DF= D+(R(X))
addr04a2:        stxd           ; Store via X and devrement
addr04a3:        ghi RA         ; Get high register RA
addr04a4:        adc            ; Add with carry
addr04a5:        str RD         ; Store D to (RD)
addr04a6:        RETURN         ; Set P=R5 as program counter

addr04a7:        CALL   addr02c5    ; Set P=R4 as program counter
addr04aa:        ldi  10h        ; Load D immediate
addr04ac:        plo RF         ; Put low register RF
addr04ad:        lda RD         ; Load D from (RD), increment RD
addr04ae:        phi R8         ; Put high register R8
addr04af:        ldn RD         ; Load D with (RD)
addr04b0:        plo R8         ; Put low register R8
addr04b1:        ldn RD         ; Load D with (RD)
addr04b2:        shl            ; Shift left D
addr04b3:        str RD         ; Store D to (RD)
addr04b4:        dec RD         ; Decrement (RD)
addr04b5:        ldn RD         ; Load D with (RD)
addr04b6:        shlc           ; Shift left with carry
addr04b7:        str RD         ; Store D to (RD)
addr04b8:        CALL   addr0522    ; Set P=R4 as program counter
addr04bb:        bnf  addr04c5       ; Short branch on DF=0
addr04bd:        sex RD         ; Set P=RD as datapointer
addr04be:        inc RD         ; Increment (RD)
addr04bf:        glo R8         ; Get low register R8
addr04c0:        add            ; Add D: D,DF= D+(R(X))
addr04c1:        stxd           ; Store via X and devrement
addr04c2:        ghi R8         ; Get high register R8
addr04c3:        adc            ; Add with carry
addr04c4:        str RD         ; Store D to (RD)
addr04c5:        dec RF         ; Decrement (RF)
addr04c6:        glo RF         ; Get low register RF
addr04c7:        inc RD         ; Increment (RD)
addr04c8:        bnz   addr04b1       ; Short branch on D!=0
addr04ca:        RETURN         ; Set P=R5 as program counter

addr04cb:        CALL   addr02c5    ; Set P=R4 as program counter
addr04ce:        ghi RA         ; Get high register RA
addr04cf:        str R2         ; Store D to (R2)
addr04d0:        glo RA         ; Get low register RA
addr04d1:        or             ; Logical OR  D with (R(X))
addr04d2:        lbz  addr037f      ; Long branch on D=0
addr04d5:        ldn RD         ; Load D with (RD)
addr04d6:        xor            ; Logical exclusive OR  D with (R(X))
addr04d7:        stxd           ; Store via X and devrement
addr04d8:        CALL   addr0513    ; Set P=R4 as program counter
addr04db:        dec RD         ; Decrement (RD)
addr04dc:        dec RD         ; Decrement (RD)
addr04dd:        CALL   addr0513    ; Set P=R4 as program counter
addr04e0:        inc RD         ; Increment (RD)
addr04e1:        ghi RD         ; Get high register RD
addr04e2:        lskp           ; Long skip
addr04e3:        ghi RD         ; Get high register RD
addr04e4:        stxd           ; Store via X and devrement
addr04e5:        plo RA         ; Put low register RA
addr04e6:        phi RA         ; Put high register RA
addr04e7:        ldi  11h        ; Load D immediate
addr04e9:        plo RF         ; Put low register RF
addr04ea:        sex RD         ; Set P=RD as datapointer
addr04eb:        glo RA         ; Get low register RA
addr04ec:        sm             ; Substract memory: DF,D=D-(R(X))
addr04ed:        str R2         ; Store D to (R2)
addr04ee:        dec RD         ; Decrement (RD)
addr04ef:        ghi RA         ; Get high register RA
addr04f0:        smb            ; Substract memory with borrow
addr04f1:        bnf addr04f6       ; Short branch on DF=0
addr04f3:        phi RA         ; Put high register RA
addr04f4:        ldn R2         ; Load D with (R2)
addr04f5:        plo RA         ; Put low register RA
addr04f6:        inc RD         ; Increment (RD)
addr04f7:        inc RD         ; Increment (RD)
addr04f8:        inc RD         ; Increment (RD)
addr04f9:        ldx            ; Pop stack. Place value in D register
addr04fa:        shlc           ; Shift left with carry
addr04fb:        stxd           ; Store via X and devrement
addr04fc:        ldx            ; Pop stack. Place value in D register
addr04fd:        shlc           ; Shift left with carry
addr04fe:        stxd           ; Store via X and devrement
addr04ff:        glo RA         ; Get low register RA
addr0500:        shlc           ; Shift left with carry
addr0501:        CALL   addr0524    ; Set P=R4 as program counter
addr0504:        dec RF         ; Decrement (RF)
addr0505:        glo RF         ; Get low register RF
addr0506:        lbnz  addr04ea     ; Long branch on D!=0
addr0509:        inc R2         ; Increment (R2)
addr050a:        ldn R2         ; Load D with (R2)
addr050b:        shl            ; Shift left D
addr050c:        bnf  addr0521       ; Short branch on DF=0
addr050e:        sep R7         ; Set P=R7 as program counter
addr050f:        inc RA         ; Increment (RA)
addr0510:        plo RD         ; Put low register RD
addr0511:        br  addr0518        ; Short branch
addr0513:        sex RD         ; Set P=RD as datapointer
addr0514:        ldx            ; Pop stack. Place value in D register
addr0515:        shl            ; Shift left D
addr0516:        bnf  addr0521       ; Short branch on DF=0
addr0518:        inc RD         ; Increment (RD)
addr0519:        ghi RD         ; Get high register RD
addr051a:        sm             ; Substract memory: DF,D=D-(R(X))
addr051b:        stxd           ; Store via X and devrement
addr051c:        ghi RD         ; Get high register RD
addr051d:        smb            ; Substract memory with borrow
addr051e:        str RD         ; Store D to (RD)
addr051f:        smi  00h        ; Substract D,DF to value
addr0521:        RETURN         ; Set P=R5 as program counter

addr0522:        glo RA         ; Get low register RA
addr0523:        shl            ; Shift left D
addr0524:        plo RA         ; Put low register RA
addr0525:        ghi RA         ; Get high register RA
addr0526:        shlc           ; Shift left with carry
addr0527:        phi RA         ; Put high register RA
addr0528:        RETURN         ; Set P=R5 as program counter

addr0529:        sep R7         ; Set P=R7 as program counter
addr052a:        inc R8         ; Increment (R8)
addr052b:        lbz  addr03b1      ; Long branch on D=0
addr052e:        lda RB         ; Load D from (RB), increment RB
addr052f:        xri  0dh        ; Logical XOR D with value
addr0531:        bnz  addr052e       ; Short branch on D!=0
addr0533:        CALL   addr0698    ; Set P=R4 as program counter
addr0536:        bz  addr054b        ; Short branch on D=0
addr0538:        CALL   addr010c    ; Set P=R4 as program counter
addr053b:        bdf  addr0546       ; Short branch on DF=1
addr053d:        sep R7         ; Set P=R7 as program counter
addr053e:        inc RC         ; Increment (RC)
addr053f:        phi R9         ; Put high register R9
addr0540:        lda RD         ; Load D from (RD), increment RD
addr0541:        plo R9         ; Put low register R9
addr0542:        sep R7         ; Set P=R7 as program counter
addr0543:        inc R7         ; Increment (R7)
addr0544:        str RD         ; Store D to (RD)
addr0545:        RETURN         ; Set P=R5 as program counter

addr0546:        sep R7         ; Set P=R7 as program counter
addr0547:        inc RE         ; Increment (RE)
addr0548:        phi R9         ; Put high register R9
addr0549:        lda RD         ; Load D from (RD), increment RD
addr054a:        plo R9         ; Put low register R9
addr054b:        lbr  addr037f      ; Long branch
addr054e:        sep R7         ; Set P=R7 as program counter
addr054f:        dec R0         ; Decrement (R0)
addr0550:        phi RB         ; Put high register RB
addr0551:        lda RD         ; Load D from (RD), increment RD
addr0552:        plo RB         ; Put low register RB
addr0553:        CALL   addr0698    ; Set P=R4 as program counter
addr0556:        bz  addr054b        ; Short branch on D=0
addr0558:        sep R7         ; Set P=R7 as program counter
addr0559:        inc RC         ; Increment (RC)
addr055a:        glo R9         ; Get low register R9
addr055b:        stxd           ; Store via X and devrement
addr055c:        ghi R9         ; Get high register R9
addr055d:        str RD         ; Store D to (RD)
addr055e:        br  addr0542        ; Short branch
addr0560:        CALL   addr05fe    ; Set P=R4 as program counter
addr0563:        bz  addr0538        ; Short branch on D=0
addr0565:        sep R7         ; Set P=R7 as program counter
addr0566:        dec R8         ; Decrement (R8)
addr0567:        glo RA         ; Get low register RA
addr0568:        stxd           ; Store via X and devrement
addr0569:        ghi RA         ; Get high register RA
addr056a:        str RD         ; Store D to (RD)
addr056b:        br  addr054b        ; Short branch
addr056d:        CALL   addr058b    ; Set P=R4 as program counter
addr0570:        lda R2         ; Load D from (R2), increment R2
addr0571:        phi RA         ; Put high register RA
addr0572:        ldn R2         ; Load D with (R2)
addr0573:        plo RA         ; Put low register RA
addr0574:        sep R7         ; Set P=R7 as program counter
addr0575:        dec R6         ; Decrement (R6)
addr0576:        glo R2         ; Get low register R2
addr0577:        stxd           ; Store via X and devrement
addr0578:        ghi R2         ; Get high register R2
addr0579:        stxd           ; Store via X and devrement
addr057a:        CALL   addr0601    ; Set P=R4 as program counter
addr057d:        bnz  addr0565       ; Short branch on D!=0
addr057f:        br  addr0588        ; Short branch
addr0581:        CALL   addr058b    ; Set P=R4 as program counter
addr0584:        lda R2         ; Load D from (R2), increment R2
addr0585:        phi R9         ; Put high register R9
addr0586:        ldn R2         ; Load D with (R2)
addr0587:        plo R9         ; Put low register R9
addr0588:        lbr  addr022d      ; Long branch
addr058b:        sep R7         ; Set P=R7 as program counter
addr058c:        dec R2         ; Decrement (R2)
addr058d:        inc R2         ; Increment (R2)
addr058e:        inc R2         ; Increment (R2)
addr058f:        glo R2         ; Get low register R2
addr0590:        adi  02h        ; Add D,DF with value
addr0592:        xor            ; Logical exclusive OR  D with (R(X))
addr0593:        dec RD         ; Decrement (RD)
addr0594:        bnz  addr059c       ; Short branch on D!=0
addr0596:        ghi R2         ; Get high register R2
addr0597:        adci  00h       ; Add with carry immediate
addr0599:        xor            ; Logical exclusive OR  D with (R(X))
addr059a:        bz  addr054b        ; Short branch on D=0
addr059c:        inc R2         ; Increment (R2)
addr059d:        RETURN         ; Set P=R5 as program counter

addr059e:        sep R7         ; Set P=R7 as program counter
addr059f:        inc R6         ; Increment (R6)
addr05a0:        skp            ; Skip next byte
addr05a1:        ghi RD         ; Get high register RD
addr05a2:        shl            ; Shift left D
addr05a3:        sep R7         ; Set P=R7 as program counter
addr05a4:        inc RA         ; Increment (RA)
addr05a5:        ghi RD         ; Get high register RD
addr05a6:        shrc           ; Shift right with carry
addr05a7:        str RD         ; Store D to (RD)
addr05a8:        br  addr05b2        ; Short branch
addr05aa:        ldi  30h        ; Load D immediate
addr05ac:        plo RB         ; Put low register RB
addr05ad:        CALL   addr0354    ; Set P=R4 as program counter
addr05b0:        ghi RD         ; Get high register RD
addr05b1:        phi RB         ; Put high register RB
addr05b2:        CALL   addr0106    ; Set P=R4 as program counter
addr05b5:        ani  7fh        ; Logical AND D with value
addr05b7:        bz  addr05b2        ; Short branch on D=0
addr05b9:        str R2         ; Store D to (R2)
addr05ba:        xri  7fh        ; Logical XOR D with value
addr05bc:        bz  addr05b2        ; Short branch on D=0
addr05be:        xri  75h        ; Logical XOR D with value
addr05c0:        bz  addr059e        ; Short branch on D=0
addr05c2:        xri  19h        ; Logical XOR D with value
addr05c4:        bz  addr05a1        ; Short branch on D=0
addr05c6:        sep R7         ; Set P=R7 as program counter
addr05c7:        inc R3         ; Increment (R3)
addr05c8:        ldn R2         ; Load D with (R2)
addr05c9:        xor            ; Logical exclusive OR  D with (R(X))
addr05ca:        bz  addr05d7        ; Short branch on D=0
addr05cc:        dec RD         ; Decrement (RD)
addr05cd:        ldn R2         ; Load D with (R2)
addr05ce:        xor            ; Logical exclusive OR  D with (R(X))
addr05cf:        bnz  addr05dd       ; Short branch on D!=0
addr05d1:        dec RB         ; Decrement (RB)
addr05d2:        glo RB         ; Get low register RB
addr05d3:        smi  30h        ; Substract D,DF to value
addr05d5:        bdf  addr05b2       ; Short branch on DF=1
addr05d7:        ldi  30h        ; Load D immediate
addr05d9:        plo RB         ; Put low register RB
addr05da:        ldi  0dh        ; Load D immediate
addr05dc:        skp            ; Skip next byte
addr05dd:        ldn R2         ; Load D with (R2)
addr05de:        str RB         ; Store D to (RB)
addr05df:        sep R7         ; Set P=R7 as program counter
addr05e0:        inc R9         ; Increment (R9)
addr05e1:        glo RB         ; Get low register RB
addr05e2:        sm             ; Substract memory: DF,D=D-(R(X))
addr05e3:        bnf  addr05ec       ; Short branch on DF=0
addr05e5:        ldi  07h        ; Load D immediate
addr05e7:        CALL   addr03f4    ; Set P=R4 as program counter
addr05ea:        ldn RB         ; Load D with (RB)
addr05eb:        skp            ; Skip next byte
addr05ec:        lda RB         ; Load D from (RB), increment RB
addr05ed:        xri  0dh        ; Logical XOR D with value
addr05ef:        bnz  addr05b2       ; Short branch on D!=0
addr05f1:        CALL   addr03d5    ; Set P=R4 as program counter
addr05f4:        sep R7         ; Set P=R7 as program counter
addr05f5:        inc R8         ; Increment (R8)
addr05f6:        glo RB         ; Get low register RB
addr05f7:        str RD         ; Store D to (RD)
addr05f8:        ldi  30h        ; Load D immediate
addr05fa:        plo RB         ; Put low register RB
addr05fb:        lbr  addr02c5      ; Long branch
addr05fe:        CALL   addr02c5    ; Set P=R4 as program counter
addr0601:        glo RA         ; Get low register RA
addr0602:        str R2         ; Store D to (R2)
addr0603:        ghi RA         ; Get high register RA
addr0604:        or             ; Logical OR  D with (R(X))
addr0605:        lbz  addr037f      ; Long branch on D=0
addr0608:        sep R7         ; Set P=R7 as program counter
addr0609:        dec R0         ; Decrement (R0)
addr060a:        phi RB         ; Put high register RB
addr060b:        lda RD         ; Load D from (RD), increment RD
addr060c:        plo RB         ; Put low register RB
addr060d:        CALL   addr0698    ; Set P=R4 as program counter
addr0610:        lsnz           ; Long skip on D!=0
addr0611:        glo RD         ; Get low register RD
addr0612:        RETURN         ; Set P=R5 as program counter

addr0613:        sex RD         ; Set P=RD as datapointer
addr0614:        glo RA         ; Get low register RA
addr0615:        sd             ; Substract D: D,DF=(R(X))-D
addr0616:        str R2         ; Store D to (R2)
addr0617:        ghi RA         ; Get high register RA
addr0618:        dec RD         ; Decrement (RD)
addr0619:        sdb            ; Substract D with borrow
addr061a:        sex R2         ; Set P=R2 as datapointer
addr061b:        or             ; Logical OR  D with (R(X))
addr061c:        bdf  addr0612       ; Short branch on DF=1
addr061e:        lda RB         ; Load D from (RB), increment RB
addr061f:        xri  0dh        ; Logical XOR D with value
addr0621:        bnz  addr061e       ; Short branch on D!=0
addr0623:        br  addr060d        ; Short branch
addr0625:        CALL   addr0628    ; Set P=R4 as program counter
addr0628:        CALL   addr02c5    ; Set P=R4 as program counter
addr062b:        lda RD         ; Load D from (RD), increment RD
addr062c:        phi R8         ; Put high register R8
addr062d:        lda RD         ; Load D from (RD), increment RD
addr062e:        plo R8         ; Put low register R8
addr062f:        lda RD         ; Load D from (RD), increment RD
addr0630:        phi R6         ; Put high register R6
addr0631:        lda RD         ; Load D from (RD), increment RD
addr0632:        plo R6         ; Put low register R6
addr0633:        glo RD         ; Get low register RD
addr0634:        str R2         ; Store D to (R2)
addr0635:        sep R7         ; Set P=R7 as program counter
addr0636:        inc R9         ; Increment (R9)
addr0637:        ldn R2         ; Load D with (R2)
addr0638:        str RD         ; Store D to (RD)
addr0639:        plo RD         ; Put low register RD
addr063a:        glo RA         ; Get low register RA
addr063b:        RETURN         ; Set P=R5 as program counter

addr063c:        sep R7         ; Set P=R7 as program counter
addr063d:        dec RC         ; Decrement (RC)
addr063e:        glo RB         ; Get low register RB
addr063f:        stxd           ; Store via X and devrement
addr0640:        ghi RB         ; Get high register RB
addr0641:        str RD         ; Store D to (RD)
addr0642:        CALL   addr05fe    ; Set P=R4 as program counter
addr0645:        sep R7         ; Set P=R7 as program counter
addr0646:        dec RA         ; Decrement (RA)
addr0647:        glo RB         ; Get low register RB
addr0648:        stxd           ; Store via X and devrement
addr0649:        ghi RB         ; Get high register RB
addr064a:        stxd           ; Store via X and devrement
addr064b:        CALL   addr05fe    ; Set P=R4 as program counter
addr064e:        dec RB         ; Decrement (RB)
addr064f:        dec RB         ; Decrement (RB)
addr0650:        sep R7         ; Set P=R7 as program counter
addr0651:        dec RA         ; Decrement (RA)
addr0652:        glo RB         ; Get low register RB
addr0653:        sm             ; Substract memory: DF,D=D-(R(X))
addr0654:        dec RD         ; Decrement (RD)
addr0655:        ghi RB         ; Get high register RB
addr0656:        smb            ; Substract memory with borrow
addr0657:        bdf  addr067b       ; Short branch on DF=1
addr0659:        lda RB         ; Load D from (RB), increment RB
addr065a:        phi RA         ; Put high register RA
addr065b:        lda RB         ; Load D from (RB), increment RB
addr065c:        plo RA         ; Put low register RA
addr065d:        bnz  addr0662       ; Short branch on D!=0
addr065f:        ghi RA         ; Get high register RA
addr0660:        bz  addr067b        ; Short branch on D=0
addr0662:        CALL   addr0415    ; Set P=R4 as program counter
addr0665:        ldi  2dh        ; Load D immediate
addr0667:        xri  0dh        ; Logical XOR D with value
addr0669:        CALL   addr03f4    ; Set P=R4 as program counter
addr066c:        CALL   addr010c    ; Set P=R4 as program counter
addr066f:        bdf  addr067b       ; Short branch on DF=1
addr0671:        lda RB         ; Load D from (RB), increment RB
addr0672:        xri  0dh        ; Logical XOR D with value
addr0674:        bnz  addr0667       ; Short branch on D!=0
addr0676:        CALL   addr03d5    ; Set P=R4 as program counter
addr0679:        br  addr0650        ; Short branch
addr067b:        sep R7         ; Set P=R7 as program counter
addr067c:        dec RC         ; Decrement (RC)
addr067d:        phi RB         ; Put high register RB
addr067e:        lda RD         ; Load D from (RD), increment RD
addr067f:        plo RB         ; Put low register RB
addr0680:        RETURN         ; Set P=R5 as program counter

addr0681:        sep R7         ; Set P=R7 as program counter
addr0682:        dec R6         ; Decrement (R6)
addr0683:        glo R2         ; Get low register R2
addr0684:        stxd           ; Store via X and devrement
addr0685:        ghi R2         ; Get high register R2
addr0686:        str RD         ; Store D to (RD)
addr0687:        sep R7         ; Set P=R7 as program counter
addr0688:        inc R8         ; Increment (R8)
addr0689:        dec RD         ; Decrement (RD)
addr068a:        lsz            ; Long skip on D=0
addr068b:        sep R7         ; Set P=R7 as program counter
addr068c:        dec R8         ; Decrement (R8)
addr068d:        plo RA         ; Put low register RA
addr068e:        lda RD         ; Load D from (RD), increment RD
addr068f:        inc R2         ; Increment (R2)
addr0690:        inc R2         ; Increment (R2)
addr0691:        sex R2         ; Set P=R2 as datapointer
addr0692:        stxd           ; Store via X and devrement
addr0693:        glo RA         ; Get low register RA
addr0694:        stxd           ; Store via X and devrement
addr0695:        lbr  addr022d      ; Long branch
addr0698:        sep R7         ; Set P=R7 as program counter
addr0699:        dec R7         ; Decrement (R7)
addr069a:        lda RB         ; Load D from (RB), increment RB
addr069b:        str RD         ; Store D to (RD)
addr069c:        inc RD         ; Increment (RD)
addr069d:        lda RB         ; Load D from (RB), increment RB
addr069e:        stxd           ; Store via X and devrement
addr069f:        or             ; Logical OR  D with (R(X))
addr06a0:        inc RD         ; Increment (RD)
addr06a1:        RETURN         ; Set P=R5 as program counter

addr06a2:        CALL   addr045e    ; Set P=R4 as program counter
addr06a5:        CALL   addr05fe    ; Set P=R4 as program counter
addr06a8:        adi  0ffh        ; Add D,DF with value
addr06aa:        ghi RD         ; Get high register RD
addr06ab:        plo RF         ; Put low register RF
addr06ac:        bdf addr06ba  ; Short branch on DF=1
addr06ae:        ghi RB         ; Get high register RB
addr06af:        phi RD         ; Put high register RD
addr06b0:        glo RB         ; Get low register RB
addr06b1:        plo RD         ; Put low register RD
addr06b2:        dec RF         ; Decrement (RF)
addr06b3:        dec RF         ; Decrement (RF)
addr06b4:        dec RF         ; Decrement (RF)
addr06b5:        lda RD         ; Load D from (RD), increment RD
addr06b6:        xri  0dh        ; Logical XOR D with value
addr06b8:        bnz addr06b4       ; Short branch on D!=0
addr06ba:        dec RB         ; Decrement (RB)
addr06bb:        dec RB         ; Decrement (RB)
addr06bc:        CALL   addr045e    ; Set P=R4 as program counter
addr06bf:        sep R7         ; Set P=R7 as program counter
addr06c0:        dec R8         ; Decrement (R8)
addr06c1:        ldn RB         ; Load D with (RB)
addr06c2:        xri  0dh        ; Logical XOR D with value
addr06c4:        stxd           ; Store via X and devrement
addr06c5:        str RD         ; Store D to (RD)
addr06c6:        bz  addr06d9        ; Short branch on D=0
addr06c8:        ghi RA         ; Get high register RA
addr06c9:        str RD         ; Store D to (RD)
addr06ca:        inc RD         ; Increment (RD)
addr06cb:        glo RA         ; Get low register RA
addr06cc:        str RD         ; Store D to (RD)
addr06cd:        ghi RB         ; Get high register RB
addr06ce:        phi RA         ; Put high register RA
addr06cf:        glo RB         ; Get low register RB
addr06d0:        plo RA         ; Put low register RA
addr06d1:        inc RF         ; Increment (RF)
addr06d2:        inc RF         ; Increment (RF)
addr06d3:        inc RF         ; Increment (RF)
addr06d4:        lda RA         ; Load D from (RA), increment RA
addr06d5:        xri  0dh        ; Logical XOR D with value
addr06d7:        bnz  addr06d3       ; Short branch on D!=0
addr06d9:        sep R7         ; Set P=R7 as program counter
addr06da:        dec RE         ; Decrement (RE)
addr06db:        phi RA         ; Put high register RA
addr06dc:        lda RD         ; Load D from (RD), increment RD
addr06dd:        plo RA         ; Put low register RA
addr06de:        sep R7         ; Set P=R7 as program counter
addr06df:        dec R4         ; Decrement (R4)
addr06e0:        glo RA         ; Get low register RA
addr06e1:        sm             ; Substract memory: DF,D=D-(R(X))
addr06e2:        plo RA         ; Put low register RA
addr06e3:        dec RD         ; Decrement (RD)
addr06e4:        ghi RA         ; Get high register RA
addr06e5:        smb            ; Substract memory with borrow
addr06e6:        phi RA         ; Put high register RA
addr06e7:        inc RD         ; Increment (RD)
addr06e8:        glo RF         ; Get low register RF
addr06e9:        add            ; Add D: D,DF= D+(R(X))
addr06ea:        phi RF         ; Put high register RF
addr06eb:        glo RF         ; Get low register RF
addr06ec:        ani  80h        ; Logical AND D with value
addr06ee:        lsz            ; Long skip on D=0
addr06ef:        ldi  0ffh        ; Load D immediate
addr06f1:        dec RD         ; Decrement (RD)
addr06f2:        adc            ; Add with carry
addr06f3:        sex R2         ; Set P=R2 as datapointer
addr06f4:        stxd           ; Store via X and devrement
addr06f5:        phi R8         ; Put high register R8
addr06f6:        ghi RF         ; Get high register RF
addr06f7:        stxd           ; Store via X and devrement
addr06f8:        str R2         ; Store D to (R2)
addr06f9:        glo R2         ; Get low register R2
addr06fa:        sd             ; Substract D: D,DF=(R(X))-D
addr06fb:        ghi R8         ; Get high register R8
addr06fc:        str R2         ; Store D to (R2)
addr06fd:        ghi R2         ; Get high register R2
addr06fe:        sdb            ; Substract D with borrow
addr06ff:        lbdf  addr037e     ; Long branch on DF=1
addr0702:        glo RF         ; Get low register RF
addr0703:        bz  addr0730        ; Short branch on D=0
addr0705:        str R2         ; Store D to (R2)
addr0706:        shl            ; Shift left D
addr0707:        bnf  addr071e       ; Short branch on DF=0
addr0709:        sep R7         ; Set P=R7 as program counter
addr070a:        dec RE         ; Decrement (RE)
addr070b:        phi RF         ; Put high register RF
addr070c:        lda RD         ; Load D from (RD), increment RD
addr070d:        plo RF         ; Put low register RF
addr070e:        sex R2         ; Set P=R2 as datapointer
addr070f:        sm             ; Substract memory: DF,D=D-(R(X))
addr0710:        plo R8         ; Put low register R8
addr0711:        ghi RF         ; Get high register RF
addr0712:        adci  00h       ; Add with carry immediate
addr0714:        phi R8         ; Put high register R8
addr0715:        lda R8         ; Load D from (R8), increment R8
addr0716:        str RF         ; Store D to (RF)
addr0717:        inc RF         ; Increment (RF)
addr0718:        inc RA         ; Increment (RA)
addr0719:        ghi RA         ; Get high register RA
addr071a:        bnz  addr0715       ; Short branch on D!=0
addr071c:        br  addr0730        ; Short branch
addr071e:        ghi RF         ; Get high register RF
addr071f:        plo RF         ; Put low register RF
addr0720:        ghi R8         ; Get high register R8
addr0721:        phi RF         ; Put high register RF
addr0722:        sep R7         ; Set P=R7 as program counter
addr0723:        dec R4         ; Decrement (R4)
addr0724:        phi R8         ; Put high register R8
addr0725:        lda RD         ; Load D from (RD), increment RD
addr0726:        plo R8         ; Put low register R8
addr0727:        dec RA         ; Decrement (RA)
addr0728:        sex RF         ; Set P=RF as datapointer
addr0729:        ldn R8         ; Load D with (R8)
addr072a:        dec R8         ; Decrement (R8)
addr072b:        stxd           ; Store via X and devrement
addr072c:        inc RA         ; Increment (RA)
addr072d:        ghi RA         ; Get high register RA
addr072e:        bnz  addr0729       ; Short branch on D!=0
addr0730:        sep R7         ; Set P=R7 as program counter
addr0731:        dec R4         ; Decrement (R4)
addr0732:        inc R2         ; Increment (R2)
addr0733:        lda R2         ; Load D from (R2), increment R2
addr0734:        stxd           ; Store via X and devrement
addr0735:        ldn R2         ; Load D with (R2)
addr0736:        str RD         ; Store D to (RD)
addr0737:        sep R7         ; Set P=R7 as program counter
addr0738:        dec RE         ; Decrement (RE)
addr0739:        phi RA         ; Put high register RA
addr073a:        lda RD         ; Load D from (RD), increment RD
addr073b:        plo RA         ; Put low register RA
addr073c:        sep R7         ; Set P=R7 as program counter
addr073d:        dec R8         ; Decrement (R8)
addr073e:        plo RF         ; Put low register RF
addr073f:        or             ; Logical OR  D with (R(X))
addr0740:        bz  addr074e        ; Short branch on D=0
addr0742:        glo RF         ; Get low register RF
addr0743:        str RA         ; Store D to (RA)
addr0744:        inc RA         ; Increment (RA)
addr0745:        lda RD         ; Load D from (RD), increment RD
addr0746:        str RA         ; Store D to (RA)
addr0747:        inc RA         ; Increment (RA)
addr0748:        lda RB         ; Load D from (RB), increment RB
addr0749:        str RA         ; Store D to (RA)
addr074a:        xri  0dh        ; Logical XOR D with value
addr074c:        bnz  addr0747       ; Short branch on D!=0
addr074e:        lbr  addr03b5      ; Long branch
addr0751:        stxd           ; Store via X and devrement
addr0752:        str R2         ; Store D to (R2)
addr0753:        ghi RD         ; Get high register RD
addr0754:        phi RA         ; Put high register RA
addr0755:        dec RD         ; Decrement (RD)
addr0756:        lda R3         ; Load D from (R3), increment R3
addr0757:        RETURN         ; Set P=R5 as program counter

addr0758:        str RD         ; Store D to (RD)
addr0759:        dec RD         ; Decrement (RD)
addr075a:        glo R8         ; Get low register R8
addr075b:        ani  0fh        ; Logical AND D with value
addr075d:        ori  60h        ; Logical OR D with value
addr075f:        str RD         ; Store D to (RD)
addr0760:        ani  08h        ; Logical AND D with value
addr0762:        lsz            ; Long skip on D=0
addr0763:        nop            ; No operation
addr0764:        inc R2         ; Increment (R2)
;IL Code
				DW    0DD24h
				DW    03A91h
				DW    02710h
				DW    0E159h
				DW    0C52Ah
				DW    05610h
				DW    0112Ch
				DW    08B4Ch
				DW    045D4h
				DW    0A080h
				DW    0BD31h
				DW    08FE0h
				DW    0131Dh
				DW    09447h
				DW    0CF88h
				DW    054CFh
				DW    0318Fh
				DW    0E010h
				DW    01116h
				DW    08053h
				DW    055C2h
				DW    0318Fh
				DW    0E014h
				DW    01690h
				DW    050D2h
				DW    08349h
				DW    04ED4h
				DW    0E571h
				DW    088BBh
				DW    0E11Dh
				DW    08FA2h
				DW    02158h
				DW    06F83h
				DW    0AC22h
				DW    05583h
				DW    0BA24h
				DW    093E0h
				DW    0231Dh
				DW    0318Fh
				DW    02048h
				DW    09149h
				DW    0C631h
				DW    08F32h
				DW    03731h
				DW    08F84h
				DW    05448h
				DW    045CEh
				DW    01C1Dh
				DW    0380Dh
				DW    09A49h
				DW    04E50h
				DW    055D4h
				DW    0A010h
				DW    0E724h
				DW    03F20h
				DW    09127h
				DW    0E159h
				DW    081ACh
				DW    0318Fh
				DW    01311h
				DW    082ACh
				DW    04DE0h
				DW    01D89h
				DW    05245h
				DW    05455h
				DW    052CEh
				DW    0E015h
				DW    01D85h
				DW    0454Eh
				DW    0C4E0h
				DW    02D9Ah
				DW    04C49h
				DW    053D4h
				DW    0E70Ah
				DW    00001h
				DW    00A7Fh
				DW    0FF65h
				DW    0318Fh
				DW    03231h
				DW    0E024h
				DW    00000h
				DW    00000h
				DW    00A80h
				DW    01F1Dh
				DW    08552h
				DW    055CEh
				DW    0380Ah
				DW    08643h
				DW    04C45h
				DW    041D2h
				DW    02B9Ah
				DW    0504Ch
				DW    04FD4h
				DW    0318Fh
				DW    095ACh
				DW    00B0Bh
				DW    00A00h
				DW    02A32h
				DW    0620Ah
				DW    00040h
				DW    01A0Ah
				DW    00040h
				DW    0325Ah
				DW    01864h
				DW    03902h
				DW    038F4h
				DW    00A6Dh
				DW    08018h
				DW    00B0Ah
				DW    00008h
				DW    01B0Bh
				DW    00402h
				DW    00503h
				DW    0050Ah
				DW    00008h
				DW    01A19h
				DW    0090Ah
				DW    00213h
				DW    00908h
				DW    00201h
				DW    0138Fh
				DW    0AC31h
				DW    08FE0h
				DW    00A01h
				DW    00902h
				DW    00103h
				DW    0010Bh
				DW    02E0Ch
				DW    01DE0h
				DW    01D8Ah
				DW    0504Fh
				DW    04BC5h
				DW    00A01h
				DW    01831h
				DW    08F6Ch
				DW    0914Fh
				DW    055D4h
				DW    00A01h
				DW    0260Ah
				DW    00008h
				DW    0325Ah
				DW    03231h
				DW    0E02Eh
				DW    00C1Dh
				DW    09E53h
				DW    04156h
				DW    0C5E0h
				DW    02454h
				DW    05552h
				DW    04E20h
				DW    04F4Eh
				DW    02052h
				DW    04543h
				DW    04F52h
				DW    0C423h
				DW    02448h
				DW    04954h
				DW    0204Bh
				DW    045D9h
				DW    06239h
				DW    05C0Ah
				DW    00106h
				DW    00B0Bh
				DW    02E0Ch
				DW    0230Ah
				DW    009FDh
				DW    00924h
				DW    01209h
				DW    02012h
				DW    0190Ah
				DW    00100h
				DW    01809h
				DW    02012h
				DW    02E0Ch
				DW    01D86h
				DW    04C4Fh
				DW    041C4h
				DW    0E062h
				DW    03985h
				DW    00924h
				DW    00A09h
				DW    0FA0Ah
				DW    00001h
				DW    00920h
				DW    0122Eh
				DW    0660Ah
				DW    00018h
				DW    01813h
				DW    02D23h
				DW    02454h
				DW    04150h
				DW    04520h
				DW    04552h
				DW    0524Fh
				DW    0D22Bh
				DW    08452h
				DW    045CDh
				DW    01DA0h
				DW    080BDh
				DW    03814h
				DW    085ADh
				DW    031A6h
				DW    01764h
				DW    081ABh
				DW    031A6h
				DW    085ABh
				DW    031A6h
				DW    0185Ah
				DW    085ADh
				DW    031A6h
				DW    01954h
				DW    02F31h
				DW    0B585h
				DW    0AA31h
				DW    0B51Ah
				DW    05A85h
				DW    0AF31h
				DW    0B51Bh
				DW    0542Fh
				DW    09952h
				DW    04E44h
				DW    0A80Ah
				DW    08080h
				DW    0120Ah
				DW    00929h
				DW    01A0Ah
				DW    01A85h
				DW    01813h
				DW    00980h
				DW    01201h
				DW    00B32h
				DW    02C61h
				DW    0720Bh
				DW    00402h
				DW    00305h
				DW    0031Bh
				DW    01A19h
				DW    00B09h
				DW    0060Ah
				DW    00000h
				DW    01C17h
				DW    02F8Eh
				DW    05553h
				DW    052A8h
				DW    0318Fh
				DW    03231h
				DW    03231h
				DW    080A9h
				DW    02E2Fh
				DW    09149h
				DW    04E50h
				DW    0A80Ah
				DW    00126h
				DW    00A00h
				DW    00832h
				DW    05A0Ah
				DW    00008h
				DW    0187Dh
				DW    09146h
				DW    04C47h
				DW    0A80Ah
				DW    009F8h
				DW    00A00h
				DW    00532h
				DW    05A0Ah
				DW    00001h
				DW    0196Bh
				DW    08F50h
				DW    04545h
				DW    04BA8h
				DW    00A01h
				DW    01431h
				DW    08F80h
				DW    0A90Bh
				DW    02E2Fh
				DW    0A212h
				DW    02FC1h
				DW    02F80h
				DW    0A831h
				DW    08F80h
				DW    0A92Fh
				DW    083ACh
				DW    0398Fh
				DW    00B2Fh
				DW    084BDh
				DW    00902h
				DW    02F8Eh
				DW    0BC84h
				DW    0BD09h
				DW    0032Fh
				DW    084BEh
				DW    00905h
				DW    02F09h
				DW    0012Fh
				DW    080BEh
				DW    084BDh
				DW    00906h
				DW    02F84h
				DW    0BC09h
				DW    0052Fh
				DW    00904h
				DW    02F31h
				DW    08F0Bh
				DW    00B06h
				DW    00107h
				DW    00109h
				DW    00102h
				DW    0011Ch
				DW    06009h
				DW    0060Ah
				DW    00000h
				DW    01C60h
				DW    02F00h
				DB    00h
;IL Code End
addr09d8:        ldi  82h        ; Load D immediate
addr09da:        plo R1         ; Put low register R1
addr09db:        ldi  0ch        ; Load D immediate
addr09dd:        phi R1         ; Put high register R1
addr09de:        b1   addr09de        ; Short branch on EF1=1
addr09e0:        inp 1          ; Input to (R(X)) and D, N=001
addr09e1:        sex R3         ; Set P=R3 as datapointer
addr09e2:        ret            ; Return from interrupt, set IE=1
addr09e3:        RETURN         ; Set P=R5 as program counter

addr09e4:        ori  34h        ; Logical OR D with value
addr09e6:        phi RF         ; Put high register RF
addr09e7:        dec RD         ; Decrement (RD)
addr09e8:        sex RD         ; Set P=RD as datapointer
addr09e9:        glo RD         ; Get low register RD
addr09ea:        plo RF         ; Put low register RF
addr09eb:        ldi  0d5h        ; Load D immediate
addr09ed:        stxd           ; Store via X and devrement
addr09ee:        ldi  9dh        ; Load D immediate
addr09f0:        stxd           ; Store via X and devrement
addr09f1:        glo RF         ; Get low register RF
addr09f2:        stxd           ; Store via X and devrement
addr09f3:        ghi RF         ; Get high register RF
addr09f4:        str RD         ; Store D to (RD)
addr09f5:        ldi  01h        ; Load D immediate
addr09f7:        sep RD         ; Set P=RD as program counter
addr09f8:        br   addr09e4        ; Short branch
addr09fa:        lbr  addr0a29      ; Long branch
addr09fd:        ldi  0f0h        ; Load D immediate
addr09ff:        phi RC         ; Put high register RC
addr0a00:        ldi  65h        ; Load D immediate
addr0a02:        plo RC         ; Put low register RC
addr0a03:        ldi  80h        ; Load D immediate
addr0a05:        phi RD         ; Put high register RD
addr0a06:        smi  00h        ; Substract D,DF to value
addr0a08:        sep RC         ; Set P=RC as program counter
addr0a09:        ghi RD         ; Get high register RD
addr0a0a:        bnz  addr0a06       ; Short branch on D!=0
addr0a0c:        seq            ; Set Q=1
addr0a0d:        lda RA         ; Load D from (RA), increment RA
addr0a0e:        phi RF         ; Put high register RF
addr0a0f:        ldi  09h        ; Load D immediate
addr0a11:        plo RF         ; Put low register RF
addr0a12:        plo RD         ; Put low register RD
addr0a13:        shl            ; Shift left D
addr0a14:        sep RC         ; Set P=RC as program counter
addr0a15:        dec RF         ; Decrement (RF)
addr0a16:        ghi RF         ; Get high register RF
addr0a17:        shl            ; Shift left D
addr0a18:        phi RF         ; Put high register RF
addr0a19:        glo RF         ; Get low register RF
addr0a1a:        bnz  addr0a14       ; Short branch on D!=0
addr0a1c:        glo RD         ; Get low register RD
addr0a1d:        shr            ; Shift right D
addr0a1e:        sep RC         ; Set P=RC as program counter
addr0a1f:        dec R8         ; Decrement (R8)
addr0a20:        ghi R8         ; Get high register R8
addr0a21:        bnz  addr0a0c       ; Short branch on D!=0
addr0a23:        sep RC         ; Set P=RC as program counter
addr0a24:        sep RC         ; Set P=RC as program counter
addr0a25:        sep RC         ; Set P=RC as program counter
addr0a26:        sep RC         ; Set P=RC as program counter
addr0a27:        req            ; Reset Q=0
addr0a28:        RETURN         ; Set P=R5 as program counter

addr0a29:        ldi  0f0h        ; Load D immediate
addr0a2b:        phi RC         ; Put high register RC
addr0a2c:        ldi  0bah        ; Load D immediate
addr0a2e:        plo RC         ; Put low register RC
addr0a2f:        ldi  0f9h        ; Load D immediate
addr0a31:        phi RD         ; Put high register RD
addr0a32:        sep RC         ; Set P=RC as program counter
addr0a33:        bnf  addr0a2f       ; Short branch on DF=0
addr0a35:        ghi RD         ; Get high register RD
addr0a36:        bnz  addr0a32       ; Short branch on D!=0
addr0a38:        sep RC         ; Set P=RC as program counter
addr0a39:        bdf  addr0a38       ; Short branch on DF=1
addr0a3b:        ldi  01h        ; Load D immediate
addr0a3d:        phi RD         ; Put high register RD
addr0a3e:        plo RD         ; Put low register RD
addr0a3f:        sep RC         ; Set P=RC as program counter
addr0a40:        ghi RD         ; Get high register RD
addr0a41:        shlc           ; Shift left with carry
addr0a42:        phi RD         ; Put high register RD
addr0a43:        bnf  addr0a3f       ; Short branch on DF=0
addr0a45:        sep RC         ; Set P=RC as program counter
addr0a46:        glo RD         ; Get low register RD
addr0a47:        shr            ; Shift right D
addr0a48:        bdf  addr0a59       ; Short branch on DF=1
addr0a4a:        ghi RD         ; Get high register RD
addr0a4b:        str RA         ; Store D to (RA)
addr0a4c:        sex RA         ; Set P=RA as datapointer
addr0a4d:        out 4          ; Output (R(X)); Increment R(X), N=100
addr0a4e:        adi  0ffh        ; Add D,DF with value
addr0a50:        glo R8         ; Get low register R8
addr0a51:        shlc           ; Shift left with carry
addr0a52:        plo R8         ; Put low register R8
addr0a53:        ani  03h        ; Logical AND D with value
addr0a55:        bnz  addr0a38       ; Short branch on D!=0
addr0a57:        inc R9         ; Increment (R9)
addr0a58:        glo RA         ; Get low register RA
addr0a59:        RETURN         ; Set P=R5 as program counter

;INPUT FROM KEYBOARD ROUTINE
addr0a5a:        ghi RE         ; Get high register RE
addr0a5b:        bz  addr0ab0        ; Short branch on D=0
addr0a5d:        SERIAL_B  addr0a5d        ; Short branch on EF4=1 SERIAL INPUT ROUTINE
addr0a5f:        shr            ; Shift right D
addr0a60:        CALL   addr00f9    ; Set P=R4 as program counter
addr0a63:        SERIAL_B  addr0a5a        ; Short branch on EF4=1
addr0a65:        ldi  7Fh        ; Load D immediate
addr0a67:        plo RF         ; Put low register RF
addr0a68:        ghi RE         ; Get high register RE
addr0a69:        shr            ; Shift right D
addr0a6a:        SERIAL_B  addr0a70        ; Short branch on EF4=1
addr0a6c:        bnf  addr0a71       ; Short branch on DF=0
addr0a6e:        seq            ; Set Q=1
addr0a6f:        skp            ; Skip next byte
addr0a70:        req            ; Reset Q=0
addr0a71:        CALL   addr00f6    ; Set P=R4 as program counter
addr0a74:        glo RF         ; Get low register RF
addr0a75:        shr            ; Shift right D
addr0a76:        plo RF         ; Put low register RF
addr0a77:        SERIAL_BN  addr0a7b       ; Short branch on EF4=0
addr0a79:        ori  80h        ; Logical OR D with value
addr0a7b:        bdf  addr0a67   ; Short branch on DF=1
				 ghi RE
				 shr
				 SERIAL_B  +       ; Short branch on EF4=1
				 seq            ; Set Q=1
			 	 skp            ; Skip next byte
+				 req            ; Reset Q=0
				 CALL   addr00f6    ; Set P=R4 as program counter
				 req
                 glo RF         ; Get low register RF
                 RETURN         ; Set P=R5 as program counter

;OUTPUT TO SCREEN ROUTINE
addr0a83:        plo RC         ; Put low register RC
addr0a84:        phi RC         ; Put high register RC
addr0a85:        ghi RE         ; Get high register RE
addr0a86:        bnz  addr0a8b       ; Short branch on D!=0
addr0a88:        glo RC         ; Get low register RC
addr0a89:        br  addr0aba        ; Short branch

;SERIAL OUTPUT ROUTINE
addr0a8b:        ldi  0ah        ; Load D immediate
addr0a8d:        plo RF         ; Put low register RF
addr0a8e:        CALL   addr00f6    ; Set P=R4 as program counter
addr0a91:        adi  00h        ; Add D,DF with value
addr0a93:        CALL   addr00f6    ; Set P=R4 as program counter
addr0a96:        lsnf           ; Long skip on DF=0
addr0a97:        req            ; Reset Q=0
addr0a98:        skp            ; Skip next byte
addr0a99:        seq            ; Set Q=1
addr0a9a:        ghi RC         ; Get high register RC
addr0a9b:        smi  00h        ; Substract D,DF to value
addr0a9d:        shrc           ; Shift right with carry
addr0a9e:        phi RC         ; Put high register RC
addr0a9f:        dec RF         ; Decrement (RF)
addr0aa0:        glo RF         ; Get low register RF
addr0aa1:        bnz  addr0a93       ; Short branch on D!=0
addr0aa3:        glo RC         ; Get low register RC
addr0aa4:        RETURN         ; Set P=R5 as program counter

addr0aa5:        sep R7         ; Set P=R7 as program counter
addr0aa6:        ldn RF         ; Load D with (RF)
addr0aa7:        shl            ; Shift left D
addr0aa8:        shl            ; Shift left D
addr0aa9:        shl            ; Shift left D
addr0aaa:        bnz   addr0ab3       ; Short branch on D!=0
addr0aac:        shlc           ; Shift left with carry
addr0aad:        CALL   addr0ad8    ; Set P=R4 as program counter
addr0ab0:        CALL   addr09d8    ; Set P=R4 as program counter
addr0ab3:        KB_BN   addr0aa5       ; Short branch on EF3=0
addr0ab5:        ghi RD         ; Get high register RD
addr0ab6:        CALL   addr0ad8    ; Set P=R4 as program counter
addr0ab9:        inp 7          ; Input to (R(X)) and D, N=111
addr0aba:        CALL   addr0ad8    ; Set P=R4 as program counter
addr0abd:        plo RE         ; Put low register RE
addr0abe:        xri  0ah        ; Logical XOR D with value
addr0ac0:        bz   addr0ac6        ; Short branch on D=0
addr0ac2:        SERIAL_B   addr0ac6        ; Short branch on EF4=1
addr0ac4:        glo RE         ; Get low register RE
addr0ac5:        RETURN         ; Set P=R5 as program counter

addr0ac6:        CALL   addr09d8    ; Set P=R4 as program counter
addr0ac9:        ldi  0ch        ; Load D immediate
addr0acb:        phi RF         ; Put high register RF
addr0acc:        dec RF         ; Decrement (RF)
addr0acd:        ghi RF         ; Get high register RF
addr0ace:        bnz  addr0acc       ; Short branch on D!=0
addr0ad0:        SERIAL_B   addr0ad0        ; Short branch on EF4=1
addr0ad2:        sex R3         ; Set P=R3 as datapointer
addr0ad3:        out 1          ; Output (R(X)); Increment R(X), N=001
addr0ad4:        idl            ; Idle or wait for interrupt or DMA request
addr0ad5:        glo RE         ; Get low register RE
addr0ad6:        dis            ; Disable. Return from interrupt, set IE=0
addr0ad7:        RETURN         ; Set P=R5 as program counter

addr0ad8:        ani  7fh        ; Logical AND D with value
addr0ada:        plo RE         ; Put low register RE
addr0adb:        smi  60h        ; Substract D,DF to value
addr0add:        glo RE         ; Get low register RE
addr0ade:        bnf addr0ae3       ; Short branch on DF=0
addr0ae0:        smi  20h        ; Substract D,DF to value
addr0ae2:        plo RE         ; Put low register RE
addr0ae3:        sex R2         ; Set P=R2 as datapointer
addr0ae4:        glo RA         ; Get low register RA
addr0ae5:        stxd           ; Store via X and devrement
addr0ae6:        ghi RA         ; Get high register RA
addr0ae7:        stxd           ; Store via X and devrement
addr0ae8:        glo R9         ; Get low register R9
addr0ae9:        stxd           ; Store via X and devrement
addr0aea:        ghi R9         ; Get high register R9
addr0aeb:        stxd           ; Store via X and devrement
addr0aec:        glo R8         ; Get low register R8
addr0aed:        stxd           ; Store via X and devrement
addr0aee:        ghi R8         ; Get high register R8
addr0aef:        stxd           ; Store via X and devrement
addr0af0:        ldi  1eh        ; Load D immediate
addr0af2:        plo RA         ; Put low register RA
addr0af3:        ldi  0ch        ; Load D immediate
addr0af5:        phi RA         ; Put high register RA
addr0af6:        sep R7         ; Set P=R7 as program counter
addr0af7:        ldn R8         ; Load D with (R8)
addr0af8:        phi R8         ; Put high register R8
addr0af9:        lda RD         ; Load D from (RD), increment RD
addr0afa:        plo R8         ; Put low register R8
addr0afb:        lda RD         ; Load D from (RD), increment RD
addr0afc:        ani  07h        ; Logical AND D with value
addr0afe:        phi R9         ; Put high register R9
addr0aff:        sep R7         ; Set P=R7 as program counter
addr0b00:        inc R3         ; Increment (R3)
addr0b01:        glo RE         ; Get low register RE
addr0b02:        xor            ; Logical exclusive OR  D with (R(X))
addr0b03:        bz  addr0b4e        ; Short branch on D=0
addr0b05:        glo RE         ; Get low register RE
addr0b06:        smi  7fh        ; Substract D,DF to value
addr0b08:        bz  addr0b20        ; Short branch on D=0
addr0b0a:        adi  5fh        ; Add D,DF with value
addr0b0c:        bdf  addr0ba8       ; Short branch on DF=1
addr0b0e:        adi  13h        ; Add D,DF with value
addr0b10:        bz  addr0b71        ; Short branch on D=0
addr0b12:        adi  01h        ; Add D,DF with value
addr0b14:        bz  addr0b5f        ; Short branch on D=0
addr0b16:        adi  02h        ; Add D,DF with value
addr0b18:        bz  addr0b55        ; Short branch on D=0
addr0b1a:        adi  09h        ; Add D,DF with value
addr0b1c:        bz  addr0b4e        ; Short branch on D=0
addr0b1e:        bnf  addr0b46       ; Short branch on DF=0
addr0b20:        sep R7         ; Set P=R7 as program counter
addr0b21:        inc RA         ; Increment (RA)
addr0b22:        ghi R9         ; Get high register R9
addr0b23:        ani  07h        ; Logical AND D with value
addr0b25:        phi R9         ; Put high register R9
addr0b26:        adi  0feh        ; Add D,DF with value
addr0b28:        glo R8         ; Get low register R8
addr0b29:        shlc           ; Shift left with carry
addr0b2a:        xor            ; Logical exclusive OR  D with (R(X))
addr0b2b:        ani  07h        ; Logical AND D with value
addr0b2d:        xor            ; Logical exclusive OR  D with (R(X))
addr0b2e:        str RD         ; Store D to (RD)
addr0b2f:        sep R7         ; Set P=R7 as program counter
addr0b30:        ldn R9         ; Load D with (R9)
addr0b31:        ghi R9         ; Get high register R9
addr0b32:        stxd           ; Store via X and devrement
addr0b33:        glo R8         ; Get low register R8
addr0b34:        stxd           ; Store via X and devrement
addr0b35:        ghi R8         ; Get high register R8
addr0b36:        stxd           ; Store via X and devrement
addr0b37:        inc R2         ; Increment (R2)
addr0b38:        lda R2         ; Load D from (R2), increment R2
addr0b39:        phi R8         ; Put high register R8
addr0b3a:        lda R2         ; Load D from (R2), increment R2
addr0b3b:        plo R8         ; Put low register R8
addr0b3c:        lda R2         ; Load D from (R2), increment R2
addr0b3d:        phi R9         ; Put high register R9
addr0b3e:        lda R2         ; Load D from (R2), increment R2
addr0b3f:        plo R9         ; Put low register R9
addr0b40:        lda R2         ; Load D from (R2), increment R2
addr0b41:        phi RA         ; Put high register RA
addr0b42:        ldn R2         ; Load D with (R2)
addr0b43:        plo RA         ; Put low register RA
addr0b44:        glo RE         ; Get low register RE
addr0b45:        RETURN         ; Set P=R5 as program counter

addr0b46:        ldi  80h        ; Load D immediate
addr0b48:        sep RA         ; Set P=RA as program counter
addr0b49:        xri  0ffh        ; Logical XOR D with value
addr0b4b:        and            ; Logical AND: D with (R(X))
addr0b4c:        br  addr0b52        ; Short branch
addr0b4e:        ldi  80h        ; Load D immediate
addr0b50:        sep RA         ; Set P=RA as program counter
addr0b51:        or             ; Logical OR  D with (R(X))
addr0b52:        str R8         ; Store D to (R8)
addr0b53:        br  addr0b20        ; Short branch
addr0b55:        glo R8         ; Get low register R8
addr0b56:        adi  30h        ; Add D,DF with value
addr0b58:        plo R8         ; Put low register R8
addr0b59:        ghi R8         ; Get high register R8
addr0b5a:        adci  00h       ; Add with carry immediate
addr0b5c:        phi R8         ; Put high register R8
addr0b5d:        br  addr0b77        ; Short branch
addr0b5f:        ldi  3fh        ; Load D immediate
addr0b61:        plo R8         ; Put low register R8
addr0b62:        ldi  0fh        ; Load D immediate
addr0b64:        phi R8         ; Put high register R8
addr0b65:        sex R8         ; Set P=R8 as datapointer
addr0b66:        ghi RD         ; Get high register RD
addr0b67:        stxd           ; Store via X and devrement
addr0b68:        glo R8         ; Get low register R8
addr0b69:        smi  0b0h        ; Substract D,DF to value
addr0b6b:        ghi R8         ; Get high register R8
addr0b6c:        smbi  0dh       ; Substract memory toh borrow, immediate
addr0b6e:        bdf  addr0b66       ; Short branch on DF=1
addr0b70:        irx            ; Increment register X
addr0b71:        ghi RD         ; Get high register RD
addr0b72:        phi R9         ; Put high register R9
addr0b73:        glo R8         ; Get low register R8
addr0b74:        ani  0f8h        ; Logical AND D with value
addr0b76:        plo R8         ; Put low register R8
addr0b77:        glo R8         ; Get low register R8
addr0b78:        smi  08h        ; Substract D,DF to value
addr0b7a:        ghi R8         ; Get high register R8
addr0b7b:        smbi  0fh       ; Substract memory toh borrow, immediate
addr0b7d:        bnf  addr0b20       ; Short branch on DF=0
addr0b7f:        ldi  0b0h        ; Load D immediate
addr0b81:        plo RF         ; Put low register RF
addr0b82:        glo R8         ; Get low register R8
addr0b83:        adi  0b0h        ; Add D,DF with value
addr0b85:        ani  0f8h        ; Logical AND D with value
addr0b87:        plo RA         ; Put low register RA
addr0b88:        ldi  0dh        ; Load D immediate
addr0b8a:        phi RF         ; Put high register RF
addr0b8b:        adci  00h       ; Add with carry immediate
addr0b8d:        phi RA         ; Put high register RA
addr0b8e:        lda RA         ; Load D from (RA), increment RA
addr0b8f:        str RF         ; Store D to (RF)
addr0b90:        inc RF         ; Increment (RF)
addr0b91:        glo RF         ; Get low register RF
addr0b92:        smi  08h        ; Substract D,DF to value
addr0b94:        ghi RF         ; Get high register RF
addr0b95:        smbi  0fh       ; Substract memory toh borrow, immediate
addr0b97:        bnf  addr0b8e       ; Short branch on DF=0
addr0b99:        glo RF         ; Get low register RF
addr0b9a:        smi  40h        ; Substract D,DF to value
addr0b9c:        ghi RD         ; Get high register RD
addr0b9d:        bnf  addr0b8f       ; Short branch on DF=0
addr0b9f:        glo R8         ; Get low register R8
addr0ba0:        ani  07h        ; Logical AND D with value
addr0ba2:        plo R8         ; Put low register R8
addr0ba3:        ldi  0fh        ; Load D immediate
addr0ba5:        phi R8         ; Put high register R8
addr0ba6:        br  addr0b20        ; Short branch
addr0ba8:        glo RE         ; Get low register RE
addr0ba9:        shl            ; Shift left D
addr0baa:        adi  6fh        ; Add D,DF with value
addr0bac:        plo RF         ; Put low register RF
addr0bad:        ghi RD         ; Get high register RD
addr0bae:        adci  0ch       ; Add with carry immediate
addr0bb0:        phi RF         ; Put high register RF
addr0bb1:        sep R7         ; Set P=R7 as program counter
addr0bb2:        ldn RB         ; Load D with (RB)
addr0bb3:        lda RF         ; Load D from (RF), increment RF
addr0bb4:        str RD         ; Store D to (RD)
addr0bb5:        lda RF         ; Load D from (RF), increment RF
addr0bb6:        adi  2fh        ; Add D,DF with value
addr0bb8:        plo RF         ; Put low register RF
addr0bb9:        ghi RD         ; Get high register RD
addr0bba:        adci  0dh       ; Add with carry immediate
addr0bbc:        phi RF         ; Put high register RF
addr0bbd:        ghi R9         ; Get high register R9
addr0bbe:        str R2         ; Store D to (R2)
addr0bbf:        dec R2         ; Decrement (R2)
addr0bc0:        ldn RD         ; Load D with (RD)
addr0bc1:        ani  07h        ; Logical AND D with value
addr0bc3:        phi R9         ; Put high register R9
addr0bc4:        ldn RD         ; Load D with (RD)
addr0bc5:        ani 0f8h        ; Logical AND D with value
addr0bc7:        sep RA         ; Set P=RA as program counter
addr0bc8:        inc RA         ; Increment (RA)
addr0bc9:        inc RA         ; Increment (RA)
addr0bca:        plo R9         ; Put low register R9
addr0bcb:        inc R2         ; Increment (R2)
addr0bcc:        sex R2         ; Set P=R2 as datapointer
addr0bcd:        ldn RD         ; Load D with (RD)
addr0bce:        ani  07h        ; Logical AND D with value
addr0bd0:        sd             ; Substract D: D,DF=(R(X))-D
addr0bd1:        phi R9         ; Put high register R9
addr0bd2:        glo R9         ; Get low register R9
addr0bd3:        str RD         ; Store D to (RD)
addr0bd4:        lda RF         ; Load D from (RF), increment RF
addr0bd5:        sex RD         ; Set P=RD as datapointer
addr0bd6:        and            ; Logical AND: D with (R(X))
addr0bd7:        sep RA         ; Set P=RA as program counter
addr0bd8:        or             ; Logical OR  D with (R(X))
addr0bd9:        str R8         ; Store D to (R8)
addr0bda:        sep RA         ; Set P=RA as program counter
addr0bdb:        bdf addr0bd4       ; Short branch on DF=1
addr0bdd:        ldn RD         ; Load D with (RD)
addr0bde:        sep RA         ; Set P=RA as program counter
addr0bdf:        inc RA         ; Increment (RA)
addr0be0:        inc RA         ; Increment (RA)
addr0be1:        lbnf addr0bfc       ; Short branch on DF=0
addr0be3:        glo RF         ; Get low register RF
addr0be4:        smi  06h        ; Substract D,DF to value
addr0be6:        plo RF         ; Put low register RF
addr0be7:        inc R8         ; Increment (R8)
addr0be8:        glo R8         ; Get low register R8
addr0be9:        ani  07h        ; Logical AND D with value
addr0beb:        bnz addr0bf6       ; Short branch on D!=0
addr0bed:        ghi R9         ; Get high register R9
addr0bee:        ani  87h        ; Logical AND D with value
addr0bf0:        ori  50h        ; Logical OR D with value
addr0bf2:        phi R9         ; Put high register R9
addr0bf3:        dec RA         ; Decrement (RA)
addr0bf4:        dec RA         ; Decrement (RA)
addr0bf5:        sep RA         ; Set P=RA as program counter
addr0bf6:        ghi R9         ; Get high register R9
addr0bf7:        ori 0f8h        ; Logical OR D with value
addr0bf9:        phi R9         ; Put high register R9
addr0bfa:        lbr  addr0bd4        ; Short branch
addr0bfc:        sex R2         ; Set P=R2 as datapointer
addr0bfd:        ori  80h        ; Logical OR D with value
addr0bff:        skp            ; Skip next byte
addr0c00:        inc R9         ; Increment (R9)
addr0c01:        shr            ; Shift right D
addr0c02:        bnf  addr0c00       ; Short branch on DF=0
addr0c04:        glo R9         ; Get low register R9
addr0c05:        sdi  09h        ; Substract D,DF from value
addr0c07:        phi R9         ; Put high register R9
addr0c08:        smi  08h        ; Substract D,DF to value
addr0c0a:        bnf addr0c19       ; Short branch on DF=0
addr0c0c:        phi R9         ; Put high register R9
addr0c0d:        inc R8         ; Increment (R8)
addr0c0e:        glo R8         ; Get low register R8
addr0c0f:        ani  07h        ; Logical AND D with value
addr0c11:        bnz addr0c19       ; Short branch on D!=0
addr0c13:        ldi  50h        ; Load D immediate
addr0c15:        phi R9         ; Put high register R9
addr0c16:        dec RA         ; Decrement (RA)
addr0c17:        dec RA         ; Decrement (RA)
addr0c18:        sep RA         ; Set P=RA as program counter
addr0c19:        nop            ; No operation
addr0c1a:        lbr  addr0b77      ; Long branch
addr0c1d:        sep R3         ; Set P=R3 as program counter
addr0c1e:        str R2         ; Store D to (R2)
addr0c1f:        glo R8         ; Get low register R8
addr0c20:        smi  0b0h        ; Substract D,DF to value
addr0c22:        ghi R8         ; Get high register R8
addr0c23:        smbi  0dh       ; Substract memory toh borrow, immediate
addr0c25:        ghi RD         ; Get high register RD
addr0c26:        bnf  addr0c47       ; Short branch on DF=0
addr0c28:        ghi R9         ; Get high register R9
addr0c29:        ani  87h        ; Logical AND D with value
addr0c2b:        plo R9         ; Put low register R9
addr0c2c:        bz  addr0c45        ; Short branch on D=0
addr0c2e:        shl            ; Shift left D
addr0c2f:        bdf  addr0c3a       ; Short branch on DF=1
addr0c31:        ldn R2         ; Load D with (R2)
addr0c32:        shr            ; Shift right D
addr0c33:        str R2         ; Store D to (R2)
addr0c34:        dec R9         ; Decrement (R9)
addr0c35:        glo R9         ; Get low register R9
addr0c36:        bnz  addr0c31       ; Short branch on D!=0
addr0c38:        br  addr0c46        ; Short branch
addr0c3a:        shr            ; Shift right D
addr0c3b:        sdi  08h        ; Substract D,DF from value
addr0c3d:        plo R9         ; Put low register R9
addr0c3e:        ldn R2         ; Load D with (R2)
addr0c3f:        shl            ; Shift left D
addr0c40:        str R2         ; Store D to (R2)
addr0c41:        dec R9         ; Decrement (R9)
addr0c42:        glo R9         ; Get low register R9
addr0c43:        bnz  addr0c3e       ; Short branch on D!=0
addr0c45:        shl            ; Shift left D
addr0c46:        ldn R2         ; Load D with (R2)
addr0c47:        sex R8         ; Set P=R8 as datapointer
addr0c48:        sep R3         ; Set P=R3 as program counter
addr0c49:        br  addr0c4d        ; Short branch
addr0c4b:        br  addr0c1e        ; Short branch
addr0c4d:        ghi R9         ; Get high register R9
addr0c4e:        adi  18h        ; Add D,DF with value
addr0c50:        bnf  addr0c54       ; Short branch on DF=0
addr0c52:        ori  80h        ; Logical OR D with value
addr0c54:        ani  0f7h        ; Logical AND D with value
addr0c56:        phi R9         ; Put high register R9
addr0c57:        shl            ; Shift left D
addr0c58:        ani  0e0h        ; Logical AND D with value
addr0c5a:        xri  0c0h        ; Logical XOR D with value
addr0c5c:        bnz  addr0c70       ; Short branch on D!=0
addr0c5e:        ghi R9         ; Get high register R9
addr0c5f:        ani  07h        ; Logical AND D with value
addr0c61:        bnf  addr0c65       ; Short branch on DF=0
addr0c63:        ori  0f8h        ; Logical OR D with value
addr0c65:        phi R9         ; Put high register R9
addr0c66:        glo R8         ; Get low register R8
addr0c67:        adi  28h        ; Add D,DF with value
addr0c69:        plo R8         ; Put low register R8
addr0c6a:        ghi R8         ; Get high register R8
addr0c6b:        adci  00h       ; Add with carry immediate
addr0c6d:        phi R8         ; Put high register R8
addr0c6e:        br  addr0c1d        ; Short branch
addr0c70:        glo R8         ; Get low register R8
addr0c71:        smi  08h        ; Substract D,DF to value
addr0c73:        plo R8         ; Put low register R8
addr0c74:        ghi R8         ; Get high register R8
addr0c75:        smbi  00h       ; Substract memory toh borrow, immediate
addr0c77:        phi R8         ; Put high register R8
addr0c78:        br  addr0c1d        ; Short branch
addr0c7a:        ldi  03h        ; Load D immediate
addr0c7c:        plo R0         ; Put low register R0
addr0c7d:        sex R2         ; Set P=R2 as datapointer
addr0c7e:        lda R2         ; Load D from (R2), increment R2
addr0c7f:        shl            ; Shift left D
addr0c80:        lda R2         ; Load D from (R2), increment R2
addr0c81:        ret            ; Return from interrupt, set IE=1
addr0c82:        nop            ; No operation
addr0c83:        dec R2         ; Decrement (R2)
addr0c84:        sav            ; Save
addr0c85:        dec R2         ; Decrement (R2)
addr0c86:        stxd           ; Store via X and devrement
addr0c87:        ldi  0dh        ; Load D immediate
addr0c89:        phi R0         ; Put high register R0
addr0c8a:        ldi  0b0h        ; Load D immediate
addr0c8c:        plo R0         ; Put low register R0
addr0c8d:        b1  addr0c8d        ; Short branch on EF1=1
addr0c8f:        glo R0         ; Get low register R0
addr0c90:        dec R0         ; Decrement (R0)
addr0c91:        plo R0         ; Put low register R0
addr0c92:        sex R0         ; Set P=R0 as datapointer
addr0c93:        dec R0         ; Decrement (R0)
addr0c94:        plo R0         ; Put low register R0
addr0c95:        ghi R0         ; Get high register R0
addr0c96:        xri  0fh        ; Logical XOR D with value
addr0c98:        bnz  addr0c8f       ; Short branch on D!=0
addr0c9a:        phi R0         ; Put high register R0
addr0c9b:        ldi  0fh        ; Load D immediate
addr0c9d:        plo R0         ; Put low register R0
addr0c9e:        shrc           ; Shift right with carry
addr0c9f:        str R2         ; Store D to (R2)
addr0ca0:        ldx            ; Pop stack. Place value in D register
addr0ca1:        adi  01h        ; Add D,DF with value
addr0ca3:        str R0         ; Store D to (R0)
addr0ca4:        smi  3dh        ; Substract D,DF to value
addr0ca6:        bnf  addr0c7a       ; Short branch on DF=0
addr0ca8:        stxd           ; Store via X and devrement
addr0ca9:        ldx            ; Pop stack. Place value in D register
addr0caa:        adi  01h        ; Add D,DF with value
addr0cac:        str R0         ; Store D to (R0)
addr0cad:        br  addr0c7a        ; Short branch
CTBL:	DW		08608h		;SP MASK BYTE AND DATA POINTER
		DW		0820Ah		;! MASK BYTE AND DATA POINTER
		DW		0E508h		;" MASK BYTE AND DATA POINTER
		DW		0F823h		;# MASK BYTE AND DATA POINTER
		DW		0E435h		;$ MASK BYTE AND DATA POINTER
		DW		0E55Ah		;% MASK BYTE AND DATA POINTER
		DW		0F423h		;& MASK BYTE AND DATA POINTER
		DW		0C200h		;' MASK BYTE AND DATA POINTER
		DW		0C111h		;( MASK BYTE AND DATA POINTER
		DW		0C211h		;) MASK BYTE AND DATA POINTER
		DW		0E03Ch		;* MASK BYTE AND DATA POINTER
		DW		0E547h		;+ MASK BYTE AND DATA POINTER
		DW		0C307h		;, MASK BYTE AND DATA POINTER
		DW		0C441h		;- MASK BYTE AND DATA POINTER
		DW		08407h		;. MASK BYTE AND DATA POINTER
		DW		0E529h		;/ MASK BYTE AND DATA POINTER
		DW		0E111h		;0 MASK BYTE AND DATA POINTER
		DW		0E243h		;1 MASK BYTE AND DATA POINTER
		DW		0E44Fh		;2 MASK BYTE AND DATA POINTER
		DW		0E103h		;3 MASK BYTE AND DATA POINTER
		DW		0E01Dh		;4 MASK BYTE AND DATA POINTER
		DW		0E042h		;5 MASK BYTE AND DATA POINTER
		DW		0E249h		;6 MASK BYTE AND DATA POINTER
		DW		0E073h		;7 MASK BYTE AND DATA POINTER
		DW		0E303h		;8 MASK BYTE AND DATA POINTER
		DW		0E049h		;9 MASK BYTE AND DATA POINTER
		DW		08304h		;: MASK BYTE AND DATA POINTER
		DW		0C335h		; MASK BYTE AND DATA POINTER
		DW		0E541h		;< MASK BYTE AND DATA POINTER
		DW		0E503h		;= MASK BYTE AND DATA POINTER
		DW		0E517h		;> MASK BYTE AND DATA POINTER
		DW		0E05Ah		;? MASK BYTE AND DATA POINTER
		DW		0E079h		;@ MASK BYTE AND DATA POINTER
		DW		0E12Fh		;A MASK BYTE AND DATA POINTER
		DW		0E56Dh		;B MASK BYTE AND DATA POINTER
		DW		0E417h		;C MASK BYTE AND DATA POINTER
		DW		0E217h		;D MASK BYTE AND DATA POINTER
		DW		0E560h		;E MASK BYTE AND DATA POINTER
		DW		0E534h		;F MASK BYTE AND DATA POINTER
		DW		0E24Fh		;G MASK BYTE AND DATA POINTER
		DW		0E33Bh		;H MASK BYTE AND DATA POINTER
		DW		08217h		;I MASK BYTE AND DATA POINTER
		DW		0E155h		;J MASK BYTE AND DATA POINTER
		DW		0E060h		;K MASK BYTE AND DATA POINTER
		DW		0E343h		;L MASK BYTE AND DATA POINTER
		DW		0F96Dh		;M MASK BYTE AND DATA POINTER
		DW		0F41Dh		;N MASK BYTE AND DATA POINTER
		DW		0E017h		;O MASK BYTE AND DATA POINTER
		DW		0E573h		;P MASK BYTE AND DATA POINTER
		DW		0E00Bh		;Q MASK BYTE AND DATA POINTER
		DW		0E53Bh		;R MASK BYTE AND DATA POINTER
		DW		0E029h		;S MASK BYTE AND DATA POINTER
		DW		0E066h		;T MASK BYTE AND DATA POINTER
		DW		0E21Dh		;U MASK BYTE AND DATA POINTER
		DW		0E379h		;V MASK BYTE AND DATA POINTER
		DW		0FB2Eh		;W MASK BYTE AND DATA POINTER
		DW		0E260h		;X MASK BYTE AND DATA POINTER
		DW		0E273h		;Y MASK BYTE AND DATA POINTER
		DW		0E035h		;Z MASK BYTE AND DATA POINTER
		DW		0C017h		;[ MASK BYTE AND DATA POINTER
		DW		0E329h		;\ MASK BYTE AND DATA POINTER
		DW		0C117h		;] MASK BYTE AND DATA POINTER
		DW		0E200h		;^ MASK BYTE AND DATA POINTER
		DW		0E507h		;_ MASK BYTE AND DATA POINTER
DOTS:	DW		00000h		;START OF DOT TABLE
		DW		08080h		;
		DW		0E897h		;
		DW		0A897h		;
		DW		06840h		;
		DW		04020h		;
		DW		040ADh		;
		DW		0B6ADh		;
		DW		04404h		;
		DW		02056h		;
		DW		0DD57h		;
		DW		02000h		;
		DW		0F4AAh		;
		DW		0A9AAh		;
		DW		0F400h		;
		DW		039E9h		;
		DW		0ABADh		;
		DW		02900h		;
		DW		055FAh		;
		DW		054F8h		;
		DW		05400h		;
		DW		0C024h		;
		DW		04A91h		;
		DW		0600Ah		;
		DW		05575h		;
		DW		05151h		;
		DW		02014h		;
		DW		0EC86h		;
		DW		04C27h		;
		DW		0E400h		;
		DW		01515h		;
		DW		0BE55h		;
		DW		0B600h		;
		DW		001C2h		;
		DW		03CD2h		;
		DW		091F0h		;
		DW		01002h		;
		DW		0572Ah		;
		DW		070A0h		;
		DW		05800h		;
		DW		0DE68h		;
		DW		0A462h		;
		DW		01C06h		;
		DW		02355h		;
		DW		01518h		;
		DW		01051h		;
		DW		00422h		;
		DW		0A144h		;
		DW		000AFh		;
		DW		0ACD6h		;
		DW		0ACAFh		;
		DW		00042h		;
		DW		0425Fh		;
		DW		052F9h		;
		DW		01000h		;
		DW		04645h		;
		DW		0566Dh		;
		DW		04600h		;
		DW		09494h		;
		DW		0562Dh		;
		DW		0EE00h		;
		DW		06894h		;
		DW		0B4B4h		;
		DW		05400h		;
		SEP		RF		;