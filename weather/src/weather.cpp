#include <cstdio>
#include <string>
#include <iostream>
#include <random>
#include <thread>
#include <chrono>
#include <sstream>
#include <boost/asio.hpp>
#include <InfluxDBFactory.h>
#include "weather.h"

int main()
{
    GetOWM getowmcurrent;
    GetOWM getowmforecast;
    std::string unit = "metric";
    std::time_t timeTmp;
    std::stringstream ts;
    GetOWMStruct serverResponse;
    Json::Value jsonObject;
    WeatherStruct data;

    std::random_device device;
    std::mt19937 generator(device());
    std::uniform_int_distribution<int> dist(0, 1000);
    std::string hostname = boost::asio::ip::host_name();

    auto influxdb = influxdb::InfluxDBFactory::Get("http://influxdb:8086?");
    int retries = 45; // The number of retries, and total seconds, to wait for Influx
    for (int retry = 0; retry < retries; retry++)
    {
        try
        {
            influxdb->query("CREATE DATABASE Weather");
            break;
        }
        catch (std::runtime_error &msg)
        {
            std::cout << "InfluxDB is not available, will retry in 1 second. Total time waiting: ";
            std::cout << retry + 1 << " second(s)" << std::endl;
            std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        }
    }
    influxdb = influxdb::InfluxDBFactory::Get("http://influxdb:8086/?db=Weather");

    //Forecast is only fetched once
    getowmforecast.setApiKey("32128c8c3146ed424448200c42d7b070");
    getowmforecast.setCity("lat=47.02&lon=8.31");
    getowmforecast.setUrl(FORECASTAPIURL);

    serverResponse = GetOWMStruct();
    try
    {
        serverResponse = getowmforecast.getForecast(unit);
    }
    catch (std::string msg)
    {
        std::cout << "GetOWMCurlException: ";
        std::cout << msg << std::endl;
        return EXIT_FAILURE;
    }

    std::istringstream response(serverResponse.message);
    response >> jsonObject;

    std::cout << "Upload forecast to influxdb";
    for (int dpoint = 0; dpoint < 40; dpoint++)
    {
        data.temperature.temperature = jsonObject["list"][dpoint]["main"]["temp"].asFloat();
        data.humidity = jsonObject["list"][dpoint]["main"]["humidity"].asInt();
        data.pressure = jsonObject["list"][dpoint]["main"]["pressure"].asInt();
        data.dt = jsonObject["list"][dpoint]["dt"].asInt();
        std::chrono::system_clock::time_point dt = std::chrono::system_clock::from_time_t(data.dt);

        std::cout << "." << std::flush;

        influxdb->write(influxdb::Point{"Temperature"}
                            .addField("value", data.temperature.temperature)
                            .setTimestamp(dt)
                            .addTag("host", hostname));

        influxdb->write(influxdb::Point{"Humidity"}
                            .addField("value", data.humidity)
                            .setTimestamp(dt)
                            .addTag("host", hostname));

        influxdb->write(influxdb::Point{"Pressure"}
                            .addField("value", data.pressure)
                            .setTimestamp(dt)
                            .addTag("host", hostname));
    }
    std::cout << std::endl;

    std::cout << "Upload current weather to influxdb periodically" << std::endl;
    for (;;)
    {
        getowmcurrent = GetOWM();
        getowmcurrent.setApiKey("32128c8c3146ed424448200c42d7b070");
        getowmcurrent.setCity("lat=47.02&lon=8.31");
        getowmcurrent.setUrl(CURRENTAPIURL);
        data = WeatherStruct();
        jsonObject = Json::Value();
        serverResponse = GetOWMStruct();
        try
        {
            serverResponse = getowmcurrent.getCurrent(unit);
        }
        catch (std::string msg)
        {
            std::cout << "GetOWMCurlException: ";
            std::cout << msg << std::endl;
            return EXIT_FAILURE;
        }

        std::istringstream response(serverResponse.message);
        response >> jsonObject;
        data.temperature.temperature = jsonObject["main"]["temp"].asFloat();
        data.temperature.feels_like = jsonObject["main"]["feels_like"].asFloat();
        data.temperature.min = jsonObject["main"]["temp_min"].asFloat();
        data.temperature.max = jsonObject["main"]["temp_max"].asFloat();
        data.humidity = jsonObject["main"]["humidity"].asInt();
        data.pressure = jsonObject["main"]["pressure"].asInt();
        data.location = jsonObject["name"].asString();
        data.conditions = jsonObject["weather"][0]["description"].asString();
        data.wind.degrees = jsonObject["wind"]["deg"].asInt();
        data.wind.speed = jsonObject["wind"]["speed"].asFloat();
        data.sun.rise = jsonObject["sys"]["sunrise"].asInt();
        data.sun.set = jsonObject["sys"]["sunset"].asInt();
        data.dt = jsonObject["dt"].asInt();

        std::cout << "." << std::flush;

        influxdb->write(influxdb::Point{"CurrentTemp"}
                            .addField("value", data.temperature.temperature)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"FeelsLike"}
                            .addField("value", data.temperature.feels_like)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"CurTempMin"}
                            .addField("value", data.temperature.min)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"CurTempMax"}
                            .addField("value", data.temperature.max)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"CurrentHumidity"}
                            .addField("value", data.humidity)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"CurrentPressure"}
                            .addField("value", data.pressure)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"Location"}
                            .addField("value", data.location)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"Conditions"}
                            .addField("value", data.conditions)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"WindDirection"}
                            .addField("value", data.wind.degrees)
                            .addTag("host", hostname));
        influxdb->write(influxdb::Point{"WindSpeed"}
                            .addField("value", data.wind.speed)
                            .addTag("host", hostname));
        timeTmp = data.sun.rise;
        ts.str(std::string());
        ts << std::put_time(std::localtime(&timeTmp), "%r");
        influxdb->write(influxdb::Point{"SunRise"}
                            .addField("value", ts.str())
                            .addTag("host", hostname));
        timeTmp = data.sun.set;
        ts.str(std::string());
        ts << std::put_time(std::localtime(&timeTmp), "%r");
        influxdb->write(influxdb::Point{"SunSet"}
                            .addField("value", ts.str())
                            .addTag("host", hostname));
        timeTmp = data.dt;
        ts.str(std::string());
        ts << std::put_time(std::localtime(&timeTmp), "%Y-%m-%d %r");
        influxdb->write(influxdb::Point{"DateTime"}
                            .addField("value", ts.str())
                            .addTag("host", hostname));
        //free account limit is 60 calls per minute
        std::this_thread::sleep_for(std::chrono::seconds(30));
    }
    return 0;
}
