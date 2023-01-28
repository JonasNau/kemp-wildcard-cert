#!/bin/bash


domainName=""
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
      	echo "Automatically renew a SSL-Certificate and upload it to Kemp LoadMaster (Load Balancer)"
	echo "Usage:"
	echo "command [options]"
	echo ""
	echo "Options:"
	echo "-d or --domain-name (The Domain / Certificate Name Certbot has registered the domain for)"
	echo "-u or --username (The username for Kemp Authentication"
	echo "-p or --password (The password for Kemp Authentication"
	echo "-o or --source-ip (The IP or the domain of the Kemp LoadBalancer API"
	echo "-c or --certificate-file (The local path to the certificate file to update)"
	echo "-k or --key-file (The local path to the key file to update)"
	echo "-n or --certificate-identifier (The certificate identifier in Kemp, how the cert is named)"
	echo ""
      ;;

    -d)
      shift
      if test $# -gt 0; then
        domainName=$1
      else
        echo "no domain name for certbot specified"
        exit 1
      fi
      shift
      ;;
    --domain-name*)
      domainName=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;


    -u)
      shift
      if test $# -gt 0; then
        username=$1
      else
        echo "no username specified"
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
        echo "no password specified"
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

if [[ $domainName == "" ]];
then
	echo "You must specify a domain name for certbot." >&2
	exit 1
fi

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


#Renew Certificate

response=$(bash renew-specific-certbot-certificate.sh --domain-name="$domainName")

echo "$response"

if [[ $response == *"not ready for renewal"* ]];
then
	echo "The Certificate $domainName will not be renewd and uploaded because the domain is not ready for renewal"
exit 0
fi

#Upload Certificate


response=$(bash uploadCertificateToKemp.sh --username="$username" --password="$password" --source-ip="$sourceIP" --certificate-file="$certificateFilePath" --key-file="$certificateKeyPath" --certificate-identifier="$certificateIdentifier")

echo "$response"

if [[ $response != *"Uploading the certificate for the entry $certificateIdentifier was successful!"* ]];
then
	echo "The Certificate for domain $domainName for the Kemp SSL-Certificate entry $certificateIdentifier could not be replaced / uploaded"
exit 1
fi


echo "The Certificate for domain $domainName for the Kemp SSL-Certificate entry $certificateIdentifier successfully updated."

echo "Certificate for domain $domainName was successfully renewed"
