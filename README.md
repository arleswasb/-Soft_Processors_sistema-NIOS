```markdown
# Projeto Contador 0-99 com Processador Nios II (Cyclone II)

Este repositório contém o projeto de um sistema embarcado baseado em um soft-core processor **Nios II** (Altera/Intel), sintetizado em uma FPGA Cyclone II (EP2C35F672C6) utilizando a placa de desenvolvimento Altera DE2-35.

---

## 1. Árvore Estrutural do Projeto

Esta é a organização recomendada para o repositório. O arquivo `.gitignore` configurado garante que apenas estes arquivos de "receita" (código-fonte e configurações essenciais) sejam rastreados, ignorando os gigabytes de arquivos temporários de compilação:

```text
meu-projeto-nios2/
├── .gitignore               # Regras de exclusão de arquivos temporários do Quartus/Eclipse
├── README.md                # Documentação principal do projeto
├── hardware/Projeto_01      # Arquivos de configuração e síntese do hardware (Quartus/Qsys)
│   ├── Projeto_01.qpf       # Arquivo de gerenciamento do projeto Quartus
│   ├── Projeto_01.qsf       # Arquivo com configurações de pinagem e restrições
│   ├── Projeto_01.vhd       # Arquivo Top-Level em VHDL (Instanciação do Qsys)
│   ├── pjt_nios_ii.qsys     # Sistema do processador montado na ferramenta Qsys
|   └── Projeto_01.qar       # hardware inteiro compactado em um único arquivo!
└── software/                # Código-fonte da aplicação (Nios II SBT / Eclipse)

    └── contador_0_99/
        └── main.c           # Lógica principal em C (Contador, Debounce e Displays)

```

---

## 2. Mapeamento de Pinos (Pin Planner - DE2-35)

Para que o processador Nios II consiga se comunicar com o mundo físico, os sinais lógicos criados no bloco Top-Level foram mapeados nos pinos reais do chip da FPGA Cyclone II (`EP2C35F672C6`). Segue a tabela oficial configurada no Pin Planner:

| Nome do Sinal no Código | Pino FPGA | Componente Físico na Placa | Tipo de Sinal | Descrição |
| --- | --- | --- | --- | --- |
| `CLOCK_50` | **PIN_N2** | Oscilador de 50 MHz | Entrada | Clock global do sistema |
| `KEY[0]` | **PIN_G26** | Botão de Pressão KEY0 | Entrada | Reset de Hardware (Reinicia o Nios II) |
| `CHAVES[0]` | **PIN_N25** | Chave Seletora SW0 | Entrada | Controle de Direção (1 = UP, 0 = DOWN) |
| `CHAVES[1]` | **PIN_N26** | Chave Seletora SW1 | Entrada | Reset de Software (Zera o Contador) |
| `CHAVES[2]` | **PIN_P25** | Chave Seletora SW2  | Entrada | Controle do contador (start / stop) |
| `DISPLAY_7SEG[0]` | **PIN_R2** | Display HEX6 - Segmento A | Saída | Unidade do Contador |
| `DISPLAY_7SEG[1]` | **PIN_P4** | Display HEX6 - Segmento B | Saída | Unidade do Contador |
| `DISPLAY_7SEG[2]` | **PIN_P3** | Display HEX6 - Segmento C | Saída | Unidade do Contador |
| `DISPLAY_7SEG[3]` | **PIN_M2** | Display HEX6 - Segmento D | Saída | Unidade do Contador |
| `DISPLAY_7SEG[4]` | **PIN_M3** | Display HEX6 - Segmento E | Saída | Unidade do Contador |
| `DISPLAY_7SEG[5]` | **PIN_M5** | Display HEX6 - Segmento F | Saída | Unidade do Contador |
| `DISPLAY_7SEG[6]` | **PIN_M4** | Display HEX6 - Segmento G | Saída | Unidade do Contador |
| `DISPLAY_7SEG[7]` | **PIN_L3** | Display HEX7 - Segmento A | Saída | Dezena do Contador |
| `DISPLAY_7SEG[8]` | **PIN_L2** | Display HEX7 - Segmento B | Saída | Dezena do Contador |
| `DISPLAY_7SEG[9]` | **PIN_L9** | Display HEX7 - Segmento C | Saída | Dezena do Contador |
| `DISPLAY_7SEG[10]` | **PIN_L6** | Display HEX7 - Segmento D | Saída | Dezena do Contador |
| `DISPLAY_7SEG[11]` | **PIN_L7** | Display HEX7 - Segmento E | Saída | Dezena do Contador |
| `DISPLAY_7SEG[12]` | **PIN_P9** | Display HEX7 - Segmento F | Saída | Dezena do Contador |
| `DISPLAY_7SEG[13]` | **PIN_N9** | Display HEX7 - Segmento G | Saída | Dezena do Contador |
| `LEDS[0..9]` | *PIN_AE23 a PIN_Y18* | Bloco de 10 LEDs Vermelhos | Saída | Exibição em código binário direto |

---

## Funcionalidades do Sistema

* **Contador Decimal (0 a 99):** Exibição em tempo real utilizando dois displays de 7 segmentos (`HEX0` e `HEX1`).
* **Inversão de Sentido Dinâmica:** Controlado pela chave seletora `SW[0]` (1 = Contagem Crescente / Up, 0 = Contagem Decrescente / Down).
* **Reset Lógico de Alta Prioridade:** Controlado pela chave seletora `SW[1]`. Quando ativada, força o contador síncronamente para `00` e bloqueia novas contagens, mantendo o processador em execução.
* **Saída Binária Paralela:** O valor atual do contador é convertido e exibido em formato binário direto nos 10 `LEDS` vermelhos da placa.
* **Controle de Execução (Start/Stop):** Controlado pela chave seletora `SW[2]` alterna o estado do contador entre "Rodando" (Play) e "Pausado" (Pause).

---

## Arquitetura do Hardware (Qsys)

O processador Nios II foi configurado com os seguintes submódulos no Qsys:

* **Nios II/e:** Processador soft-core em sua versão econômica.
* **On-Chip Memory:** 20.000 bytes de memória RAM/ROM interna da FPGA.
* **JTAG UART:** Interface de comunicação para depuração e terminal.
* **PIO Chaves (Input - 2 bits):** Mapeado para monitorar as chaves `SW[0]`, `SW[1]` e `SW[3]`.
* **PIO Botão (Input - 1 bit):** Mapeado para monitorar o botão `KEY[O]`.
* **PIO LEDs (Output - 10 bits):** Barramento conectado aos LEDs vermelhos para exibição binária.
* **PIO Displays (Output - 14 bits):** Barramento unificado que controla os displays `HEX0` (bits 0 a 6) e `HEX1` (bits 7 a 13).

---


---

##  Como Executar o Projeto

1. **Hardware:** Abra o projeto no Quartus II, abra o *Programmer* e descarregue o arquivo compilado `Projeto_01.sof` na FPGA via cabo USB-Blaster.
2. **Atenção** Tambem podemos utilizar o arquivo Projeto_01.qar para abrir o projeto em outro computador.
3. **Software:** Abra o *Nios II Software Build Tools for Eclipse*, importe a pasta do projeto contina em `software/contador_0_99`, gere o pacote BSP (*Generate BSP*) e execute o projeto utilizando a opção *Run As -> Nios II Hardware*.

```
