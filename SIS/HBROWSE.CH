// ******************************************
// Defini‡”es TBrowseDB
// Copyright (c) 1994,1995, Hawk Software
// Roberto Falc„o Rocha

// Cores 
#define HBC_TITULO    m->cBTITULO
#define HBC_MOVER     m->cBMOVER
#define HBC_DADOS     m->cBDADOS
#define HBC_STATUS    m->cBSTATUS
#define HBC_FUNCOES   m->cBFUNCOES
#define HBC_TECLAS    m->cBTECLAS
#define HBC_RODAPE    m->cBRODAPE
#define HBC_CERCADURA m->cBCERCADURA
#define HBC_DELETADO  m->cBDELETADO
#define HBC_MBROWSE   m->cBMBROWSE
#define HBC_MVBROWSE  m->cBMVBROWSE

// Rela‡oes proporcionais de coordenadas
#define HB_RELSTATUS 0.25
#define HB_RELRODAPE 0.75

// Separadores do Browse
#define HB_HEADSEP "ÄÂÄ"
#define HB_COLSEP  " ³ "
#define HB_FOOTSEP "ÄÁÄ"

// Para usar no vetor de configuracao
#define HB_OBJETO 1
#define HB_TELA   2
#define HB_TITULO 3
#define HB_FECHA  4

// Define o tamanho minimo das janelas
#define HB_MINLIN 7
#define HB_MINCOL 16

// Para usar no vetor auxiliar de tela
#define HB_BARRA  1 
#define HB_SPACE1 2
#define HB_SPACE2 3

// Definicoes de teclas na encontradas em INKEY.CH
// Para o Browse
#define K_ALT_MINUS 386  // ALT--
#define K_ALT_DIR  413   // ALT-->
#define K_ALT_ESQ 411    // ALT-<-

// Elementos da barra
#define  HBB_INILIN         1
#define  HBB_INICOL         2
#define  HBB_FINLIN         3
#define  HBB_FINCOL         4
#define  HBB_COR            5
#define  HBB_POSICAO        6

#define  HBB_ELEMENTOS      6

// Seta, barra e fundo
#define  HBB_SETACIMA       CHR(  24 )
#define  HBB_SETABAIXO      CHR(  25 )
#define  HBB_BARRA          CHR( 178 ) 
#define  HBB_FUNDO          CHR( 176 )

// Memo
#define HBM_MESSAGE "<memo>"