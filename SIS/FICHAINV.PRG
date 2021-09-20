** FICHA PARA INVENTARIO - STFICHA
** W.L.V
SET DELETED ON
SET COLO TO G,B/W
SET TALK OFF
SET DATE GERMAN
sele 1
use ceccmer

M_DATA=DATE()
CLEA
@ 04,00 Clea to 24,79
**Display Cabecalho Video
@ 04,01 SAY 'FICHAINV : FICHA DE INVENTARIO.'
@ 06,01 SAY 'INFORME A DATA...:' GET M_DATA
READ
IF LASTKEY()==27
   retu
endif
@ 13,25 SAY 'Imprimindo! Aguarde...'
SELE 1

CI=0
CT=0
SET DEVICE TO PRINT
declare m_cod[2],m_des[2],m_des1[2],m_uni[2],m_qtd[2]
M_NUM:=1
M_NUM1:=2
DO WHILE .NOT. EOF()
   IF LASTKEY()==27
      EXIT
   ENDIF
   SELE 1
   FOR n=1 to 2 
     m_cod[n] = codigom
     m_des[n] = subs(descrim,1,25)
     m_des1[n]= subs(descrim,26,34)
     m_uni[n] = unidade
     m_qtd[n] = 0
     skip
   next
	***
	NUM =ALLTRIM(STR(INT(M_NUM)))
	NUM1=ALLTRIM(STR(INT(M_NUM1)))
	N1  =repl("0",7-len(num))+num
	N2  =repl("0",7-len(num1))+num1
	
   **Imprimir
   
   SELE 1
	usuario=" "
	*** PRIMEIRA COM DATA E NOME DA EMPRESA
	
   @ 01,010 SAY USUARIO
	@ 01,040 SAY ':'
	@ 01,050 SAY USUARIO
	@ 02,040 SAY ':'
   @ 03,005 SAY 'FICHA DE INVENTARIO FISICO '
	@ 03,040 SAY ':'
   @ 03,045 SAY 'FICHA DE INVENTARIO FISICO '
	@ 04,040 SAY ':'
   @ 05,001 SAY CHR(218)+REPLICATE(CHR(196),35)+CHR(191)+'  :'
   @ 05,042 SAY CHR(218)+REPLICATE(CHR(196),35)+CHR(191)
   @ 06,001 SAY CHR(179)+' DATA: '+DTOC(M_DATA)+'       No  '+N1+'  '+CHR(179)+'  :'
   @ 06,042 SAY CHR(179)+' DATA: '+DTOC(M_DATA)+'       No  '+N2+'  '+CHR(179)
   @ 07,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
   @ 07,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
   @ 08,001 SAY CHR(179)+' COD.: '+CHR(179)+' '+M_COD[1]+SPACE(12)+CHR(179)+'  :'
   @ 08,042 SAY CHR(179)+' COD.: '+CHR(179)+' '+M_COD[2]+SPACE(12)+CHR(179)
   @ 09,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
   @ 09,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
   @ 10,001 SAY CHR(179)+' DESC.: '+CHR(179)+' '+M_DES[1]+SPACE(25-LEN(M_DES[1]))+CHR(179)+'  :'
   @ 10,042 SAY CHR(179)+' DESC.: '+CHR(179)+' '+M_DES[2]+SPACE(25-LEN(M_DES[1]))+CHR(179)
   @ 11,001 SAY CHR(179)+' '+M_DES1[1]+SPACE(34-LEN(M_DES1[1]))+CHR(179)+'  :'
   @ 11,042 SAY CHR(179)+' '+M_DES1[2]+SPACE(34-LEN(M_DES1[2]))+CHR(179)
   @ 12,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
   @ 12,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
   @ 13,001 SAY CHR(179)+' UNI.: '+M_UNI[1]+' '+CHR(179)+' QUANT.:                '+CHR(179)+'  :'
	@ 13,042 SAY CHR(179)+' UNI.: '+M_UNI[2]+' '+CHR(179)+' QUANT.:                '+CHR(179)
   @ 14,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
   @ 14,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
   @ 15,001 SAY CHR(179)+' CONTADOR:            VISTO:       '+CHR(179)+'  :'
   @ 15,042 SAY CHR(179)+' CONTADOR:            VISTO:       '+CHR(179)
   @ 16,001 SAY CHR(192)+REPLICATE(CHR(196),35)+CHR(217)+'  :'
   @ 16,042 SAY CHR(192)+REPLICATE(CHR(196),35)+CHR(217)
	@ 17,040 SAY ':'
	@ 17,001 SAY REPL("-",78)
	**
	CL:=18
	N :=3
	FOR X=1 TO 3
	  C =ALLTRIM(STR(N))
     @ CL,001 SAY CHR(218)+REPLICATE(CHR(196),35)+CHR(191)+' :'
     @ CL,042 SAY CHR(218)+REPLICATE(CHR(196),35)+CHR(191)
	  CL++
	  @ CL,001 SAY CHR(179)+' '+C+'o CONTAGEM          No  '+N1+'  '+CHR(179)+'  :'
	  @ CL,042 SAY CHR(179)+' '+C+'o CONTAGEM          No  '+N2+'  '+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+' COD.: '+CHR(179)+' '+M_COD[1]+SPACE(12)+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+' COD.: '+CHR(179)+' '+M_COD[2]+SPACE(12)+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
	  CL++
	  @ CL,001 SAY CHR(179)+' DESC.: '+CHR(179)+' '+M_DES[1]+SPACE(25-LEN(M_DES[1]))+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+' DESC.: '+CHR(179)+' '+M_DES[2]+SPACE(25-LEN(M_DES[2]))+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+' '+M_DES1[1]+SPACE(34-LEN(M_DES1[1]))+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+' '+M_DES1[2]+SPACE(34-LEN(M_DES1[2]))+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
	  CL++
	  @ CL,001 SAY CHR(179)+' UNI.: '+M_UNI[1]+' '+CHR(179)+' QUANT.:                '+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+' UNI.: '+M_UNI[2]+' '+CHR(179)+' QUANT.:                '+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+REPLICATE(CHR(196),35)+CHR(179)
	  CL++
     @ CL,001 SAY CHR(179)+' CONTADOR:            VISTO:       '+CHR(179)+'  :'
     @ CL,042 SAY CHR(179)+' CONTADOR:            VISTO:       '+CHR(179)
	  CL++
     @ CL,001 SAY CHR(192)+REPLICATE(CHR(196),35)+CHR(217)+'  :'
     @ CL,042 SAY CHR(192)+REPLICATE(CHR(196),35)+CHR(217)
	  CL++
	  @ CL,040 SAY ':'
	  @ CL,001 SAY REPL("-",78)+' :'
	  CL++
	  N--
	NEXT  
	M_NUM =M_NUM +2
   M_NUM1=M_NUM1+2
ENDDO
SET DEVICE TO SCREEN
CLOSE DATA
RETURN
**FIM