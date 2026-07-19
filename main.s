.text
.globl main
.globl passa_fase  

main:
carrega_fase: 

    
    # 1. Pinta tudo na Tela 0
    la t0, frame_atual
    li t1, 0
    sw t1, 0(t0)
    jal pinta_fundo
    jal desenha_mapa
    jal desenha_personagem
    jal desenha_inimigos

    # 2. Pinta tudo na Tela 1
    la t0, frame_atual
    li t1, 1
    sw t1, 0(t0)
    jal pinta_fundo
    jal desenha_mapa
    jal desenha_personagem
    jal desenha_inimigos

    # 3. Liga o monitor na Tela 0
    li t0, 0xFF200604
    sw zero, 0(t0)

loop_principal:
    li a7, 32
    li a0, 1
    ecall 

aguarda_input:
    li t0, 0xFF200000
    lw t1, 0(t0)
    andi t1, t1, 1
    beqz t1, loop_principal

    # ===================================================
    # 1. TROCA O PINCEL PARA A TELA ESCONDIDA
    # ===================================================
    la t0, frame_atual
    lw t1, 0(t0)
    xori t1, t1, 1       
    sw t1, 0(t0)

    # 2. JUIZ DE TURNO (Guarda a posição)
    la t0, player_x
    lw s10, 0(t0)
    la t0, player_y
    lw s11, 0(t0)

    # 3. FAXINA NO ESCURO
    jal apaga_personagens          

    # 4. DODÔ ANDA E CHECA
    jal verifica_teclado        
    jal checa_colisao_inimigos  
    
    la t0, player_x
    lw t1, 0(t0)
    la t0, player_y
    lw t2, 0(t0)
    bne s10, t1, permite_inimigo
    bne s11, t2, permite_inimigo
    j pula_turno_inimigo          

permite_inimigo:
    la t3, old_x
    lw t4, 0(t3)
    addi t4, t4, 1
    li t5, 3
    bne t4, t5, salva_contador
    li t4, 0               
salva_contador:
    sw t4, 0(t3)
    bnez t4, pula_turno_inimigo   

turno_inimigo:
    jal move_inimigos           
    jal checa_colisao_inimigos  

pula_turno_inimigo:
    # 6. DESENHA A ARTE NOVA NO ESCURO
    jal desenha_personagem
    jal desenha_inimigos
    
    # ===================================================
    # 7. VIRA O MONITOR 
    # ===================================================
    jal atualiza_tela

    j loop_principal

# ===================================================
# FUNÇÃO:Apaga os Inimigos e o Dodô
# ===================================================
.globl apaga_personagens
apaga_personagens:
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    # 1. Guarda a posição real do Dodô no bolso
    la t0, player_x
    lw s0, 0(t0)
    la t1, player_y
    lw s1, 0(t1)

    # 2. Apaga o Dodô primeiro
    jal restaura_radar

    # 3. Escolhe qual inimigo apagar
    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 2
    beq t1, t2, disfarca_cachorro

disfarca_rato:
    la t0, rato_x
    lw t1, 0(t0)
    la t2, player_x
    sw t1, 0(t2)
    la t0, rato_y
    lw t1, 0(t0)
    la t2, player_y
    sw t1, 0(t2)
    jal restaura_radar
    j restaura_dodo

disfarca_cachorro:
    la t0, cachorro_x
    lw t1, 0(t0)
    la t2, player_x
    sw t1, 0(t2)
    la t0, cachorro_y
    lw t1, 0(t0)
    la t2, player_y
    sw t1, 0(t2)
    jal restaura_radar

restaura_dodo:
    # 4. Devolve a posição original para o Dodô
    la t0, player_x
    sw s0, 0(t0)
    la t1, player_y
    sw s1, 0(t1)

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    jr ra

# ===================================================
# ROTINA DE TRANSIÇÃO DE FASE E GAME OVER
# ===================================================
passa_fase:

    la t0, fase_atual
    lw t1, 0(t0)         
    
    li t2, 2
    beq t1, t2, venceu_o_jogo # SE A FASE ERA A 2, VAI PARA A TELA DE VITÓRIA

    # ---------------------------------------------------------
    # melodia
    # ---------------------------------------------------------
    addi sp, sp, -4
    sw ra, 0(sp)
    jal toca_musica_transicao 
    lw ra, 0(sp)
    addi sp, sp, 4

    # Salva fase_atual como 2
    la t0, fase_atual
    li t1, 2
    sw t1, 0(t0)
    
    # Reseta a posição do Dodô para o início do Mapa 2
    la t0, player_x
    li t1, 16
    sw t1, 0(t0)
    la t0, player_y
    li t1, 208
    sw t1, 0(t0)
    
    j carrega_fase            

