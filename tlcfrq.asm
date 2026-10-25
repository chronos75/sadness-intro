// tlc v1.6 frq player $3400-37ff
// $d400 -> ff40 -- plays through ff40 


tlcfrq:

// tlc v1.6 frq player disassembled   , 400 bytes
// $d400 -> ff40 -- plays through ff40 

// Zeropage vectors
// Zeropage variables
.label zp40 = $40  // (7)
.label zp41 = $41  // (1)
.label zp48 = $48  // (8)
//---------
.label V_0200 = $0200
.label V_0201 = $0201
.label V_0202 = $0202
.label V_0203 = $0203
.label V_0204 = $0204
.label V_020A = $020A
.label V_0211 = $0211
//---------
.label V_EAEA = $EAEA
//---------
//; *** Start ***
X_7000:
	ldx #$0E
B_7005: jsr S_70A5
	jsr S_70B2
	jsr S_7139
	jsr S_7187
	jsr S_7194
	txa
	sec
	sbc #$07
	tax
	bpl B_7005
	jsr S_71A1
	jsr S_71CF
	ldx V_0200
	lda $FF44,x
	beq B_702D
	and #$80
	beq B_7034
B_702D: ldx #$FE
	ldy #$03
	jmp L_703E
//;
B_7034: lda $FF40,x
	ldy $FF41,x
	tax
	jsr S_7200
L_703E: stx $FF0E  // Sound1 Freq Lo
	tya
	and #$03
	sta V_704C + 1
	lda $FF12  // Sound1 Freq Hi / Gfx
	and #$FC
V_704C: ora #$02
	sta $FF12  // Sound1 Freq Hi / Gfx
	ldx V_0201
	lda $FF44,x
	bne B_7060
	ldx #$FE
	ldy #$03
	jmp L_706A
//;
B_7060: lda $FF40,x
	ldy $FF41,x
	tax
	jsr S_7200
L_706A: stx $FF0F  // Sound2 Freq Lo
	sty $FF10  // Sound2 Freq Hi
	ldx V_0201
	lda $FF44,x
	and #$80
	bne B_7085
	lda V_0202
	ora #$30
	sta $FF11  // Volume
	jmp L_708D
//;
B_7085: lda V_0202
	ora #$50  // "P"
	sta $FF11  // Volume
V_708D:
L_708D: ldx #$00
	lda V_7350,x
	sta V_0200
	lda V_7354,x
	sta V_0201
	dex
	bpl B_70A1
	ldx #$03
	nop
B_70A1: stx V_708D + 1
	rts
//$70A5  --------
S_70A5: lda V_0203,x
	cmp #$FF
	bne B_70B1
	lda #$01
	sta V_0204,x
B_70B1: rts
//$70B2  --------
S_70B2: lda $FF44,x
	and #$01
	bne B_70BA
	rts
//$70BA  --------
B_70BA: lda V_0204,x
	cmp #$00
	bne B_70E7
	lda $FF45,x
	lsr  // div / 16
	lsr
	lsr
	lsr
	tay
	lda V_0202,x
	clc
	adc V_7260,y
	sta V_0202,x
	lda V_0203,x
	adc V_7270,y
	sta V_0203,x
	bcc B_70E6
	lda #$FF
	sta V_0202,x
	sta V_0203,x
B_70E6: rts
//$70E7  --------
B_70E7: jsr S_70F8
	lda $FF46,x
	and #$F0
	cmp V_0203,x
	bcc B_70F7
	sta V_0203,x
B_70F7: rts
//$70F8  --------
S_70F8: ldy #$05
	lda V_0203,x
B_70FD: cmp V_7280,y
	bcc B_7107
	dey
	cpy #$00
	bne B_70FD
B_7107: lda V_7288,y
	bit V_EAEA
	pha
	lda $FF45,x
	and #$0F
	sta V_7118 + 1
	pla
	clc
V_7118: adc #$01
	tay
	lda V_0202,x
	sec
	sbc V_7290,y
	sta V_0202,x
	lda V_0203,x
	sbc V_72A0,y
	sta V_0203,x
	bcs B_7138
	lda #$00
	sta V_0202,x
	sta V_0203,x
B_7138: rts
//$7139  --------
S_7139: lda $FF44,x
	and #$01
	beq B_7141
	rts
//$7141  --------
B_7141: lda #$00
	sta V_0204,x
	ldy #$05
	lda V_0203,x
B_714B: cmp V_7280,y
	bcc B_7155
	dey
	cpy #$00
	bne B_714B
B_7155: lda V_7288,y
	bit V_EAEA
	pha
	lda $FF46,x
	and #$0F
	sta V_7166 + 1
	pla
	clc
V_7166: adc #$0E
	tay
	lda V_0202,x
	sec
	sbc V_7290,y
	sta V_0202,x
	lda V_0203,x
	sbc V_72A0,y
	sta V_0203,x
	bcs B_7186
	lda #$00
	sta V_0202,x
	sta V_0203,x
B_7186: rts
//$7187  --------
S_7187: lda V_0203,x
	cmp #$04
	bcs B_7193
	lda #$00
	sta $FF44,x
B_7193: rts
//$7194  --------
S_7194: lda $FF44,x
	and #$06
	beq B_71A0
	lda #$00
	sta $FF44,x
B_71A0: rts
//$71A1  --------
S_71A1: lda #$00
	sta zp48
	lda V_0203
	clc
	adc V_020A
	bcc B_71B0
	inc zp48
