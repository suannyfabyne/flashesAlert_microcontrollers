;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    FEVEREIRO DE 2016                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*			    PISCA-PISCA                            *
;*               SUANNY FABYNE DA SILVA VIEIRA                     *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		FLAG ;VARIAVEL Q SER� UTILIZADA PARA AUXILIAR NA INTERRUP�AO
		CONTDELAY ;VARIAVEL AUXILIAR PARA FAZER DELAY DE MEIO SEGUNDO
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;     GP0 COMO PISCA ALERTA (1 LIGA O PISCA ALERTA, 0 P/ DESLIGA)
;     GP1, (1 PARA PISCAR O LED DA ESQUERDA, 0 P/ DESLIGAR )
;     GP2, (1 PARA PISCAR O LED DA DIREITA, 0 P/ DESLIGAR )
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;   GP4 REPRESENTA O LED DA ESQUERDA E GP5 O DA DIREITA (1 LIGA O LED, 0 DESLIGA)
; 

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER� ESCRITA AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES
	MOVLW B'000' 
	MOVWF FLAG ;INICALIZA�AO DE FLAG COMO 000, O BIT MENOS SIGNIFICATIVO CORRESPONDE A GP0 (PISCAALERTA), O DO MEIO GP1 (ESQUERDA) E O MAIS SIGNIGICATIVO GP2 (DIREITA)
	BTFSC GPIO, GP0 ; SE O GP0, QUE ACIONA O PISCA ALERTA, FOR 1, SER� SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAALERTA
	BTFSC GPIO, GP1 ; SE O GP1, QUE ACIONA O LED ESQUERDO, FOR 1, SER� SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAGP4
	BTFSC GPIO, GP2 ; SE O GP2, QUE ACIONA O LED DIREITO, FOR 1, SER� SETADA A FLAG QUE CORRESPONDE A MESMA
	GOTO PISCAGP5 
	GOTO SAI_INT ;SE TIVER INTERRUP�AO, MAS NEM GP0, GP1 OU GP2 TIVER EM 2, SAI DA INTERRUP�AO COM FLAG ZERADA
PISCAALERTA
	MOVLW B'001' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP0 ACESO (PISCA ALERTA)
	MOVWF FLAG
	GOTO SAI_INT
PISCAGP4
	MOVLW B'010' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP1 ACESO (ESQUERDA)
	MOVWF FLAG
	GOTO SAI_INT
PISCAGP5
	MOVLW B'100' ;SETA O BIT DA FLAG CORRESPONDENTE AO GP2 ACESO (DIREITA)
	MOVWF FLAG
	GOTO SAI_INT

	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	BCF INTCON, 0 ;SETA O BIT 0 DO INTCON, PARA NAO FICARMOS SEMPRE EM LOOP NA INTERRUP�AO, SEM SAIR
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.

DELAYPISCA ;SUBROTINA REFERENTE AO DISPLAY
	MOVLW .8 ;TIMER0 CONTAR� DE 10 AT� 256 8 VEZES, PARA OCORRER O DELAY DESEJADO DE MEIO SEGUNDO
	MOVWF CONTDELAY
	BCF INTCON, T0IF 
	MOVLW .10 ;INICIA COM 10, POIS (256-10)x256x8 = 500ms 
	MOVWF TMR0
TIMER
	BTFSS INTCON, T0IF
	GOTO TIMER
	GOTO CONTADOR
CONTADOR
	BCF INTCON, T0IF
	MOVLW .10
	MOVWF TMR0
	DECFSZ CONTDELAY ;REPETE A CONTAGEM DO TIMER0 8 VEZES, E AP�S ISSO, RETORNA
	GOTO TIMER
	RETURN
	

	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000111' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS) GP0, GP1 E GP2 COMO ENTRADA
	MOVWF	TRISIO		;COMO SA�DAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000111' ;USANDO ESCALA DE 256, E ALTERANDO O BIT 7 PARA DESABILITAR O GPIO PULL-UPS
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'10001000'  ;SETA BIT 7 PARA HABILITAR ITERRUP�OES, E BIT 3 PARA HABILITAR INTERRUP�AO DO GPIO
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	MOVLW	B'00000111' ;SETA BIT 0, 1 E 2 PARA OCORRER A INTERRUP�AO AO MUDAR PORTAS GPO, GP1 E GP2
	MOVWF	IOC
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	MOVLW B'000'
	MOVWF FLAG
	MOVLW .8
	MOVWF CONTDELAY
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN ;MODELO FEITO E TESTANDO EM PULL-DOWN
	BTFSC FLAG, 0 ;CONFERE SE O BIT 0 DA FLAG QUE CORRESPONDE AO GP0 EM 1 (OU PISCA ALERTA) ESTA DESLIGADO
	GOTO PISCAALERTAMAIN ;SE TIVER LIGADO, VAI PARA O PISCA ALERTA
	BTFSC FLAG, 1 ;CONFERE SE O BIT 1 DA FLAG QUE CORRESPONDE AO GP1 EM 1 (OU ESQUERDA) ESTA DESLIGADO
	GOTO PISCAGP4MAIN
	BTFSC FLAG, 2 ;CONFERE SE O BIT 2 DA FLAG QUE CORRESPONDE AO GP2 EM 1 (OU ESQUERDA) ESTA DESLIGADO
	GOTO PISCAGP5MAIN
	GOTO MAIN ;SE NENHUM BIT DA FLAG ESTIVER SETADO, OU SEJA, GP0 GP1 E GP1 TODOS EM 0. CONTINUA EM LOOP NO MAIN
PISCAALERTAMAIN	
	BSF GPIO, GP4 ;SETA AS PORTAS GP4 E GP5, CORRESPONDENTES AOS LEDS, PARA PISCAR OS LEDS COM FREQUENCIA DE 1 SEGUNDO
	BSF GPIO, GP5
	CALL DELAYPISCA ;DELAY DE MEIO SEGUNDO
	BCF GPIO, GP4
	BCF GPIO, GP5
	CALL DELAYPISCA 
	BTFSS FLAG,0 ;QUANDO VOLTAR DA INTERRUP�AO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO PISCAALERTA AINDA EST� EM 1
	GOTO MAIN  ;SE A INTERRUP�AO GERADA FEZ SAIR DO PISCAALERTA, ENTAO SAI DESSA LABEL E VOLTA PRO MAIN
	GOTO PISCAALERTAMAIN
PISCAGP4MAIN
	BSF GPIO, GP4
	CALL DELAYPISCA
	BCF GPIO, GP4
	CALL DELAYPISCA
	BTFSS FLAG,1 ;QUANDO VOLTAR DA INTERRUP�AO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO ESQUERDA AINDA EST� EM 1
	GOTO MAIN ;SE A INTERRUP�AO GERADA FEZ MUDAR A CHAVE QUE ATIVA O ESQUERDA, ENTAO VOLTA PRO MAIN
	GOTO PISCAGP4MAIN
PISCAGP5MAIN
	BSF GPIO, GP5
	CALL DELAYPISCA
	BCF GPIO, GP5
	CALL DELAYPISCA
	BTFSS FLAG,2 ;QUANDO VOLTAR DA INTERRUP�AO, PRECISA DESSA CHECAGEM PARA CONFERIR SE A PORTA CORRESPONDENTE AO DIREITA AINDA EST� EM 1
	GOTO MAIN ;SE A INTERRUP�AO GERADA FEZ MUDAR A CHAVE QUE ATIVA O ESQUERDA, ENTAO VOLTA PRO MAIN
	GOTO PISCAGP5MAIN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END