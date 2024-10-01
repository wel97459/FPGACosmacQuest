IL_SB   MACRO                   ;Save basic pointer
        DB 010h
    ENDM

IL_PC   MACRO                   ;Print literal string  
        DB 024h
    ENDM

IL_GL   MACRO                   ;Get input line
        DB 027H
    ENDM

IL_BR   MACRO  addr             ;Relative Branch
    IF (addr-$) > 0
        DB 60h + (addr-$+!)
    ELSE
        DB 60h - (1+$-addr)
    ENDIF
    ENDM

IL_BE   MACRO  addr             ;Branch if not end of line
        DB 0E0h + ((addr-$-1)&31)
    ENDM

        
STRT    IL_PC
        DB ':', 091h            ;':Q^'  Start Of IL Program
        IL_GL                   ;GL
        IL_SB                   ;SB
        IL_BE LO                ;BE      :LO
        IL_BR STMT              ;BR      :STRT
LO      DB 0C5h                 ;BN      :STMT
        DB 02Ah                 ;IL
        DB 056h                 ;BR      :STRT
XEC     DB 010h                 ;SB
        DB 011h                 ;RB
        DB 02Ch                 ;XQ
STMT    DB 08Bh, 04Ch, 045h             ;BC      :GOTO     'LET'
        DB 0D4h;
        DB 0A0h                 ;BV      * !18
        DB 080h, 0BDh               ;BC      * !20     '='
LET     DB 031h, 08Fh        ;JS      :EXPR
        DB 0E0h                 ;BE      * !23
        DB 013h                 ;SV
        DB 01Dh                 ;NX
GOTO    DB 094h, 047h, 0CFh       ;BC      :PRNT     'GO'
        DB 088h, 054h, 0CFh             ;BC      :GOSB     'TO'
        DB 031h, 08Fh               ;JS      :EXPR
        DB 0E0h                 ;BE      * !34
        DB 010h                 ;SB
        DB 011h                 ;RB
        DB 016h                 ;GO
GOSB    DB 080h, 053h, 055h       ;BC      * !39     'SUB'
        DB 0C2h                ;--
        DB 031h, 08Fh               ;JS      :EXPR
        DB 0E0h                 ;BE      * !44
        DB 014h                 ;GS
        DB 016h                 ;GO
PRNT    DB 090h, 050h, 0D2h       ;BC      :SKIP     'PR'
        DB 083h, 049h, 04Eh             ;BC      :P0       'INT'
        DB 0D4h                ;--
P0      DB 0E5h         ;BE      :P3
        DB 071h                 ;BR      Z233
P1      DB 088h, 0BBh         ;BC      Z234      ';'
P2      DB 0E1h         ;BE      :P3
        DB 01Dh                 ;NX
P3      DB 08Fh, 0A2h         ;BC      Z235      '"'
        DB 021h                 ;PQ
        DB 058h                 ;BR      :P1
SKIP_   DB 06Fh       ;BR      :IF
        DB 083h, 0ACh    ;Z234       BC      Z236      ','
        DB 022h                 ;PT
        DB 055h                 ;BR      :P2
        DB 083h, 0BAh    ;Z236       BC      Z233      ':'
        DB 024h, 093h               ;PC                'S^'
        DB 0E0h      ;Z233       BE      * !73
        DB 023h                 ;NL
        DB 01Dh                 ;NX
        DB 031h, 08Fh    ;Z235       JS      :EXPR
        DB 020h                 ;PN
        DB 048h                 ;BR      :P1
IF_     DB 091h, 049h, 0C6h         ;BC      :INPT     'IF'
        DB 031h, 08Fh               ;JS      :EXPR
        DB 032h, 037h               ;JS      Z237
        DB 031h, 08Fh               ;JS      :EXPR
        DB 084h, 054h, 048h             ;BC      :I1       'THEN'
        DB 045h, 0CEh               ;--
I1      DB 01Ch         ;CP
        DB 01Dh                 ;NX
        DB 038h, 00Dh               ;J       :STMT
