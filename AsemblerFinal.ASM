; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application
AppEntry                ld hl, 5ACFh
                        ld (shovelPos), hl
                        call pintar
                        call bordes
                        call pala
                        call bomba

inicio                  call pintar
                        call bordes
                        call pala
                        call caida
                        jp inicio

; Pinta fondo;

pintar                  ld a, 00101101b
                        ld hl, 5800h
                        ld b, 255
screenFill              ld (hl), a
                        inc hl
                        djnz screenFill

                        ld hl, 5900h
                        ld b, 255
screenFill2             ld (hl), a
                        inc hl
                        djnz screenFill2

                        ld hl, 5A00h
                        ld b, 255
screenFill3             ld (hl), a
                        inc hl
                        djnz screenFill3
                        ret

; Pinta bordes ;

bordes                  ld a, 00001001b

                        ld hl, 5800h
                        ld b, 32
screenTop               ld (hl), a
                        inc hl
                        djnz screenTop

                        ld hl, 5820h
                        ld b, 23
screenLeft              ld (hl), a
                        add hl, 32
                        djnz screenLeft

                        ld hl, 583Fh
                        ld b, 23
screenRight             ld (hl), a
                        add hl, 32
                        djnz screenRight

                        ld hl, 5AE0h
                        ld b, 32
screenBot               ld (hl), a
                        inc hl
                        djnz screenBot
                        ret
; Pinta Pala ;
pala                    ld hl, (shovelPos)
                        ld a, 00011011b
                        ld (hl), a
                        ret
; Pinta Bomba ;
bomba                   ld hl, 582Fh
                        ld (bombPos), hl
                        ld a, 00010010b
                        ld (hl), a
                        ret

; Caida ;
caida                   ld b, 21
bombDrop                ld a, 00101101b
                        ld hl, (bombPos)
                        ld (hl), a
                        add hl, 32
                        ld a, 00010010b
                        ld (hl), a
                        ld (bombPos), hl
                        call retardo
                        call colision_pala
                        call colision_fondo


move                    ld a, 0dfh
                        in a, (0feh)
                        bit 0, a
                        jp z, right
                        bit 1, a
                        jp z, left

moveCont                djnz bombDrop
                        ret

; Retardo ;
retardo                 halt
                        halt
                        halt
                        halt
                        halt
                        ret

; Movimientos pala ;
right                   ld a, 00101101b
                        ld hl, (shovelPos)
                        ld (hl), a
                        inc hl
                        ld a, 00011011b
                        ld (hl), a
                        ld (shovelPos), hl
                        ld a, (shovelX)
                        inc a
                        ld (shovelX), a
                        jp moveCont

left                    ld a, 00101101b
                        ld hl, (shovelPos)
                        ld (hl), a
                        dec hl
                        ld a, 00011011b
                        ld (hl), a
                        ld (shovelPos), hl
                        ld a, (shovelX)
                        dec a
                        ld (shovelX), a
                        jp moveCont

; Colision ;
colision_fondo          ld a, 00001001b
                        ld c, a
                        add hl, 32
                        ld a, (hl)
                        cp a, c
                        jp z, AppEntry

colision_pala           add hl, -32
                        ld a, 00011011b
                        ld c, a
                        add hl, 32
                        ld a, (hl)
                        cp a, c
                        jp z, rand
                        ret


; Random ;
rand                    ld a, r                  ; Load the A register with the refresh register
                        ld l, a                  ; Copy register A into register L
                        AND %00011111b           ; This masking prevents the address we are forming from accessing RAM
                        ld h, a                  ; Copy register A into register H
                        ld a,(hl)
                        ld hl, 5820h
                        add hl, a
                        ld (bombPos), hl
                        jp inicio
                        ret

bombPos                 defs 8
shovelPos               defs 8
shovelX                 defs 1
bombX                   defs 1

; Stop planting code after this. (When generating a tape file we save bytes below here)
AppLast                 equ *-1                         ; The last used byte's address

; Generate some useful debugging commands

                        profile AppFirst,AppLast-AppFirst+1     ; Enable profiling for all the code

; Setup the emulation registers, so Zeus can emulate this code correctly

Zeus_PC                 equ AppEntry                            ; Tell the emulator where to start
Zeus_SP                 equ $FF40                               ; Tell the emulator where to put the stack

; These generate some output files

                        ; Generate a SZX file
                        output_szx AppFilename+".szx",$0000,AppEntry    ; The szx file

                        ; If we want a fancy loader we need to load a loading screen
;                        import_bin AppFilename+".scr",$4000            ; Load a loading screen

                        ; Now, also generate a tzx file using the loader
                        output_tzx AppFilename+".tzx",AppFilename,"",AppFirst,AppLast-AppFirst,1,AppEntry ; A tzx file using the loader


