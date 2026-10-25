// % Sadness in your eyes v1.2 intro   * 2022-23 % by Chronos of Absence

// Thanks to Csabo and Siz
// Source code can be compiled with Kick Assembler, distributed as freeware
// Portions can be used in your project but please dont forget to credit me :D
// Ntsc/Pal, Frq/Sid support 

// "S" - to force SIDPLAY

// parameters / frame counter 

.label ptr = $d0
.label bordercolor = $33fb
.label bordercolor2 = $33fc

.label fcounter1 = $33fd
.label fcounter2 = $33fe
.label fcounter3 = $33ff
.label randomnumber = $62
.label palntsc = $2fff
.label scrollp1 = $20f0
.label scrollp2 = $20f1
.label scrollp3 = $20f2
.label scrollp4 = $20f3
.label titlecolorc1 = $20f4
.label titlecolorc2 = $20f5
.label sinpt1 = $33fa

.label sintabla = $5000

	* = $1000-2
	.word $1000  // "program header"


.if (* < $1000) { .fill $1000-*, $FF }
	* = $1000
	.import source "sadnessff40.asm"

.if (* < $2100) { .fill $2100-*, $FF }
	* = $2100

foprogi:

	sei
	sta $ff3e
	jsr $d88b
//---

// detect nstc^pal 1
	lda $ff80
	cmp #$05  // if ff80 is 05 -- ntsc is set
	bne pall
	lda #$d8
	sta palntsc
	jmp foprogi2
pall: lda #$98
	sta palntsc

//grafikus mod
// ff07 98 pal , d8 ntsc

//text mod
// ff07 08 pal , 48 nts

//---	

foprogi2:
	sta $ff3f
	lda #$04
	sta scrollp1
	lda #$04
	sta scrollp3
	lda #$03
	sta scrollp2
	lda #$02
	sta scrollp4
	lda #$80
	sta sinpt1
	jsr scrollreset
 	jsr scrollreset2
	lda #$71
	sta bordercolor
	lda $ff07
	and #$40
	ora #$98
	sta $ff07

	sta $ff3f
	lda #$00
	sta $fc80
	sta $fc81
//---       
	lda #$00
	sta $ff11
	lda #$1f
	sta $fe98
//---

// sidekick test override
// 	jmp foprogi3



//---

.label sid = $fe80
//----------------------
// Detect presence of a SID card. $ff: present

// Reset SID
	lda #0  // ez kimaradt
	ldy #24
sidreset1:
	sta sid,y
	dey
	bpl sidreset1

// Check if both PotX and PotY are $ff (SID is present and nothing is plugged in)	
	lda sid+25
	and sid+26
	cmp #$ff
	bne sidpotfailed
	jmp foprogi3
// Either PotX or PotY is not $ff - no SID or paddle is not fully left - try alternative detection
// Reset SID (again)
sidpotfailed:
	ldy #24
	lda #0
sidreset2:
	sta sid,y
	dey
	bpl sidreset2
// Read oscillator 3 - should be always 0
	ldx #0
readsid:
	lda sid+27
	bne nosid
	dex
	bne readsid
//	lda #$31
//	sta $ff19    ;ezmiez
//	lda #$ff
//	db $2c
	jmp foprogi3
nosid:
  	lda #$2c
	sta musicplayer+3  // sid disable
	lda #$00
	sta $fe98
  	lda #$20
	sta musicplayer+6  // frq enable
	jmp foprogi4
//---
foprogi3:
        lda #$20
	sta musicplayer+3  // sid enable
	lda #$00
	sta $fe98
  	lda #$2c
	sta musicplayer+6  // frq disable
foprogi4: sta $ff3f

// reset frame counter
	lda #$00
	sta fcounter1
	sta fcounter2
	sta fcounter3
	sta titlecolorc1
	sta titlecolorc2

//

	jsr $14d7  // music init


	lda #$71
