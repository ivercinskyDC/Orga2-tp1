#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include "obdd.h"

char *formulasFile  =  "formulas.txt";

//TODO: implementar
void run_tests(){
	obdd_mgr* new_mgr	= obdd_mgr_create();

	obdd* x1_obdd		= obdd_mgr_var(new_mgr, "x1");
	obdd* x2_obdd		= obdd_mgr_var(new_mgr, "x2");
	
	obdd* x1_or_x2_obdd	= obdd_apply_or(x1_obdd, x2_obdd);
	obdd_print(x1_or_x2_obdd);
	
	obdd* x1_and_x2_obdd = obdd_apply_and(x1_obdd, x2_obdd);
	obdd_print(x1_and_x2_obdd);

	obdd* not_x1_obdd		= obdd_apply_not(x1_obdd);
	obdd* x1_and_not_x1_obdd = obdd_apply_and(x1_obdd, not_x1_obdd);
	obdd_print(x1_and_not_x1_obdd);

	obdd* not_x2_obdd		= obdd_apply_not(x2_obdd);
	obdd* not_x1_or_not_x2 = obdd_apply_or(not_x1_obdd, not_x2_obdd);
	obdd* not_x1_or_not_x2_or_x1 = obdd_apply_or(not_x1_or_not_x2, x1_obdd);

	obdd* exists_x2_such = obdd_exists(x1_and_not_x1_obdd, "x2");
	obdd_print(exists_x2_such);

	

}

int main (void){
	run_tests();
	int save_out = dup(1);
	remove(formulasFile);
	int pFile = open(formulasFile, O_RDWR|O_CREAT|O_APPEND, 0600);
	if (-1 == dup2(pFile, 1)) { perror("cannot redirect stdout"); return 255; }
	run_tests();
	fflush(stdout);
	close( pFile );
	dup2(save_out, 1);
	return 0;    
}


