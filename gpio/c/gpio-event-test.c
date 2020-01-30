#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>

struct gpiod_line *get_gpio_line(int bank, int gpio)
{
	struct gpiod_chip *chip;
	struct gpiod_line *line;

	/* open the GPIO bank */
	chip = gpiod_chip_open_by_number(bank);
	if (chip == NULL)
	       goto error;

	/* open the GPIO line */
	line = gpiod_chip_get_line(chip, gpio);
	if (line == NULL)
		goto error;

	return line;

error:
	perror("Error setting gpiod\n");
	return NULL;
}

int main(int argc, char *argv[])
{
	struct gpiod_line *output_line;
	struct gpiod_line *input_line;
	struct gpiod_line_event event;
	int line_value = 0;
	int ret;

	/* check the arguments */
	if (argc < 5) {
		printf("Usage: "
			"gpio-event-test <input-bank> <input-gpio> <output-bank> <output-gpio>\n");
		return EXIT_FAILURE;
	}

	input_line = get_gpio_line(atoi(argv[1]), atoi(argv[2]));

	output_line = get_gpio_line(atoi(argv[3]), atoi(argv[4]));

	ret = gpiod_line_request_rising_edge_events(input_line, "gpio-test");
	if (ret < 0) {
		perror("Request events failed\n");
		return EXIT_FAILURE;
	}

	ret = gpiod_line_request_output(output_line, "gpio-test",
		GPIOD_LINE_ACTIVE_STATE_HIGH);
	if (ret < 0) {
		perror("Request output failed\n");
		return EXIT_FAILURE;
	}

	while (1) {
		gpiod_line_event_wait(input_line, NULL);

		if (gpiod_line_event_read(input_line, &event) != 0)
			continue;

		/* this should always be a rising event */
		if (event.event_type != GPIOD_LINE_EVENT_RISING_EDGE)
			continue;

		/* toggle output */
		line_value = !line_value;
		printf("Setting pin to %d\n", line_value);
		gpiod_line_set_value(output_line, line_value);
	}

	return EXIT_SUCCESS;

error:
	printf("Error setting gpiod\n");
	return EXIT_FAILURE;
}
