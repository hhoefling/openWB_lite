while read -r x; do
	value="${x#*=}"
	if [[ "${value:0:1}" == "'" ]] ; then
		value="${value:1:-1}"
		key="${x%%=*}"
		export "$key=$value"
	else
		export "$x"
	fi
done < /var/www/html/openWB/openwb.conf

readonly SOFORT0=0
readonly MINPV1=1
readonly NURPV2=2
readonly STOP3=3
readonly STANDBY4=4
readonly SUBMODE_NACHLADEN7=7