nyuggerbela: sta $0800,x
	sta $0900,x
	sta $0a00,x
	sta $0aff,x
	inx
	cpx #$ff
	bne nyuggerbela


	jsr titlekiir

	lda #<irq0
	sta $fffe
	lda #>irq0
	sta $ffff  // set irq

	cli
	jmp *  // *** ez a legegyszerubb, hogy vegtelen ciklust csinalj :-)



//musicplayer, tlc frq or sid

musicplayer:
	jsr $1003
	jsr sidplay
	jsr tlcfrq
	rts
sidplay:
	ldx #$1f  // sid player
sidcikl: lda $ff40,x
	sta $fe80,x
	sta $fd40,x
	dex
	bpl sidcikl
	rts

//screentop     
//
//	db " DIZZY++   (C) BY ULYSSES777 IN 2020    "
//	db "----------------------------------------"
//	db " DO YOU NEED UNLIMITED LIVES? (Y/N) ( ) " 	

billnyom:
	lda #$7f  // set latch 7f
	sta $fd30
	sta $ff08
	lda $ff08
	and #$10  // space pressed
	beq menu
	rts

// trainer menu


menu: sei
	sta $ff3e
	lda #$0b
	sta $ff06  // screen off
	jsr $d88b
	jsr $dd27
	sta $ff3f
	lda #$00
	sta $ff11  // nemitunk
	ldx #$00
nema: sta $ff40,x
	sta $fe80,x
	inx
	cpx #$20
	bne nema
	lda #$c4
	sta $ff12
	lda #$d0
	sta $ff13
	lda #$b3
	sta $fffe
	lda #$fc
	sta $ffff  // set irq
	lda #$00
	sta $ff19
	sta $ff15
//	ldx #$00
//sctop	lda screentop,x
//	adc #$80
//	sta $0c00,x     ; sima szoveg
//	inx
//	cpx #$78
//	bne sctop
//	ldx #$00
//szin1	lda #$45
//	sta $0801,x
//	inx     
//	cpx #$77
//	bne szin1

	jmp $5100


	// cmap enabled (converted)

szoveg1:
	.byte $20,$20,$02,$0F,$02,$02,$19,$20,$02,$05,$01,$12,$09,$0E,$07,$20,$2B,$37,$04,$07,$0D,$06,$20,$31,$30,$31,$25,$20,$28,$0E,$14,$13,$03,$2F,$10,$01,$0C,$29,$20,$20,0

scrolltext1:

	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$04,$05,$05,$10,$20,$04,$05,$05,$10,$20,$12,$05,$13,$10,$05,$03,$14,$2E,$2E,$20,$0C,$05,$14,$08,$01,$12,$07,$19,$2C,$20,$14,$03,$06,$13,$20,$0D,$01,$05,$13,$14,$12,$0F,$2C,$20,$13,$19,$13,$14,$05,$0D,$20,$33,$31,$2C,$20,$05,$18,$03,$05,$05,$04,$2C,$20,$12,$05,$13,$0F,$15,$12,$03,$05,$2C,$20,$07,$0F,$14,$15,$2C,$20,$14,$05,$0B,$2C,$20,$06,$09,$12,$05,$2C,$20,$0C,$0F,$04,$2C,$20,$08,$0F,$0B,$15,$14,$0F,$20,$06,$0F,$12,$03,$05,$2C,$20,$14,$08,$05,$20,$04,$12,$05,$01,$0D,$13,$2C,$20,$0B,$32,$2C,$20,$02,$01,$15,$0B,$0E,$05,$03,$08,$14,$2C,$20,$0D,$05,$14,$08,$01,$02,$0F,$0C,$09,$18,$2C,$20,$15,$0C,$14,$04,$2C,$20
	.byte $13,$09,$0E,$07,$15,$0C,$01,$12,$20,$03,$12,$05,$17,$2C,$20,$07,$05,$0E,$05,$13,$09,$13,$20,$10,$12,$0F,$0A,$05,$03,$14,$2C,$20,$0D,$05,$07,$01,$13,$14,$19,$0C,$05,$20,$2E,$2E,$2E,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$40,$40,$40,$40,$40,0

