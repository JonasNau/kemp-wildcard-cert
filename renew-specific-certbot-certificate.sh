#!/bin/bash


#Read Command Line Args
while test $# -gt 0; do
  case "$1" in
    -h|--help)
	shift
      	echo "Automatically renew a specific certificate"
	echo "Usage:"
	echo "command [options]"
	echo ""
	echo "Options:"
	echo "-d or --domain-name \(The name of the certificate to Renew\)"
      ;;
    -d)
      shift
      if test $# -gt 0; then
        export domainName=$1
      else
        echo "no domainName specified"
        exit 1
      fi
      shift
      ;;
    --domain-name*)
      export domainName=`echo $1 | sed -e 's/^[^=]*=//g'`
      shift
      ;;
    *)
      break
      ;;
  esac
done


if [ "$domainName" == "" ];
then
	echo "You need to specify a domain name! (--domain-name='')" >&2
	exit 1
fi

outputCertRenewal=$(certbot renew --cert-name "$domainName")

if [[ $? -ne 0 ]];
then
	exit $?
fi

#echo "OUTPUT: $outputCertRenewal"

NOT_READY_FOR_RENEWAL="The following certificates are not due for renewal yet"
if [[ $outputCertRenewal == *"$NOT_READY_FOR_RENEWAL"* ]];
then
	echo "$domainName is not ready for renewal."
	exit 0
else
	CERTBOT_SUCCESS_MESSAGE="Congratulations!"
	if [[ $outputCertRenewal == *"$CERTBOT_SUCCESS_MESSAGE"* ]];
	then
		echo "Certificate for $domainName was successfully renewed!";
		exit 0
	else
		echo "ERROR: Certificate for $domainName colud not be renewed!" >&2
		exit 1
	fi
fi