INPT    DB 09Ah, 049h, 04Eh       ;BC      :RETN     'INPUT'
        DB 050h, 055h, 0D4h             ;--
        DB 0A0h      ;Z242       BV      * !104
        DB 010h                 ;SB
        DB 0E7h                 ;BE      Z238
        DB 024h, 03Fh, 020h  ;Z239       PC                '? Q^'
        DB 091h                ;--
        DB 027h                 ;GL
        DB 0E1h                 ;BE      Z238
        DB 059h                 ;BR      Z239
        DB 081h, 0ACh    ;Z238       BC      Z240      ','
        DB 031h, 08Fh    ;Z240       JS      :EXPR
        DB 013h                 ;SV
        DB 011h                 ;RB
        DB 082h, 0ACh               ;BC      Z241      ','
        DB 04Dh                 ;BR      Z242
        DB 0E0h      ;Z241       BE      * !123
        DB 01Dh                 ;NX
RETN_   DB 089h, 052h, 045h       ;BC      :END      'RETURN'
        DB 054h, 055h, 052h             ;--
        DB 0CEh                ;--
        DB 0E0h                 ;BE      * !132
        DB 015h                 ;RS
        DB 01Dh                 ;NX
END     DB 085h, 045h, 04Eh        ;BC      :LIST     'END'
        DB 0C4h                ;--
        DB 0E0h                 ;BE      * !139
        DB 02Dh                 ;WS
LIST_   DB 09Ah, 04Ch, 049h       ;BC      :RUN      'LIST'
        DB 053h, 0D4h               ;--
        DB 0E7h                 ;BE      Z243
        DB 00Ah, 000h, 001h             ;LN      #0001
        DB 00Ah, 07Fh, 0FFh             ;LN      #7FFF
        DB 065h                 ;BR      Z244
        DB 031h, 08Fh    ;Z243       JS      :EXPR
        DB 032h, 031h               ;JS      Z245
        DB 0E0h                 ;BE      * !158
        DB 024h, 000h, 000h  ;Z244       PC                '@^@^@^@^J^@^'
        DB 000h, 000h, 00Ah             ;--
        DB 080h                ;--
        DB 01Fh                 ;LS
        DB 01Dh                 ;NX
RUN_    DB 085h, 052h, 055h        ;BC      :CLER     'RUN'
        DB 0CEh                ;--
        DB 038h, 00Ah               ;J       :XEC
CLER    DB 086h, 043h, 04Ch       ;BC      :PLOT     'CLEAR'
        DB 045h, 041h, 0D2h             ;--
        DB 02Bh                 ;MT