scrolltext2:

	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$14,$08,$05,$20,$14,$17,$0F,$20,$0D,$0F,$13,$14,$20,$10,$0F,$17,$05,$12,$06,$15,$0C,$20,$17,$01,$12,$12,$09,$0F,$12,$13,$20,$01,$12,$05,$20,$10,$01,$14,$09,$05,$0E,$03,$05,$20,$01,$0E,$04,$20,$14,$09,$0D,$05,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$01,$02,$13,$05,$0E,$03,$05,$20,$10,$12,$0F,$15,$04,$0C,$19,$20,$10,$12,$05,$13,$05,$0E,$14,$13,$20,$14,$0F,$04,$01,$19,$20,$2E,$2E,$2E,$20,$02,$0F,$02,$02,$19,$20,$02,$05,$01,$12,$09,$0E,$07,$20,$2B,$37,$04,$07,$0D,$06,$20,$31,$30,$31,$25,$20,$28,$0E,$14,$13,$03,$2F,$10,$01,$0C,$29,$20,$2D,$20,$28,$03,$29,$20,$31,$39,$38,$37,$20,$14,$08,$05,$20,$05,$04,$07,$05,$20,$20
	.byte $20,$0F,$12,$09,$07,$09,$0E,$01,$0C,$0C,$19,$20,$03,$0F,$0E,$16,$05,$12,$14,$05,$04,$20,$02,$19,$20,$03,$05,$05,$0B,$01,$19,$20,$01,$0E,$04,$20,$10,$0C,$01,$13,$0D,$01,$20,$09,$0E,$20,$0A,$15,$13,$14,$20,$14,$17,$0F,$20,$04,$01,$19,$13,$20,$09,$0E,$20,$31,$39,$39,$30,$2C,$20,$02,$15,$14,$20,$09,$14,$20,$17,$01,$13,$20,$15,$0E,$10,$0C,$01,$19,$01,$02,$0C,$05,$20,$04,$15,$05,$20,$14,$0F,$20,$13,$05,$16,$05,$12,$01,$0C,$20,$03,$12,$09,$14,$09,$03,$01,$0C,$20,$07,$01,$0D,$05,$20,$02,$12,$05,$01,$0B,$09,$0E,$07,$20,$02,$15,$07,$13,$2E,$20,$13,$0F,$20,$17,$05,$20,$04,$05,$03,$09,$04,$05,$04,$20,$14,$0F,$20,$06,$09,$18,$20,$09,$14,$20,$15,$13,$09,$0E,$07,$20,$08,$0F,$0B,$15,$14,$0F,$20,$06,$0F,$12,$03,$05,$27,$13,$20,$16,$05,$12,$13,$09,$0F,$0E,$20,$17,$09,$14,$08,$20,$0B,$09,$0E,$04,$20,$10,$05,$12,$0D,$09,$13,$13,$09,$0F,$0E,$2E,$20
	.byte $20,$03,$12,$05,$04,$09,$14,$13,$2E,$2E,$20,$0B,$09,$03,$08,$19,$20,$12,$05,$0D,$01,$13,$14,$05,$12,$05,$04,$20,$14,$08,$05,$20,$0F,$12,$09,$07,$09,$0E,$01,$0C,$20,$14,$09,$14,$0C,$05,$20,$13,$03,$12,$05,$05,$0E,$2C,$20,$03,$13,$01,$02,$0F,$20,$01,$0E,$04,$20,$13,$09,$1A,$20,$06,$09,$18,$05,$04,$20,$14,$0F,$0E,$13,$20,$0F,$06,$20,$02,$15,$07,$13,$2C,$20,$01,$0E,$04,$20,$06,$09,$0E,$01,$0C,$0C,$19,$20,$01,$0C,$0C,$20,$10,$15,$14,$20,$14,$0F,$07,$05,$14,$08,$05,$12,$2C,$20,$14,$12,$01,$09,$0E,$05,$04,$2C,$20,$04,$0F,$03,$13,$20,$02,$0F,$12,$12,$0F,$17,$05,$04,$20,$02,$19,$20,$03,$08,$12,$0F,$0E,$0F,$13,$2E,$20,$20,$17,$05,$20,$08,$0F,$10,$05,$20,$14,$08,$09,$13,$20,$09,$13,$20,$14,$08,$05,$20,$06,$09,$0E,$01,$0C,$20,$06,$0F,$12,$0D,$20,$0F,$06,$20,$14,$08,$09,$13,$20,$07,$12,$05,$01,$14,$20
	.byte $03,$0C,$01,$13,$13,$09,$03,$2E,$20,$03,$08,$05,$03,$0B,$20,$0F,$15,$14,$20,$14,$08,$05,$20,$0D,$01,$10,$20,$14,$08,$09,$13,$20,$07,$01,$0D,$05,$20,$09,$13,$20,$08,$15,$07,$05,$21,$20,$20,$20,$13,$09,$04,$05,$20,$0E,$0F,$14,$05,$2E,$2E,$20,$0D,$19,$20,$10,$12,$0F,$07,$12,$01,$0D,$13,$20,$17,$09,$0C,$0C,$20,$14,$12,$19,$20,$14,$0F,$20,$01,$15,$14,$0F,$04,$05,$14,$05,$03,$14,$20,$13,$09,$04,$20,$03,$01,$12,$04,$2C,$20,$02,$15,$14,$20,$09,$06,$20,$19,$0F,$15,$20,$07,$05,$14,$20,$13,$09,$0C,$05,$0E,$03,$05,$2C,$20,$01,$13,$20,$17,$09,$14,$08,$20,$13,$09,$04,$05,$0B,$09,$03,$0B,$20,$32,$36,$34,$2C,$20,$19,$0F,$15,$20,$03,$01,$0E,$20,$06,$0F,$12,$03,$05,$20,$09,$14,$20,$02,$19,$20,$10,$12,$05,$13,$13,$09,$0E,$07,$20,$13,$20,$0B,$05,$19,$2E,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $2D,$20,$2D,$20,$2D,$20,$13,$01,$04,$0E,$05,$13,$13,$20,$09,$0E,$20,$19,$0F,$15,$12,$20,$05,$19,$05,$13,$20,$09,$0E,$14,$12,$0F,$20,$31,$2E,$32,$20,$2D,$20,$03,$0F,$04,$05,$20,$01,$0E,$04,$20,$07,$06,$18,$20,$28,$05,$18,$03,$05,$10,$14,$20,$31,$18,$32,$20,$13,$05,$14,$20,$02,$0F,$12,$12,$0F,$17,$05,$04,$20,$06,$12,$0F,$0D,$20,$13,$0F,$0D,$05,$17,$08,$05,$12,$05,$20,$09,$20,$03,$01,$0E,$27,$14,$20,$12,$05,$0D,$05,$0D,$02,$05,$12,$2E,$29,$20,$02,$19,$20,$03,$08,$12,$0F,$0E,$0F,$13,$20,$0F,$06,$20,$01,$02,$13,$05,$0E,$03,$05,$2C,$20,$07,$12,$05,$01,$14,$20,$0D,$15,$13,$09,$03,$20,$02,$19,$20,$1A,$01,$12,$04,$01,$18,$20,$28,$03,$36,$34,$29,$2C,$20,$06,$12,$11,$20,$10,$0C,$01,$19,$05,$12,$20,$02,$19,$20,$14,$0C,$03,$2E
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$32,$39,$2E,$30,$39,$2E,$32,$30,$32,$33,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$40,$40,$40,$40,$40,0

