## Setup examples

These are example setups that can be used as a guide if you happen to use the same setup, or as a reference if your situation differs a bit.  
It is still highly recommended to read the [synapse readme](https://github.com/matrix-org/synapse/blob/master/README.rst) which goes in to much more detail.

### Server at home behind NAT

The first thing we need is a DNS A record to your home IP (perferably a static IP, if you don't have that a dynamic dns service could work as well).
If you host more services at home a subdomain can work, such as matrix.example.com.  
In this example we're going to host the matrix server on the matrix.example.com subdomain and we're going to assume this runs on the same host as where the main domain is pointing to.  
Add the matrix.example.com DNS A record pointing to the same IP as the example.com domain.  
When using a subdomain it is recommended to make an SRV record pointing to matrix subdomain:  
    `_matrix._tcp.example.com 3600 IN SRV 10 0 8448 matrix.example.com`  

The DNS record should then look something like:

    `$ dig -t srv _matrix._tcp.example.com`  
    `_matrix._tcp.example.com. 3600    IN      SRV     10 0 8448 matrix.example.com.`

Once that's done we can generate the config files and self signed certificate:

   ` docker run -v /opt/synapse:/data --rm -e SERVER_NAME=example.com -e REPORT_STATS=no avhost/docker-matrix generate`

At this point it's possible to edit the configuration file homeserver.yaml and turnserver.conf, located in this example in `/opt/synapse`  
In homeserver.yaml we may want to enable registration and [recaptcha](https://github.com/matrix-org/synapse/blob/master/docs/CAPTCHA_SETUP.rst)  
In turnserver.conf we have to set the external ip and we can change the TURN portrange (here the default is used):  

    `external-ip=203.0.113.0`  
    `min-port=49152`  
    `max-port=65535`

The next step is to forward the relevant ports in the router to the server (note that docker by default writes iptables rules to open the ports needed):

`443, 8448` TCP for the matrix server (443 for clients 8448 for federation)  
`3478, 5349` TCP/UDP for STUN  
`49152-65535` TCP/UDP for TURN  

We now need to configure the webserver reverse proxy. This is done to allow clients to connect on the default 443 port and to use a valid certificate (for instance [letsencrypt](https://letsencrypt.org/docs/)).  
For more details on reverse proxy look at the documentation for the webserver of choice. Here we give an example config for apache2:  
First we need to enable mod_proxy and mod_proxy_http and mod_ssl, if you haven't already:  
`# a2enmod proxy proxy_http ssl`  
Then we can create the apache config for the subdomain using a reverse proxy by making /etc/apache2/sites-available/matrix.example.com-ssl.conf.  
This is an example of a resulting config. Note that letsencrypt should write part of the config using certbot.

```apache
<IfModule mod_ssl.c>
<VirtualHost *:443>
   ServerName matrix.example.com
   ServerAdmin webmaster@localhost
   DocumentRoot /var/www/html

   ErrorLog ${APACHE_LOG_DIR}/error.log
   CustomLog ${APACHE_LOG_DIR}/access.log combined

   RewriteEngine on
   SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
   SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
   Include /etc/letsencrypt/options-ssl-apache.conf
   <Location />
      ProxyPass  http://127.0.0.1:8008/
      ProxyPassReverse  /
   </Location>
   ProxyVia On
   ProxyPreserveHost On
   RequestHeader set X-Forwarded-Proto 'https' env=HTTPS
   </VirtualHost>
   # vim: syntax=apache ts=4 sw=4 sts=4 sr noet
</IfModule>
```

Once the config is created we'll need to enable the site:  
`a2ensite matrix.example.com`

At this point we're ready to start the server:  
`docker run --name=matrix -d --restart=always -p 8448:8448 -p 8008:8008 -p 3478:3478 -p 3478:3478/udp -p 5349:5349/udp -p 5349:5349 -p 49152-65535:49152-65535/udp -p 49152-65535:49152-65535 -v /opt/synapse:/data avhost/docker-matrix start`

After the container successfully started and the reverse proxy is configured we should be able to connect to the server using a matrix client and register a user (if that was enabled in the config).

If the client connected successfully we should check whether the federation works properly by going to:

`https://matrix.org/federationtester/api/report?server_name=example.com`

If everything checks out this means the synapse server is up and running.
