extern free
extern malloc

%define obdd_size 16
%define obdd_manager_offset 0
%define obdd_root_offset 8


global obdd_mgr_mk_node
obdd_mgr_mk_node:
ret

global obdd_node_destroy
obdd_node_destroy:
ret

/** implementar en ASM
obdd* obdd_create(obdd_mgr* mgr, obdd_node* root){
	obdd* new_obdd		= malloc(sizeof(obdd));
	new_obdd->mgr		= mgr;
	new_obdd->root_obdd	= root;
	return new_obdd;
}
**/
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
