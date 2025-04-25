extern terminate
extern printStr
extern printStrLn
extern readImageFile
extern writeImageFile

;************************************************************************************************
section .rodata
;************************************************************************************************
msg_error1: 	   db "Numero errado de argumentos!", 0
msg_error2:	    db "Modo nao reconhecido! So sao permitidos C ou M.", 0
msg_error3:	    db "Metodo nao implementado!", 0
msg_success1: 	 db "Imagens lidas com sucesso. Boa!", 0
msg_success2:	  db "Imagem modificada com sucesso, gerando novo ficheiro...", 0
msg_success3:	  db "Nova imagem criada com sucesso!", 0

;************************************************************************************************
section .bss
;************************************************************************************************
option			          resb 1
name_left_image		  resb 255
name_right_image	  resb 255
name_write		       resb 255

bytes_left_image	  resb 1048576
size_left_image		  resd 1
offset_left_image	 resd 1
bytes_read_left		  resq 1

bytes_right_image	 resb 1048576
size_right_image	  resd 1
offset_right_image	resd 1
bytes_read_right	  resq 1

;************************************************************************************************
section .data
;************************************************************************************************
blueK               	dd 0.144
greenK              	dd 0.587
redK                	dd 0.299

;************************************************************************************************
section .text
;************************************************************************************************
global _start:
_start:
 ;1) Ler argumentos
 ;1.1) Verificar numero de argumentos
 mov rax, [rsp]				          ;obter o numero de argumentos passados
 cmp rax, 5				              ;verificar se tem 4 argumentos
 mov rdi, msg_error1			      ;colocar a mensagem de erro
 jne error				               ;imprimir erro caso for diferente
 
 ;1.2) Guardar o 1 argumento
 mov rax, [rsp + 16]			      ;obter o endereco do 1 argumento
 mov bl, [rax]				           ;copiar o conteudo para bl
 mov [option], bl			         ;copiar o caratere para o buffer

 ;1.3) Guardar o 2 argumento
 mov rdi, [rsp + 24]			      ;colocar o endereco do 2 argumento
 mov rsi, name_left_image		  ;colocar o endereco do buffer
 call copyStr				            ;guardar o nome no buffer

 ;1.4) Guardar o 3 argumento
 mov rdi, [rsp + 32]			      ;colocar o endereco do 3 argumento
 mov rsi, name_right_image	  ;colocar o endereco do buffer
 call copyStr				            ;guardar o nome no buffer

 ;1.5) Guardar o 4 argumento
 mov rdi, [rsp + 40]			      ;colocar o endereco do 4 argumento
 mov rsi, name_write			      ;colocar o endereco do buffer
 call copyStr				            ;guardar o nome no buffer
 
 ;1.6) Guardar imagens
 mov rdi, name_left_image		  ;colocar o nome da imagem da esquerda
 mov rsi, bytes_left_image		 ;colocar o endereco do buffer
 call readImageFile
 mov [bytes_read_left], rax		;guardar a quantidade de bytes lidos

 mov rdi, name_right_image		 ;colocar o nome da imagem da direita
 mov rsi, bytes_right_image		;colocar o endereco do buffer
 call readImageFile
 mov [bytes_read_right], rax	;guardar a quantidade de bytes lidos

 ;++++++++++++++++++++++++++++++
 mov rdi, msg_success1
 call printStrLn
 ;++++++++++++++++++++++++++++++

 ;2) Ler tamanho e offset
 mov eax, [bytes_left_image+2] 		;colocar o endereco onde comeca o size
 mov [size_left_image], eax		    ;guardar o tamanho da imagem
 mov eax, [bytes_left_image+10]		;colocar o endereco do offset
 mov [offset_left_image], eax		  ;guardar o offset da imagem

 mov eax, [bytes_right_image+2]		;colocar o endereco do size
 mov [size_right_image], eax		   ;guardar o tamanho da imagem
 mov eax, [bytes_right_image+10]	;colcoar o endereco do offset
 mov [offset_right_image], eax		 ;guardar o offset da imagem
 
 ;3) Verificar modo
 mov al, [option]			             ;copiar a opcao
 cmp al, 'C'				                 ;comparar com C
 je color				                    ;usar algorirmo COLOR
 cmp al, 'M'				                 ;comparar com M
 je mono				                     ;usar algoritmo MONO
 mov rdi, msg_error2		           ;colocar a mensagem de erro
 jmp error

 ;4) Color
 ;==============================================
 ; ALTERACOES SERAO FEITAS NA IMG DA DIREITA
 ; r10 	imagem esq 	(+4)
 ; r11 	imagem dir 	(+4)
 ; rcx  tamanho 	(referencia)
 ; rdx  contador
 ; rax  rascunho
 ;==============================================
