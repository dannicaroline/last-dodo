# Last Dodo

Projeto final da disciplina de Introdução aos Sistemas Computacionais da Universidade de Brasília (UnB).

O jogo foi desenvolvido em Assembly RISC-V e é inspirado em *Journey of the Prairie King*. O objetivo é levar o dodô até a grama localizada no canto da tela, desviando dos inimigos.

## Como executar

Baixe todos os arquivos do projeto e instale o Java e o RARS.

Abra o arquivo `main.asm` no RARS. Em seguida, vá em **Tools** e abra o **Bitmap Display** e o **Keyboard and Display MMIO Simulator**. Nas duas janelas, clique em **Connect to Program** e depois execute o programa.

## Como jogar

Use as teclas **W, A, S e D** em "Keyboard and Display MMIO Simulator"para movimentar o personagem.

O objetivo é chegar até a grama no canto da tela sem encostar nos inimigos.

O primeiro inimigo se movimenta apenas da direita para a esquerda.

O segundo inimigo calcula a distância entre ele e o dodô e tenta se aproximar do jogador a cada movimento.

A hitbox utilizada é de 20 pixels.

O jogador possui 3 vidas. Ao perder todas elas, a tela fica preta indicando o fim do jogo.

Depois de concluir a segunda fase, o jogo é encerrado.
