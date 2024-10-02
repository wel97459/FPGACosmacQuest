IL_SX   MACRO stack                  ;Duplicate Top number (two bytes) on Stack
        DB 00h + (stack & 07h)
    ENDM

IL_NO   MACRO                   ;Duplicate Top number (two bytes) on Stack
        DB 08h
    ENDM
IL_LB   MACRO val               ;Push Literal byte onto stack
        DW 0900H | val & FFh
    ENDM

IL_LN   MACRO val               ;Push Literal number
        DW 0A0000H | val & FFFFh
    ENDM

IL_DS   MACRO                   ;Duplicate Top number (two bytes) on Stack
        DB 0Bh
    ENDM

IL_SP   MACRO                   ;Stack Pop
        DB 0Ch
    ENDM

IL_SB   MACRO                   ;Save basic pointer
        DB 10h
    ENDM

IL_RB   MACRO                   ;Restore basic pointer
        DB 11h
    ENDM

IL_FV   MACRO                   ;Fetch Variable
        DB 12h
    ENDM

IL_SV   MACRO                   ;Store Variable
        DB 13H
    ENDM

IL_GS   MACRO                   ;GOSUB Save
        DB 14H
    ENDM

IL_RS   MACRO                   ;Restore Saved Line
        DB 15H
    ENDM

IL_GO   MACRO                   ;GOTO
        DB 16H
    ENDM