B_71B0: clc
	adc V_0211
	bcc B_71B8
	inc zp48
B_71B8: lsr zp48
	ror
	lsr zp48
	ror
	lsr zp48
	ror
	lsr zp48
	ror
	lsr zp48
	ror
	tax
	lda V_7358,x
	sta V_0202
	rts
//$71CF  --------
S_71CF: ldx V_0200
	lda $FF44,x
	beq B_71DF
	ldx V_0201
	lda $FF44,x
	bne B_71EB
B_71DF: lda V_7370,x
	sta V_0200
	lda V_7371,x
	sta V_0201
B_71EB: ldx V_0200
	lda $FF44,x
	and #$80
	bne B_71F6
	rts
//$71F6  --------
B_71F6: ldy V_0201
	stx V_0201
	sty V_0200
	rts
//$7200  --------
S_7200: cpy #$00
	beq B_724E
	stx zp40
	sty zp41
	tya
	cmp #$10
	bcc B_721B
	ldx #$FE
	tya
	bmi B_7226
B_7212: inx
	asl zp40
	rol
	bpl B_7212
	tay
	bmi B_7226
B_721B: ldx #$06
B_721D: lsr
	ror zp40
	dex
	tay
	bne B_721D
	ldy zp40
B_7226: lda V_7300,y
	cpx #$00
	beq B_7233
	bpl B_7237
B_722F: lsr
	inx
	bmi B_722F
B_7233: ldy #$03
	bne B_724A
B_7237: sta zp40
	lda #$00
B_723B: asl zp40
	rol
	cmp #$02
	bcs B_7245
	dex
	bne B_723B
B_7245: eor #$FF
	tay
	lda zp40
B_724A: eor #$FF
	tax
	rts
//$724E  --------
B_724E: ldx #$FD
	ldy #$03
	rts
//$7253  --------
//$7253  --------
	.byte $00,$54,$4C,$43,$20,$31,$2E,$36,$20,$32,$30,$30,$35
V_7260: .byte $FF,$FF,$FF,$FF,$FF,$55,$FF,$33,$AA,$B1,$D8,$3E,$05,$AC,$03,$A1
V_7270: .byte $FF,$FF,$FF,$7F,$7F,$55,$3F,$33,$2A,$13,$09,$06,$05,$01,$01,$00
V_7280: .byte $5D,$36,$1A,$0E,$06,$00,$00,$00
V_7288: .byte $00,$20,$40,$60,$80,$A0,$00,$00
V_7290: .byte $80,$80,$80,$80,$80,$66,$66,$00,$24,$BA,$86,$96,$80,$9E,$FC,$9E
V_72A0: .byte $28,$28,$28,$28,$28,$20,$20,$1B,$17,$0E,$08,$05,$04,$01,$00,$00
	.byte $00,$00,$00,$00,$80,$80,$00,$80,$80,$CC,$55,$C9,$70,$D0,$7E,$4F
	.byte $27,$27,$27,$27,$13,$13,$0D,$13,$13,$07,$04,$02,$02,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$55,$55,$00,$55,$8E,$37,$48,$40,$28
	.byte $1C,$1C,$1C,$0E,$0E,$0E,$0E,$09,$09,$04,$02,$01,$01,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$17,$B4,$92,$71,$1F,$13
V_7300: .byte $0C,$0C,$06,$06,$04,$03,$03,$04,$04,$02,$01,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$AA,$AA,$AA,$00,$24,$92,$61,$4E,$1A,$10,$0A
.byte $08,$04,$04,$04,$04,$02,$02,$02,$02,$01,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$80,$33,$99,$50,$33,$29,$0E,$08,$05
.byte $06,$06,$03,$02,$03,$03,$02,$01,$01,$00,$00,$00,$00,$00,$00,$00
V_7350: .byte $00,$00,$00,$00
V_7354: .byte $0E,$0E,$07,$00
V_7358: .byte $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$05,$06
.byte $06,$06,$07,$07,$07,$08,$08,$08
V_7370: .byte $07
V_7371: .byte $0E,$00,$00,$00,$00,$00,$00,$0E,$00,$00,$00,$00,$00,$00,$07,$E6
	.byte $E5,$E3,$E1,$DF,$DE,$DC,$DA,$D9,$D7,$D6,$D4,$D3,$D1,$D0,$CE,$CD
	.byte $CB,$CA,$C9,$C7,$C6,$C5,$C3,$C2,$C1,$C0,$BE,$BD,$BC,$BB,$B9,$B8
	.byte $B7,$B6,$B5,$B4,$B3,$B2,$B1,$B0,$AF,$AD,$AC,$AB,$AA,$A9,$A9,$A8
	.byte $A7,$A6,$A5,$A4,$A3,$A2,$A1,$A0,$9F,$9F,$9E,$9D,$9C,$9B,$9A,$9A
	.byte $99,$98,$97,$96,$96,$95,$94,$93,$93,$92,$91,$91,$90,$8F,$8E,$8E
	.byte $8D,$8C,$8C,$8B,$8A,$8A,$89,$89,$88,$87,$87,$86,$85,$85,$84,$84
	.byte $83,$82,$82,$81,$81,$80,$80,$7F,$7F,$7E,$7D,$7D,$7C,$7C,$7B,$7B
	.byte $7A,$7A,$79,$79,$78,$78,$77,$77,$76,$76,$75,$75,$75,$74

// //// 
