#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h> 
#include <dirent.h>

#include "pwm_utils.h"

#define MAX_BUF 50

// Write values to PWM files
int pwm_write_val(char *pwm, char *file, uint64_t val) {
	int fd;
	char buf[MAX_BUF];
	char path[MAX_BUF];

	strcpy(path, pwm);
	strcat(path, file);
	fd = open(path, O_WRONLY);

	if (fd < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		return -1;
	}

	if (snprintf(buf, MAX_BUF, "%u", val) < 0)
		goto failed;

	if (write(fd, buf, strlen(buf)) < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		goto failed;
	}

	close(fd);
	return 0;

failed:
	close(fd);
	return -1;
}

// Write strings to PWM files
int pwm_write_str(char *pwm, char *file, char *val) {
	int fd;
	char path[MAX_BUF];

	strcpy(path, pwm);
	strcat(path, file);
	fd = open(path, O_WRONLY);

	if (fd < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		return -1;
	}

	if (write(fd, val, strlen(val)) < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		close(fd);
		return -1;
	}

	close(fd);
	return 0;
}

// Read PWM files
int pwm_read(char *pwm, char *file, char *val, uint8_t size) {
	int fd;
	char path[MAX_BUF];

	strcpy(path, pwm);
	strcat(path, file);
	fd = open(path, O_RDONLY);

	if (fd < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		return -1;
	}

	if ( read(fd, val, size) < 0) {
		printf("Error Number % d\n", errno);
		perror("pwm");
		close(fd);
		return -1;
	}

	close(fd);
	return 0;
}

// Check if there is a PWM channel
int pwm_exists(char *path) {
	DIR* fd = opendir(path);
	int exists;

	if(fd){
		exists = 0;
	} else {
		exists = -1;
	}

	closedir(fd);
	return exists;
}