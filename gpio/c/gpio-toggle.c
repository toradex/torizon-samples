#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>
#include <string.h>

int main(int argc, char *argv[]){
	int line_value = 0;
	char bank[32];
	unsigned int line;

	/* Checking if the GPIO usage will be via SODIIM name or bank and line */
	if (argc == 2) {
		/* Getting SODIMM parameters */
		if (gpiod_ctxless_find_line(argv[1], bank, sizeof(bank), &line) <= 0)
		{
			printf("Error finding GPIO\n");
			return EXIT_FAILURE;
		}
	/* Getting the bank and line of the GPIO pin  */
	} else if (argc == 3) {
		snprintf(bank, sizeof(bank), "gpiochip%s", argv[1]);
		line = atoi(argv[2]);
	}
	/* Displaying the program usage */
	 else {
		printf("Usage by SODIMM name:\n"
			"\tgpio-toggle <OUTPUT-SODIMM-NAME>\n"
			"Usage by bank/pin number:\n"
			"\tgpio-toggle <OUTPUT-BANK-LINE> <OUTPUT-GPIO-LINE>\n");
		return EXIT_FAILURE;
	}

	while (1) {
		/* GPIO pin toggle */
		line_value = !line_value;
		gpiod_ctxless_set_value(bank, line,line_value, false,"gpio-toggle",NULL,NULL);
		sleep(1);
		printf("Setting pin to %d\n", line_value);
	}

	return EXIT_SUCCESS;