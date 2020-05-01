#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#include "iio_utils.h"

#define MAX_BUF 20
#define CHANNEL 4
#define DEV_NAME "stmpe-adc"	//driver name 

static int read_adc_sample(char *sysfs_dir)
{
	char *tmp;

	if (asprintf(&tmp, "in_voltage%u_raw", CHANNEL) < 0)
	{
		printf("%s: failed to allocate memory\n", __func__);
		return -1;
	}

	return read_sysfs_posint(tmp,sysfs_dir);
}

static int read_voltage_scale(char *sysfs_dir, float *val)
{
	return read_sysfs_float("in_voltage_scale",sysfs_dir,val);
}

int main(int argc, char **argv)
{
	int sample_val;
	float voltage_scale;
	char *chrdev_name, *sysfs_dir;
	int ret_val = 0, dev_num = 0;

	dev_num = find_type_by_name(DEV_NAME, "iio:device");
	if (dev_num < 0)
	{
		printf("Failed to find iio:device for %s\n", DEV_NAME);
		ret_val = -1;
		goto quit_program;
	}

	if (asprintf(&chrdev_name, "/dev/iio:device%d", dev_num) < 0)
	{
		printf("%d: Failed to allocate memory \n", __LINE__);
		perror("asprintf: ");
		ret_val = -1;
		goto quit_program;
	}

	if (asprintf(&sysfs_dir, "/sys/bus/iio/devices/iio:device%d", dev_num) < 0)
	{
		printf("%d: Failed to allocate memory\n", __LINE__);
		ret_val = -1;
		goto err1;
	}

    sample_val = read_adc_sample(sysfs_dir);
	if (sample_val < 0)
	{
		ret_val = -1;
		goto err2;
	}

	printf("Raw Sample Value: 0x%04x\n", (unsigned int) sample_val);

	if (read_voltage_scale(sysfs_dir, &voltage_scale) < 0)
	{
		ret_val = -1;
		goto err2;
	}

	printf("Voltage: %.2f V\n", (sample_val * voltage_scale / 1000));

err2:
	free(sysfs_dir);
err1:
	free(chrdev_name);
quit_program:
	return ret_val;
}
