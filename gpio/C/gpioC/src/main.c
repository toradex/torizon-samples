#include <stdio.h>
#include <gpiod.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    const char* gpiolineName = NULL;//"SODIMM_55";
    const char* gpioChip = "/dev/gpiochip0";

    if (gpiolineName == NULL) {
        struct gpiod_chip* chip = gpiod_chip_open(gpioChip);
        printf("%s - %d lines\n", gpiod_chip_name(chip), gpiod_chip_num_lines(chip));

        for (unsigned int line_offset = 0; line_offset < gpiod_chip_num_lines(chip); line_offset++) {
            struct gpiod_line* line = gpiod_chip_get_line(chip, line_offset);

            const char* line_name = gpiod_line_name(line);
            if (line_name == NULL) {
                line_name = "unnamed";
            }

            const char* line_consumer;
            if (gpiod_line_is_used(line)) {
                line_consumer = gpiod_line_consumer(line);
            } else {
                line_consumer = "unused";
            }

            printf("Line %d: %s %s\n", line_offset, line_name, line_consumer);

            gpiod_line_release(line);
        }

        gpiod_chip_close(chip);
    } else {
        struct gpiod_line* gpioline = gpiod_line_find(gpiolineName);

        if (gpioline == NULL) {
            printf("Invalid line name.\n");
        } else {
            gpiod_line_request_output(gpioline, "GPIO application", 0);
            while (1) {
                gpiod_line_set_value(gpioline, 0);
                usleep(1000000);
                gpiod_line_set_value(gpioline, 1);
                usleep(1000000);
            }
        }
    }

    return 0;
}