PLOT    DB 09Ah, 050h, 04Ch       ;BC      Z246      'PLOT'
        DB 04Fh, 0D4h               ;--
        DB 031h, 08Fh               ;JS      :EXPR
        DB 095h, 0ACh               ;BC      Z247      ','
        DB 00Bh                 ;DS
        DB 00Bh                 ;DS
        DB 00Ah, 000h, 02Ah             ;LN      42
        DB 032h, 062h               ;JS      Z248      COMPARE >0 AND <42
        DB 00Ah, 000h, 040h             ;LN      64        MULTIPLY BY 64
        DB 01Ah                 ;MP
        DB 00Ah, 000h, 040h             ;LN      64
        DB 032h, 05Ah               ;JS      Z249      GET NEXT EXPR AND COMP >0 AND <64
        DB 018h                 ;AD                ADD TOGETHER (X*64+Y)
        DB 064h                 ;BR      Z250      SKIP JUMPS
        DB 039h, 002h    ;Z246       J       :POKE
        DB 038h, 0F4h    ;Z247       J       Z251
        DB 00Ah, 06Dh, 080h  ;Z250       LN      BUFF<<3         BUFF*8
        DB 018h                 ;AD                ADD (BUFF*8)+(X*64+Y)
        DB 00Bh                 ;DS
        DB 00Ah, 000h, 008h             ;LN      8
        DB 01Bh                 ;DV                ((BUFF*8)+(X*64+Y))/8
        DB 00Bh                 ;DS
        DB 004h                 ;SX 4
        DB 002h                 ;SX 2
        DB 005h                 ;SX 5
        DB 003h                 ;SX 3
        DB 005h                 ;SX 5
        DB 00Ah, 000h, 008h             ;LN      8
        DB 01Ah                 ;MP                 MULTIPLY BY 8
        DB 019h                 ;SU                 GET REMANDER
        DB 009h, 00Ah               ;LB      TVXY+2
        DB 002h                 ;SX 2
        DB 013h                 ;SV                 STORE NEW BIT POINTER
        DB 009h, 008h               ;LB      TVXY
        DB 002h                 ;SX 2
        DB 001h                 ;SX 1
        DB 013h                 ;SV                 STORE NEW CURSOR
        DB 08Fh, 0ACh               ;BC      Z252      ','
        DB 031h, 08Fh               ;JS      :EXPR
        DB 0E0h      ;Z251       BE      * !245
        DB 00Ah, 001h, 009h             ;LN      TYPEV
        DB 002h                 ;SX 2
        DB 001h                 ;SX 1
        DB 003h                 ;SX 3
        DB 001h                 ;SX 1
        DB 00Bh                 ;DS
        DB 02Eh                 ;US                CALL TYPEV AND OUTPUT BYTE
        DB 00Ch                 ;SP                POP RETURNED VALUE
        DB 01Dh                 ;NX                NEXT STATEMENT
        DB 0E0h      ;Z252       BE      * !257
        DB 01Dh                 ;NX
POKE    DB 08Ah, 050h, 04Fh       ;BC      :OUT      'POKE'
        DB 04Bh, 0C5h               ;--
        DB 00Ah, 001h, 018h             ;LN      ILPOKE
        DB 031h, 08Fh               ;JS      :EXPR
        DB 06Ch                 ;BR      Z253
OUT_    DB 091h, 04Fh, 055h        ;BC      :SAVE     'OUT'
        DB 0D4h                ;--
        DB 00Ah, 001h, 026h             ;LN      ILINPOUT
        DB 00Ah, 000h, 008h             ;LN      8
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <8
        DB 032h, 031h    ;Z253       JS      Z245      CHECK FOR ,AND GET EXPR
        DB 0E0h                 ;BE      * !284
        DB 02Eh                 ;US                CALL ILINPOUT OR ILPOKE
        DB 00Ch                 ;SP                POP RETURNED VALUE
        DB 01Dh                 ;NX                NEXT STATEMENT
SAVE    DB 09Eh, 053h, 041h       ;BC      Z254      'SAVE'
        DB 056h, 0C5h               ;--
        DB 0E0h                 ;BE      * !293
        DB 024h, 054h, 055h             ;PC                'TURN ON RECORD'
        DB 052h, 04Eh, 020h             ;--
        DB 04Fh, 04Eh, 020h             ;--
        DB 052h, 045h, 043h             ;--
        DB 04Fh, 052h, 0C4h             ;--
        DB 023h                 ;NL
        DB 024h, 048h, 049h             ;PC                'HIT KEY'
        DB 054h, 020h, 04Bh             ;--
        DB 045h, 0D9h               ;--
        DB 062h                 ;BR      Z255
        DB 039h, 05Ch    ;Z254       J       :LOAD
        DB 00Ah, 001h, 006h  ;Z255       LN      KEYV
        DB 00Bh                 ;DS
        DB 00Bh                 ;DS
        DB 02Eh                 ;US                CALL KEY INPUT
        DB 00Ch                 ;SP                POP RETURNED VALUE
        DB 023h                 ;NL                NEW LINE
        DB 00Ah, 009h, 0FDh             ;LN      ILSAVE
        DB 009h, 024h               ;LB      MEND
        DB 012h                 ;FV
        DB 009h, 020h               ;LB      BASIC
        DB 012h                 ;FV
        DB 019h                 ;SU                END PROGRAM-BEGIN PROGRAM
        DB 00Ah, 001h, 000h             ;LN      256
        DB 018h                 ;AD                ADD 256 ????
        DB 009h, 020h               ;LB      BASIC
        DB 012h                 ;FV
        DB 02Eh                 ;US                CALL ILSAVE
        DB 00Ch                 ;SP                POP RETURNED VALUE
        DB 01Dh                 ;NX                NEXT STATEMENT
