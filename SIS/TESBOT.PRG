// cria botao com relevo n ocentro da tela
// aciona a funcao que el o mouse permitindo a se do botao
//

bc_inic()
private botao1,cod_bot
// cria botao
tipo  := 2
acion := 1
bot_a := bc_criabot(.2,.8,,,tipo,asc("A"),"Botao ~A",,acion)
//
cod_botao := 0
tecla     := 0
Do While tecla <> 27
   bc_lemouse(@cod_botao,,@tecla)
	do case
		case cod_botao = bot_a
			bc_textm(.3,.6,"Botao 1 teste teste")
		
	endcase
enddo
//
bc_elimbot()
bc_fim()
//