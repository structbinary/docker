echo sleep for 6 min so that letsencrypt container will come up
sleep 6

echo build starting nginx config


echo replacing ___my.example.com___/$MY_DOMAIN_NAME
echo replacing ___LETSENCRYPT_IP___/$LETSENCRYPT_PORT_80_TCP_ADDR
echo replacing ___LETSENCRYPT_PORT___/$LETSENCRYPT_PORT_80_TCP_PORT
echo replacing ___APPLICATION_IP___/$APP_PORT_80_TCP_ADDR
echo replacing ___APPLICATION_PORT___/$APP_PORT_80_TCP_PORT

# Populate domain name into the nginx reverse proxy config.
sed -i "s/___my.example.com___/$MY_DOMAIN_NAME/g" /etc/nginx/nginx.conf
# Add your app's container IP and port into config
sed -i "s/___APPLICATION_IP___/$APP_PORT_80_TCP_ADDR/g" /etc/nginx/nginx.conf
sed -i "s/___APPLICATION_PORT___/$APP_PORT_80_TCP_PORT/g" /etc/nginx/nginx.conf
sed -i "s/___LETSENCRYPT_IP___/$LETSENCRYPT_PORT_80_TCP_ADDR/g" /etc/nginx/nginx.conf
sed -i "s/___LETSENCRYPT_PORT___/$LETSENCRYPT_PORT_80_TCP_PORT/g" /etc/nginx/nginx.conf

cat /etc/nginx/nginx.conf
echo .
echo Firing up nginx in the background.
nginx

# Check user has specified domain name
if [ -z "$MY_DOMAIN_NAME" ]; then
    echo "Need to set MY_DOMAIN_NAME (to a letsencrypt-registered name)."
    exit 1
fi  

# This bit waits until the letsencrypt container has done its thing.
# We see the changes here bceause there's a docker volume mapped.
echo Waiting for folder /etc/letsencrypt/live/$MY_DOMAIN_NAME to exist
while [ ! -d /etc/letsencrypt/live/$MY_DOMAIN_NAME ] ;
do
    sleep 3
done

while [ ! -f /etc/letsencrypt/live/$MY_DOMAIN_NAME/fullchain.pem ] ;
do
	echo Waiting for file fullchain.pem to exist
    sleep 3
done

while [ ! -f /etc/letsencrypt/live/$MY_DOMAIN_NAME/privkey.pem ] ;
do
	echo Waiting for file privkey.pem to exist
    sleep 3
done

echo replacing ___my.example.com___/$MY_DOMAIN_NAME
echo replacing ___LETSENCRYPT_IP___/$LETSENCRYPT_PORT_80_TCP_ADDR
echo replacing ___LETSENCRYPT_PORT___/$LETSENCRYPT_PORT_80_TCP_PORT
echo replacing ___LETSENCRYPT_HTTPS_IP___/$LETSENCRYPT_PORT_443_TCP_ADDR
echo replacing ___LETSENCRYPT_HTTPS_PORT___/$LETSENCRYPT_PORT_443_TCP_PORT
echo replacing ___APPLICATION_IP___/$APP_PORT_80_TCP_ADDR
echo replacing ___APPLICATION_PORT___/$APP_PORT_80_TCP_PORT


# Populate domain name into the nginx reverse proxy config.
sed -i "s/___my.example.com___/$MY_DOMAIN_NAME/g" /etc/nginx/nginx-secure.conf

# Add LE container IP and port into config
sed -i "s/___LETSENCRYPT_IP___/$LETSENCRYPT_PORT_80_TCP_ADDR/g" /etc/nginx/nginx-secure.conf
sed -i "s/___LETSENCRYPT_PORT___/$LETSENCRYPT_PORT_80_TCP_PORT/g" /etc/nginx/nginx-secure.conf
sed -i "s/___LETSENCRYPT_HTTPS_IP___/$LETSENCRYPT_PORT_443_TCP_ADDR/g" /etc/nginx/nginx-secure.conf
sed -i "s/___LETSENCRYPT_HTTPS_PORT___/$LETSENCRYPT_PORT_443_TCP_PORT/g" /etc/nginx/nginx-secure.conf

# Adding  app's container IP and port into config
sed -i "s/___APPLICATION_IP___/$APP_PORT_80_TCP_ADDR/g" /etc/nginx/nginx-secure.conf
sed -i "s/___APPLICATION_PORT___/$APP_PORT_80_TCP_PORT/g" /etc/nginx/nginx-secure.conf

#reloading nginx config with the latest ssl config
kill -9 $(ps aux | grep '[n]ginx' | awk '{print $2}')
echo sleeping for 3 sec so that all the process should get killed
echo getting process id $(ps aux | grep '[n]ginx' | awk '{print $2}')
cp /etc/nginx/nginx-secure.conf /etc/nginx/nginx.conf

nginx -g 'daemon off;'