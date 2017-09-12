extern free
extern malloc
;global obdd_node_destroy

;global obdd_destroy
global str_len
global str_copy
global str_cmp
%define NULL 0

%define obdd_size 16
%define obdd_manager_offset 0
%define obdd_root_offset 8

%define obdd_node_size 28
%define obdd_node_varId_offset 0
%define obdd_node_nodeId_offset 4
%define obdd_node_ref_count_offset 8
%define obdd_node_high_offset 12
%define obdd_node_low_offset 20

%define obdd_mgr_vars_dict_offset 28
extern obdd_node_destroy ; hay que borrarlo dsp
extern dictionary_add_entry
extern obdd_mgr_get_next_node_ID
section .text


global obdd_mgr_mk_node
obdd_mgr_mk_node:
    push rbp ;A
    mov rbp, rsp
    push r15 ;D
    push r14 ;A
    push r13 ;D
    push r12 ;A
    push r11 ;D
    sub rsp, 8 ;A

    mov r15, rdi ;mgr
    mov r14, rsi ;var
    mov r13, rdx ;hidh_obdd
    mov r12, rcx ;low_obdd
    

    ;ESTABA USANDO R11 COMO REGISTRO DE LA
    ;CONVENCIO C. ESTA MAL.
    ;LUEGO MALLOC ME CAMBIABA EL VALOR 
    ;SOLUCION MOVI MALLOC AL PRINCIPIOO
    ;PODRIA HABER UTILIZADO RBX EN VEZ DE R11.    
    mov rdi, obdd_node_size
    call malloc
    push rax
    sub rsp, 8

    mov rdi, [r15+obdd_mgr_vars_dict_offset]
    mov rsi, r14
    call dictionary_add_entry
    xor r11, r11
    mov r11d, eax ;varID

    mov rdi, r15
    call obdd_mgr_get_next_node_ID
    xor r14, r14
    mov r14d, eax; nodeId
    
    add rsp, 8
    pop rax
    
    mov [rax + obdd_node_varId_offset], r11d
    mov [rax + obdd_node_nodeId_offset], r14d
    mov [rax + obdd_node_high_offset], r13
    mov [rax + obdd_node_low_offset], r12
    mov dword [rax + obdd_node_ref_count_offset], 0
    mov r15, rax    
    cmp r13, NULL
    jne .refHigh
    .next:
    cmp r12, NULL
    jne .refLow
    jmp .fin

    .refHigh:
        add dword [r13+obdd_node_ref_count_offset], 1
        jmp .next


    .refLow:
        add dword [r12+obdd_node_ref_count_offset], 1
        jmp .fin

    .fin:
        mov rax, r15
        add rsp, 8
        pop r11
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret

;obdd_node_destroy:
;ret

global obdd_create
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

global obdd_destroy
obdd_destroy:
    push rbp
    mov rbp, rsp
    push r14
    sub rsp, 8
    cmp qword [rdi+obdd_root_offset], NULL
    je .borrarManager
    mov r14, rdi
    mov rdi, [rdi+obdd_root_offset]
    call obdd_node_destroy
    mov rdi, r14
    mov qword [rdi+obdd_root_offset], NULL
    .borrarManager:
        mov qword [rdi+obdd_manager_offset], NULL
        call free
    .fin:
        add rsp, 8
        pop r14
        pop rbp
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
        cmp dl, 0
        je .seguir
        cmp cl, 0
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
