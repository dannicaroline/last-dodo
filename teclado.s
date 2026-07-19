.text
.globl verifica_teclado

verifica_teclado:
    addi sp, sp, -4
    sw ra, 0(sp)

    # ----------------------------------------------------
    # 1. LÊ O STATUS DO TECLADO
    # ----------------------------------------------------
    li t0, 0xFF200000
    lw t1, 0(t0)
    andi t1, t1, 1
    beqz t1, fim_teclado

    # Lê qual tecla foi apertada
    lw t2, 4(t0)          

    # Pega as posições atuais do Dodô (X e Y)
    la t3, player_x
    lw a0, 0(t3)          
    la t4, player_y
    lw a1, 0(t4)          

    # Salva a posição antiga
    la t6, old_x
    sw a0, 0(t6)
    la t6, old_y
    sw a1, 0(t6)

    # ----------------------------------------------------
    # 2. IDENTIFICA A TECLA E A DIREÇÃO
    # ----------------------------------------------------
    li t5, 119            # W (Cima)
    beq t2, t5, move_w
    li t5, 97             # A (Esquerda)
    beq t2, t5, move_a
    li t5, 115            # S (Baixo)
    beq t2, t5, move_s
    li t5, 100            # D (Direita)
    beq t2, t5, move_d
    
    li t5, 109            # m (Música/Som - minúsculo)
    beq t2, t5, aperta_m
    
    j fim_teclado         # Outra tecla ignorada

move_w: 
    la t6, direcao_dodo
    sw t5, 0(t6)         
    addi a1, a1, -16
    j testa_colisao

move_a: 
    la t6, direcao_dodo
    sw t5, 0(t6)         
    addi a0, a0, -16
    j testa_colisao

move_s: 
    la t6, direcao_dodo
    sw t5, 0(t6)         
    addi a1, a1, 16
    j testa_colisao

move_d: 
    la t6, direcao_dodo
    sw t5, 0(t6)         
    addi a0, a0, 16
    j testa_colisao

testa_colisao:
    # ----------------------------------------------------
    # 3. COLISÃO COM AS BORDAS DA TELA
    # ----------------------------------------------------
    bltz a0, erro_movimento
    li t5, 296
    bgt a0, t5, erro_movimento
    bltz a1, erro_movimento
    li t5, 216
    bgt a1, t5, erro_movimento

    # ----------------------------------------------------
    # 4. MATEMÁTICA DA MATRIZ
    # ----------------------------------------------------
    addi t0, a0, 12      
    srli t0, t0, 4       
    addi t1, a1, 12      
    srli t1, t1, 4       

    li t2, 20            
    mul t1, t1, t2       
    add t0, t1, t0       

    # ----------------------------------------------------
    # 5. ESCOLHE O MAPA CERTO
    # ----------------------------------------------------
    la t3, fase_atual
    lw t4, 0(t3)
    li t5, 1
    beq t4, t5, pega_matriz_1
    
    la t1, mapa2
    j continua_matriz
    
pega_matriz_1:
    la t1, mapa1
    
continua_matriz:
    add t1, t1, t0
    lb t2, 0(t1)         

    # ----------------------------------------------------
    # 6. AS REGRAS DO JOGO
    # ----------------------------------------------------
    li t5, 1
    beq t2, t5, erro_movimento   
    li t5, 2
    beq t2, t5, erro_movimento   
    li t5, 5
    beq t2, t5, erro_movimento   

    li t5, 3
    bne t2, t5, checa_saida       
    la t3, fase_atual
    lw t4, 0(t3)
    li t5, 2
    beq t4, t5, erro_movimento    

checa_saida:
    # 1. Checa o bloco 4 (saída original/árvore)
    li t5, 4                 
    beq t2, t5, vai_para_passa_fase 

    # 2. Checa a Grama! 

    li t5, 6                 
    beq t2, t5, vai_para_passa_fase

    j movimento_liberado

# ==========================================
# ETIQUETAS FINAIS DO TECLADO
# ==========================================
aperta_m:
    # Chama a função de som que mora no main.s
    jal toca_som_passo
    j fim_teclado

erro_movimento:
    j fim_teclado

vai_para_passa_fase:
    j passa_fase

movimento_liberado:
    la t3, player_x
    sw a0, 0(t3)         
    la t4, player_y
    sw a1, 0(t4)         

    # TOCO SOM DE PASSO: Nota aguda curta de bloco de madeira (woodblock)
    addi sp, sp, -4
    sw ra, 0(sp)
    li a0, 76            # Nota aguda
    li a2, 115           # Instrumento: Woodblock (percussivo)
    jal toca_som
    lw ra, 0(sp)
    addi sp, sp, 4

    jal move_inimigos
    j fim_teclado

fim_teclado:
    # ----------------------------------------------------
    # RECUPERA O RA ANTES DE SAIR
    # ----------------------------------------------------
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
