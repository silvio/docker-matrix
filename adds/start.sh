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

		echo "-=> start vector.im client"
		(
			if [ -f /data/vector.im.conf ]; then
				echo "The vector  web client is now handled via silvio/docker-matrix-vector"
			fi
		)

		echo "-=> start matrix"
		python -m synapse.app.homeserver \
		       --config-path /data/homeserver.yaml \
		;;
	"stop")
		echo "-=> stop matrix"
		echo "-=> via docker stop ..."
		;;
	"version")
		echo "-=> Matrix Version"
		cat /synapse.version
		;;
	"generate")
		breakup="0"
		[[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
		[[ -z "${REPORT_STATS}" ]] && echo "STOP! environment variable REPORT_STATS must be set to 'no' or 'yes'" && breakup="1"
		[[ "${breakup}" == "1" ]] && exit 1

		[[ "${REPORT_STATS}" != "yes" ]] && [[ "${REPORT_STATS}" != "no" ]] && \
			echo "STOP! REPORT_STATS needs to be 'no' or 'yes'" && breakup="1"

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
		       --config-path /data/homeserver.yaml \
		       --generate-config \
		       --report-stats ${REPORT_STATS} \
		       --server-name ${SERVER_NAME}

		echo "-=> configure some settings in homeserver.yaml"
		awk -v TURNURIES="turn_uris: [\"turn:${SERVER_NAME}:3478?transport=udp\", \"turn:${SERVER_NAME}:3478?transport=tcp\"]" \
		    -v TURNSHAREDSECRET="turn_shared_secret: \"${turnkey}\"" \
		    -v PIDFILE="pid_file: /data/homeserver.pid" \
		    -v DATABASE="database: \"/data/homeserver.db\"" \
		    -v LOGFILE="log_file: \"/data/homeserver.log\"" \
		    -v MEDIASTORE="media_store_path: \"/data/media_store\"" \
		    '{
			sub(/turn_shared_secret: "YOUR_SHARED_SECRET"/, TURNSHAREDSECRET);
			sub(/turn_uris: \[\]/, TURNURIES);
			sub(/pid_file: \/homeserver.pid/, PIDFILE);
			sub(/database: "\/homeserver.db"/, DATABASE);
			sub(/log_file: "\/homeserver.log"/, LOGFILE);
			sub(/media_store_path: "\/media_store"/, MEDIASTORE);
			print;
		    }' /data/homeserver.yaml > /data/homeserver.tmp
		mv /data/homeserver.tmp /data/homeserver.yaml

		echo "-=> you have to review the generated configuration file homeserver.yaml"
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac

