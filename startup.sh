#!/bin/bash

supervisord -c /etc/supervisor/conf.d/supervisord.conf
/etc/init.d/cron start
/etc/init.d/nginx start
php-fpm8.0 --nodaemonize