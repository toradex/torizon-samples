# Bluetooth example #

Bluetooth example using libbluetooth.

Run this code on computer while running the example on module:

```c
#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>

int main(int argc, char **argv)
{
    struct sockaddr_rc addr = { 0 };
    int s, status;
    char dest[18] = { 0 };
    
    strcpy(dest, argv[1]);
    printf("Bluetooth Address of server: %s\n", dest);
    
    // allocate a socket
    s = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);

    // set the connection parameters (who to connect to)
    addr.rc_family = AF_BLUETOOTH;
    addr.rc_channel = (uint8_t) 1;
    str2ba( dest, &addr.rc_bdaddr );

    // connect to server
    status = connect(s, (struct sockaddr *)&addr, sizeof(addr));

    // send a message
    if( status == 0 ) {
        status = write(s, "hello!", 6);
    }

    if( status < 0 ) perror("uh oh");

    close(s);
    return 0;
}
```

Compiling the code: ```gcc rfcomm-client.c -o rfcomm-client -lbluetooth```
Running the application on computer terminal with the module's IP as an argument: ```$ ./rfcomm-client 48:E7:DA:FE:A3:68```

Remember to activate Bluetooth on your module as discoverable on.

References:
https://stackoverflow.com/questions/28868393/accessing-bluetooth-dongle-from-inside-docker
https://community.toradex.com/t/c-application-for-ble-connection/20035/5
https://developer.toradex.com/linux-bsp/application-development/networking-connectivity/bluetooth-linux/
https://developer.toradex.com/torizon/application-development/ide-extension/pass-arguments-to-containerized-applications/
https://developer.toradex.com/torizon/application-development/networking-connectivity/networking-with-torizoncore/
https://stackoverflow.com/questions/45044504/bluetooth-programming-in-c-secure-connection-and-data-transfer
https://people.csail.mit.edu/albert/bluez-intro/x502.html
