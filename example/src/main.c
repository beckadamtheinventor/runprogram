
#include <stdint.h>
#include <tice.h>
#include "runprogram.h"


/* Runs a program and returns to itself */
int main(void){
	uint8_t key;
	os_PutStrLine("Press Clear to exit");
	do {
		while (!(key=os_GetCSC()));
		if (key != sk_Clear){
			run_program("DEMO", 6, "DEMO", 6);
		}
	} while (key != sk_Clear);
	return 0;
}