anim1:

//   3b6b, 3b6c
//   3b93,3b94 

// anim 1, fazis 1

//03 01 04
//10 0f 11
//
//05 06 07
//12 13 12

	lda fcounter1
	cmp #$10
	bne anm11
	lda #$01
	sta $3b6b
	lda #$02
	sta $3b6c
	lda #$0e
	sta $3b93
	lda #$05
	sta $3b94
	rts

//

// anim 1, fazis 2

anm11: lda fcounter1
	cmp #$20
	bne anm12
	lda #$01
	sta $3b6b
	lda #$03
	sta $3b6c
	lda #$0f
	sta $3b93
	lda #$10
	sta $3b94
	rts
//

// anim 1, fazis 3

anm12: lda fcounter1
	cmp #$30
	bne anm13
	lda #$01
	sta $3b6b
	lda #$04
	sta $3b6c
	lda #$0f
	sta $3b93
	lda #$11
	sta $3b94
//
anm13: rts

anim2:

// 3a12, 3a13
// 3a32, 3a33

// anim 2, fazis 1

//2.
//05 06 07 06 08 09
//12 13 12 13 12 13

//3.
//05 0a 0b 0c 05 0d
//14 15 14 15 16 17



	lda fcounter1
	cmp #$10
	bne anm21
	lda #$05
	sta $3a12
	lda #$06
	sta $3a13
	lda #$12
	sta $3a3a
	lda #$13
	sta $3a3b
	rts

