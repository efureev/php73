#!/bin/sh

# ----------------------------------------------------------------------
# Create the .env file if it does not exist.
# ----------------------------------------------------------------------

#if [[ ! -f "/www/app/.env" ]] && [[ -f "/www/app/.env.example" ]];
#then
#cp /var/www/app/.env.example /var/www/app/.env
#fi

# ----------------------------------------------------------------------
# Run Composer
# ----------------------------------------------------------------------

if [[ ! -d "/www/vendor" ]];
then
cd /www
composer update
composer dump-autoload -o
composer install
composer clear-cache
fi

# ----------------------------------------------------------------------
# Start supervisord
# ----------------------------------------------------------------------

#exec /usr/bin/supervisord -n -c /etc/supervisord.conf
