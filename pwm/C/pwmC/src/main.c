#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <math.h>

#include "pwm_utils.h"

#define POLARITY "normal"
// Duty cycle (%)
#define DUTY_CYCLE 50
// Frequency value in Hz
#define FREQUENCY 1000

// Write PWM properties
void pwm_set(char *pwm, uint64_t period, uint64_t duty_cycle) {

	char c_pwm0[50];
	strcpy(c_pwm0, pwm);
	strcat(c_pwm0, "pwm0/");

	char property[15];

	// Exports a PWM channel for use with sysfs
	if (pwm_exists(c_pwm0) < 0) {
		if (pwm_write_val(pwm, "export", 0) < 0) {
			printf("failed to export \n");
			exit(EXIT_FAILURE);
		}
	}

	// Duty cycle initialization
	if (pwm_write_val(c_pwm0, "duty_cycle", 0) < 0) {
		printf("failed to set duty cycle\n");
		exit(EXIT_FAILURE);
	}

	// Write the total period of the PWM signal.
	if (pwm_write_val(c_pwm0, "period", period) < 0) {
		printf("failed to set period\n");
		exit(EXIT_FAILURE);
	}

	// Write the active time of the PWM signal.
	if (pwm_write_val(c_pwm0, "duty_cycle", duty_cycle) < 0) {
		printf("failed to set duty cycle\n");
		exit(EXIT_FAILURE);
	}

	// Write the polarity of the PWM signal
	if (pwm_write_str(c_pwm0, "polarity", POLARITY) < 0) {
		printf("failed to set polarity\n");
		exit(EXIT_FAILURE);
	}

	// Enable the PWM signal
	if (pwm_write_val(c_pwm0, "enable", 1) < 0) {
		printf("failed to enable pwm\n");
		exit(EXIT_FAILURE);
	}
}
// Read PWM properties
void pwm_get(char *pwm) {
	char period[15];
	char duty_cycle[15];

	double relative_duty_cycle;
	float frequency;

	char c_pwm0[50];
	strcpy(c_pwm0, pwm);
	strcat(c_pwm0, "pwm0/");

	// Read the total period of the PWM signal.
	if (pwm_read(c_pwm0, "period", period, 15) < 0) {
		printf("failed to read period\n");
	} else {
		// Convert period to frequency
		frequency = 1.0e9/atoi(period);
		printf("frequency is %d Hz\n", frequency);
	}

	// Read the active time of the PWM signal.
	if (pwm_read(c_pwm0, "duty_cycle", duty_cycle, 15) < 0) {
		printf("unable to read duty cycle\n");
	} else {
		// Convert absolute to relative duty cycle
		relative_duty_cycle = (atof(duty_cycle)*100)/atof(period);
		printf("duty cycle is %.2lf %%\n", relative_duty_cycle);
	}
}

int main(int argc, char **argv) {
	// Change the path below according to which PWM you're using
	char pwm[25] = "/sys/class/pwm/pwmchip0/";

	double relative_duty_cycle = DUTY_CYCLE;
	uint64_t frequency = FREQUENCY;

	// Get command-line arguments
	if ( argc == 3 ) {
		// Overwrite variables if there are CLI arguments
		frequency = atoi(argv[1]);
		relative_duty_cycle = atof(argv[2]);
	// Check if the wrong number of arguments were passed to the program
	} else if (argc != 1) {
		printf("invalid arguments \n"
		"usage: %s <Frequency (Hz)> <DUTY_CYCLE (0-100 %%)> \n", argv[0]);
		exit(EXIT_FAILURE);
	}
	// Check the duty cycle range
	if ( relative_duty_cycle < 0 || relative_duty_cycle > 100 ) {
		printf("invalid arguments \n"
		"duty cycle must be between 0 and 100 %%\n");
		exit(EXIT_FAILURE);
	}

	// Convert frequency to period
	uint64_t period = (uint64_t) round(1.0e9/frequency);
	// Convert relative to absolute duty cycle
	uint64_t duty_cycle = (uint64_t) round((relative_duty_cycle/100) * period);

	pwm_set(pwm, period, duty_cycle);
	pwm_get(pwm);

	return 0;
}