//

// anim 2, fazis 2

anm21: lda fcounter1
	cmp #$20
	bne anm22
	lda #$07
	sta $3a12
	lda #$06
	sta $3a13
	lda #$12
	sta $3a3a
	lda #$13
	sta $3a3b
	rts
//

// anim 2, fazis 3

anm22: lda fcounter1
	cmp #$30
	bne anm23
	lda #$08
	sta $3a12
	lda #$09
	sta $3a13
	lda #$12
	sta $3a3a
	lda #$13
	sta $3a3b
//
anm23: rts


anim3:


// anim 3, fazis 1

//3.
//05 0a 0b 0c 05 0d
//14 15 14 15 16 17


//3a4d,3a4e
//3a75,3a76

	lda fcounter1
	cmp #$10
	bne anm31
	lda #$05
	sta $3a4d
	lda #$0a
	sta $3a4e
	lda #$14
	sta $3a75
	lda #$15
	sta $3a76
	rts

//

// anim 3, fazis 2

anm31: lda fcounter1
	cmp #$20
	bne anm32
	lda #$0b
	sta $3a4d
	lda #$0c
	sta $3a4e
	lda #$14
	sta $3a75
	lda #$15
	sta $3a76


	rts
//

// anim 3, fazis 3

anm32: lda fcounter1
	cmp #$30
	bne anm33

	lda #$05
	sta $3a4d
	lda #$0d
	sta $3a4e
	lda #$16
	sta $3a75
	lda #$17
	sta $3a76

//
anm33: rts


	cmap:




// title kiiro  

titlekiir:

        lda #$00
	ldx #$00
titlekiir2: lda szoveg1,x
	cmp #$3a
	bmi simabet  // ugras ha kisebb 3a - nal pont forditva muxik ahogy kene
	sta $0ed0,x  // sima szoveg
	clc
	sbc #$3f
	sta $0ef8,x
	jmp tov
simabet:
	sta $0ed0,x  // szamok es jelek
	clc
	adc #$40
	sta $0ef8,x
tov: inx
        cpx #$27
        bne titlekiir2
	rts

titlecolorchanger:

	inc titlecolorc1
	lda titlecolorc1
	cmp #$48
	beq switcher1
	rts

// color scheme changer

switcher1:
	ldx titlecolorc2
        ldy #$00
