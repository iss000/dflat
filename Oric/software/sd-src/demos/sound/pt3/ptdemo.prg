; PT3 player in dflat!
; 2025
def_start()
 dim code[100]
 println "Ensure PT3 player is loaded in 0x8000"
 println "Ensure PT3 tune is loaded in 0x2000"
 _asm(0):_asm(0):_asm(2)
 println "Call start, mute, stop for player"
 enddef
 ;
 ;
 def_asm(o)
  .opt o
  .org code
  userIrq=0x06
  pt3init=0x8000
  pt3play=pt3init+7
  pt3mute=pt3init+10
  .oldIrq
  .ds 2
  ; Initialise player to run on irq
  .start
  php:sei
  ; Remember previous user irq
  lda userIrq:sta oldIrq
  lda userIrq+1:sta oldIrq+1
  ; Instate PT3 irq
  lda #pt3Irq&0xff:sta userIrq
  lda #pt3Irq>>8:sta userIrq+1
  ; Initialise the pt3 player
  ; A,X provides song address
  lda #0x00
  ldx #0x20
  jsr pt3init
  ; Restore P (enables interrupts)
  plp
  rts
  ; Call pt3 player every interrupt
  .pt3Irq
  ; Simply call the player each tick
  jsr pt3play
  rts
  ; mute player
  .mute
  jsr pt3mute
  rts
  ; stop player
  .stop
  php:sei
  ; Restore previous irq
  lda oldIrq:sta userIrq
  lda oldIrq+1:sta userIrq+1
  ; Restore P (enables interrupts)
  plp
  rts
enddef
;
println "Check instructions!"