color:
 ;4.1) Preparar registos
 mov r10, bytes_left_image		    ;copiar o inicio da imagem da esquerda
 xor rbx, rbx				               ;limpar registo
 mov ebx, [offset_left_image]		 ;copiar o offset
 add r10, rbx				               ;adicionar o offset
 add r10, 2				                 ;inicio do Red

 mov r11, bytes_right_image		   ;copiar o inicio da imagem da direita
 xor rbx, rbx				               ;limpar registo
 mov ebx, [offset_right_image]		;copiar o offset
 add r11, rbx			    	           ;adicionar o offset
 add r11, 2			                  ;inicio do Red

 xor rcx, rcx				               ;limpar o registo
 mov ecx, [size_right_image]		  ;copiar o tamanho

 xor rdx, rdx			                ;limpar o registo
 mov edx, [offset_right_image]		;colocar a posicao inicial
 add edx, 2				                 ;colocar a posicao do Red
 
 ;4.2) Fazer ciclo
colorCycle:
 mov al, [r10]				              ;copiar o valor de Red da esquerda para al
 mov [r11], al				              ;copiar o valor Red para img da direita
 add r10, 4				                 ;avancar para proximo pixel da esquerda
 add r11, 4				                 ;avancar para proximo pixel da direita
 add rdx, 4				                 ;aumentar o contador
 cmp rcx, rdx				               ;comparar se ja acabou a imagem
 jle write				                  ;se ja terminou salta para escrever o ficheiro
 jmp colorCycle				             ;continuar o ciclo
 

 ;==============================================
 ; ALTERACOES SERAO FEITAS NA IMG DA DIREITA
 ; r10 	imagem esq 	(+4)
 ; r11 	imagem dir  (+4)
 ; rcx  tamanho 	(referencia)
 ; rdi  contador
 ; rbx	acumulador temporario
 ; r8   armazenamento temporario(vermelho)
 ; r9   armazenamento temporario(azul e verde)
 ; xmm0 blueK		(constante)
 ; xmm1 valor azul
 ; xmm2 greenK		(constante)
 ; xmm3 valor verde
 ; xmm4 redK		(constante)
 ; xmm5 valor vermelho
 ;==============================================
 ;5) Mono
mono:
 ;5.1) Preparar registos
 mov r10, bytes_left_image		    ;copiar o inicio da imagem da esquerda
 xor rbx, rbx				               ;limpar o registo
 mov ebx, [offset_left_image]   ;copiar o offset para ebx
 add r10, rbx                   ;adicionar o offset
 mov r11, bytes_right_image		   ;copiar o inicio da imagem da direita
 xor rbx, rbx			                ;limpar registo
 mov ebx, [offset_right_image]	 ;copiar o offset para ebx
 add r11, rbx			                ;adicionar o offset
 
 xor rcx, rcx                   ;limpar o registo
 mov ecx, [size_right_image]		  ;colocar o tamanho
 
 xor rdi, rdi                   ;limpar o registo
 mov edi, [offset_right_image]		;colocar o valor da posicao atual
 
 ;5.2) Fazer ciclo
