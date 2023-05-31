#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>
#include <string.h>

/* gpiod_line is a struct that contains both the bank and the line of a GPIO pin. Thus, we will call it gpiod_pin for simplification */
typedef struct gpiod_line gpiod_pin;
typedef struct gpiod_line_event gpiod_pin_event;

gpiod_pin *get_gpio_pin(char* bank, int line){
	struct gpiod_chip *chip;
	gpiod_pin *pin;

	/* open the GPIO bank path "/dev/gpiochip<bank_number>" */
	chip = gpiod_chip_open_by_name(bank);
	if (chip == NULL)
		return NULL;

	/* Getting the GPIO line of a specific bank */
	pin = gpiod_chip_get_line(chip, line);
	if (pin == NULL)
		return NULL;

	return pin;
}

int main(int argc, char *argv[]){
	gpiod_pin *output_pin;
	gpiod_pin *input_pin;
	gpiod_pin_event event;
	int pin_value = 0;
	int ret;
	char bank[32];
	unsigned int line;

	/* Displaying the program usage */
	if (!(argc == 3 || argc == 5)) {
		printf("Usage by SODIMM name:\n"
			"\tgpio-event <INPUT-SODIMM-NAME> <OUTPUT-SODIMM-NAME>\n"
			"Usage by bank/pin number:\n"
			"\tgpio-event <INPUT-BANK> <INPUT-GPIO-LINE> <OUTPUT-BANK> <OUTPUT-GPIO-LINE>\n");
		return EXIT_FAILURE;
	}
	/* Getting the input and output GPIO pin */
	if (argc == 5) {
		char bank[10];

		snprintf(bank, sizeof(bank), "gpiochip%s", argv[1]);
		input_pin = get_gpio_pin(bank, atoi(argv[2]));

		snprintf(bank, sizeof(bank), "gpiochip%s", argv[3]);
		output_pin = get_gpio_pin(bank, atoi(argv[4]));
	}
	/* Getting the input and output GPIO pin by the SODIMM name */
	else {	
		if (gpiod_ctxless_find_line(argv[1], bank, sizeof(bank), &line) <= 0) {
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}

		input_pin = get_gpio_pin(bank, line);

		if (input_pin == NULL) {
			perror("Error setting gpiod\n");
			return EXIT_FAILURE;
		}

		if (gpiod_ctxless_find_line(argv[2], bank, sizeof(bank), &line) <= 0) {
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}

		output_pin = get_gpio_pin(bank, line);

		if (output_pin == NULL) {
			perror("Error setting gpiod\n");
			return EXIT_FAILURE;
		}
	}

	/* Enabling rising edges events on the input pin */
	ret = gpiod_line_request_rising_edge_events(input_pin, "gpio-test");
	/* The function returns 0 if the operation succeeds, -1 on failure */
	if (ret < 0) {
		perror("Request events failed\n");
		return EXIT_FAILURE;
	}

	/* Setting the pin as output */
	ret = gpiod_line_request_output(output_pin, "gpio-test",
		GPIOD_LINE_ACTIVE_STATE_HIGH);
	/* The function returns 0 if the pin was properly reserved */
	if (ret < 0) { 
		perror("Request output failed\n");
		return EXIT_FAILURE;
	}

	while (1) { 
		/* Waiting for an event on the input pin */
		gpiod_line_event_wait(input_pin, NULL);

		/* Reading next pending event from the GPIO pin */
		if (gpiod_line_event_read(input_pin, &event) != 0)
			continue;

		/* Checking if it is a rising event as previously defined */
		if (event.event_type != GPIOD_LINE_EVENT_RISING_EDGE)
			continue;

		/* Output toggle */
		pin_value = !pin_value;
		printf("Setting pin to %d\n", pin_value);
		gpiod_line_set_value(output_pin, pin_value);
	}

	return EXIT_SUCCESS;
}