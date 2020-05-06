#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>
#include <string.h>

struct gpiod_line *get_gpio_line(char* bank, int gpio)
{
	struct gpiod_chip *chip;
	struct gpiod_line *line;

	/* open the GPIO bank */
	chip = gpiod_chip_open_by_name(bank);
	if (chip == NULL)
		return NULL;

	/* open the GPIO line */
	line = gpiod_chip_get_line(chip, gpio);
	if (line == NULL)
		return NULL;

	return line;
}

int main(int argc, char *argv[])
{
	struct gpiod_line *output_line;
	struct gpiod_line *input_line;
	struct gpiod_line_event event;
	int line_value = 0;
	int ret;
	char chip[32];
	unsigned int offset;

	/* check the arguments */
	if (!(argc == 3 || argc == 5)) {
		printf("Usage by bank/pin number:\n"
			"\tgpio-event INPUT-BANK-NUMBER INPUT-GPIO-NUMBER OUTPUT-BANK-NUMBER OUTPUT-GPIO-NUMBER\n"
			"Usage by SODIMM name:\n"
			"\tgpio-event INPUT-SODIMM-NAME OUTPUT-SODIMM-NAME\n");
		return EXIT_FAILURE;
	}

	if (argc == 5) {
		char gpio_chip[10];
		snprintf(gpio_chip, sizeof(gpio_chip), "gpiochip%s", argv[1]);
		input_line = get_gpio_line(gpio_chip, atoi(argv[2]));
		snprintf(gpio_chip, sizeof(gpio_chip), "gpiochip%s", argv[3]);
		output_line = get_gpio_line(gpio_chip, atoi(argv[4]));
	}
	else {	
		if (gpiod_ctxless_find_line(argv[1], chip, sizeof(chip), &offset) <= 0) {
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}
		input_line = get_gpio_line(chip, offset);
		if (input_line == NULL) {
			perror("Error setting gpiod\n");
			return EXIT_FAILURE;
		}

		if (gpiod_ctxless_find_line(argv[2], chip, sizeof(chip), &offset) <= 0) {
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}
		output_line = get_gpio_line(chip, offset);
		if (output_line == NULL) {
			perror("Error setting gpiod\n");
			return EXIT_FAILURE;
		}
	}
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
}