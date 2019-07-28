#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include "err.h"
#include "euron_fun.h"

int main(int argc, char* args[]) {
	if (argc != THREAD_NUM + 1)
		fatal("invalid number of arguments");

	pthread_t tid[THREAD_NUM];
	Thread_args argss[THREAD_NUM] ;
	for (int i = 0; i < THREAD_NUM; i++) {
		argss[i].n = i;
		argss[i].prog = args[i + 1];
	}


	for (int i = 1; i < THREAD_NUM; i++) {
		if (pthread_create(&tid[i], NULL, &call_euron, (void*)&(argss[i])))
      syserr("Function create_thread failed for thread %d.", i);
	}

	call_euron((void*)&(argss[0]));

	 for (int i = 1; i < THREAD_NUM; ++i)
    if (pthread_join(tid[i], NULL))
      syserr("Function join_thread failed for thread %d.", i);
}