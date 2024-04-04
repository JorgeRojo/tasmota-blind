#!/bin/bash

set -e

. .env

echo ">> ------------ .env ------------ <<"
echo "> TAMOTA_DEVIDE_HOST:  " $TAMOTA_DEVIDE_HOST
echo "> SET_MQTT:            " $SET_MQTT
echo "> MQTT_HOST:           " $MQTT_HOST
echo "> MQTT_PORT:           " $MQTT_PORT
echo "> MQTT_USER_NAME:      " $MQTT_USER_NAME
echo "> MQTT_PASSWORD:       " $MQTT_PASSWORD
echo ">> ------------------------------ <<"

TAMOTA_DEVIDE_URL="http://$TAMOTA_DEVIDE_HOST"

get_response_code() {
	echo $(curl --write-out '%{http_code}' --silent --output /dev/null ${TAMOTA_DEVIDE_URL})
}
wait_for_restart() {
	printf "$1.."
	local count=0
	local http_code=0
	while [ $count -lt 30 ] || [ $http_code -ne "200" ]; do
		sleep '.5'
		count=$((count + 5))
		http_code=$(get_response_code)
		printf "."
	done
	echo ""
}

if [ "$SET_MQTT" = true ]; then
	curl -s -X GET "${TAMOTA_DEVIDE_URL}/mq?mh=${MQTT_HOST}&ml=${MQTT_PORT}&mc=DVES_%2506X&mu=${MQTT_USER_NAME}&mp=${MQTT_PASSWORD}&mt=tasmota_%2506X&mf=%25prefix%25%2F%25topic%25%2F&save=" >/dev/null
	echo "> mqtt config done"
	wait_for_restart "> restarting"
fi

## send script
BERRY_SCRIPT="$(cat ./autoexec.be)"

curl -s -X POST "${TAMOTA_DEVIDE_URL}/ufse" \
	-H "Content-Type: application/x-www-form-urlencoded" \
	--data-urlencode "name=autoexec.be" \
	--data-urlencode "content=${BERRY_SCRIPT}" \
	--data-urlencode "save="

echo "> autoexec.be uploaded"

# restart
curl -s -X GET "$TAMOTA_DEVIDE_URL/?rst=" >/dev/null
wait_for_restart "> restarting"
echo "> DONE!"
