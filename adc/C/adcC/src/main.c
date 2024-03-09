#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#include "iio_utils.h"

#define MAX_BUF 20
#define CHANNEL 0

static int read_adc_sample(char *sysfs_dir)
{
	char *tmp;
	int adc_sample;

	if (asprintf(&tmp, "in_voltage%u_raw", CHANNEL) < 0)
	{
		printf("%s: failed to allocate memory\n", __func__);
		return -1;
	}

	adc_sample = read_sysfs_posint(tmp,sysfs_dir);
	free(tmp);

	return adc_sample;
}

static int read_voltage_scale(char *sysfs_dir, float *val)
{
	return read_sysfs_float("in_voltage_scale",sysfs_dir,val);
}

int main(int argc, char **argv)
{
	int sample_val;
	float voltage_scale;
	char *sysfs_dir;
	int dev_num = 0;

	if (asprintf(&sysfs_dir, "/sys/bus/iio/devices/iio:device%d", dev_num) < 0)
	{
		printf("%d: Failed to allocate memory\n", __LINE__);
		free(sysfs_dir);
		return -1;
	}

	sample_val = read_adc_sample(sysfs_dir);
	if (sample_val < 0)
	{
		free(sysfs_dir);
		return -1;
	}

	printf("Raw Sample Value: 0x%04x\n", (unsigned int) sample_val);

	if (read_voltage_scale(sysfs_dir, &voltage_scale) < 0)
	{
		free(sysfs_dir);
		return -1;
	}

	printf("Voltage: %.2f V\n", (sample_val * voltage_scale / 1000));

	free(sysfs_dir);
    return 0;
}