venceu_o_jogo:
    j tela_vitoria            

# ---------------------------------------------------------
# MÚSICA DE TRANSIÇÃO (Undertale Celesta Short)
# ---------------------------------------------------------
toca_musica_transicao:
    li a2, 8             # Instrumento Celesta
    li a3, 127           # Volume Máximo
    li a0, 62            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 67            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 69            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 71            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 74            
    li a1, 500           
    li a7, 33            
    ecall
    jr ra

# ===================================================
# SISTEMA DE ÁUDIO MIDI PADRÃO
# ===================================================
.globl toca_som_passo, toca_som_erro

toca_som_passo:
    li a0, 60       
    li a1, 100      
    li a2, 0        
    li a3, 100      
    li a7, 31       
    ecall
    jr ra

toca_som_erro:
    li a0, 45       
    li a1, 300      
    li a2, 114      
    li a3, 127      
    li a7, 31
    ecall
    jr ra

# =========================================================
# FUNÇÃO: Checa Colisão com Inimigos (Hitbox por Área Real)
# =========================================================
.globl checa_colisao_inimigos
checa_colisao_inimigos:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 2
    beq t1, t2, colide_cachorro

colide_rato:
    la t0, player_x
    lw t1, 0(t0)
    la t2, rato_x
    lw t3, 0(t2)
    sub t4, t1, t3
    bgez t4, rato_dx_ok
    neg t4, t4
rato_dx_ok:
    li t5, 20               # Raio da Hitbox X
    bge t4, t5, fim_colisao

    la t0, player_y
    lw t1, 0(t0)
    la t2, rato_y
    lw t3, 0(t2)
    sub t4, t1, t3
    bgez t4, rato_dy_ok
    neg t4, t4
rato_dy_ok:
    li t5, 20               # Raio da Hitbox Y
    bge t4, t5, fim_colisao
    j dodo_toma_dano

colide_cachorro:
    la t0, player_x
    lw t1, 0(t0)
    la t2, cachorro_x
    lw t3, 0(t2)
    sub t4, t1, t3
    bgez t4, lobo_dx_ok
    neg t4, t4
lobo_dx_ok:
    li t5, 20               
    bge t4, t5, fim_colisao

    la t0, player_y
    lw t1, 0(t0)
    la t2, cachorro_y
    lw t3, 0(t2)
    sub t4, t1, t3
    bgez t4, lobo_dy_ok
    neg t4, t4
lobo_dy_ok:
    li t5, 20               
    bge t4, t5, fim_colisao

dodo_toma_dano:
    jal toca_som_erro

    la t0, player_hp
    lw t1, 0(t0)
    addi t1, t1, -1
    sw t1, 0(t0)
    
    blez t1, game_over 
    
    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 2
    beq t1, t2, renasce_mapa2

renasce_mapa1:
    # TOCO SOM DE DANO (Som agudo de susto)
    li a0, 80            
    li a1, 150           
    li a2, 4             
    li a3, 127           
    li a7, 33            
    ecall

    la t0, player_x
    li t1, 32
    sw t1, 0(t0)
    la t0, player_y
    li t1, 32
    sw t1, 0(t0)

    la t0, rato_x
    li t1, 128           
    sw t1, 0(t0)
    la t0, rato_y
    li t1, 112           
    sw t1, 0(t0)
    
    j carrega_fase

renasce_mapa2:
    # TOCO SOM DE DANO (Som agudo de susto)
    li a0, 80            
    li a1, 150           
    li a2, 4             
    li a3, 127           
    li a7, 33            
    ecall

    la t0, player_x
    li t1, 16
    sw t1, 0(t0)
    la t0, player_y
    li t1, 208
    sw t1, 0(t0)

    la t0, cachorro_x
    li t1, 265         
    sw t1, 0(t0)
    la t0, cachorro_y
    li t1, 64           
    sw t1, 0(t0)
    
    j carrega_fase

