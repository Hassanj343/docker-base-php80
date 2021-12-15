FROM ubuntu:20.04
ARG S3_REGION
ARG S3_ACCESS_KEY
ARG S3_SECRET

WORKDIR /var/www

RUN ln -fs /usr/share/zoneinfo/Europe/London /etc/localtime \
    && apt-get update \
    && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && apt-get install -y \
    vim \
    curl \
    nginx \
    php8.0-fpm \
    php8.0-dev \
    php8.0-bcmath \
    php8.0-curl \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-xml \
    php8.0-zip \
    php8.0-soap \
    php8.0-ldap \
    php8.0-sqlite3 \
    php8.0-redis \
    php8.0-gd \
    php-imagick \
    unzip \
    wget \
    git \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/21.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install libcurl3-openssl-dev \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools \
    && apt-get install -y unixodbc-dev \
    && apt-get -y install gcc g++ make autoconf libc-dev pkg-config \
    && pecl install sqlsrv-5.10.0beta1 \
    && pecl install pdo_sqlsrv-5.10.0beta1 \
    && printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini \
    && printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini \
    && phpenmod -v 8.0 sqlsrv pdo_sqlsrv \
    && wget https://github.com/DataDog/dd-trace-php/releases/download/0.65.1/datadog-php-tracer_0.65.1_amd64.deb -O /tmp/datadog-php-tracer.deb \
    && dpkg -i /tmp/datadog-php-tracer.deb \
    && rm -f /etc/nginx/sites-available/* \
    && rm -f /etc/nginx/sites-enabled/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && ln -sf /dev/stderr /var/log/php-fpm_error.log \
    && rm -Rf /var/www/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && curl -sL https://deb.nodesource.com/setup_16.x  | bash - \
    && apt-get -y install nodejs\
    && apt-get update \
    && apt-get -y install python3.7 \
    && apt-get -y install python3-distutils python3-apt \
    && chown -R www-data:www-data /var/www \
    && chmod -R 777 /tmp \
    #install supervisor
    && apt-get install -y supervisor \
    #install rsyslog
    && apt-get install rsyslog -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && service php8.0-fpm start

RUN cd /tmp \
    && mkdir /root/.aws \
    && touch /root/.aws/config \
    && curl -O https://bootstrap.pypa.io/get-pip.py \
    && python3 get-pip.py \
    && pip install awscli --upgrade
    # && echo [default] >> /root/.aws/config \
    # && echo region=$S3_REGION >> /root/.aws/config \
    # && echo aws_access_key_id=$S3_ACCESS_KEY >> /root/.aws/config \
    # && echo aws_secret_access_key=$S3_SECRET >> /root/.aws/config

RUN apt-get -y update \
    && apt-get clean

#Supervisor base config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

#PHP Config
COPY ./php/cli/php.ini /etc/php/8.0/cli/php.ini
COPY ./php/fpm/php.ini /etc/php/8.0/fpm/php.ini

COPY ./nginx.conf /etc/nginx/conf.d/site.conf
COPY ./php-fpm.conf /etc/php/8.0/fpm/pool.d/www.conf
COPY ./startup.sh /tmp/startup.sh

RUN chmod 777 /tmp/startup.sh

EXPOSE 80

ENTRYPOINT [ "/tmp/startup.sh" ]