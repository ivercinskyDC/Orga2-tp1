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
extern free
extern malloc
extern dictionary_add_entry
extern dictionary_key_for_value
extern obdd_mgr_get_next_node_ID
extern is_constant
extern is_true


section .data
    true_var: db '1',0
    false_var: db '0',0


global obdd_mgr_mk_node
global obdd_node_destroy
global obdd_create
global obdd_destroy
global obdd_node_apply

section .text



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


obdd_node_destroy:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12
    push rbx
    sub rsp, 8

    mov r15, rdi

    cmp dword [r15+obdd_node_ref_count_offset], 0
    jne .fin

    cmp qword [r15+obdd_node_high_offset], NULL
    jne .borrarHigh
    .dspDeHigh:
    cmp qword [r15+obdd_node_low_offset], NULL
    jne .borrarLow
    
    jmp .seguir

    .borrarHigh:
        mov rdi, [r15+obdd_node_high_offset]
        mov qword [r15+obdd_node_high_offset], NULL
        dec dword [rdi+obdd_node_ref_count_offset]
        call obdd_node_destroy
        jmp .dspDeHigh
        
    .borrarLow:
        mov rdi, [r15+obdd_node_low_offset]
        mov qword [r15+obdd_node_low_offset], NULL
        dec dword [rdi+obdd_node_ref_count_offset]
        call obdd_node_destroy

    .seguir:
        mov dword [r15+obdd_node_varId_offset], 0
        mov dword [r15+obdd_node_nodeId_offset], 0
        mov rdi, r15
        call free

    .fin:
        add rsp, 8
        pop rbx
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret

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

;rdi funcion to aply
;rsi mgr
;rdx left_node
;rcx right_node


