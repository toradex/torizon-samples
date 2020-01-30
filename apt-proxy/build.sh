# detects if we have squid-deb-proxy running and set APT_PROXY_ARG
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "HEAD /" | nc $LOCAL_IP 8000 | grep squid-deb-proxy >> /dev/null

# proxy is running
if [ $? -eq 0 ]
then
    echo "squid-deb-proxy is running"
    APT_PROXY_ARG=$LOCAL_IP
else
    echo "squid-deb-proxy is not running, enable it if you want to cache packages used in containers."
    APT_PROXY_ARG=""
fi

# build the image
docker build --rm -t myimagename:latest --build-arg APT_PROXY=$APT_PROXY_ARG .