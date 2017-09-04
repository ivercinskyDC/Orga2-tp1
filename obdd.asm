extern free
extern malloc

global obdd_mgr_mk_node
obdd_mgr_mk_node:
ret

global obdd_node_destroy
obdd_node_destroy:
ret

global obdd_create
obdd_create:
ret

global obdd_destroy
obdd_destroy:
ret

global obdd_node_apply
obdd_node_apply:
ret

global is_tautology
is_tautology:
ret

global is_sat
is_sat:
ret

global str_len
; uint32_t str_len(char *a);
; en rdi tenemos el ptr al string
str_len:
    push rbp
    mov rbp, rsp
    xor rax, rax
    .ciclo:
        cmp byte [rsi], 10 ; comparamos con el caracter de fin 
        je .fin ; si era el fin salimos
        inc eax ; sino incrementamos eax
        lea rsi, [rsi + 1] ; movemos el ptr a la siguiente posicion
        jmp .ciclo
    .fin:
    pop rbp
ret

global str_copy
str_copy:
ret

global str_cmp
str_cmp:
    
ret
