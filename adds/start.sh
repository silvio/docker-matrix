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
				options=""

				while read -r line; do
					[ "${line:0:1}" == "#" ] && continue
					[ "${line:0:1}" == " " ] && continue
					options="${options} ${line}"
				done < /data/vector.im.conf

				cd /vector-web/vector
				echo "-=> vector.im options: http-server ${options}"
				http-server ${options} &
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
		VERSION=$(tail -n 1 /synapse.version)
		echo "-=> Matrix Version: ${VERSION}"
		;;
	"generate")
		turnkey=$(pwgen -s 64 1)
		echo "-=> generate turn config"
		echo "lt-cred-mech" > /data/turnserver.conf
		echo "use-auth-secret" >> /data/turnserver.conf
		echo "static-auth-secret=${turnkey}" >> /data/turnserver.conf
		echo "realm=turn.${SERVER_NAME}" >> /data/turnserver.conf
		echo "cert=/data/${SERVER_NAME}.tls.crt" >> /data/turnserver.conf
		echo "pkey=/data/${SERVER_NAME}.tls.key" >> /data/turnserver.conf

		echo "-=> generate vector.im server config"
		echo "# change this option to your needs" >> /data/vector.im.conf
		echo "-p 8080" > /data/vector.im.conf
		echo "-A 0.0.0.0" >> /data/vector.im.conf
		echo "-c 3500" >> /data/vector.im.conf
		echo "--ssl" >> /data/vector.im.conf
		echo "--cert /data/${SERVER_NAME}.tls.crt" >> /data/vector.im.conf
		echo "--key /data/${SERVER_NAME}.tls.key" >> /data/vector.im.conf

		echo "-=> generate synapse config"
		python -m synapse.app.homeserver \
		       --config-path /data/homeserver.yaml \
		       --generate-config \
		       --server-name ${SERVER_NAME}

		echo "-=> configure some settings in homeserver.yaml"
		awk -v SERVER_NAME="${SERVERNAME}" \
		    -v TURNURIES="turn_uris: [\"turn:${SERVER_NAME}:3478?transport=udp\", \"turn:${SERVER_NAME}:3478?transport=tcp\"]" \
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

