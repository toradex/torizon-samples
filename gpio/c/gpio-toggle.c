#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>
#include <string.h>

int main(int argc, char *argv[])
{
	int line_value = 0;
	char chip[32];
	unsigned int offset;

	/* check the arguments */
	if (argc == 2) {
		/* get SODIMM parameters */
		if (gpiod_ctxless_find_line(argv[1], chip, sizeof(chip), &offset) <= 0)
		{
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}
	} else if (argc == 3) {
		snprintf(chip, sizeof(chip), "gpiochip%s", argv[1]);
		offset = atoi(argv[2]);
	}
	 else {
		printf("Usage by bank/pin number:\n"
			"\tgpio-toggle OUTPUT-BANK-NUMBER OUTPUT-GPIO-NUMBER\n"
			"Usage by SODIMM name:\n"
			"\tgpio-toggle OUTPUT-SODIMM-NAME\n");
		return EXIT_FAILURE;
	}

	while (1) {
		line_value = !line_value;
		gpiod_ctxless_set_value(chip, offset,line_value, false,"gpio-toggle",NULL,NULL);
		sleep(1);
		printf("Setting pin to %d\n", line_value);
	}

	return EXIT_SUCCESS;
}