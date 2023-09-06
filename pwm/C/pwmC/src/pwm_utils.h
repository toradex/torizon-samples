#ifndef __PWM_UTILS_H__
#define __PWM_UTILS_H__

int pwm_write_val(char *pwm, char *file, uint64_t val);
int pwm_write_str(char *pwm, char *file, char *val);
int pwm_read(char *pwm, char *file, char *val, uint8_t size);
int pwm_exists(char *path);

#endif