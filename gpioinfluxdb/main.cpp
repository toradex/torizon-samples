#include <cstdio>
#include <string>
#include <iostream>
#include <random>
#include <thread>
#include <chrono>
#include <boost/asio.hpp>
#include <gpiod.h>
#include "InfluxDBFactory.h"

// pin SODIMM_135 & SODIMM_133 of colibri imx7
#define IN_DEV      0
#define IN_INDEX    2
#define OUT_DEV     1
#define OUT_INDEX   26

/*
// pin MXM3_1 and MXM3_3 of Apalis imx8
#define IN_DEV      0
#define IN_INDEX    8
#define OUT_DEV     0
#define OUT_INDEX   9
*/

using namespace std;
using namespace influxdb;

struct gpiod_line* get_gpio_line(int bank, int gpio)
{
    struct gpiod_chip* chip;
    struct gpiod_line* line;

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

int main()
{
    struct gpiod_line* output_line;
    struct gpiod_line* input_line;
    struct gpiod_line_event event;

    int line_state = 0;
    int counter = 0;
    int ret;

    //configures gpio lines
    input_line = get_gpio_line(IN_DEV, IN_INDEX);
    output_line = get_gpio_line(OUT_DEV, OUT_INDEX);

    ret = gpiod_line_request_both_edges_events(input_line, "GPIOInfluxDB");
    if (ret < 0) {
        cerr << "Request events failed" << endl;
        return EXIT_FAILURE;
    }

    ret = gpiod_line_request_output(output_line, "GPIOInfluxDB",
        GPIOD_LINE_ACTIVE_STATE_HIGH);
    if (ret < 0) {
        cerr << "Request output failed" << endl;
        return EXIT_FAILURE;
    }
    
    // read device hostname
    string hostname = boost::asio::ip::host_name();

    // open influxdb main interface
    auto influxdb = InfluxDBFactory::Get("http://influxdb:8086?");
    
    auto start = chrono::high_resolution_clock::now();

    // the influxDB container may not be immediately ready to receive requests
    // retry the operation for 60'' 
    for (;;)
    {
        try
        {
            // create database
            // if it already exists no error will be generated
            influxdb->query("CREATE DATABASE test");
            break;
        }
        catch (runtime_error e)
        {
            auto elapsed = chrono::duration_cast<chrono::seconds>(chrono::high_resolution_clock::now() - start);            

            if (elapsed.count() > 60.0)
            {
                // can't connect
                cout << "Timeout connecting to InfluxDB!";
                return -1;
            }

            this_thread::sleep_for(chrono::seconds(1));
        }
    }

    // open the test database
    influxdb = InfluxDBFactory::Get("http://influxdb:8086/?db=test");

    auto prev = chrono::high_resolution_clock::now();

    for (;;)
    {
        // wait until line state changes
        gpiod_line_event_wait(input_line,NULL);

        auto now = chrono::high_resolution_clock::now();

        chrono::duration<double> pulse_len = chrono::duration_cast<chrono::milliseconds>(now - prev);
        

        // read current event
        gpiod_line_event_read(input_line, &event);

        // read current state and change output pin accordingly
        line_state = gpiod_line_get_value(input_line);
        gpiod_line_set_value(output_line, line_state);

        // increase counter at each event
        counter++;

        // store the even in the influxdb database
        influxdb->write(Point{ "test" }.addField("value", line_state).addField("counter", counter).addField("pulse_len", pulse_len.count()).addTag("host", hostname));
        
        // print out current state on the console
        cout << line_state << endl;

        prev = now;
    }

    return 0;
}