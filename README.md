# kemp-wildcard-cert
An instruction how to add a wildcard certificate to Kemp LoadMaster Load Balancer automatically with the KEMP API.


 


# Table of contents  
1. [Introduction](#introduction)  
2. [Usage](#paragraph1)  

## Features  

- automatically renew a wildcard certificate and replace it in KEMP

## Introduction

The original Idea came from NetworkChuck from this [video](https://www.youtube.com/watch?v=LlbTSfc4biw) in which he set up the free load balancer from kemptechnologies called Load Master. It's purpose is to send traffic to different web servers in a home network based on the subdomain . To Generate and maintain a wildcard certificate he used Cloudflares Proxying technology.

I followed the video and the installation and encountered a lot of issues with the certificate but ater a long time got it.

The main disadvantages of using Cloudflares Proxy to hide an IP were the caching is buggy and produces a lot of issues. If you disable the proxy and just get thre traffic directly to your Loadbalancer, the certificate wont work anymore.

Because of that much pain with cloudflares Proxy method I just use cloudflare as Domain Provider (DNS-Server) and generate my wildcard certificate by my own with certbot and automatically update it with the following scripts.

## Run Locally  

To run the script you need any linux distribution.

Clone the project  

~~~bash  
  git clone https://github.com/JonasNau/kemp-wildcard-cert
~~~

Go to the project directory  

~~~bash  
  cd kemp-wildcard-cert
~~~

# Install dependencies  

- CURL
- Certbot

# Generate the first Certificate with Certbot

To use this script you will need to initially generate a wildcard cert via the commandline and add a method for the [ACME (Automatic Certificate Management Environment)](https://de.wikipedia.org/wiki/Automatic_Certificate_Management_Environment) verification process. In this example it is made by a dns txt entry. 


~~~bash  
  $ sudo certbot certonly --manual --preferred-challenges dns -d "*.plaindomain.com" -d "plaindomain.com"
~~~

Where plaindomain.com is your domain.

You can now use the outputed certificate file and private key to test your Certificate. Just upload it to Kemp and as Identifier just take your plaindomain.com.


To update your certificate with certbot manually run:
~~~bash  
  $ sudo certbot renew --cert-name plaindomain.com
~~~

# Use the KEMP API
To enable the KEMP API go to your KEMP LoadMaster dashboard to "Certificates & Security" -> "Remote Access" -> Check the checkbox "Enable API Interface"

~~~bash  
  $ sudo curl -F "cert=@/etc/letsencrypt/live/plaindomain.com/fullchain.pem" -F "key=@/etc/letsencrypt/live/plaindomain.com/privkey.pem"  -k "https://[username]:[password]@[IP of Kemp Load Master Dashboard]/access/addcert?cert=[kemp Identifier of the certificate]&replace=1"
~~~


# Configure Automatic Renewal as Crontab
~~~bash  
  $ sudo crontab -e
~~~

Add the following to the crontab file:
~~~
sudo bash PATH_TO_SCRIPT/autoRenewCertificateForKemp.sh --domain-name="[plaindomain.com (Certbot domain name)]" --username="[username]" --password="[Password]" --source-ip="[IP of the Dashboard]" --certificate-file="/etc/letsencrypt/live/plaindomain.com/fullchain.pem" --key-file="/etc/letsencrypt/live/plaindomain.com/privkey.pem" --certificate-identifier="[KEMP Identifier]"
~~~

## Further Links  

- [Kemp API](https://support.kemptechnologies.com/hc/en-us/articles/9151884055693-How-to-upload-a-SSL-certificate-by-API)
- [KEMP Free Load Balancer](https://freeloadbalancer.com/)

## Feedback  

If you have any feedback, please reach out to me.

## License  

[The Unlicence](https://choosealicense.com/licenses/unlicense/)
 