nemkesz: lda hi_titlecolor,x
	sta $0ad0,y
	lda lo_titlecolor,x
	sta $0af8,y
	iny
	cpy #$28
	bne nemkesz
	lda #$00
	sta titlecolorc1
	inx
	stx titlecolorc2
	cpx #$09
	bne svege
	lda #$00
	sta titlecolorc2
svege: rts

// logo color schemes

hi_titlecolor:

//	db $26,$27,$22,$21,$26,$27,$22,$25
	.byte $26,$23,$24,$23,$23,$22,$21,$25,$23,$24


lo_titlecolor:

//	db $43,$42,$41,$42,$44,$45,$42,$47
	.byte $43,$45,$47,$42,$41,$47,$46,$43,$44,$45


//26,23,24,23,23,22,21,25,23,24
//43,45,47,42,41,47,46,43,44,45	

// scroller 

scroller1:  // - felso, greetings scroll

 	lda scrollp1
  	sec
  	sbc scrollp2
  	and #$06
  	sta scrollp1
  	bcs v1ssza
 	jmp v1ssza2
v1ssza: rts
v1ssza2: ldx #$00

idebazz: lda $0c29,x
	sta $0c28,x
	lda $0c51,x
	sta $0c50,x
	inx
	cpx #$28
	bne idebazz
	lda scroller1  // ezt modositja 3480 3481
	cmp #$40
	beq scrollreset

//-------------

	cmp #$3a
	bmi simabetuk3  // ugras ha kisebb 3a - nal pont forditva muxik ahogy kene
	sta $0c4f  // sima szoveg
	clc
	sbc #$3f
	sta $0c77
	jmp tovabb3
simabetuk3:
	sta $0c4f  // szamok es jelek
	clc
	adc #$40
	sta $0c77
//-------------
//;sta $0e57
//;sta $0e7f
tovabb3:
	inc scroller1+$26
	beq nemtom2
	rts
nemtom2: inc scroller1+$27
	rts

scrollreset:
	lda #<scrolltext1
	sta scroller1+$26
	lda #>scrolltext1
        sta scroller1+$27
        rts



//       ; scroller2 

scroller2:  // - also, pofazkodos

 	lda scrollp3
  	sec
  	sbc scrollp4
  	and #$06
  	sta scrollp3
  	bcs v1ssza3
 	jmp v1ssza4
v1ssza3: rts
v1ssza4: ldx #$00

idebazz2: lda $0f71,x
	sta $0f70,x
	lda $0f99,x
	sta $0f98,x
	inx
	cpx #$28
	bne idebazz2
	lda scroller2  // ezt modositja 3480 3481
	cmp #$40
	beq scrollreset2
//-------------

	cmp #$3a
	bmi simabetuk4  // ugras ha kisebb 3a - nal pont forditva muxik ahogy kene
	sta $0fbf  // sima szoveg
	clc
	sbc #$3f
	sta $0f97
	jmp tovabb3
simabetuk4:
	sta $0f97  // szamok es jelek
	clc
	adc #$40
	sta $0fbf
//-------------
//;sta $0e57
//;sta $0e7f
tovabb4:
	lda scroller2
	cmp #$40
	beq scrollreset2
	inc scroller2+$26
	beq nemtom3
	rts
nemtom3: inc scroller2+$27
	rts
scrollreset2:

	lda #<scrolltext2
	sta scroller2+$26
	lda #>scrolltext2
        sta scroller2+$27
        rts

//ff07 sinus scroller

//lkirak	lda $3a00,x
//	sta $0cc8,x
//	lda $3b00,x
//	sta $0dc8,x
//	
//	

//	lda #$d8    
//	sta palntsc
//	jmp foprogi2
//pall	lda #$98
//	sta palntsc

//	sta bordercolor	
//	lda $ff07
//	and #$40
//	ora #$98
//	sta $ff07
//----	

