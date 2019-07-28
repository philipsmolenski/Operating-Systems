#include <minix/drivers.h>
#include <minix/chardriver.h>
#include <stdio.h>
#include <stdlib.h>
#include <minix/ds.h>

#define BUFFSIZE 1024
#define MODULO 65521

static ssize_t adler_read(devminor_t minor, u64_t position, endpoint_t endpt,
    cp_grant_id_t grant, size_t size, int flags, cdev_id_t id);
static ssize_t adler_write(devminor_t minor, u64_t position, endpoint_t endpt,
	cp_grant_id_t grant, size_t size, int flags, cdev_id_t id);

static void sef_local_startup(void);
static int sef_cb_init(int type, sef_init_info_t *info);
static int sef_cb_lu_state_save(int);
static int lu_state_restore(void);

static struct chardriver adler_tab = {
    .cdr_read	= adler_read,
    .cdr_write  = adler_write,
};

static u32_t A, B;

void calculate_addler (u32_t *a, u32_t *b, size_t len, unsigned char buff[BUFFSIZE]) {
	for (size_t i = 0; i < len; i++) {
		*a += buff[i];
		*b += *a;
		*a %= MODULO;
		*b %= MODULO; 
	}
}

int main(void) {
    sef_local_startup();
    chardriver_task(&adler_tab);
    return OK;
}

static void sef_local_startup() {
    sef_setcb_init_fresh(sef_cb_init);
    sef_setcb_init_lu(sef_cb_init);
    sef_setcb_init_restart(sef_cb_init);

    sef_setcb_lu_prepare(sef_cb_lu_prepare_always_ready);
    sef_setcb_lu_state_isvalid(sef_cb_lu_state_isvalid_standard);
    sef_setcb_lu_state_save(sef_cb_lu_state_save);
    sef_startup();
}

static int sef_cb_lu_state_save(int UNUSED(state)) {
/* Save the state. */
    ds_publish_u32("A", A, DSF_OVERWRITE);
    ds_publish_u32("B", B, DSF_OVERWRITE);

    return OK;
}

static int lu_state_restore() {
/* Restore the state. */
    u32_t value_a;
    u32_t value_b;

    ds_retrieve_u32("A", &A);
    ds_retrieve_u32("B", &B);
    ds_delete_u32("A");
    ds_delete_u32("B");

    return OK;
}

static int sef_cb_init(int type, sef_init_info_t *UNUSED(info)) {
    int do_announce_driver = TRUE;
    A = 1;
    B = 0;

    if (type == SEF_INIT_LU) {
    	lu_state_restore();
    	do_announce_driver = FALSE;
    }

    if (do_announce_driver) {
        chardriver_announce();
    }

    return OK;
}

static ssize_t adler_read(devminor_t UNUSED(minor), u64_t position, endpoint_t endpt,
	cp_grant_id_t grant, size_t size, int UNUSED(flags), cdev_id_t UNUSED(id)) {

	if (position != 0 || size < 8)
		return EINVAL;

	int r;
	char buff[8];
	u32_t sum = (B << 16) | A;
	A = 1;
	B = 0;

	if (size > 8)
		size = 8;

	for (int i = 7; i >= 0; i--) {
		int res = sum % 16;
		sum = (sum >> 4);

		if (res < 10)
			buff[i] = '0' + res;

		else
			buff[i] = 'a' + res - 10;
	}

	r = sys_safecopyto(endpt, grant, 0, (vir_bytes)buff, size);

	if (r != OK)
		return r;

	return size;
}

static ssize_t adler_write(devminor_t UNUSED(minor), u64_t UNUSED(position), endpoint_t endpt,
    cp_grant_id_t grant, size_t size, int UNUSED(flags), cdev_id_t UNUSED(id)) {

	size_t offset, chunk;
	int r;
	unsigned char buf[BUFFSIZE];

	for (offset = 0; offset < size; offset += chunk) {
		chunk = MIN(size - offset, BUFFSIZE);
		r = sys_safecopyfrom(endpt, grant, offset, (vir_bytes)buf, chunk);
		
		if (r != OK) 
			return r;

		calculate_addler(&A, &B, chunk, buf);
	}

	return size;
}