LOAD    DB 086h, 04Ch, 04Fh             ;BC      Z256      'LOAD'
        DB 041h, 0C4h               ;--
        DB 0E0h                 ;BE      * !354
        DB 062h                 ;BR      Z257
        DB 039h, 085h    ;Z256       J       Z258
        DB 009h, 024h    ;Z257       LB      MEND
        DB 00Ah, 009h, 0FAh             ;LN      ILLOAD
        DB 00Ah, 000h, 001h             ;LN      1
        DB 009h, 020h               ;LB      BASIC
        DB 012h                 ;FV
        DB 02Eh                 ;US                CALL ILLOAD
        DB 066h                 ;BR      Z259      ILLOAD SKIPS THIS IF NO ERROR
        DB 00Ah, 000h, 018h             ;LN      0x18      SPARE STACK SIZE-1,DOES NOT GET IT?
        DB 018h                 ;AD                ADD TO RETURN VALUE
        DB 013h                 ;SV                SAVE MEM END
        DB 02Dh                 ;WS                WARM START
        DB 023h      ;Z259       NL
        DB 024h, 054h, 041h             ;PC                'TAPE ERROR'
        DB 050h, 045h, 020h             ;--
        DB 045h, 052h, 052h             ;--
        DB 04Fh, 0D2h               ;--
        DB 02Bh                 ;MT
        DB 084h, 052h, 045h  ;Z258       BC      :DFLT     'REM'
        DB 0CDh                ;--
        DB 01Dh                 ;NX
DFLT    DB 0A0h                 ;BV      * !395
        DB 080h, 0BDh               ;BC      * !397    '='
        DB 038h, 014h               ;J       :LET
EXPR    DB 085h, 0ADh       ;BC      Z260      '-'
        DB 031h, 0A6h               ;JS      :TERM
        DB 017h                 ;NE
        DB 064h                 ;BR      Z261
        DB 081h, 0ABh    ;Z260       BC      Z262      '+'
        DB 031h, 0A6h    ;Z262       JS      :TERM
        DB 085h, 0ABh    ;Z261       BC      Z263      '+'
        DB 031h, 0A6h               ;JS      :TERM
        DB 018h                 ;AD
        DB 05Ah                 ;BR      Z261
        DB 085h, 0ADh    ;Z263       BC      Z264      '-'
        DB 031h, 0A6h               ;JS      :TERM
        DB 019h                 ;SU
        DB 054h                 ;BR      Z261
        DB 02Fh      ;Z264       RT
TERM    DB 031h, 0B5h       ;JS      :RND
        DB 085h, 0AAh    ;Z266       BC      Z265      '*'
        DB 031h, 0B5h               ;JS      :RND
        DB 01Ah                 ;MP
        DB 05Ah                 ;BR      Z266
        DB 085h, 0AFh    ;Z265       BC      Z267      '/'
        DB 031h, 0B5h               ;JS      :RND
        DB 01Bh                 ;DV
        DB 054h                 ;BR      Z266
        DB 02Fh      ;Z267       RT
RND     DB 099h, 052h, 04Eh        ;BC      Z268      'RND('
        DB 044h, 0A8h               ;--
        DB 00Ah, 080h, 080h             ;LN      0x8080
        DB 012h                 ;FV
        DB 00Ah, 009h, 029h             ;LN      0x0929
        DB 01Ah                 ;MP
        DB 00Ah, 01Ah, 085h             ;LN      0x1A85
        DB 018h                 ;AD
        DB 013h                 ;SV
        DB 009h, 080h               ;LB      0x80
        DB 012h                 ;FV
        DB 001h                 ;SX 1
        DB 00Bh                 ;DS
        DB 032h, 02Ch               ;JS      Z269
        DB 061h                 ;BR      Z270
        DB 072h      ;Z268       BR      :USR
        DB 00Bh      ;Z270       DS
        DB 004h                 ;SX 4
        DB 002h                 ;SX 2
        DB 003h                 ;SX 3
        DB 005h                 ;SX 5
        DB 003h                 ;SX 3
        DB 01Bh                 ;DV
        DB 01Ah                 ;MP
        DB 019h                 ;SU
        DB 00Bh                 ;DS
        DB 009h, 006h               ;LB      6
        DB 00Ah, 000h, 000h             ;LN      0
        DB 01Ch                 ;CP
        DB 017h                 ;NE
        DB 02Fh                 ;RT
