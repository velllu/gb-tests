DEF VBlankStart EQU 144
DEF rLY EQU $FF44
DEF rNR52 EQU $FF26
DEF rLCDC EQU $FF40
DEF rOBP0 EQU $FF48
DEF rIE EQU $FFFF
DEF rIF EQU $FF0F
DEF rDMA EQU $FF46
DEF OAMRAM EQU $FE00

section "VBlank Interrupt", rom0[$40]
    jp VBlank

section "Header", rom0[$100]
    nop
    jp Main
    ds $150 - @, 0 ; Header space

; Loads an area of the ROM into the RAM, arguments are:
; - `HL`, starting point of RAM
; - `DE`, starting point of ROM
; - `BC`, end point of ROM
LoadArea:
    ld a, [de]
    ld [hl+], a
    inc de

    ; We check if DE == BC, so we first
    ; compare D to B
    ld a, b
    cp d
    jp nz, LoadArea

    ; and then E to C
    ld a, c
    cp e
    jp nz, LoadArea

    ret

; Clears an area of the RAM, arguments are:
; - `HL`, starting point of RAM
; - `BC`, end point of ROM
ClearArea:
    ld a, 0
    ld [hl+], a
    inc de

    ; We check if HL == BC, so we first
    ; compare D to B
    ld a, b
    cp h
    jp nz, ClearArea

    ; and then L to C
    ld a, c
    cp l
    jp nz, ClearArea

    ret

WaitVBlank:
    ld a, [rLY]
    cp VBlankStart
    
    jp nz, WaitVBlank
    ret

Main:
    di

    ; We turn off audio
    ld a, 0
    ld [rNR52], a

    ; We wait VBlank so we can turn off the LCD, it's
    ; harmful to the console to turn off the LCD while
    ; not in VBlank
    call WaitVBlank

    ; Turn off the LCD
    ld a, 0
    ld [rLCDC], a

    ; We clear the VRAM
    ld hl, $8000
    ld bc, $9FFF
    call ClearArea

    ; We clear the OAM
    ld hl, $FE00
    ld bc, $FE9F
    call ClearArea
 
    ; We load the Tiles
    ld hl, $8000
    ld de, Tiles
    ld bc, TilesEnd
    call LoadArea

    ; We load sprites in OAM
    ld hl, $FE00
    ld de, SpriteData
    ld bc, SpriteDataEnd
    call LoadArea

    ; Set the palette
    ld a, %11100100
    ld [rOBP0], a

    ; And now we turn back on the display
    ld a, %10000010
    ld [rLCDC], a

    ; Enable VBlank interrupt
    ld a, 1
    ld [rIE], a
    ld a, 0
    ld [rIF], a
    ei

Halting:
    halt
    jp Halting

VBlank:
    ; Move by 1
    ld b, 1

    ; Increase the X everytime
    ld hl, OAMRAM + 1
    ld a, [hl]
    add a, b
    ld [hl], a

    ld hl, OAMRAM + 5
    ld a, [hl]
    add a, b
    ld [hl], a

    ld hl, OAMRAM + 9
    ld a, [hl]
    add a, b
    ld [hl], a

    reti

SpriteData:
    ; Sprite 1
    db 160 / 2 ; Y
    db 0       ; X
    db 1       ; Tile number
    db 0       ; Attributes

    ; Sprite 2
    db 160 / 2 + 16 ; Y
    db 0            ; X
    db 1            ; Tile number
    db 0            ; Attributes

    ; Sprite 3, the one next to Sprite 2
    db 160 / 2 + 16 ; Y
    db 8            ; X
    db 1            ; Tile number
    db 0            ; Attributes
SpriteDataEnd:

section "Tile data", rom0
Tiles:
    rept 16
        db 0
    endr

    incbin "dist/sprite.2bpp"
TilesEnd:
