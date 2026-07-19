.data

# =========================================================
# CONTROLE DO JOGO, DA TELA E JOGADOR
# =========================================================
fase_atual:    .word 1      
frame_atual:   .word 0      
direcao_dodo:  .word 100    

player_hp:     .word 3      # <-- Definido apenas UMA VEZ aqui!

player_x:      .word 32       
player_y:      .word 32
old_x:         .word 32
old_y:         .word 32

# =========================================================
# POSIÇÃO E CONTROLE DOS INIMIGOS (Mapas 1 e 2)
# =========================================================
rato_x:             .word 128    
rato_y:             .word 112
rato_dir:           .word 16     
rato_olhando_dir:   .word 1      # 1 = Direita, 0 = Esquerda

cachorro_x:         .word 265  
cachorro_y:         .word 64
cachorro_olhando_dir: .word 1    

# =========================================================
# EXPORTAÇÃO DE SÍMBOLOS GLOBAIS
# =========================================================
.globl player_x, player_y, old_x, old_y, fase_atual, frame_atual, direcao_dodo
.globl player_hp, rato_x, rato_y, rato_dir, rato_olhando_dir
.globl cachorro_x, cachorro_y, cachorro_olhando_dir
.globl mapa1, mapa2
.globl restaura_radar, sprite_grama, sprite_arvore, sprite_madeira
.globl sprite_dodo_w, sprite_dodo_a, sprite_dodo_s, sprite_dodo_d
.globl sprite_madeira_escura, sprite_caixa, sprite_arvore_escura
.globl sprite_rato, sprite_cachorro
.globl sprite_trofeu
# =========================================================
# MAPAS DO JOGO
# =========================================================
mapa1:
    .include "mapa1.data"

mapa2:
    .include "mapa2.data"  

# =========================================================
# INCLUSÃO DE SPRITES DO JOGADOR E CENÁRIO
# =========================================================
.include "dodo.data"
.include "madeira_escura.data"    
.include "caixa.data"   
.include "arvore_escura.data"

.align 2
sprite_grama:
    .include "grama.data"

sprite_arvore:
    .include "arvore.data"

sprite_madeira:
    .include "madeira.data"

# =========================================================
# INCLUSÃO DE SPRITES DOS INIMIGOS
# =========================================================
.align 2
sprite_rato:
    .include "rato.data"

sprite_cachorro:
    .include "cachorro.data"
 
 
#sprite do trofeu
sprite_do_trofeu:
    .include "sprite_trofeu.data"