sinsc1: lda sintabla
	pha
	and #$07
	eor #$07
	ora #$80
	sta sinpt1
	pla
	and #$F8
	lsr  // div / 8
	lsr
	lsr
	tax
	ldy #$00
sinkiir: lda $3a00,x
	sta $0cc8,y
	lda $3a28,x
	sta $0cf0,y
	lda $3a50,x
	sta $0d18,y
	lda $3a78,x
	sta $0d40,y
	lda $3aa0,x
	sta $0d68,y
	lda $3ac8,x
	sta $0d90,y
	lda $3af0,x
	sta $0db8,y
	lda $3b18,x
	sta $0de0,y
	lda $3b40,x
	sta $0e08,y
	lda $3b68,x
	sta $0e30,y
	lda $3b90,x
	sta $0e58,y
	lda $3bb8,x
	sta $0e80,y
	lda $3be0,x
	sta $0ea8,y
	inx
	iny
	cpy #$28
	bne sinkiir
	inc sinsc1 + 1
	inc sinsc1 + 1
	rts



// irq0   fenti scroller

irq0:
	pha
	txa
	pha
	tya
	pha
	inc $ff09
	lda #$00
	ldx #$30

//	ldx #$94
wait0: cpx $ff1e
	bcs wait0
//  

// ntsc^pal
//----------------
//	lda palntsc
	lda scrollp1
	sta $ff07
//----------------

   	lda bordercolor
	sta $ff15
	sta $ff19
	lda #$00
	sta $ff12
	lda #$40
	sta $ff13
//	lda #$1a
	lda #$22

	sta $ff0b

	lda #<irq1
	sta $fffe
	lda #>irq1
	sta $ffff
	pla
	tay
	pla
	tax
	pla
	rti

// irq1      logo

irq1:
	pha
	txa
	pha
	tya
	pha
	inc $ff09
	lda #$00
//	ldx #$98
	ldx #$30

wait1: cpx $ff1e
	bcs wait1


// ntsc^pal
//----------------
//	lda palntsc
	lda sinpt1
	sta $ff07
//----------------

	sta $ff3f
//;        	
 	lda #$71
	sta $ff15
//	lda #$23
	sta $ff19
	lda #$00
	sta $ff12
	lda #$48
	sta $ff13
// 	;lda #$cc
	lda #$92
	sta $ff0b
	lda #<irq2
	sta $fffe
	lda #>irq2
	sta $ffff
	pla
	tay
	pla
	tax
	pla
	rti

// irq2   - szovegkiiro

irq2:
	pha
	txa
	pha
	tya
	pha
	inc $ff09
	lda #$00
//	ldx #$98
	ldx #$10

wait2: cpx $ff1e
	bcs wait2


// ntsc^pal
//----------------
	lda palntsc
	sta $ff07
//----------------

	sta $ff3f
//;        	
 	lda #$71
	sta $ff15
//	lda #$33
	sta $ff19
	lda #$00
	sta $ff12
	lda #$40
	sta $ff13
//	;lda #$cc
//	lda #$b0
	lda #$a8
	sta $ff0b
	lda #<irq3
	sta $fffe
	lda #>irq3
	sta $ffff
	pla
	tay
	pla
	tax
	pla
	rti


// irq3, also scroller

irq3:
	pha
	txa
	pha
	tya
	pha
	inc $ff09
	lda #$00
	ldx #$80

wait3: cpx $ff1e
	bcs wait3

// ntsc^pal
//----------------
	lda scrollp3
//	lda palntsc
	sta $ff07
//----------------
//   	lda #$5d
//   	lda #$ee
   	lda bordercolor
	sta $ff15
	sta $ff19
	lda #$00
	sta $ff12
	lda #$40
	sta $ff13

	lda #$ff
	sta $ff0b

	lda #<irq0
	sta $fffe
	lda #>irq0
	sta $ffff
	jsr musicplayer
	jsr effektvez
	inc fcounter1
	lda fcounter1
	cmp #$ff
     	bne fcountervege
     	inc fcounter2
