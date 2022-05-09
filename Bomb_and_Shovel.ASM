; This is a basic template file for writing 48K Spectrum code.

AppFilename             equ "NewFile"                   ; What we're called (for file generation)

AppFirst                equ $8000                       ; First byte of code (uncontended memory)

                        zeusemulate "48K","ULA+"        ; Set the model and enable ULA+


; Start planting code here. (When generating a tape file we start saving from here)

                        org AppFirst                    ; Start of application
; Main Entry Point ;
AppEntry                ld hl, 5ACFh
                        ld (posicionPala), hl

                        call pintaPantalla
                        call pintaBordes
                        call pintaPala
                        call pintaBomba

inicio                  call pintaPantalla
                        call pintaBordes
                        call pintaPala
                        call caidaBomba
                        jp inicio

; Pinta el fondo ;
pintaPantalla           ld a, 00101101b
                        ld hl, 5800h
                        ld b, 255
rellenaPantalla1        ld (hl), a
                        inc hl
                        djnz rellenaPantalla1

                        ld hl, 5900h
                        ld b, 255
rellenaPantalla2        ld (hl), a
                        inc hl
                        djnz rellenaPantalla2

                        ld hl, 5A00h
                        ld b, 255
rellenaPantalla3        ld (hl), a
                        inc hl
                        djnz rellenaPantalla3
                        ret

; Pinta bordes ;
pintaBordes             ld a, 00001001b
                        ld hl, 5800h
                        ld b, 32
pintaBordesTop          ld (hl), a
                        inc hl
                        djnz pintaBordesTop

                        ld hl, 5820h
                        ld b, 23
pintaBordesLeft         ld (hl), a
                        add hl, 32
                        djnz pintaBordesLeft

                        ld hl, 583Fh
                        ld b, 23
pintaBordesRight        ld (hl), a
                        add hl, 32
                        djnz pintaBordesRight

                        ld hl, 5AE0h
                        ld b, 32
pintaBordesBot          ld (hl), a
                        inc hl
                        djnz pintaBordesBot
                        ret

; Pinta Pala ;
pintaPala               ld hl, (posicionPala)
                        ld a, 00011011b
                        ld (hl), a
                        ret

; Pinta Bomba ;
pintaBomba              ld hl, 582Fh
                        ld (posicionBomba), hl
                        ld a, 00010010b
                        ld (hl), a
                        ret

; Caida ;
caidaBomba              ld b, 21
caidaBomba2             ld a, 00101101b
                        ld hl, (posicionBomba)
                        ld (hl), a
                        add hl, 32
                        ld a, 00010010b
                        ld (hl), a
                        ld (posicionBomba), hl
                        call retardo
                        call colisionPala
                        call colisionFondo

movimientoPala          ld a, 0dfh
                        in a, (0feh)
                        bit 0, a
                        jp z, mueveDerecha
                        bit 1, a
                        jp z, mueveIzquierda

movimientoPalaContinua  djnz caidaBomba2
                        ret

; Retardo ;
retardo                 halt
                        halt
                        halt
                        halt
                        halt
                        ret

; Movimientos pala ;
mueveDerecha            ld a, 00101101b
                        ld hl, (posicionPala)
                        ld (hl), a
                        inc hl
                        ld a, 00011011b
                        ld (hl), a
                        ld (posicionPala), hl
                        ld a, (posicionXPala)
                        inc a
                        ld (posicionXPala), a
                        jp movimientoPalaContinua

mueveIzquierda          ld a, 00101101b
                        ld hl, (posicionPala)
                        ld (hl), a
                        dec hl
                        ld a, 00011011b
                        ld (hl), a
                        ld (posicionPala), hl
                        ld a, (posicionXPala)
                        dec a
                        ld (posicionXPala), a
                        jp movimientoPalaContinua

; Colision ;
colisionFondo           ld a, 00001001b
                        ld c, a
                        add hl, 32
                        ld a, (hl)
                        cp a, c
                        jp z, AppEntry

colisionPala            add hl, -32
                        ld a, 00011011b
                        ld c, a
                        add hl, 32
                        ld a, (hl)
                        cp a, c
                        jp z, generarNumero
                        ret

; Generar numero aleatorio ;
generarNumero           ld a, r                  ; Load the A register with the refresh register
                        ld l, a                  ; Copy register A into register L
                        AND %00011111b           ; This masking prevents the address we are forming from accessing RAM
                        ld h, a                  ; Copy register A into register H
                        ld a,(hl)
                        ld hl, 5820h
                        add hl, a
                        ld (posicionBomba), hl
                        jp inicio
                        ret

; Variables auxiliares ;
posicionBomba           defs 8

posicionPala            defs 8
posicionXPala           defs 1


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


