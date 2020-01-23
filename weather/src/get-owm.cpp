#include "get-owm.h"
#include <random>
#include <sstream>

static size_t WriteCallback(void *contents, size_t size, size_t nmemb, void *userp);

GetOWM::GetOWM()
{
}

GetOWMStruct GetOWM::getCurrent(const std::string& unit)
{
    CURL *curl;
    CURLcode result;
    GetOWMStruct outputStruct;
    std::ostringstream ss;
    std::stringstream token;
    std::random_device device;
    std::mt19937 generator(device());
    std::uniform_int_distribution<int> dist(0, 1000);

    curl = curl_easy_init();
    if (curl)
    {
        token.str(std::string());
	token << dist(generator);
        ss << apiPath << queryCity << "&units=" << unit << "&APPID=" << apiKey << "&TOKEN=" << token.str();
        std::string queryUrl = ss.str();
        char* apiUrl = new char [queryUrl.length()+1];
        std::strcpy(apiUrl, queryUrl.c_str());
        
        curl_easy_setopt(curl, CURLOPT_URL, apiUrl);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, GETOWM_CURL_TIMEOUT);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
        curl_easy_setopt(curl, CURLOPT_DNS_CACHE_TIMEOUT, 2 );
        curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, GETOWM_USER_AGENT);

        struct curl_slist *list = NULL;
        list = curl_slist_append(list, "Accept: */*");
        list = curl_slist_append(list, "Cache-Control: no-cache");
        list = curl_slist_append(list, "Connection: keep-alive");
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, list);

        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &outputBody);

        result = curl_easy_perform(curl);

	curl_slist_free_all(list);
        delete[] apiUrl;
        curl_easy_cleanup(curl);

        if (result != CURLE_OK)
        {
            std::string exception = curl_easy_strerror(result);
            throw exception;
        }
        else
        {
            outputStruct.status = GETOWM_OK;
            outputStruct.message = outputBody;
        }
    }
    return outputStruct;
}

GetOWMStruct GetOWM::getForecast(const std::string& unit)
{
    CURL *curl;
    CURLcode result;
    GetOWMStruct outputStruct;
    std::ostringstream ss;

    curl = curl_easy_init();
    if (curl)
    {
        ss << apiPath << queryCity << "&units=" << unit << "&APPID=" << apiKey;
        std::string queryUrl = ss.str();
        char* apiUrl = new char [queryUrl.length()+1];
        std::strcpy(apiUrl, queryUrl.c_str());
        
        curl_easy_setopt(curl, CURLOPT_URL, apiUrl);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, GETOWM_CURL_TIMEOUT);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_HTTPGET, 1);
        curl_easy_setopt(curl, CURLOPT_DNS_CACHE_TIMEOUT, 2 );
        curl_easy_setopt(curl, CURLOPT_IPRESOLVE, CURL_IPRESOLVE_V4);
        curl_easy_setopt(curl, CURLOPT_USERAGENT, GETOWM_USER_AGENT);

        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &outputBody);

        result = curl_easy_perform(curl);
        delete[] apiUrl;

        curl_easy_cleanup(curl);

        if (result != CURLE_OK)
        {
            std::string exception = curl_easy_strerror(result);
            throw exception;
        }
        else
        {
            outputStruct.status = GETOWM_OK;
            outputStruct.message = outputBody;
        }
    }
    return outputStruct;
}

void GetOWM::setUrl(const std::string& url)
{
    apiPath = url;
}

void GetOWM::setCity(const std::string& city)
{
    queryCity = city;
}

void GetOWM::setApiKey(const std::string& apikey)
{
    apiKey = apikey;
}

static size_t WriteCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}