game_over:
    # TOCO SOM DE MORTE (Órgão fúnebre longo)
    li a0, 36            
    li a1, 1000          
    li a2, 19            
    li a3, 127           
    li a7, 33            
    ecall

    # PREPARA O APAGÃO DA TELA
    la t0, frame_atual
    lw a3, 0(t0)
    li t0, 0xFF0
    add t0, t0, a3
    slli t0, t0, 20

    # Pinta os 19200 pixels de PRETO
    li t1, 19200
    li t2, 0x00000000    
loop_tela_morte:
    sw t2, 0(t0)
    addi t0, t0, 4
    addi t1, t1, -1
    bnez t1, loop_tela_morte

    jal atualiza_tela

trava_game_over:
    j trava_game_over              

fim_colisao:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra   

# =========================================================
# TELA DE VITÓRIA DEFINITIVA (32 BITS)
# =========================================================
tela_vitoria:
    # ---------------------------------------------------------
    # TRILHA DE VITÓRIA 
    # ---------------------------------------------------------
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li a2, 8             
    li a3, 127           
    li a0, 62            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 67            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 69            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 71            
    li a1, 150           
    li a7, 33            
    ecall
    li a0, 74            
    li a1, 600           
    li a7, 33            
    ecall
    
    lw ra, 0(sp)
    addi sp, sp, 4

    la t0, frame_atual
    lw t1, 0(t0)         
    
    li t0, 0xFF000000    
    beqz t1, fim_calculo_base
    li t0, 0xFF100000    
fim_calculo_base:

    # PINTA O FUNDO DE AZUL 
    li t1, 19200         
    li t2, 0x000040C0    
    mv t3, t0            

loop_fundo_azul:
    sw t2, 0(t3)         
    addi t3, t3, 4       
    addi t1, t1, -1
    bnez t1, loop_fundo_azul

    la t1, sprite_trofeu 
    
    li t2, 93            
    li t4, 0             

loop_linha_trofeu:
    li t5, 0             
    li t3, 133           

loop_coluna_trofeu:
    lbu t6, 0(t1)        
    
    li a0, 255
    beq t6, a0, pula_pixel_transparente

    li s1, 320
    mul s2, t2, s1       
    add s2, s2, t3       
    add s3, t0, s2       

    sb t6, 0(s3)         

pula_pixel_transparente:
    addi t1, t1, 1       
    addi t3, t3, 1       
    addi t5, t5, 1       
    li a0, 54
    blt t5, a0, loop_coluna_trofeu

    addi t2, t2, 1       
    addi t4, t4, 1       
    li a0, 54
    blt t4, a0, loop_linha_trofeu

    jal atualiza_tela

trava_vitoria:
    j trava_vitoria


# =========================================================
# FUNÇÃO: Desenha os Inimigos na Tela
# =========================================================
.globl desenha_inimigos
desenha_inimigos:
    addi sp, sp, -4
    sw ra, 0(sp)

    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 2
    beq t1, t2, desenha_cachorro

desenha_rato:
    la t0, rato_x
    lw a0, 0(t0)            
    la t0, rato_y
    lw a1, 0(t0)            
    la a2, sprite_rato      
    la t3, frame_atual
    lw a3, 0(t3)
    li a4, 24               
    li a5, 24               
    jal desenha_sprite      
    j fim_desenha_inimigos

desenha_cachorro:
    la t0, cachorro_x
    lw a0, 0(t0)            
    la t0, cachorro_y
    lw a1, 0(t0)            
    la a2, sprite_cachorro  
    la t3, frame_atual
    lw a3, 0(t3)
    li a4, 24               
    li a5, 24               
    jal desenha_sprite      

fim_desenha_inimigos:
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra

# =========================================================
# FUNÇÃO: Move Inimigos (I
# =========================================================
.globl move_inimigos
move_inimigos:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    la t0, fase_atual
    lw t1, 0(t0)
    li t2, 2
    beq t1, t2, setup_ia_cachorro

IA_rato:
    la t0, rato_x
    lw s1, 0(t0)            
    la t2, rato_dir
    lw s2, 0(t2)            
    add s3, s1, s2          

    li t5, 208              
    bge s3, t5, inverte_rato
    li t5, 96               
    ble s3, t5, inverte_rato

    mv a0, s3
    la t0, rato_y
    lw a1, 0(t0)
    jal le_matriz_inimigos
    bnez a0, inverte_rato

    la t0, rato_x
    sw s3, 0(t0)            
    j fim_move_inimigos

