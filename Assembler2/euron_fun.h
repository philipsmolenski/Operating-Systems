#ifndef EURON_FUN_H
#define EURON_FUN_H

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <inttypes.h>

void swap();

int test_reg (int reg, uint64_t n, char const *prog);

typedef struct {
	uint64_t n;
	char const *prog;
} Thread_args;

uint64_t get_value(uint64_t n) {
  assert(n < THREAD_NUM);
  swap();
  return n + 1;
}

void put_value(uint64_t n, uint64_t v) {
  assert(n < THREAD_NUM);
  swap();
  assert(v == n + 4);
}

uint64_t euron(uint64_t n, char const *prog);


void *call_euron(void* arg) {
	Thread_args *args = (Thread_args*)arg;
	for (int i = 1; i < 7; i++) {
		if (test_reg(i, args->n, args->prog))
			printf("ERROR thread %" PRIu64 " reg_num %d\n", args->n, i);
		else
			printf("OK thread %" PRIu64 " reg_num %d\n", args->n, i);

	}
	printf("Thread %" PRIu64 ", result %" PRIu64 "\n", args->n, euron(args->n, args->prog));
	return NULL;	
}


#endif
