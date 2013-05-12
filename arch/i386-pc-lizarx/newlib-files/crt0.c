extern int main(int, char**); //int argc, char **argv, char **environ);
//void uprintf(char* fmt, ...);
//void uprintfstrcol_scr(char font, char* fmt);
//extern void uprintf(char* fmt, ...);
void _start()
{
	int argc=0; 
	char** argv=(void*)0x0;
	//asm volatile()
	//asm volatile()
	start3(0,(char**)0x0);
}
int start3(int argc, char** argv){
	unsigned long *origin, *target;
	int i;

	for(i = 0; i < argc; i++){
		origin = ((unsigned long*)argv) + ((i * 2) + 1);
		target = ((unsigned long*)argv) + i;
		*target = *origin;
	}
	return main(argc, argv);
}
