#!/usr/bin/env bash

OPTION="${1}"

if [ ! -z "${ROOTPATH}" ]; then
	echo ":: We have changed the semantic and doesn't need the ROOTPATH"
	echo ":: variable anymore"
fi

case $OPTION in
	"start")
		if [ -f /data/turnserver.conf ]; then
			echo "-=> start turn"
			/usr/local/bin/turnserver --daemon -c /data/turnserver.conf
		fi

		echo "-=> start matrix"
		python -m synapse.app.homeserver \
		       --config-path /data/homeserver.yaml \
		;;
	"stop")
		echo "-=> stop matrix"
		echo "-=> via docker stop ..."
		;;
	"version")
		VERSION=$(tail -n 1 /synapse.version)
		echo "-=> Matrix Version: ${VERSION}"
		;;
	"generate")
		echo "-=> the function generate is deprecated"
		turnkey=$(pwgen -s 64 1)
		echo "-=> generate turn config"
		echo "lt-cred-mech" > /data/turnserver.conf
		echo "use-auth-secret" >> /data/turnserver.conf
		echo "static-auth-secret=${turnkey}" >> /data/turnserver.conf
		echo "realm=turn.${SERVER_NAME}" >> /data/turnserver.conf
		echo "cert=/data/${SERVER_NAME}.tls.crt" >> /data/turnserver.conf
		echo "pkey=/data/${SERVER_NAME}.tls.key" >> /data/turnserver.conf

		echo "-=> generate synapse config"
		python -m synapse.app.homeserver \
			  --server-name $SERVER_NAME \
			  --config-path /data/homeserver.yaml \
			  --media-store-path /data/media_storage \
			  --database-path /data/homeserver.db \
			  --pid-file /data/homeserver.pid \
			  --log-file /data/homeserver.log \
			  --turn-shared-secret "${turnkey}" \
			  --turn-user-lifetime 86400000 \
			  --generate-config

		echo "turn_uris:" >> /data/homeserver.yaml
		echo "- turn:turn.$SERVER_NAME:3478?transport=udp" >> /data/homeserver.yaml
		echo "- turn:turn.$SERVER_NAME:3478?transport=tcp" >> /data/homeserver.yaml
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac

