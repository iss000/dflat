; PT3 player in dflat!
; 2025
def_start()
 dim f$[50]
 ; Load the PT3 player to 0x8000
 bload 0x8000,"pt3play.bin"
 repeat
  cls
  dir
  print "Enter PT3 file: "
  input f$
  ; Load song to 0x2000
  bload 0x2000,f$
  a=call(0x8000,0x00,0x20,0)
  println "Hit any key to stop"
  repeat
   a=call(0x8007,0,0,0)
   k=get(0)
   wait 1
  until k<>0
  play 0,0,0,0
 until 0
enddef
;
println "Check instructions!"
