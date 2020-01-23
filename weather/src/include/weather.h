#ifndef WEATHER_H
#define WEATHER_H

#include <iostream>
#include <iomanip>
#include <cstdlib>
#include "get-owm.h"

#include <jsoncpp/json/json.h>

struct Temperature {
    float temperature;
    float feels_like;
    float min;
    float max;
};

struct Wind {
    float speed;
    int	 degrees;
};

struct Sun {
    int rise;
    int set;
};

struct WeatherStruct {
    Temperature temperature;
    int humidity;
    int pressure;
    std::string location;
    std::string conditions;
    Wind wind;
    Sun sun;
    int dt;
};

const std::string CURRENTAPIURL = "api.openweathermap.org/data/2.5/weather?";
const std::string FORECASTAPIURL = "api.openweathermap.org/data/2.5/forecast?";

#endif
