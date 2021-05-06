def_start() ; 4000 bytes of space for machine code dim code[200,10]; ; Back screen 8000 bytes; dim backBuffer[100,40] ; Sprite table dim sprTable[15] ; 400b for ship dim sprShip[200] ; 500b for alien dim sprAlien1[250], sprAlien2[250] dim sprAlien3[150], sprAlien4[150] dim sprAlien5[80], sprAlien6[80] dim sprAlien7[40], sprAlien8[40] ; Which sprite to show dim sprSelect[9] ; Temp strings dim d$[50],t$[50]; reset t:t=rnd(t) _init() state=0 repeat  if state==0:_attract():endif  if state==1:_initGame():endif  if state==2:_playGame():endif until 0enddef;def_init(); base=0xa000+199*40 horizon=80 perspective=4 paper 0:ink 4:hires:cursor 1 _doAsm() _generateSprites() reset j:j=rnd(j) for j=0,50,1:point rnd(0)\240,rnd(0)\horizon:next for j=1,50,1  circle 140,horizon+10,j  plot 140-50-5,horizon-j+10-1,1  plot 140+50+5,horizon-j+10-1,7 next pixmode 0 for j=horizon,horizon+60,1:line 0,j,239,j:nextenddef;def_attract() startOffset=0 startColour=16+5:altColour=(16+6)^startColour xPos=120<<8:yPos=185<<8:dx=0:dy=0 xStep=32:yStep=32:friction=8 t=call(drawSprite,0,xPos>>8,yPos>>8) repeat  println "Press any key":t=get(1):if t=='q':abort:endif  t=call(loopLand,0,0,0)  ax=100:ay=horizon+2  repeat   spriteMask=0x00   t=call(drawSprite,(ay-horizon)>>3+1,ax,ay)   ay=ay+(ay-horizon)>>4+1   spriteMask=0xff   t=call(drawSprite,(ay-horizon)>>3+1,ax,ay)   wait 2  until ay > 180 until 0enddef;;def_initGame()enddef;def_playGame()enddef;def_doAsm() println "Assembling.." ; Three pass assembler ; 0=process silently but do not generate code ; 1=process with printout to screen ; 2=process silently and generate code ; 3=process with printout to screen and generate code _asm(0):println "Done Pass 1" _asm(0):println "Done Pass 2" _asm(2):println "Done Pass 3" println "Code size=",endAsm-startAsmenddef;def_asm(o) ztmp24=0x3d pointSetup=0xcfe5 kbstick=0xc737; .opt o .org code.startAsm.drawLand .lda addr(colour) .drawLineAbs:.sta 0x1234:; Self modifying code ; Decrement y .dey ; Update line address .sec .lda drawLineAbs+1:.sbc #40:.sta drawLineAbs+1 .lda  drawLineAbs+2:.sbc #0:.sta  drawLineAbs+2 ; Decrement bar size counter .dex ; Check if x<0 .bpl skipReset ; Reset current bar size in X .jsr calcBarSize ; Flip colour .lda addr(colour):.eor addr(altColour) .sta addr(colour).skipReset .cpy addr(horizon) .bcs drawLand .inc addr(startOffset):;.inc addr(startOffset) .rts;; Calculate new bar size (y-reg-horizon+2)/4.calcBarSize .sec:.tya:.sbc addr(horizon) .clc:.adc #2:.lsr:.lsr .tax .rts;; initialise landscape.initLand ; Start painting from bottom .ldy #199 .lda addr(base):.sta drawLineAbs+1 .lda addr(base)+1:.sta drawLineAbs+2 ; Initialise bar size .jsr calcBarSize .cpx addr(startOffset):.bcs skipInitReset .lda #0:.sta addr(startOffset) .lda addr(startColour):.eor addr(altColour) .sta addr(startColour).skipInitReset .sec:.txa:.sbc addr(startOffset):.tax .lda addr(startColour):.sta addr(colour) .rts;; do one loop.loopLand .jsr initLand .jsr drawLand .jsr playerUpdate ; Check stick status returned for fire .and #16 .beq loopLand .rts;; Hires bit mask to bit position look up; 1=pos 5*2+3, 2=pos 4*2+3, 4=pos 3*2+3; 8=pos 2*2+3,16=pos 1*2+3,32=pos 0*2+3.maskLookUp.db  0,13,11, 0, 9, 0, 0, 0.db  7, 0, 0, 0, 0, 0, 0, 0.db  5, 0, 0, 0, 0, 0, 0, 0.db  0, 0, 0, 0, 0, 0, 0, 0.db  3, 0, 0, 0, 0, 0, 0, 0; Draw sprite indexed in A at pos x,y.drawSprite linebase=0x32 linemask=0x34 lineoffset=0x35 ztSprPtr=ztmp24+0 ztWidth=ztmp24+2 ztHeight=ztmp24+3 ztSize=ztmp24+4 .pha ; Get line base and offset .jsr pointSetup .sty lineoffset ; Get sprite address .pla:.asl:.tax .lda addr(sprTable),x:.sta ztSprPtr:;         	+0 = sprite pointer L .lda addr(sprTable)+1,x:.sta ztSprPtr+1:;     	+1 = sprite pointer H ; Now save the width, height and size .ldy #0:.lda (ztSprPtr),y:.sta ztWidth:;     	+2 = width .iny:.lda (ztSprPtr),y:.sta ztHeight:;        	+3 = height .iny:.lda (ztSprPtr),y:.sta ztSize:;        	+4 = size ; Get sprite position pointer .ldx linemask:.ldy maskLookUp,x ; Initialise self-modifying addresses .lda (ztSprPtr),y:.sta source1-2:.sta source2-2 .iny .lda (ztSprPtr),y:.sta source1-1:.sta source2-1 ; Set up line base with offset .clc:.lda linebase:.adc lineoffset .sta dest1-2:.sta dest2-2 .lda linebase+1:.adc #0 .sta dest1-1:.sta dest2-1; .brk:.db 0 ; Number of rows to do .ldx ztHeight.nextSpriteRow ; Poke from right to left starting at width .ldy ztWidth.plotSpriteRow .lda 0xffff,y:.source1 .and addr(spriteMask) .sta 0xffff,y:.dest1 .dey:.bne plotSpriteRow ; Now plot the attribute .lda 0xffff:.source2 .sta 0xffff:.dest2 ; Increment sprite pointer by width+1 .sec .lda source1-2:.adc ztWidth .sta source1-2:.sta source2-2 .lda source1-1:.adc #0 .sta source1-1:.sta source2-1 ; Move screen down by 40 .clc .lda dest1-2:.adc #40 .sta dest1-2:.sta dest2-2 .lda dest1-1:.adc #0 .sta dest1-1:.sta dest2-1 ; Decrement height .dex ; Keep going until all rows done .bne nextSpriteRow .rts;.playerUpdate  .lda addr(xPos)+1:.sta addr(ox)+1  .lda addr(yPos)+1:.sta addr(oy)+1  .jsr kbstick:.pha  .pla:.pha:.and #1:.beq skipLeft  ; Do left dx only if not -2  .lda addr(dx)+1:.cmp #-3&0xff:.beq dxLowerLimit  .sec  .lda addr(dx):.sbc addr(xStep):.tay  .lda addr(dx)+1:.sbc addr(xStep)+1  .bpl limitMinusDX:.cmp #-3&0xff:.bcs limitMinusDX.dxLowerLimit  .lda #-3&0xff:.ldy #0x80.limitMinusDX  .sta addr(dx)+1:.sty addr(dx).skipLeft  .pla:.pha:.and #2:.beq skipRight  ; Do right dx only if not 2  .lda addr(dx)+1:.cmp #2:.beq dxUpperLimit  .clc  .lda addr(dx):.adc addr(xStep):.tay  .lda addr(dx)+1:.adc addr(xStep)+1  .bmi limitPlusDX:.cmp #3:.bcc limitPlusDX.dxUpperLimit  .lda #2:.ldy #0x80.limitPlusDX  .sta addr(dx)+1:.sty addr(dx).skipRight  ; Do friction in x  .ldy addr(dx)+1:.bmi frictionXPlus  .sec:.lda addr(dx):.sbc addr(friction):.sta addr(dx)  .tya:.sbc addr(friction)+1:.sta addr(dx)+1  .bcs frictionY.frictionXZero:.lda #0:.sta addr(dx):.sta addr(dx)+1  .beq frictionY.frictionXPlus  .clc:.lda addr(dx):.adc addr(friction):.sta addr(dx)  .tya:.adc addr(friction)+1:.sta addr(dx)+1  .bcs frictionXZero.frictionY  ; Add x velocity to position  .clc:.lda addr(xPos):.adc addr(dx):.tya  .lda addr(xPos)+1:.adc addr(dx)+1  .cmp #10:.bcs skipLeftMargin:.lda #10:.ldy #0x80:.jsr dxNegate.skipLeftMargin  .cmp #211:.bcc skipRightMargin:.lda #210:.ldy #0x80:.jsr dxNegate.skipRightMargin  .sta addr(xPos)+1:.sty addr(xPos)  ; Add y velocity to position  .clc:.lda addr(yPos):.adc addr(dy):.sta addr(yPos)  .lda addr(yPos)+1:.adc addr(dy)+1  .cmp #100:.bcs skipTopMargin:.lda #100.skipTopMargin  .cmp #185:.bcc skipBottomMargin:.lda #185.skipBottomMargin  .sta addr(yPos)+1  ; Check old and new positions  .lda addr(xPos)+1:.cmp addr(ox)+1:.bne doUpdate  .lda addr(yPos)+1:.cmp addr(oy)+1:.bne doUpdate  ; first get stick status off stack  .pla  .rts.dxNegate  .pha:.sec  .lda #0:.sbc addr(dx):.sta addr(dx)  .lda #0:.sbc addr(dx)+1:.sta addr(dx)+1  .pla:.rts.doUpdate  .lda #0x40:.sta addr(spriteMask)  .ldx addr(ox)+1:.ldy addr(oy)+1:.lda #0  .jsr drawSprite  .lda #0xff:.sta addr(spriteMask)  .ldx addr(xPos)+1:.ldy addr(yPos)+1:.lda #0  .jsr drawSprite  ; first get stick status off stack  .pla  .rts;  ; Small routine to convert * to 1 and space to 0; X,A=Low/High of string.dataConvert .stx ztmp24:.sta ztmp24+1 .ldy #0.dataConvertLoop .lda (ztmp24),y .beq dataConvertDone .cmp #'*':.beq dataConvert1 .cmp #'X':.beq dataConvert1 .cmp #'1':.beq dataConvertDo .lda #'0' .bne dataConvertDo.dataConvert1 .lda #'1'.dataConvertDo .sta (ztmp24),y .iny .bne dataConvertLoop.dataConvertDone ; Return number of chars .tya:.tax:.lda #0 .rts;;* This label is at the end *.endAsmenddef;;; Sprite Generatordef_generateSprites() ;  println "Generating Sprites.." spriteMask=0xff ; Set up address pointer in sprite table  sprTable[1]=sprShip sprTable[2]=sprAlien8 sprTable[3]=sprAlien7 sprTable[4]=sprAlien6 sprTable[5]=sprAlien5 sprTable[6]=sprAlien4 sprTable[7]=sprAlien4 sprTable[8]=sprAlien3 sprTable[9]=sprAlien3 sprTable[10]=sprAlien2 sprTable[11]=sprAlien2 sprTable[12]=sprAlien2 sprTable[13]=sprAlien1 sprTable[14]=sprAlien1 sprTable[15]=sprAlien1 _processSpriteData(sprShip) _processSpriteData(sprAlien1) _processSpriteData(sprAlien2) _processSpriteData(sprAlien3) _processSpriteData(sprAlien4) _processSpriteData(sprAlien5) _processSpriteData(sprAlien6) _processSpriteData(sprAlien7) _processSpriteData(sprAlien8)enddef;def_processSpriteData(spr) sprBase=spr read w,h,s poke sprBase, w:poke sprBase+1, h:poke sprBase+2, s sprBase=sprBase+3 ; Now poke the destination addresses for b=0,5,1  doke sprBase, spr+3+12+s*b  sprBase=sprBase+2 next ; h rows for j=1,h,1  println "Row ",j  ; Attribute  read v  ; Bit pattern for w*6  read d$  t=call(dataConvert,d$/256,d$\256,0)  ; Do bit position 0 to 5  for b=0,5,1   ; Attribute for each position   poke sprBase+s*b,v   ; Extract bit image for each byte row   ; Put each shifted row in to right area   ; OR with 0x40 to ensure it shows up   for i=1,w,1:t$="0b"+mid(d$,i*6-5,6)	poke sprBase+s*b+i,val(t$)|0x40   next   ; Generate shifted pattern by prepending 0   t$="0"+d$   d$=t$  next  ; Ready for next line  sprBase=sprBase+w+1 nextenddef;; Data section; Each sprite: width, height, size (inc attribute); attribute, width*6 bits; Total space = 3+12+size*6;Total = 375data 4, 12, 5*12data 7, "        **              "data 7, "  *    *  *    *        "data 7, " *    * ** *    *       "data 7, " *   *  **  *   *       "data 7, "***  ********  ***      "data 4, "* **** *  * **** *      "data 7, "*   **********   *      "data 7, "       ****             "data 0, "                        "data 0, " *    ******    *       "data 0, "******************      "data 0, "*    ********    *      ";;Total = 447data 5, 12, 6*12data 1, "         ******               "data 1, "      ************            "data 1, "     ** * **** * **           "data 4, "  ********************        "data 4, " ** * * * * * * * * * *       "data 4, "******** * * * * *******      "data 3, "      ************            "data 3, "        ********              "data 0, "                              "data 0, "       **********             "data 0, "************************      "data 0, "         ******               ";;Total = data 5, 11, 6*11data 1, "        ******                "data 1, "      **********              "data 1, "     * * **** * *             "data 4, "  ******************          "data 4, " * * * * * * * * * **         "data 4, "**********************        "data 3, "      **********              "data 3, "        ******                "data 0, "                              "data 0, " ********************         "data 0, "       ********               ";data 4, 9, 5*9data 1, "      ******            "data 1, "    ** *  * **          "data 4, "  **************        "data 4, " * * * * * * * **       "data 4, "******************      "data 3, "      ******            "data 0, "                        "data 0, " ****************       "data 0, "      ******            ";data 4, 8, 5*8data 1, "      ****              "data 1, "   *** ** ***           "data 4, " ** * *  * * **         "data 4, "****************        "data 3, "     ******             "data 0, "                        "data 0, " **************         "data 0, "     ******             ";data 3, 6, 4*6data 1, "    ****          "data 1, "  ** ** **        "data 4, "*** *  * ***      "data 3, "   ******         "data 0, "                  "data 0, " **********       ";data 3, 4, 4*4data 1, "  ****            "data 4, "** ** **          "data 3, "  ****            "data 0, " ******           ";data 2, 3, 3*3data 1, " ****       "data 4, "* ** *      "data 3, " ****       ";data 2, 2, 3*2data 1, " **         "data 4, "****        "xx will not be processed xx;* COPY TO BACK BUFFER.copyFrontToBack  .lda #addr(backBuffer)\256:.sta ztmp24  .lda #addr(backBuffer)/256:.sta ztmp24+1  .lda #0x00:.sta ztmp24+2  .lda #0xa0:.sta ztmp24+3  .ldx #31:.ldy #0.frontToBackLoop  .lda (ztmp24+2),y:.sta (ztmp24),y  .iny:.bne frontToBackLoop  .inc ztmp24+3:.inc ztmp24+1  .dex:.bne frontToBackLoop  .ldy #63.frontToBackLast  .lda (ztmp24+2),y:.sta (ztmp24),y  .dey:.bpl frontToBackLast  .rts; COPY TO FRONT BUFFER.copyBackToFront  .lda #addr(backBuffer)\256:.sta ztmp24+2  .lda #addr(backBuffer)/256:.sta ztmp24+3  .lda #0x00:.sta ztmp24  .lda #0xa0:.sta ztmp24+1  .ldx #31:.ldy #0.backToFrontLoop  .lda (ztmp24+2),y:.sta (ztmp24),y  .iny:.bne backToFrontLoop  .inc ztmp24+3:.inc ztmp24+1  .dex:.bne backToFrontLoop  .ldy #63.backToFrontLast  .lda (ztmp24+2),y:.sta (ztmp24),y  .dey:.bpl backToFrontLast  .rts