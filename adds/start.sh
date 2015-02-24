#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
		if [ -f /$ROOTPATH/turnserver.conf ]; then
			echo "-=> start turn"
			/usr/local/bin/turnserver --daemon -c /$ROOTPATH/turnserver.conf
		fi

		echo "-=> start matrix"
		python -m synapse.app.homeserver \
		       --config-path /$ROOTPATH/homeserver.yaml \
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
		turnkey=$(pwgen -s 64 1)
		echo "-=> generate turn config"
		echo "lt-cred-mech" > /$ROOTPATH/turnserver.conf
		echo "use-auth-secret" >> /$ROOTPATH/turnserver.conf
		echo "static-auth-secret=${turnkey}" >> /$ROOTPATH/turnserver.conf
		echo "realm=turn.$SERVER_NAME" >> /$ROOTPATH/turnserver.conf
		echo "cert=/$ROOTPATH/port1024.net.tls.crt" >> /$ROOTPATH/turnserver.conf
		echo "pkey=/$ROOTPATH/port1024.net.tls.key" >> /$ROOTPATH/turnserver.conf

		echo "-=> generate synapse config"
		python -m synapse.app.homeserver \
			  --server-name $SERVER_NAME \
			  --config-path /$ROOTPATH/homeserver.yaml \
			  --media-store-path /$ROOTPATH/media_storage \
			  --database-path /$ROOTPATH/homeserver.db \
			  --pid-file /$ROOTPATH/homeserver.pid \
			  --log-file /$ROOTPATH/homeserver.log \
			  --turn-shared-secret "${turnkey}" \
			  --turn-user-lifetime 86400000 \
			  --generate-config

		echo "turn_uris:" >> /$ROOTPATH/homeserver.yaml
		echo "- turn:turn.$SERVER_NAME:3478?transport=udp" >> /$ROOTPATH/homeserver.yaml
		echo "- turn:turn.$SERVER_NAME:3478?transport=tcp" >> /$ROOTPATH/homeserver.yaml
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac

