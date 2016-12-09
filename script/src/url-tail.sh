#!/bin/bash

if [ $# -lt 1 ]; then
	echo
	echo "Syntax: url-tail <URL> [<starting_tail_offset_in_bytes> | -1] [<update_interval_in_secs>] [<curl_options>...]"
	echo
	echo "    if <starting_tail_offset_in_bytes> is -1, all contents of the file will be initially fetched."
	echo
	exit 1
fi

url=$1

starting_tail_offset_in_bytes=0
if [ $# -ge 2 ]; then
	case $2 in
      -1)
      starting_tail_offset_in_bytes=-1
      ;;
    	''|*[!0-9]*)
			echo "Tail offset must be a positive number or -1"
			exit 1
			;;
	    *)
			starting_tail_offset_in_bytes=$2
			;;
	esac
fi

update_interval_in_secs=3
if [ $# -ge 3 ]; then
  update_interval_in_secs=$3
fi

curl_exec=curl
if [ $# -ge 4 ]; then
  shift
  shift
  shift
  curl_exec="curl $@"
fi

function check_non_200_response() {
	url=$1
	ret=`$curl_exec -s -I -X HEAD $url | head -n 1`
	if [ -z "$ret" ]; then
		echo Connection error.
		exit 1
	fi
	status=`echo $ret | cut -d$' ' -f2`
	if [ "$status" -ne 200 ]; then
		echo $ret
		exit 1
	fi
}

function check_ranges_support() {
	url=$1
	ret=`$curl_exec -s -I -X HEAD $url | grep "Accept-Ranges: bytes"`
	if [ -z "$ret" ]; then
		echo
	else
		return 1
	fi
}

function get_length() {

	url=$1
	ret=`$curl_exec -s -I -X HEAD $url | awk '/Content-Length:/ {print $2}'`
	if [ -z "$ret" ]; then
		echo
	else
		echo $ret | sed 's/[^0-9]*//g'
	fi
}

function print_tail() {

	url=$1
	off=$2
	len=$3

	$curl_exec --header "Range: bytes=$off-$len" -s $url
}


check_non_200_response $url
check_ranges_support $url
ranges_support=$?


if [ $ranges_support -eq 0 ]; then
	echo "Ranges are nor supported by the server"
	exit 1
fi



len=`get_length $url`
if [ $starting_tail_offset_in_bytes -eq -1 ]; then
  off=0
else
  off=$((len - starting_tail_offset_in_bytes))
fi


until [ "$off" -gt "$len" ]; do
	len=`get_length $url`
	if [ -z "$len" ]; then
		echo Connection error.
		exit 1
	fi
	if [ "$off" -eq "$len" ]; then
		sleep $update_interval_in_secs
	else
		print_tail $url $off $len
	fi

	off=$len
done