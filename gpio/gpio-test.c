#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>

int main(int argc, char *argv[])
{
	struct gpiod_chip *output_chip;
	struct gpiod_line *output_line;
	int line_value = 0;
	int bank, line;

	/* check the arguments */
	if (argc > 2) {
		/* get GPIO bank argument */
		bank = atoi(argv[1]);
		/* get line argument */
		line = atoi(argv[2]);
	} else {
		printf("Example of use: test 0 12\n");
		return EXIT_FAILURE;
	}

	/* use libgpiod API */

	/* open the GPIO bank */
	output_chip = gpiod_chip_open_by_number(bank);
	/* open the GPIO line */
	output_line = gpiod_chip_get_line(output_chip, line);
	if (output_chip == NULL || output_line == NULL)
		goto error;

	/* config as output and set a description */
	gpiod_line_request_output(output_line, "gpio-test",
		GPIOD_LINE_ACTIVE_STATE_HIGH);

	while (1) {
		line_value = !line_value;
		gpiod_line_set_value(output_line, line_value);
		sleep(1);
		printf("Setting pin to %d\n", line_value);
	}

	return EXIT_SUCCESS;

error:
	printf("Error setting gpiod\n");
	return EXIT_FAILURE;
}
