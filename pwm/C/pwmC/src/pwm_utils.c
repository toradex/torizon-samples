#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h> 
#include <dirent.h>

#include "pwm_utils.h"

#define MAX_BUF 50

int pwm_write_val(char *file, uint32_t val)
{
    int fd;
    char buf[MAX_BUF]; 
    
    fd = open(file, O_WRONLY);
    if(fd < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");                  
        return -1;
    }        
    if( snprintf(buf, MAX_BUF, "%u", val) < 0)
        goto failed; 

    if( write(fd, buf, strlen(buf)) < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");                  
        goto failed;
    }

    close(fd);    
    return 0;

failed:
    close(fd);
    return -1;
}

int pwm_write_str(char *file, char *val)
{
    int fd;
    
    fd = open(file, O_WRONLY);
    if(fd < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");
        return -1;
    }        
    if( write(fd, val, strlen(val)) < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");                  
        close(fd);
        return -1;
    }

    close(fd); 
    return 0;
}

int pwm_read(char *file, char *val, uint8_t size)
{
    int fd;
    
    fd = open(file, O_RDONLY);
    if(fd < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");                          
        return -1;
    }
    if( read(fd, val, size) < 0)
    {
        printf("Error Number % d\n", errno);  
        perror("pwm");                          
        close(fd);
        return -1;    
    }
 
    close(fd);     
    return 0;
}

int pwm_exists(char *file) {
    
    DIR* fd = opendir(file);
    int exists;
    if(fd)
    {     
        exists = 0;                      
    } else {
        exists = -1;
    }
    closedir(fd);  
    return exists;
}