monoCycle:
 ;5.2.1) Calcular o valor do vermelho
 xor r8, r8                 		  ;limpar o registo
 xor rbx, rbx				               ;limpar o registo
 mov bl, [r10]               		 ;copiar o azul da esquerda para bl
 movss xmm0, dword [blueK]      ;copiar a constante para FPU
 cvtsi2ss xmm1, ebx          		 ;copiar o azul para FPU
 mulss xmm1, xmm0			            ;multiplicar o valor pela constante
 
 movss xmm2, dword [greenK]		   ;copiar a constante para FPU
 mov bl, [r10+1]            		  ;copiar o verde da esquerda para bl
 cvtsi2ss xmm3, ebx         		  ;copiar para FPU
 mulss xmm3, xmm2           		  ;multiplicar o valor pela constante
 
 movss xmm4, dword [redK]		     ;copiar a constante para FPU
 mov bl, [r10+2]			             ;copiar o verde da esquerda para bl
 cvtsi2ss xmm5, ebx			          ;copiar para FPU
 mulss xmm5, xmm4			            ;multiplicar o valor pela constante
 
 addss xmm1, xmm3			            ;adicionar o valor do verde ao azul
 addss xmm1, xmm5			            ;adicionar o valor do vermelho
 cvtss2si ebx, xmm1			          ;converter para inteiro e copiar para ebx
 mov r8b, bl                		  ;copiar para r8b
 
 ;5.2.2) Calcular o valor do azul e verde
 xor r9, r9				                 ;limpar o registo
 xor rbx, rbx				               ;limpar o registo
 mov bl, [r11]              		  ;copiar o azul da direita para bl
 cvtsi2ss xmm1, ebx			          ;copiar o azul para FPU
 mulss xmm1, xmm0			            ;multiplicar o valor pela constante
 
 mov bl, [r11+1]			             ;copiar o verde da direita para bl
 cvtsi2ss xmm3, ebx			          ;copiar o azul para FPU
 mulss xmm3, xmm2			            ;multiplicar o valor pela constante
 
 mov bl, [r11+2]            		  ;copiar o vermelho da direita para bl
 cvtsi2ss xmm5, ebx			          ;copiar o azul para FPU
 mulss xmm5, xmm4			            ;multiplicar o valor pela constante
 
 addss xmm1, xmm3			            ;adicionar o valor do verde ao azul
 addss xmm1, xmm5			            ;adicionar o valor do vermelho
 cvtss2si ebx, xmm1			          ;converter para inteiro e copiar para ebx
 mov r9b, bl				                ;copiar para r8b

 
 mov [r11], r9b         		      ;definir cor blue
 mov [r11+1], r9b       		      ;definir cor green
 mov [r11+2], r8b       		      ;definir cor red
 mov byte [r11+3], 255
 
 add r10, 4				                 ;saltar para proximo pixel da esquerda
 add r11, 4				                 ;saltar para proximo pixel da direita
 add rdi, 4				                 ;aumentar o contador
 cmp rcx, rdi				               ;comparar com o tamanho da imagem
 jle write				                  ;se ja terminou
 jmp monoCycle

 
 ;6) Escrever ficheiro
write:

 ;++++++++++++++++++++++++++++++
 mov rdi, msg_success2
 call printStrLn
 ;++++++++++++++++++++++++++++++

 mov rdi, name_write			         ;copiar o nome do ficheiro de saida
 mov rsi, bytes_right_image		   ;copiar o endereco do buffer
 mov rdx, [bytes_read_right]		  ;copiar a quantidade de bytes a escrever
 call writeImageFile

 ;++++++++++++++++++++++++++++++
 mov rdi, msg_success3
 call printStrLn
 ;++++++++++++++++++++++++++++++

 ;7) Terminar 
 call terminate

;------------------------------------------------------------------------------------------------
; convertToNum
; Objetivo: Receber um numero e converter para um string
; Entrada:
;    RDI - Numero a ser convertido
;    RSI - Endereco buffer para escrever o numero convertido
; Saida:
;    RAX - Quantidade de digitos convertidos
; Destroi: RAX,
;------------------------------------------------------------------------------------------------
printNumber:
 ;++++++++++++++++++++++++++++++
 mov rdi, msg_error3
 call error
 ;++++++++++++++++++++++++++++++



;------------------------------------------------------------------------------------------------
; copyStr
; Objectivo: Copiar um string de um endereco para um buffer
; Entrada:
;    RDI - Endereco de memoria do string a ser copiado
;    RSI - Endereco de memoria do buffer para onde o string sera guardado
; Saida:
;    RAX - Numero de bytes copiados
; Destroi: RAX(rascunho), RCX(contador)
;------------------------------------------------------------------------------------------------
copyStr:
 mov rcx, 0				        ;colocar o contador a 0
copyCicle:
 mov al, [rdi + rcx]			;copiar um caratere para al
 mov [rsi + rcx], al			;copiar o caratere para o buffer
 inc rcx				        ;incrementar o contador(proximo char)
 cmp al, 0				        ;compara o caratere copiado
 jne copyCicle				    ;repete o ciclo se for diferente
 dec rcx				        ;decrementa o contador
 mov rax, rcx				    ;copia o resultado para rax
 ret
 

;------------------------------------------------------------------------------------------------
error:
 call printStrLn			;imprimir a mensagem
 call terminate				;terminar o programa
