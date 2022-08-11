#!/bin/bash

debv=$(</etc/debian_version)
i=(${debv//./ })

case $i in
 9) distro='Stretch' ;;
 10) distro='Buster' ;;
 11) distro='Bullseye' ;;
 *) distro=$debv
esac

echo $distro