USR     DB 08Eh, 055h, 053h        ;BC      :INP      'USR('
        DB 052h, 0A8h               ;--
        DB 031h, 08Fh               ;JS      :EXPR
        DB 032h, 031h               ;JS      Z245
        DB 032h, 031h               ;JS      Z245
        DB 080h, 0A9h               ;BC      * !495    ')'
        DB 02Eh                 ;US
        DB 02Fh                 ;RT
INP     DB 091h, 049h, 04Eh        ;BC      :FLG      'INP('
        DB 050h, 0A8h               ;--
        DB 00Ah, 001h, 026h             ;LN      ILINPOUT
        DB 00Ah, 000h, 008h             ;LN      8
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <8
        DB 00Ah, 000h, 008h             ;LN      8         ADD 8 TO OP FOR INPUT
        DB 018h                 ;AD
        DB 07Dh                 ;BR      Z271
FLG     DB 091h, 046h, 04Ch        ;BC      :PEEK     'FLG('
        DB 047h, 0A8h               ;--
        DB 00Ah, 009h, 0F8h             ;LN      ILFLG     FLG WAS NEVER DOCUMENTED
        DB 00Ah, 000h, 005h             ;LN      5
        DB 032h, 05Ah               ;JS      Z249      GET EXPR AND COMP >0 AND <5
        DB 00Ah, 000h, 001h             ;LN      1
        DB 019h                 ;SU                SUB 1
        DB 06Bh                 ;BR      Z271
PEEK_   DB 08Fh, 050h, 045h       ;BC      Z272      'PEEK('
        DB 045h, 04Bh, 0A8h             ;--
        DB 00Ah, 001h, 014h             ;LN      ILPEEK
        DB 031h, 08Fh               ;JS      :EXPR
        DB 080h, 0A9h    ;Z271       BC      * !546    ')'
        DB 00Bh                 ;DS
        DB 02Eh                 ;US
        DB 02Fh                 ;RT
        DB 0A2h      ;Z272       BV      Z273
        DB 012h                 ;FV
        DB 02Fh                 ;RT
        DB 0C1h      ;Z273       BN      Z274
        DB 02Fh                 ;RT
        DB 080h, 0A8h    ;Z274       BC      * !556    '('
        DB 031h, 08Fh    ;Z269       JS      :EXPR
        DB 080h, 0A9h               ;BC      * !560    ')'
        DB 02Fh                 ;RT
        DB 083h, 0ACh    ;Z245       BC      Z275      ','
        DB 039h, 08Fh               ;J       :EXPR
        DB 00Bh      ;Z275       DS
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
        DB 031h, 08Fh    ;Z249       JS      :EXPR
        DB 00Bh                 ;DS
        DB 00Bh                 ;DS
        DB 006h                 ;SX 6
        DB 001h                 ;SX 1
        DB 007h                 ;SX 7
        DB 001h                 ;SX 1
        DB 009h, 001h    ;Z248       LB      1
        DB 002h                 ;SX 2
        DB 001h                 ;SX 1
        DB 01Ch                 ;CP
        DB 060h                 ;BR      * !616
        DB 009h, 006h               ;LB      6
        DB 00Ah, 000h, 000h             ;LN      0
        DB 01Ch                 ;CP
        DB 060h                ;BR      * !623
ENDIL   DB 02Fh                ;RT                 End Of IL Program
        DB 0, 0