obdd_node_apply:
    push rbp ;A
    mov rbp, rsp
    push r15 ;D
    push r14 ;A
    push r13 ;D
    push r12 ;A
    push rbx ;D
    sub rsp, 8 ;A

    mov r15, rdi ;apply_fkt
    mov r14, rsi ;mgr
    mov r13, rdx ;left_node
    mov r12, rcx ;right_node

    mov rdi, [r14+obdd_mgr_vars_dict_offset] ; mgr->vars_dict
    mov esi, [r13+obdd_node_varId_offset] ; left->var_ID
    call dictionary_key_for_value 
    push rax ;left_var ;D
    sub rsp, 8 ;A
    mov rdi, [r14+obdd_mgr_vars_dict_offset] ; mgr->vars_dict
    mov esi, [r12+obdd_node_varId_offset] ;right->var_ID
    call dictionary_key_for_value
    push rax ;right_var ;D
    sub rsp, 8 ;A

    mov rdi,r14 ;mgr
    mov rsi,r13 ;left
    call is_constant
    push ax; is_left_constant ;D
    sub rsp, 8 ;A
    mov rdi,r14  ;mgr
    mov rsi,r12 ;right
    call is_constant 
    push ax; is_right_constant ;D
    xor r8,r8
    xor r9,r9
    pop r8w; is_right_constant ;A
    add rsp, 8
    pop r9w; is_left_constant
    add rsp, 8
    ;pop r10; right_var
    ;add rsp, 8
    ;pop r11; left_var

    
    cmp r9w, 0
    je .is_left_constant
    cmp r8w, 0
    je .is_right_constant

    mov r8d, [r13+obdd_node_varId_offset] ;left_node_var_id
    mov r9d, [r12+obdd_node_varId_offset] ;right_node_var_id
    cmp r8d, r9d
    je .left_equals_right
    jg .is_right_constantd
    jl .is_left_constantd
    jmp .fin

    .both_left_right_constant:
        mov rdi, r14
        mov rsi, r13
        call is_true
        push rax
        sub rsp, 8
        mov rdi, r14
        mov rsi, r12
        call is_true
        add rsp, 8 
        pop rdi
        mov rsi, rax
        call r15

        cmp rax, 0
        je .wasTrue
        mov rdi, r14
        mov rsi, false_var
        mov rdx, NULL
        mov rcx, NULL
        call obdd_mgr_mk_node
        jmp .fin

        .wasTrue:
            mov rdi, r14
            mov rsi, true_var
            mov rdx, NULL
            mov rcx, NULL
            call obdd_mgr_mk_node

        jmp .fin
    .is_left_constant:
        cmp r8, 0
        je .both_left_right_constant
    .is_left_constantd:
        mov rdi, r15
        mov rsi, r14
        mov rdx, r13
        mov rcx, [r12+obdd_node_high_offset]
        call obdd_node_apply
        push rax
        sub rsp, 8
        mov rdi, r15
        mov rsi, r14
        mov rdx, r13
        mov rcx, [r12+obdd_node_low_offset]
        call obdd_node_apply
        mov rdi, r14
        add rsp, 8
        pop rdx
        mov rcx, rax
        pop rdi
        add rsp,8
        mov rsi, r10
        call obdd_mgr_mk_node
        jmp .fin
    .is_right_constant:
        cmp r9, 0
        je .both_left_right_constant
    .is_right_constantd:
        mov rdi, r15
        mov rsi, r14
        mov rdx, [r13+obdd_node_high_offset]
        mov rcx, r12
        call obdd_node_apply
        push rax
        sub rsp, 8
        mov rdi, r15
        mov rsi, r14
        mov rdx, [r13+obdd_node_low_offset]
        mov rcx, r12
        call obdd_node_apply
        mov rdi, r14
        add rsp, 8
        pop rdx
        mov rcx, rax
        pop r10
        add rsp,8
        pop r11
        mov rsi, r11
        call obdd_mgr_mk_node
        jmp .fin
    .left_equals_right:
        mov rdi, r15
        mov rsi, r14
        mov rdx, [r13+obdd_node_high_offset]
        mov rcx, [r12+obdd_node_high_offset]
        call obdd_node_apply
        push rax
        sub rsp, 8
        mov rdi, r15
        mov rsi, r14
        mov rdx, [r13+obdd_node_low_offset]
        mov rcx, [r13+obdd_node_low_offset]
        call obdd_node_apply
        mov rdi, r14
        add rsp,8
        pop rdx
        mov rcx, rax
        pop r10
        add rsp,8
        pop r11
        mov rsi, r11
        call obdd_mgr_mk_node
        jmp .fin
    
    .fin:
        add rsp, 8
        pop rbx
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret


global is_tautology
is_tautology:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12
    push rbx
    sub rsp, 8
    mov r15, rdi ;backup
    mov r14, rsi ;backup
    call is_constant
    cmp rax, 0
    jne .seguir
    mov rdi, r15
    mov rsi, [r14+obdd_node_high_offset]
    call is_tautology
    mov r13, rax
    mov rdi, r15
    mov rsi, [r14+obdd_node_low_offset]
    call is_tautology
    add rax, r13
    jmp .fin

    .seguir:
        mov rdi, r15
        mov rsi, r14
        call is_true
    .fin:
        add rsp, 8
        pop rbx
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret

global is_sat
is_sat:
    push rbp
    mov rbp, rsp
    push r15
    push r14
    push r13
    push r12
    push rbx
    sub rsp, 8
    mov r15, rdi ;backup
    mov r14, rsi ;backup
    call is_constant
    cmp rax, 0
    jne .seguir
    mov rdi, r15
    mov rsi, [r14+obdd_node_high_offset]
    call is_sat
    mov r13, rax
    mov rdi, r15
    mov rsi, [r14+obdd_node_low_offset]
    call is_sat
    or rax, r13
    jmp .fin

    .seguir:
        mov rdi, r15
        mov rsi, r14
        call is_true
    .fin:
        add rsp, 8
        pop rbx
        pop r12
        pop r13
        pop r14
        pop r15
        pop rbp
        ret


; uint32_t str_len(char *a);
; en rdi tenemos el ptr al string
global str_len
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

global str_copy
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

global str_cmp
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
