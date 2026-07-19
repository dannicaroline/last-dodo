.text
.globl desenha_mapa, desenha_personagem, atualiza_tela, pinta_fundo

# =========================================================
# FUNÇÃO 1: Derrama o Balde de Tinta na Tela Oculta
# =========================================================
pinta_fundo:
    la t3, frame_atual
    lw a3, 0(t3)         
    li t0, 0xFF0         
    add t0, t0, a3       
    slli t0, t0, 20      

    li t1, 19200         
    
    # Verifica a fase para escolher a cor base
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, cor_fundo_fase2
    
cor_fundo_fase1:
    li t2, 0x1A1A1A1A 
    j loop_fundo
cor_fundo_fase2:
    li t2, 0x14141414    

loop_fundo:
    sw t2, 0(t0)         
    addi t0, t0, 4       
    addi t1, t1, -1
    bnez t1, loop_fundo
    jr ra

# =========================================================
# FUNÇÃO 2: Desenha o Mapa na Tela Oculta
# =========================================================
desenha_mapa:
    addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # Escolhe qual matriz carregar
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, load_mapa2
load_mapa1:
    la s0, mapa1         
    j setup_loop_mapa
load_mapa2:
    la s0, mapa2

setup_loop_mapa:
    li s1, 300           
    li s2, 0             
    li s3, 0             

loop_mapa:
    beqz s1, fim_mapa    

    lb t0, 0(s0)         
    beqz t0, pula_pinta_bloco 

    li t1, 1
    beq t0, t1, eh_arvore
    li t1, 2
    beq t0, t1, eh_madeira
    li t1, 3
    beq t0, t1, eh_grama
    

    li t1, 4
    beq t0, t1, eh_saida_grama
    
    li t1, 5
    beq t0, t1, eh_arvore_escura
    
    j pula_pinta_bloco
    
eh_saida_grama:
    la a2, sprite_grama
    j pinta_bloco

eh_arvore_escura:
    la a2, sprite_arvore_escura
    j pinta_bloco
    
eh_arvore:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, toco_f2
    la a2, sprite_arvore
    j pinta_bloco
toco_f2:
    la a2, sprite_madeira_escura
    j pinta_bloco

eh_madeira:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, caixote_f2
    la a2, sprite_madeira
    j pinta_bloco
caixote_f2:
    la a2, sprite_caixa
    j pinta_bloco

eh_grama:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, grama_f2
    la a2, sprite_grama
    j pinta_bloco
grama_f2:
    # No mapa 2, o 3 pode ser arvore novamente para decorar a borda
    la a2, sprite_arvore 
    j pinta_bloco

pinta_bloco:
    mv a0, s2            
    mv a1, s3            
    la t3, frame_atual
    lw a3, 0(t3)         
    li a4, 16            
    li a5, 16            
    jal desenha_sprite   

pula_pinta_bloco:
    addi s2, s2, 16      
    li t2, 320
    blt s2, t2, proximo_bloco 
    
    li s2, 0             
    addi s3, s3, 16      

proximo_bloco:
    addi s0, s0, 1       
    addi s1, s1, -1      
    j loop_mapa

fim_mapa:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24
    jr ra

# =========================================================
# FUNÇÃO 3: Desenha o Dodô na Tela Oculta
# =========================================================
desenha_personagem:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, player_x
    lw a0, 0(t0)         
    la t1, player_y
    lw a1, 0(t1)         
    
    la t2, direcao_dodo
    lw t3, 0(t2)

    li t4, 119           # Letra W
    beq t3, t4, puxa_w
    li t4, 97            # Letra A
    beq t3, t4, puxa_a
    li t4, 115           # Letra S
    beq t3, t4, puxa_s
    
    # Se não for nenhum deles, o padrão é o D (Direita)
puxa_d:
    la a2, sprite_dodo_d
    j fim_direcao
puxa_w:
    la a2, sprite_dodo_w
    j fim_direcao
puxa_a:
    la a2, sprite_dodo_a
    j fim_direcao
puxa_s:
    la a2, sprite_dodo_s

fim_direcao:
    la t3, frame_atual
    lw a3, 0(t3)         
    li a4, 24            
    li a5, 24            
    jal desenha_sprite

    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

# =========================================================
# FUNÇÃO 4: Pintor 
# =========================================================
desenha_sprite:
    li t0, 0xFF0         
    add t0, t0, a3       
    slli t0, t0, 20      

    li t1, 320
    mul t2, a1, t1       
    add t2, t2, a0       
    add t0, t0, t2       

    mv t3, a5            
linha:
    mv t4, a4            
    mv t5, t0            
