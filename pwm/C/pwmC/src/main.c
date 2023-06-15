#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

#include "pwm_utils.h"

#define PERIOD 1000000000
#define DUTY_CYCLE 500000000
#define POLARITY "normal"

int main(int argc, char **argv)
{
    if ( pwm_exists("/sys/class/pwm/pwmchip0/pwm0/") < 0 ) {
        if( pwm_write_val("/sys/class/pwm/pwmchip0/export", 0) < 0)
        {
            printf("failed to export \n");
            exit(EXIT_FAILURE);
        }
    }    

    if( pwm_write_val("/sys/class/pwm/pwmchip0/pwm0/period", PERIOD) < 0)
    {
        printf("failed to set period\n");
        exit(EXIT_FAILURE);    
    }

    if( pwm_write_val("/sys/class/pwm/pwmchip0/pwm0/duty_cycle", DUTY_CYCLE) < 0)
    {
        printf("failed to set duty cycle\n");
        exit(EXIT_FAILURE);    
    }    

    if( pwm_write_str("/sys/class/pwm/pwmchip0/pwm0/polarity", POLARITY) < 0)
    {
        printf("failed to set polarity\n");            
        exit(EXIT_FAILURE);    
    }

    if( pwm_write_val("/sys/class/pwm/pwmchip0/pwm0/enable", 1) < 0)
    {
        printf("failed to enable pwm\n");
        exit(EXIT_FAILURE);
    }    
    
    char d_cycle[10]={0};    
    if( pwm_read("/sys/class/pwm/pwmchip0/pwm0/duty_cycle", d_cycle, 9) < 0)
        printf("unable to read duty cycle\n");
    else
        printf("duty cycle is %s\n",d_cycle);

    char polarity[10]={0};
    if( pwm_read("/sys/class/pwm/pwmchip0/pwm0/polarity", polarity, 6) < 0)
        printf("failed to read polarity\n");
    else
        printf("polarity is %s\n",polarity);

    return 0;
}