inverte_rato:
    la t2, rato_dir
    lw s2, 0(t2)
    neg s2, s2
    sw s2, 0(t2)
    j fim_move_inimigos

setup_ia_cachorro:
    la t0, cachorro_x
    lw s1, 0(t0)            
    la t0, cachorro_y
    lw s2, 0(t0)            

    la t0, player_x
    lw t1, 0(t0)
    sub s3, t1, s1          
    
    la t0, player_y
    lw t1, 0(t0)
    sub s4, t1, s2          
    
    mv t0, s3
    bgez t0, dx_ok
    neg t0, t0
dx_ok:
    mv t1, s4
    bgez t1, dy_ok
    neg t1, t1
dy_ok:

    bgt t0, t1, tenta_x_primeiro
    j tenta_y_primeiro

tenta_x_primeiro:
    beqz s3, tenta_y_secundario
    mv s5, s1               
    bgtz s3, x1_dir
    addi s5, s5, -16
    j x1_testa
x1_dir:
    addi s5, s5, 16
x1_testa:
    mv a0, s5
    mv a1, s2
    jal le_matriz_inimigos
    bnez a0, tenta_y_secundario 
    
    la t0, cachorro_x
    sw s5, 0(t0)            
    j fim_move_inimigos

tenta_y_secundario:
    beqz s4, fim_move_inimigos  
    mv s5, s2               
    bgtz s4, y2_baixo
    addi s5, s5, -16
    j y2_testa
y2_baixo:
    addi s5, s5, 16
y2_testa:
    mv a0, s1
    mv a1, s5
    jal le_matriz_inimigos
    bnez a0, fim_move_inimigos  
    
    la t0, cachorro_y
    sw s5, 0(t0)            
    j fim_move_inimigos

tenta_y_primeiro:
    beqz s4, tenta_x_secundario
    mv s5, s2               
    bgtz s4, y1_baixo
    addi s5, s5, -16
    j y1_testa
y1_baixo:
    addi s5, s5, 16
y1_testa:
    mv a0, s1
    mv a1, s5
    jal le_matriz_inimigos
    bnez a0, tenta_x_secundario 
    
    la t0, cachorro_y
    sw s5, 0(t0)            
    j fim_move_inimigos

tenta_x_secundario:
    beqz s3, fim_move_inimigos
    mv s5, s1               
    bgtz s3, x2_dir
    addi s5, s5, -16
    j x2_testa
x2_dir:
    addi s5, s5, 16
x2_testa:
    mv a0, s5
    mv a1, s2
    jal le_matriz_inimigos
    bnez a0, fim_move_inimigos  
    
    la t0, cachorro_x
    sw s5, 0(t0)            
    j fim_move_inimigos

fim_move_inimigos:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra

# =========================================================
# FUNÇÃO SECUNDÁRIA: Lê a Matriz
# =========================================================
le_matriz_inimigos:
    bltz a0, parede_matriz
    li t0, 304
    bgt a0, t0, parede_matriz
    bltz a1, parede_matriz
    li t0, 224
    bgt a1, t0, parede_matriz

    srli t0, a0, 4          
    srli t1, a1, 4          
    li t2, 20
    mul t1, t1, t2          
    add t0, t0, t1          

    la t1, fase_atual
    lw t2, 0(t1)
    li t3, 2
    beq t2, t3, ini_mapa2
ini_mapa1:
    la t1, mapa1
    j ini_le
ini_mapa2:
    la t1, mapa2
ini_le:
    add t1, t1, t0
    lb t2, 0(t1)            

    li a0, 1                
    li t3, 1
    beq t2, t3, fim_le_mat
    li t3, 2
    beq t2, t3, fim_le_mat
    li t3, 3
    beq t2, t3, fim_le_mat
    li t3, 5
    beq t2, t3, fim_le_mat
    
    li a0, 0                
fim_le_mat:
    jr ra

parede_matriz:
    li a0, 1
    jr ra
    
# =========================================================
# FUNÇÃO: Toca Nota MIDI Assíncrona
# =========================================================
toca_som:
    li a1, 120     
    li a3, 110     
    li a7, 33      
    ecall
    jr ra
    
.include "dados.s"
.include "render.s"
.include "teclado.s"
