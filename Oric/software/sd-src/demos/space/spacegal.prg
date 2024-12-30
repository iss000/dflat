; Space gallery
; A simple slide show
; of files of the form x-small.bin
; where x = 1..14
def_start()
ink 7:paper 0:hires
a=1
dim a$[20]
repeat
 a$=dec(a)+"-small.bin"
 bload 0xa000,a$
 i=0:repeat:c=get(0):i=i+1:until (i>1000)|(c<>0)
 a=a+1:if a>14:a=1:endif
until c==27
enddef
println "_start() to start slideshow"
