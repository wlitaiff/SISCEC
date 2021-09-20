CLEAR
set talk off
@ 10,10 say "Registro:"
USE SA2010
GO TOP
C = 1
DO WHILE .NOT. EOF()
   Mc = Str(c)
   @ 10,20 say recno()
   REPLAC A2_COD WITH ltrim(MC)
   C = C + 1
   SKIP
ENDDO
Set Talk On