coluna:
    lbu t6, 0(a2)        
    li a6, 255           
    beq t6, a6, ignora_pixel 
    sb t6, 0(t5)         
ignora_pixel:
    addi a2, a2, 1       
    addi t5, t5, 1       
    addi t4, t4, -1
    bnez t4, coluna      

    addi t0, t0, 320     
    addi t3, t3, -1
    bnez t3, linha       
    jr ra

# =========================================================
# FUNÇÃO 5: Vira o Monitor
# =========================================================
atualiza_tela:
    la t0, frame_atual
    lw t1, 0(t0)
    li t4, 0xFF200604
    sw t1, 0(t4)         # Acende a tela que acabamos de pintar
    jr ra

# =========================================================
# FUNÇÃO 6: Restaura o Radar
# =========================================================
restaura_radar:
    addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)

    # 1. Margem do Radar 
    la t0, player_x
    lw t1, 0(t0)
    addi s4, t1, -32 
    addi s5, t1, 64 

    la t0, player_y
    lw t1, 0(t0)
    addi s6, t1, -32
    addi s7, t1, 64

    # 2. Escolhe a fase
    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 1
    beq t1, t2, rr_m1
    la s0, mapa2
    j rr_setup
rr_m1:
    la s0, mapa1

rr_setup:
    li s1, 300           
    li s2, 0             
    li s3, 0             

rr_loop:
    beqz s1, rr_fim    

    blt s2, s4, rr_ignora
    bgt s2, s5, rr_ignora
    blt s3, s6, rr_ignora
    bgt s3, s7, rr_ignora

    la t3, frame_atual
    lw a3, 0(t3)
    li t0, 0xFF0
    add t0, t0, a3
    slli t0, t0, 20

    li t1, 320
    mul t1, s3, t1
    add t1, t1, s2
    add t0, t0, t1       

    li t1, 16            
    
    # Pega a cor de limpeza correta baseada na fase
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, rr_limpa_fase2
rr_limpa_fase1:
    li a2, 0x1A1A1A1A    # Verde
    j rr_limpa_y
rr_limpa_fase2:
    li a2, 0x14141414    # Terra

rr_limpa_y:
    li t2, 4             
    mv t3, t0
rr_limpa_x:
    sw a2, 0(t3)
    addi t3, t3, 4
    addi t2, t2, -1
    bnez t2, rr_limpa_x
    addi t0, t0, 320     
    addi t1, t1, -1
    bnez t1, rr_limpa_y
    
    lb t0, 0(s0)         
    beqz t0, rr_ignora 

    li t1, 1
    beq t0, t1, rr_arvore
    li t1, 2
    beq t0, t1, rr_madeira
    li t1, 3
    beq t0, t1, rr_grama
    
    # ---> ALTERADO: O 4 (saída) agora é desenhado com o pincel de grama separado!
    li t1, 4
    beq t0, t1, rr_saida_grama 
    
    # ---> ADICIONADO: Verifica a árvore escura para o radar não apagá-la
    li t1, 5
    beq t0, t1, rr_arvore_escura
    
    j rr_ignora

# ---> ADICIONADO: Etiqueta EXCLUSIVA da grama de saída (Ignora regras do mapa 2)
rr_saida_grama:
    la a2, sprite_grama
    j rr_pinta

# ---> ADICIONADO: Etiqueta que carrega o sprite da árvore escura
rr_arvore_escura:
    la a2, sprite_arvore_escura
    j rr_pinta

rr_arvore:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, rr_toco_f2
    la a2, sprite_arvore
    j rr_pinta
rr_toco_f2:
    la a2, sprite_madeira_escura
    j rr_pinta

rr_madeira:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, rr_caixote_f2
    la a2, sprite_madeira
    j rr_pinta
rr_caixote_f2:
    la a2, sprite_caixa
    j rr_pinta

rr_grama:
    la t4, fase_atual
    lw t5, 0(t4)
    li t6, 2
    beq t5, t6, rr_grama_f2
    la a2, sprite_grama
    j rr_pinta
rr_grama_f2:
    la a2, sprite_arvore
    
rr_pinta:
    mv a0, s2            
    mv a1, s3            
    la t3, frame_atual
    lw a3, 0(t3)         
    li a4, 16            
    li a5, 16            
    jal desenha_sprite
    j rr_ignora

rr_ignora:
    addi s2, s2, 16      
    li t2, 320
    blt s2, t2, rr_prox  
    li s2, 0             
    addi s3, s3, 16      

rr_prox:
    addi s0, s0, 1       
    addi s1, s1, -1      
    j rr_loop

rr_fim:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    addi sp, sp, 36
    jr ra
