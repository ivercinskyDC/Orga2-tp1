extern free
extern malloc
global obdd_node_destroy
global obdd_create
global obdd_destroy
global str_len
global str_copy
global str_cmp
%define obdd_size 16
%define obdd_manager_offset 0
%define obdd_root_offset 8

section .text


;global obdd_mgr_mk_node
;obdd_mgr_mk_node:
;ret

obdd_node_destroy:
ret

;/** implementar en ASM
;obdd* obdd_create(obdd_mgr* mgr, obdd_node* root){
;	obdd* new_obdd		= malloc(sizeof(obdd));
;	new_obdd->mgr		= mgr;
;	new_obdd->root_obdd	= root;
;	return new_obdd;
;}
;**/
obdd_create:
    push rbp ;A
    mov rbp, rsp
    push r15 ;D
    push r14 ;A
    mov r15, rdi
    mov r14, rsi
    mov rdi, obdd_size
    call malloc
    mov [rax+obdd_manager_offset], r15
    mov [rax+obdd_root_offset], r14
    pop r14
    pop r15
    pop rbp
ret

obdd_destroy:
ret

;global obdd_node_apply
;obdd_node_apply:
;ret

;global is_tautology
;is_tautology:
;ret

;global is_sat
;is_sat:
;ret


; uint32_t str_len(char *a);
; en rdi tenemos el ptr al string
str_len:
    ;en rdi me llega el ptr al string
    ;tengo que loopear hasta llegar al cero
    ;devuelvo el contador del loop
    mov rdx, rdi ;str = parametro de entrada rdi
    xor rcx, rcx
    xor rax, rax ;rax = 0
    ;accedo al primer char
    mov cl, [rdx+rax] ; == cl = str[rax]
    ciclo:
        cmp byte cl, 0 ; cl == 0
        je finLen ; cl != 0
        inc rax ; rax++
        mov cl, [rdx + rax] ; cl = str[rax]
        jmp ciclo 
    finLen:
        inc rax ; considero el 0 del fin del str como un elemento mas. (Para el str_copy)
        ret

ret

;en rdi recibo el string a copiar
;pasos
; cal to str_len
; malloc de rax


str_copy:
    ;en rdi me llega el ptr a copiar
    push rbp ;A
    mov rbp, rsp
    push r14 ;D
    sub rsp, 8; A
    
    mov r14, rdi ; me guardo el ptr

    call str_len ;calculo su longitud
    mov rdi, rax
    call malloc ;reservo esa cantidad de memoria
    xor rdx, rdx ;variable temporal
    xor rcx, rcx ;indice para recorrer el string
    mov dl, [r14+rcx] ;guardo el primer char
    cicloCopy:
        cmp byte dl, 0 ;era fin de string?
        je finCopy ;si, entonces termina.
        mov [rax+rcx],dl ;no, entonces copialo al nuevo string
        inc rcx ;incrementa el indice
        mov dl,[r14+rcx] ;recuperar el nuevo char a copiar
        jmp cicloCopy ;loop
    finCopy:
        mov [rax+rcx],dl;guardo el 0 para marcar el fin del str
        add rsp, 8
        pop r14
        pop rbp
        ret


str_cmp:
    push rbp;
    mov rbp, rsp

    push r15
    push r14
    push r13
    push r12

    mov r15, rdi
    mov r14, rsi

    call str_len ; rax = str_len(rdi) 
    mov r13, rax

    mov rdi, r14
    call str_len
    mov r12, rax

    mov rdi, r15
    mov rsi, r14


    .ciclo:
        mov dl, [rdi]
        mov cl, [rsi]
        cmp dl, cl
        jne .seguir
        cmp dl, r13b
        je .seguir
        cmp cl, r12b
        je .seguir
        inc rdi
        inc rsi
        jmp .ciclo

    .seguir:
        cmp dl, cl
        je .devuelveCero
        jl .devuelvePositivo
        jmp .devuelveNegativo

    .devuelveCero:
        mov rax, 0
        jmp .terminar
    .devuelvePositivo:
        mov rax,1
        jmp .terminar
    .devuelveNegativo:
        mov rax, -1
        jmp .terminar
    .terminar:
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp 

ret
