#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>   // For sleep() and access()
#include <errno.h>
#include <string.h>


#define ADC_DEVICE_PATH "/dev/verdin-adc1"

int main(void) {

    FILE *adc_file;
    char buffer[64];
    int adc_value_mv;
    double adc_value_v=1000;

    // Check if the ADC device file exists.
    if (access(ADC_DEVICE_PATH, F_OK) != 0) {
        fprintf(stderr, "Error: ADC device %s not found. Check that it is mapped correctly.\n", ADC_DEVICE_PATH);
        return EXIT_FAILURE;
    } else if (!fopen(ADC_DEVICE_PATH, "r")) {
            fprintf(stderr, "Error: Unable to open ADC device %s: %s\n", ADC_DEVICE_PATH, strerror(errno));
            sleep(1);
            return EXIT_FAILURE;
    }

    fprintf(stdout, "Reading ADC values from %s... Press Ctrl+C to stop.\n", ADC_DEVICE_PATH);
    fflush(stdout);

    // Infinite loop: read and print the ADC value once per second.
    while (1) {
        adc_file = fopen(ADC_DEVICE_PATH, "r");
        
        if (!fgets(buffer, sizeof(buffer), adc_file)) {
            fprintf(stderr, "Error: Unable to read ADC value from %s: %s\n", ADC_DEVICE_PATH, strerror(errno));
            fclose(adc_file);
            sleep(1);
            continue;
        }

        fclose(adc_file);

        // Convert the value (assumed to be in millivolts) to an integer, then to volts.
        adc_value_mv = atoi(buffer);
        adc_value_v = adc_value_mv / 1000.0;

        fprintf(stdout, "ADC Reading: %.3f V\n", adc_value_v);
        fflush(stdout);
        sleep(1);
    }

    return EXIT_SUCCESS;
}
