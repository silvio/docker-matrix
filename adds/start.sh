#!/usr/bin/env bash

OPTION="${1}"

case $OPTION in
	"start")
		echo "-=> start matrix"
		python -m synapse.app.homeserver \
		       --config-path /$ROOTPATH/homeserver.yaml \
		;;
	"stop")
		echo "-=> stop matrix"
		echo "-=> via docker stop ..."
		;;
	"generate")
		echo "-=> generate config"
		python -m synapse.app.homeserver \
			  --server-name $SERVER_NAME \
			  --config-path /$ROOTPATH/homeserver.yaml \
			  --media-store-path /$ROOTPATH/media_storage \
			  --database-path /$ROOTPATH/homeserver.db \
			  --pid-file /$ROOTPATH/homeserver.pid \
			  --log-file /$ROOTPATH/homeserver.log \
			  --generate-config
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac

