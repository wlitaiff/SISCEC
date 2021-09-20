use sb1010 exclusive
go top
Do While ! eof()
   ? recno()
   replace b1_subgru with strzero(val(b1_subgru),4)
   skip
Enddo
use