IL_NE   MACRO                   ;Negate(Two's Complement)
        DB 17H
    ENDM

IL_AD   MACRO                   ;Add
        DB 18H
    ENDM

IL_SU   MACRO                   ;Subtract
        DB 19H
    ENDM

IL_MP   MACRO                   ;Multiply
        DB 1AH
    ENDM

IL_DV   MACRO                   ;Divide
        DB 1BH
    ENDM

IL_CP   MACRO                   ;Compare
        DB 1CH
    ENDM

IL_NX   MACRO                   ;Next BASIC Statement
        DB 1DH
    ENDM

IL_LS   MACRO                   ;List the program
        DB 1FH
    ENDM

IL_PN   MACRO                   ;Print Number
        DB 20H
    ENDM

IL_PQ   MACRO                   ;Print String
        DB 21H
    ENDM

IL_PT   MACRO                   ;Print Tab
        DB 22H
    ENDM

IL_NL   MACRO                   ;New Line
        DB 23H
    ENDM

IL_PC   MACRO                   ;Print literal string  
        DB 24h
    ENDM

IL_GL   MACRO                   ;Get Input Line.
        DB 27h
    ENDM

IL_IL   MACRO                   ;Insert Basic line  
        DB 2Ah
    ENDM

IL_MT   MACRO                   ;Mark the basic program space empty
        DB 2Bh
    ENDM

IL_XQ   MACRO                   ;Execute
        DB 2Ch
    ENDM

IL_WS   MACRO                   ;Stop
        DB 2Dh
    ENDM

IL_US   MACRO                   ;Machine Language Subroutine
        DB 2Eh
    ENDM

IL_RT   MACRO                   ;IL Subroutine Return
        DB 2Fh
    ENDM

IL_JS   MACRO addr              ;IL Subroutine Call
        DW 3000H | addr-STRT & 7FFh
    ENDM

IL_J    MACRO addr              ;Jump
        DW 3800H | addr-STRT & 7FFh
    ENDM

IL_BR_B MACRO  addr             ;Relative Branch Back
        DB 60h - (1+$-addr)
    ENDM

IL_BR_F MACRO  addr             ;Relative Branch Forward
        DB 60h + (addr-$+1)
    ENDM

IL_BC MACRO  addr               ;String Match Branch
        DB 80h + ((addr-$-1)&31)
    ENDM

IL_BV MACRO  addr               ;Branch if not a Variable
        DB 0A0h + ((addr-$-1)&31)
    ENDM

IL_BN   MACRO  addr             ;Branch if not a number
        DB 0C0h + ((addr-$-1)&31)
    ENDM

IL_BE   MACRO  addr             ;Branch if not end of line
        DB 0E0h + ((addr-$-1)&31)
    ENDM

IL_ENDCHAR  MACRO char
        DB char | 80h
    ENDM

STRT    IL_PC
        DB ':', 091h            ;':Q^'  Start Of IL Program
        IL_GL                   ;GL
        IL_SB                   ;SB
        IL_BE LO                ;BE      :LO
        IL_BR_B STRT            ;BR      :STRT
LO      IL_BN STMT              ;BN      :STMT
        IL_IL                   ;IL
        IL_BR_B STRT            ;BR      :STRT
XEC     IL_SB                   ;SB
        IL_RB                   ;RB
        IL_XQ                   ;XQ
STMT    IL_BC GOTO
        DB 'LE'                 ;BC      :GOTO     'LET'
        IL_ENDCHAR 'T'
        IL_BV $+1               ;BV      * !18
        IL_BC $+1               ;BC      * !20     '='
        IL_ENDCHAR '='          
LET     IL_JS EXPR              ;JS      :EXPR
        IL_BE $+1               ;BE      * !23
        IL_SV                   ;SV
        IL_NX                   ;NX
GOTO    IL_BC PRNT
        DB 'G'                  ;BC      :PRNT     'GO'
        IL_ENDCHAR 'O'       
        IL_BC GOSB              ;BC      :GOSB     'TO'
        DB 'T'
        IL_ENDCHAR 'O'
        IL_JS EXPR              ;JS      :EXPR
        IL_BE $+1               ;BE      * !34
        IL_SB                   ;SB
        IL_RB                   ;RB
        IL_GO                   ;GO
GOSB    IL_BC $+1
        DB 'S', 'U'             ;BC      * !39     'SUB'
        IL_ENDCHAR 'B'          ;--
        IL_JS EXPR              ;JS      :EXPR
        IL_BE $+1               ;BE      * !44
        IL_GS                   ;GS
        IL_GO                   ;GO
PRNT    IL_BC SKIP_             ;BC      :SKIP     'PR'
        DB 'P'
        IL_ENDCHAR 'R'
        IL_BC P0                ;BC      :P0       'INT'
        DB 'IN'    
        IL_ENDCHAR 'T'          ;--
P0      IL_BE P3                ;BE      :P3
        IL_BR_F S3              ;BR      Z233
P1      IL_BC S1                ;BC      Z234      ';'
        IL_ENDCHAR ';'
P2      IL_BE P3                ;BE      :P3
        IL_NX                   ;NX
P3      IL_BC S5                ;BC      Z235      '"'
        IL_ENDCHAR '"'
        IL_PQ                   ;PQ
        IL_BR_B P1              ;BR      :P1
SKIP_   IL_BR_B IF_             ;BR      :IF
S1      IL_BC S2                ;Z234       BC      Z236      ','
        IL_ENDCHAR ','
        IL_PT                   ;PT
        IL_BR_B P2              ;BR      :P2
S2      IL_BC S4                ;Z236       BC      Z233      ':'
        IL_ENDCHAR ':'
S3      IL_PC                   ;PC                'S^'
        IL_ENDCHAR 13h
S4      IL_BE P3                 ;Z233       BE      * !73
        IL_NL                 ;NL
        IL_NX                 ;NX
S5      IL_JS EXPR
        DB 020h                 ;PN
        IL_BR_B P1
IF_     DB 091h, 049h, 0C6h         ;BC      :INPT     'IF'
        IL_JS EXPR
        DB 032h, 037h               ;JS      Z237
        IL_JS EXPR
        DB 084h, 054h, 048h             ;BC      :I1       'THEN'
        DB 045h, 0CEh               ;--
I1      IL_CP         ;CP
        IL_NX                 ;NX
        IL_J STMT
INPT    DB 09Ah, 049h, 04Eh       ;BC      :RETN     'INPUT'
        DB 050h, 055h, 0D4h             ;--
        IL_BV BV      ;Z242       BV      * !104
        IL_SB                 ;SB
        IL_BE Z238                 ;BE      Z238
        DB 024h, 03Fh, 020h  ;Z239       PC                '? Q^'
        DB 091h                ;--
        IL_GL                 ;GL
        IL_BE Z238                 ;BE      Z238
        IL_BR Z239                 ;BR      Z239
        DB 081h, 0ACh    ;Z238       BC      Z240      ','
        IL_JS EXPR
        IL_SV                 ;SV
        IL_RB                 ;RB
        DB 082h, 0ACh               ;BC      Z241      ','
        IL_BR Z242                 ;BR      Z242
        IL_BE BE      ;Z241       BE      * !123
        IL_NX                 ;NX
RETN_   DB 089h, 052h, 045h       ;BC      :END      'RETURN'
        DB 054h, 055h, 052h             ;--
        DB 0CEh                ;--
        DB 0E0h                 ;BE      * !132
        DB 015h                 ;RS
        IL_NX                 ;NX
END     DB 085h, 045h, 04Eh        ;BC      :LIST     'END'
        DB 0C4h                ;--
        DB 0E0h                 ;BE      * !139
        IL_WS                 ;WS
LIST_   DB 09Ah, 04Ch, 049h       ;BC      :RUN      'LIST'
        DB 053h, 0D4h               ;--
        IL_BE Z243                 ;BE      Z243
        DB 00Ah, 000h, 001h             ;LN      #0001
        DB 00Ah, 07Fh, 0FFh             ;LN      #7FFF
        IL_BR Z244                 ;BR      Z244
        IL_JS EXPR
        DB 032h, 031h               ;JS      Z245
        DB 0E0h                 ;BE      * !158
        DB 024h, 000h, 000h  ;Z244       PC                '@^@^@^@^J^@^'
        DB 000h, 000h, 00Ah             ;--
        DB 080h                ;--
        DB 01Fh                 ;LS
        IL_NX                 ;NX
RUN_    DB 085h, 052h, 055h        ;BC      :CLER     'RUN'
        DB 0CEh                ;--
        IL_J XEC
CLER    DB 086h, 043h, 04Ch       ;BC      :PLOT     'CLEAR'
        DB 045h, 041h, 0D2h             ;--
        IL_MT                 ;MT
PLOT    DB 09Ah, 050h, 04Ch       ;BC      Z246      'PLOT'
        DB 04Fh, 0D4h               ;--
        IL_JS EXPR
        DB 095h, 0ACh               ;BC      Z247      ','
        IL_DS                 ;DS
        IL_DS                 ;DS
        DB 00Ah, 000h, 02Ah             ;LN      42
        DB 032h, 062h               ;JS      Z248      COMPARE >0 AND <42
        DB 00Ah, 000h, 040h             ;LN      64        MULTIPLY BY 64
        IL_MP                  ;MP
        DB 00Ah, 000h, 040h             ;LN      64
        DB 032h, 05Ah               ;JS      Z249      GET NEXT EXPR AND COMP >0 AND <64
        IL_AD                 ;AD                ADD TOGETHER (X*64+Y)
        IL_BR_B SKIP_                 ;BR      Z250      SKIP JUMPS
        IL_J POKE
        DB 038h, 0F4h    ;Z247       J       Z251
        DB 00Ah, 06Dh, 080h  ;Z250       LN      BUFF<<3         BUFF*8
        IL_AD                 ;AD                ADD (BUFF*8)+(X*64+Y)
        IL_DS                 ;DS
        DB 00Ah, 000h, 008h             ;LN      8
        IL_DV                  ;DV                ((BUFF*8)+(X*64+Y))/8
        IL_DS                 ;DS
        IL_SX 4                 ;SX 4
        IL_SX 2                 ;SX 2
        IL_SX 5                 ;SX 5
        IL_SX 3                 ;SX 3
        IL_SX 5                 ;SX 5
        DB 00Ah, 000h, 008h             ;LN      8
        IL_MP                  ;MP                 MULTIPLY BY 8
        IL_SU                 ;SU                 GET REMANDER
        DB 009h, 00Ah               ;LB      TVXY+2
        IL_SX 2                 ;SX 2
        IL_SV                 ;SV                 STORE NEW BIT POINTER
        DB 009h, 008h               ;LB      TVXY
        IL_SX 2                 ;SX 2
        IL_SX 1                 ;SX 1
        IL_SV                 ;SV                 STORE NEW CURSOR
        DB 08Fh, 0ACh               ;BC      Z252      ','
        IL_JS EXPR
        IL_BE BE      ;Z251       BE      * !245
        DB 00Ah, 001h, 009h             ;LN      TYPEV
        IL_SX 2                 ;SX 2
        IL_SX 1                 ;SX 1
        IL_SX 3                 ;SX 3
        IL_SX 1                 ;SX 1
        IL_DS                 ;DS
        IL_US                 ;US                CALL TYPEV AND OUTPUT BYTE
        IL_SP                 ;SP                POP RETURNED VALUE
        IL_NX                 ;NX                NEXT STATEMENT
        IL_BE BE      ;Z252       BE      * !257
        IL_NX                 ;NX
POKE    DB 08Ah, 050h, 04Fh       ;BC      :OUT      'POKE'
        DB 04Bh, 0C5h               ;--
        DB 00Ah, 001h, 018h             ;LN      ILPOKE
        IL_JS EXPR
        IL_BR Z253                 ;BR      Z253
OUT_    DB 091h, 04Fh, 055h        ;BC      :SAVE     'OUT'
        DB 0D4h                ;--
        DB 00Ah, 001h, 026h             ;LN      ILINPOUT
        DB 00Ah, 000h, 008h             ;LN      8
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <8
        DB 032h, 031h    ;Z253       JS      Z245      CHECK FOR ,AND GET EXPR
        DB 0E0h                 ;BE      * !284
        IL_US                 ;US                CALL ILINPOUT OR ILPOKE
        IL_SP                 ;SP                POP RETURNED VALUE
        IL_NX                 ;NX                NEXT STATEMENT
SAVE    DB 09Eh, 053h, 041h       ;BC      Z254      'SAVE'
        DB 056h, 0C5h               ;--
        DB 0E0h                 ;BE      * !293
        DB 024h, 054h, 055h             ;PC                'TURN ON RECORD'
        DB 052h, 04Eh, 020h             ;--
        DB 04Fh, 04Eh, 020h             ;--
        DB 052h, 045h, 043h             ;--
        DB 04Fh, 052h, 0C4h             ;--
        IL_NL                 ;NL
        DB 024h, 048h, 049h             ;PC                'HIT KEY'
        DB 054h, 020h, 04Bh             ;--
        DB 045h, 0D9h               ;--
        IL_BR Z255                 ;BR      Z255
        IL_J LOAD
        DB 00Ah, 001h, 006h  ;Z255       LN      KEYV
        IL_DS                 ;DS
        IL_DS                 ;DS
        IL_US                 ;US                CALL KEY INPUT
        IL_SP                 ;SP                POP RETURNED VALUE
        IL_NL                 ;NL                NEW LINE
        DB 00Ah, 009h, 0FDh             ;LN      ILSAVE
        DB 009h, 024h               ;LB      MEND
        IL_FV                 ;FV
        DB 009h, 020h               ;LB      BASIC
        IL_FV                 ;FV
        IL_SU                 ;SU                END PROGRAM-BEGIN PROGRAM
        DB 00Ah, 001h, 000h             ;LN      256
        IL_AD                 ;AD                ADD 256 ????
        DB 009h, 020h               ;LB      BASIC
        IL_FV                 ;FV
        IL_US                 ;US                CALL ILSAVE
        IL_SP                 ;SP                POP RETURNED VALUE
        IL_NX                 ;NX                NEXT STATEMENT
LOAD    DB 086h, 04Ch, 04Fh             ;BC      Z256      'LOAD'
        DB 041h, 0C4h               ;--
        DB 0E0h                 ;BE      * !354
        IL_BR Z257                 ;BR      Z257
        DB 039h, 085h    ;Z256       J       Z258
        DB 009h, 024h    ;Z257       LB      MEND
        DB 00Ah, 009h, 0FAh             ;LN      ILLOAD
        DB 00Ah, 000h, 001h             ;LN      1
        DB 009h, 020h               ;LB      BASIC
        IL_FV                 ;FV
        IL_US                 ;US                CALL ILLOAD
        IL_BR Z259                 ;BR      Z259      ILLOAD SKIPS THIS IF NO ERROR
        DB 00Ah, 000h, 018h             ;LN      0x18      SPARE STACK SIZE-1,DOES NOT GET IT?
        IL_AD                 ;AD                ADD TO RETURN VALUE
        IL_SV                 ;SV                SAVE MEM END
        IL_WS                 ;WS                WARM START
        IL_NL      ;Z259       NL
        DB 024h, 054h, 041h             ;PC                'TAPE ERROR'
        DB 050h, 045h, 020h             ;--
        DB 045h, 052h, 052h             ;--
        DB 04Fh, 0D2h               ;--
        IL_MT                 ;MT
        DB 084h, 052h, 045h  ;Z258       BC      :DFLT     'REM'
        DB 0CDh                ;--
        IL_NX                 ;NX
DFLT    DB 0A0h                 ;BV      * !395
        DB 080h, 0BDh               ;BC      * !397    '='
        IL_J LET
EXPR    DB 085h, 0ADh       ;BC      Z260      '-'
        IL_JS TERM
        IL_NE                 ;NE
        IL_BR Z261                 ;BR      Z261
        DB 081h, 0ABh    ;Z260       BC      Z262      '+'
        IL_JS TERM
        DB 085h, 0ABh    ;Z261       BC      Z263      '+'
        IL_JS TERM
        IL_AD                 ;AD
        IL_BR Z261                 ;BR      Z261
        DB 085h, 0ADh    ;Z263       BC      Z264      '-'
        IL_JS TERM
        IL_SU                 ;SU
        IL_BR Z261                 ;BR      Z261
        IL_RT       ;Z264       RT
TERM    DB 031h, 0B5h       ;JS      :RND
        DB 085h, 0AAh    ;Z266       BC      Z265      '*'
        IL_JS RND
        IL_MP                  ;MP
        IL_BR Z266                 ;BR      Z266
        DB 085h, 0AFh    ;Z265       BC      Z267      '/'
        IL_JS RND
        IL_DV                  ;DV
        IL_BR Z266                 ;BR      Z266
        IL_RT       ;Z267       RT
RND     DB 099h, 052h, 04Eh        ;BC      Z268      'RND('
        DB 044h, 0A8h               ;--
        DB 00Ah, 080h, 080h             ;LN      0x8080
        IL_FV                 ;FV
        DB 00Ah, 009h, 029h             ;LN      0x0929
        IL_MP                  ;MP
        DB 00Ah, 01Ah, 085h             ;LN      0x1A85
        IL_AD                 ;AD
        IL_SV                 ;SV
        DB 009h, 080h               ;LB      0x80
        IL_FV                 ;FV
        IL_SX 1                 ;SX 1
        IL_DS                 ;DS
        DB 032h, 02Ch               ;JS      Z269
        IL_BR Z270                 ;BR      Z270
        IL_BR USR
        IL_DS      ;Z270       DS
        IL_SX 4                 ;SX 4
        IL_SX 2                 ;SX 2
        IL_SX 3                 ;SX 3
        IL_SX 5                 ;SX 5
        IL_SX 3                 ;SX 3
        IL_DV                  ;DV
        IL_MP                  ;MP
        IL_SU                 ;SU
        IL_DS                 ;DS
        DB 009h, 006h               ;LB      6
        DB 00Ah, 000h, 000h             ;LN      0
        IL_CP                 ;CP
        IL_NE                 ;NE
        DB 02Fh                 ;RT
USR     DB 08Eh, 055h, 053h        ;BC      :INP      'USR('
        DB 052h, 0A8h               ;--
        IL_JS EXPR
        DB 032h, 031h               ;JS      Z245
        DB 032h, 031h               ;JS      Z245
        DB 080h, 0A9h               ;BC      * !495    ')'
        IL_US                 ;US
        DB 02Fh                 ;RT
INP     DB 091h, 049h, 04Eh        ;BC      :FLG      'INP('
        DB 050h, 0A8h               ;--
        DB 00Ah, 001h, 026h             ;LN      ILINPOUT
        DB 00Ah, 000h, 008h             ;LN      8
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <8
        DB 00Ah, 000h, 008h             ;LN      8         ADD 8 TO OP FOR INPUT
        IL_AD                 ;AD
        IL_BR Z271                 ;BR      Z271
FLG     DB 091h, 046h, 04Ch        ;BC      :PEEK     'FLG('
        DB 047h, 0A8h               ;--
        DB 00Ah, 009h, 0F8h             ;LN      ILFLG     FLG WAS NEVER DOCUMENTED
        DB 00Ah, 000h, 005h             ;LN      5
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <5
        DB 00Ah, 000h, 001h             ;LN      1
        IL_SU                 ;SU                SUB 1
        IL_BR Z271                 ;BR      Z271
PEEK_   DB 08Fh, 050h, 045h       ;BC      Z272      'PEEK('
        DB 045h, 04Bh, 0A8h             ;--
        DB 00Ah, 001h, 014h             ;LN      ILPEEK
        IL_JS EXPR
        DB 080h, 0A9h    ;Z271       BC      * !546    ')'
        IL_DS                 ;DS
        IL_US                 ;US
        DB 02Fh                 ;RT
        IL_BV Z273      ;Z272       BV      Z273
        IL_FV                 ;FV
        DB 02Fh                 ;RT
        IL_BN Z274      ;Z273       BN      Z274
        DB 02Fh                 ;RT
        DB 080h, 0A8h    ;Z274       BC      * !556    '('
        IL_JS EXPR
        DB 080h, 0A9h               ;BC      * !560    ')'
        DB 02Fh                 ;RT
        DB 083h, 0ACh    ;Z245       BC      Z275      ','
        IL_J EXPR
        IL_DS      ;Z275       DS
        DB 02Fh                 ;RT
        DB 084h, 0BDh    ;Z237       BC      Z276      '='
        DB 009h, 002h               ;LB      2
        DB 02Fh                 ;RT
        DB 08Eh, 0BCh    ;Z276       BC      Z277      '<'
        DB 084h, 0BDh               ;BC      Z278      '='
        DB 009h, 003h               ;LB      3
        DB 02Fh                 ;RT
        DB 084h, 0BEh    ;Z278       BC      Z279      '>'
        DB 009h, 005h               ;LB      5
        DB 02Fh                 ;RT
        DB 009h, 001h    ;Z279       LB      1
        DB 02Fh                 ;RT
        DB 080h, 0BEh    ;Z277       BC      * !589    '>'
        DB 084h, 0BDh               ;BC      Z280      '='
        DB 009h, 006h               ;LB      6
        DB 02Fh                 ;RT
        DB 084h, 0BCh    ;Z280       BC      Z281      '<'
        DB 009h, 005h               ;LB      5
        DB 02Fh                 ;RT
        DB 009h, 004h    ;Z281       LB      4
        DB 02Fh                 ;RT
        IL_JS EXPR
        IL_DS                 ;DS
        IL_DS                 ;DS
        IL_SX 6                 ;SX 6
        IL_SX 1                 ;SX 1
        IL_SX 7                 ;SX 7
        IL_SX 1                 ;SX 1
        DB 009h, 001h    ;Z248       LB      1
        IL_SX 2                 ;SX 2
        IL_SX 1                 ;SX 1
        IL_CP                 ;CP
        IL_BR $+1                 ;BR      * !616
        DB 009h, 006h               ;LB      6
        DB 00Ah, 000h, 000h             ;LN      0
        IL_CP                 ;CP
        IL_BR $+1                ;BR      * !623
ENDIL   DB 02Fh                ;RT                 End Of IL Program
        DB 0, 0