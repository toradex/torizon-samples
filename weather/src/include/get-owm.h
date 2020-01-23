#ifndef GETOWM_H
#define GETOWM_H

#include <curl/curl.h>
#include <iostream>
#include <string>
#include <sstream>
#include <cstring>
#include <exception>

enum status_t {
    GETOWM_OK = 0,
    GETOWM_FAIL = 1
};

struct GetOWMStruct
{
    status_t status;
    std::string message;
};

const std::string GETOWM_CORE_VERSION = "1.1";
const signed long GETOWM_CURL_TIMEOUT = 5000L;
const std::string GETOWM_USER_AGENT = "GetOWM-agent/" + GETOWM_CORE_VERSION;

class GetOWM
{

  private:
    std::string apiPath;
    std::string apiKey;
    std::string queryCity;
    std::string outputBody;

  public:
    GetOWM();

    /**
     * Mutator for API URL
     */
    void setUrl(const std::string& url);

    /**
     * Mutator for City
     */
    void setCity(const std::string& city);

    /**
     * Mutator for API KEY
     */
    void setApiKey(const std::string& apikey);
    
    GetOWMStruct getCurrent(const std::string& unit);
    GetOWMStruct getForecast(const std::string& unit);

};

#endif
