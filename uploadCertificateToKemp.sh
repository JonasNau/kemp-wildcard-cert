#!/bin/bash


username=""
password=""
sourceIP=""
certificateFilePath=""
certificateKeyPath=""
certificateIdentifier=""

#Read Command Line Args
while test $# -gt 0; do
  case "$1" in
    -h|--help)
      	shift
	echo "Automatically upload a certificate to Kemp LoadMaster (Load Balancer)"
	echo "Usage:"
	echo "command [options]"
	echo ""
	echo "Options:"
	echo "-u or --username (The username for Kemp Authentication)"
	echo "-p or --password (The password for Kemp Authentication)"
	echo "-o or --source-ip (The IP or the domain of the Kemp LoadBalancer API)"
	echo "-c or --certificate-file (The local path to the certificate file to update)"
	echo "-k or --key-file (The local path to the key file to update)"
	echo "-n or --certificate-identifier (The certificate identifier in Kemp, how the cert is named)"
	echo ""
      ;;
    -u)
      shift
      if test $# -gt 0; then
        username=$1
      else
        echo "no username specified specified"
        exit 1
      fi
      shift
      ;;
    --username*)
      username=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;

    -p)
      shift
      if test $# -gt 0; then
        password=$1
      else
        echo "no password specified specified"
        exit 1
      fi
      shift
      ;;
    --password*)
      password=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;

    -o)
      shift
      if test $# -gt 0; then
        sourceIP=$1
      else
        echo "no source ip specified"
        exit 1
      fi
      shift
      ;;
    --source-ip*)
      sourceIP=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;

    -c)
      shift
      if test $# -gt 0; then
        certificateFilePath=$1
      else
        echo "no certificate file path specified"
        exit 1
      fi
      shift
      ;;
    --certificate-file*)
      certificateFilePath=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;



    -k)
      shift
      if test $# -gt 0; then
        certificateKeyPath=$1
      else
        echo "no key file specified"
        exit 1
      fi
      shift
      ;;
    --key-file*)
      certificateKeyPath=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;


    -n)
      shift
      if test $# -gt 0; then
        certificateIdentifier=$1
      else
        echo "no certificate identifier specified"
        exit 1
      fi
      shift
      ;;
    --certificate-identifier*)
      certificateIdentifier=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;



    *)
      break
      ;;
  esac
done

# main program

if [[ $username == "" ]];
then
	echo "You must specify a username" >&2
	exit 1
fi



if [[ $password == "" ]];
then
	echo "You must enter a password" >&2
	exit 1
fi



if [[ $sourceIP == "" ]];
then
	echo "You must specify a source ip" >&2
	exit 1
fi


if [[ $certificateFilePath == "" ]];
then
	echo "You must specify a certificate file path" >&2
	exit 1
fi



if [[ $certificateKeyPath == "" ]];
then
	echo "You must specify a certificate key path" >&2
	exit 1
fi



if [[ $certificateIdentifier == "" ]];
then
	echo "You must specify a certificate identifier" >&2
	exit 1
fi


#Upload Certificate to Kemp

response=$(curl -F "cert=@$certificateFilePath" -F "key=@$certificateKeyPath"  -k "https://$username:$password@$sourceIP/access/addcert?cert=$certificateIdentifier&replace=1")

echo "$response"

if [[ $response != *"Certificate Successfully Installed"* ]];
then
	echo "Uploading the certificate to Kemp Load Balancer failed!" >&2
exit 1
fi

echo "Uploading the certificate for the entry $certificateIdentifier was successful!"
