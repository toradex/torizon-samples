#!/bin/bash

usage () {
    cat <<HELP_USAGE

Usage: $0 [server-name] [client1 [client2 [client3 [...]]]]
       $0 [-h | --help]

    server-name             IP address to be used by OpenVPN server.
                             It can be a local IP adderss or a public IP address.
                             If no IP address is provided, the public IP address
                             of the machine will be used.

    client1, client2, ...   The name of clients that will connect to the OpenVPN
                             server. One certificate without password will be
                             created for each client. The name of the certificate
                             will be like client1-cert.ovpn.
                             All the certiicates will be place in the present working
                             directory.
 
    -h, --help              Display this help and exit
HELP_USAGE
}

if [ -n "$1" ] && ( [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] )
then
	usage
	exit
fi

OPENVPN_DOCKER_IMAGE="kylemanna/openvpn"
OPENVPN_PORT=1194

COLOR_GREEN="\e[32m"
COLOR_CYAN="\e[36m"
COLOR_YELLOW="\e[1;33m"
COLOR_RESET="\e[0m"

green () {
	local retval="$COLOR_GREEN$@$COLOR_RESET"
	echo -e "$retval"
}

cyan () {
	local retval="$COLOR_CYAN$@$COLOR_RESET"
	echo -e "$retval"
}

yellow () {
	local retval="$COLOR_YELLOW$@$COLOR_RESET"
	echo -e "$retval"
}

if [ -z "$1" ]
then
	SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
	echo -e "$(yellow 'No IP supplied for OpenVPN Server.')"
	echo -e "Using public IP with default PORT: $(cyan $SERVER_IP:$OPENVPN_PORT)"
else
	SERVER_IP=$1
	if [[ -n $(echo $SERVER_IP | grep -P "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}") ]]
	then
		echo "Using IP supplied for OpenVPN Server with default PORT: $(cyan $SERVER_IP:$OPENVPN_PORT)"
		shift
	else
		SERVER_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
		echo -e "$(yellow 'No IP supplied for OpenVPN Server')"
		echo -e "Using public IP with default PORT: $(cyan $SERVER_IP:$OPENVPN_PORT)"
	fi
fi

export OVPN_DATA=ovpn-data-server

if [[ -n $(docker volume list | grep $OVPN_DATA) ]]
then
	echo "Docker volume $OVPN_DATA exists. Removing it"
	command="docker volume rm $OVPN_DATA"
	echo -e "    $(cyan $command)"
	$command
fi

echo "Creating new Docker Volume $OVPN_DATA"
command="docker volume create --name $OVPN_DATA"
echo -e "    $(cyan $command)"
$command

echo "IP setup for OpenVPN Server"
command="docker run -v $OVPN_DATA:/etc/openvpn --rm $OPENVPN_DOCKER_IMAGE ovpn_genconfig -u udp://$SERVER_IP"
echo -e "    $(cyan $command)"
$command

echo "Please, setup password"
command="docker run -v $OVPN_DATA:/etc/openvpn --rm -it $OPENVPN_DOCKER_IMAGE ovpn_initpki"
echo -e "    $(cyan $command)"
$command

echo "Launching OpenVPN Server Container"
command="docker run -v $OVPN_DATA:/etc/openvpn -d -p $OPENVPN_PORT:$OPENVPN_PORT/udp --cap-add=NET_ADMIN --name ovpn-server $OPENVPN_DOCKER_IMAGE"
echo -e "    $(cyan $command)"
$command

if [ -z "$1" ]
then
	echo
	echo "No client names supplied."
	echo
	echo "To create a client with name CLIENTNAME:"
	echo "    \"docker run -v $OVPN_DATA:/etc/openvpn --rm -it $OPENVPN_DOCKER_IMAGE easyrsa build-client-full CLIENTNAME nopass\""
	echo "To retrieve .opvn certificate for client with name CLIENTNAME:"
	echo "    \"docker run -v $OVPN_DATA:/etc/openvpn --rm $OPENVPN_DOCKER_IMAGE ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn\""
	exit
fi

echo
echo "Creating .ovpn certificates for client(s) $(yellow $@)"
echo

CLIENT_ARRAY=()
CERTIFICATE_ARRAY=()

while [ -n "$1" ]
do
	CLIENT_NAME="$1"
	CLIENT_ARRAY+=($CLIENT_NAME)

	CERTIFICATE_FILENAME="$CLIENT_NAME-cert.ovpn"

	command="docker run -v $OVPN_DATA:/etc/openvpn --rm -it $OPENVPN_DOCKER_IMAGE easyrsa build-client-full $CLIENT_NAME nopass"
	echo -e "    $(cyan $command)"
	$command

	command="docker run -v $OVPN_DATA:/etc/openvpn --rm $OPENVPN_DOCKER_IMAGE ovpn_getclient $CLIENT_NAME combined"
	echo -e "    $(cyan $command) > $CERTIFICATE_FILENAME"
	$command > $CERTIFICATE_FILENAME

	echo "Certificate for client $(yellow $CLIENT_NAME) created at: $(pwd)/$CERTIFICATE_FILENAME"
	echo

	CERTIFICATE_ARRAY+=("$(pwd)/$CERTIFICATE_FILENAME")

	shift
done

TABLE_WIDTH=100
SEPARATOR="--------------------------------------------------"
ROWS="%-15s| %-7s\n"

echo
echo
echo "OpenVPN Server created on $(cyan $SERVER_IP:$OPENVPN_PORT) for clients:"
echo
printf "%-15s| %-30s\n" "Client Name" "Certificate"
printf "%.${TABLE_WIDTH}s\n" "$SEPARATOR"

for (( idx=0 ; idx<${#CLIENT_ARRAY[@]} ; idx+=1 ))
do
	printf "$ROWS" "${CLIENT_ARRAY[$idx]}" "${CERTIFICATE_ARRAY[$idx]}"
done
