#*******************************************************************************
# exercicio0.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Este programa mostra como utilizar a ferramenta keyboard and 
# display MMIO (memory-mapped I/O) simulator. Para demostrar a ferramenta,
# lemos os caracteres do teclado e ecoamos para o terminal
#
# Para o keyboard, usamos os seguintes registradores
# RCR - receiver control register    | 0xFFFF0000
# RDR - receiver data register       | 0xFFFF0004
#
# Para o display temos os seguintes registradores
# TCR - transmitter control register | 0xFFFF0008
# TDR - transmitter data register    | 0xFFFF000C
#
# Para ler um caracter do keyboard
# 1. leia o conteúdo do endereço 0xFFFF0000 (receiver control register)
# 2. Verifique o bit menos significativo do receiver control register
# 3. Se 0 vá para o item 1 senão leia o caracter digitado do endreço
#    0xFFFF0004 (receiver data register)
#
# Para escrever um caracter em display
# 1. leia o conteúdo do endereço 0xFFFF0008 (transmitter control register)
# 2. Verifique o bit menos significativo do dado lido
# 3. Se 0 vá para o item 1 (continue esperando até que o bit menos
#    significativo do transmitter control register seja igual a 1).
#    Se 1 escreva no display. Isto é feito escrevendo um dado no
#    endereço 0xFFFF000C (transmitter data register).
#
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    09/09/2019 GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

#segmento de dados
.data
	linha_comando: .space 80
	backspace: .word 8
	enter: .word 10

.text

.globl main
  
main:
# corpo do procedimento
    lw $s0, backspace
    lw $s1, enter
    li $s2, 0
    li $t2, 0
armazena_vetor:
    beqz $t2, laco2
    la $s3, linha_comando
    add $s3, $s3, $s2
    sw $t2, 0($s3)
    addiu $s2, $s2, 4
imprime_letra:
    beqz $t2, laco2
   	# endereço do TCR
    lw    $t1, 0xFFFF0008       # $t1 <- conteúdo do TCR
    andi  $t1, $t1, 0x0001  # isolamos o bit menos significativo
    beqz  $t1, imprime_letra
    # escrevemos o carcatere no display
    # endereço do TDR
    sw    $t2, 0xFFFF000C
                        
    j     laco2    	
laco2:
    lw    $t1, 0xFFFF0000       # $t1 <- conteúdo do RCR
    andi  $t1, $t1, 0x0001  # isolamos o bit menos significativo
    beqz  $t1, laco2
       
    lw    $t2, 0xFFFF0004       # $t2 <- caracter do terminal
    beq $t2, $s0, laco2
    bnez $t2, armazena_vetor
	
    # epílogo    
    li    $v0, 10           # serviço 10 - exit
    syscall