fcountervege: pla
	tay
	pla
	tax
	pla
	rti

//----- effekt ki/be kapcsolo

effektvez:
	jsr effektbe
	bit sinsc1
	bit scroller1
	bit scroller2
	bit titlecolorchanger
	bit billnyom
	jsr forcesid
//	jsr anim1
//	jsr anim2
//	jsr anim3
	rts

effektbe:
	lda fcounter2
	cmp #$00
	bne nemcsinal1
	lda fcounter1
	cmp #$88
	bne nemcsinal1
	lda #$ee
	sta bordercolor
nemcsinal1: lda fcounter2
	cmp #$00
	bne nemcsinal2
	lda fcounter1
	cmp #$aa
	bne nemcsinal2
	jsr szinkirako1
	lda #$20
	sta effektvez+3
	sta effektvez+6
	sta effektvez+9
nemcsinal2: lda fcounter2
	cmp #$01
	bne nemcsinal3
	lda fcounter1
	cmp #$7b
	bne nemcsinal3
	jsr szinkirako2
	lda #$20
	sta effektvez+12
	sta effektvez+15
nemcsinal3:
	rts

szinkirako1:  // scroll es szovegmegjelenito szinbeallitasa
	ldx #$00
lkirak0: lda #$05
	sta $0ca0,x
	sta $0cc8,x
	sta $0ea8,x
	lda #$16
	sta $0828,x
	lda #$32
	sta $0850,x
	lda #$16
	sta $0b70,x
	lda #$32
	sta $0b98,x
	inx
	cpx #$28
	bne lkirak0
        rts

szinkirako2:  // logo szinbeallitasa
	ldx #$00
lkirak1:
	lda #$01
	sta $08c8,x
	sta $08f0,x
	sta $0918,x
	sta $0918,x
	sta $0940,x
	lda #$31
	sta $0968,x
	sta $0990,x
	sta $09b8,x

	lda #$41
	sta $09e0,x
	sta $0a08,x
	sta $0a30,x
	sta $0a58,x

	inx
	cpx #$28
	bne lkirak1
        rts


screencopy:
	sta $ff3f
masol1: ldx #$00
	lda #$00
masol2: lda $4a01,x  // 4a01-tol masolunk elore
	sta $1001,x
	inx
	bne masol2
	inc $0f0a
	inc $0f0d
	lda $0f0a
 	cmp #$d2
 	bne masol1
vege:
        jmp $100d


forcesid:
	lda #$fd  // set latch fd
	sta $fd30
	sta $ff08
	lda $ff08
	and #$20  // "s" pressed
	beq fbe
	rts

fbe:
	lda #$00
	sta $ff11
	lda #$20
	sta musicplayer+3  // sid enable
	lda #$00
	sta $fe98
  	lda #$2c
	sta musicplayer+6  // frq disable
	lda #$2c
	sta effektvez+18
	rts


//eof
.if (* < $3400) { .fill $3400-*, $FF }
	* = $3400
	.import source "tlcfrq.asm"

.if (* < $3A00) { .fill $3A00-*, $FF }
	* = $3a00
	.import source "logomask.asm"


.if (* < $4000) { .fill $4000-*, $FF }
	* = $4000
	.import source "1x2_fixed.asm"

.if (* < $4800) { .fill $4800-*, $FF }
	* = $4800
	.import source "acelogoinverted.asm"

.if (* < $5000) { .fill $5000-*, $FF }
	* = $5000

// logo sinus effect
// values: 58-144 (dec) / or 3a-90 (hex)

//	include "ezjo.asm"
//	include "sin_ivory.asm"
	.import source "sin_depression.asm"
//	include "sin_complete.asm"

// obsolete

//	include "sintbl4.asm"
//	include "sintable.asm"
//	include "sinures.asm"

