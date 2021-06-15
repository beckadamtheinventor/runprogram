
public _run_program
extern __exitsp

; include 'include/ez80.inc'
include 'include/ti84pceg.inc'

_run_program:
	call ti._frameset0
	ld hl,(ix+6)
	ld a,(ix+9)
	ld de,$E30900
	ld (de),a
	inc de
	ld bc,8
	ldir
	ld hl,(ix+12)
	ld a,(ix+15)
	ld de,$E30910
	ld (de),a
	inc de
	ld c,8
	ldir
	ld sp,(__exitsp)
	pop	iy		; iy = flags
	pop	af		; a = original flash wait states
	pop hl		; hl = flash wait state control port,
	ld	(hl),a		; restore flash wait states
	call	00004F0h	; _usb_ResetTimer
; Enable OS home text buffer
	set	1,(iy + $0d)	; use text buffer
	res	3,(iy + $4a)	; use first shadow buffer
	res	5,(iy + $4c)	; use shadow buffer
; Copy setup code to cursorimage
	ld hl,cursorimagecode
	ld de,ti.cursorImage
	push de
	ld bc,cursorimagecode.len
	ldir
	ret

virtual at ti.cursorImage
	ld (.oldsp),sp
	ld hl,ti.userMem
	ld de,(ti.asm_prgm_size)
	call ti.DelMem
	ld hl,-(stub.len+9)
	add hl,sp
	ld (.smc),hl
	ld sp,hl
	ld hl,$E30900
	call ti.Mov9ToOP1
	ld de,0
.smc:=$-3
	ld hl,$E30910
	ld bc,9
	ldir
	ld hl,stub
	ld bc,stub.len
	ldir
	call ti.ChkFindSym
	jr nc,.next
	ld bc,stub.len+9
	or a,a
	sbc hl,hl
	add hl,sp
	add hl,bc
	ld sp,hl
	ret
.next:
	call ti.ChkInRam
	ex de,hl
	jr z,.in_ram
	ld de,9
	add	hl,de
	ld e,(hl)
	add	hl,de
	inc	hl
.in_ram:
	call ti.LoadDEInd_s
	ld (ti.asm_prgm_size),de
	push hl
	push de
	ex hl,de
	ld de,ti.userMem
	call ti.InsertMem
	pop bc
	pop hl
	inc hl   ;$EF
	inc hl   ;$7B
	xor a,a
	ld de,ti.userMem
	ldir
	ld hl,0
.oldsp:=$-3
	push hl
	ld hl,(.smc)
	push hl
	ld c,9
	add hl,bc
	push hl       ; return vector
	jp ti.userMem
stub:
	ld iy,ti.flags
	ld hl,ti.userMem
	ld de,(ti.asm_prgm_size)
	call ti.DelMem
	pop hl
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	jr nc,.next
	pop hl
	ld sp,hl
	ret
.next:
	call ti.ChkInRam
	ex de,hl
	jr z,.in_ram
	ld de,9
	add	hl,de
	ld e,(hl)
	add	hl,de
	inc	hl
.in_ram:
	call ti.LoadDEInd_s
	ld (ti.asm_prgm_size),de
	push hl
	push de
	ex hl,de
	ld de,ti.userMem
	call ti.InsertMem
	pop bc
	pop hl
	xor a,a
	inc hl   ;$EF
	inc hl   ;$7B
	ld de,ti.userMem
	ldir
.exit:
	pop hl
	ld sp,hl
	jp ti.userMem
.len:=$-stub
load cursorimagecode.data: $-$$ from $$
end virtual

cursorimagecode:
	db cursorimagecode.data
.len:=$-.
