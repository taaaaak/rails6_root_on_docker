FROM ruby:2.6.5

ENV LANG C.UTF-8
ENV APP_HOME /noknowApp

RUN apt-get update -qq && apt-get install -y build-essential nodejs

# This is a error handling when to be occurred yarn error.
RUN apt-get update -qq && apt-get install -y curl && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update && apt-get install -y yarn

RUN rm -rf /var/lib/apt/lists/*

# MariaDBでつなぎに行くと以下のエラーで落ちるため、MySQLをインストールする
# Mysql2::Error::ConnectionError (Plugin caching_sha2_password could not be loaded: /usr/lib/x86_64-linux-gnu/mariadb19/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory)
# https://taker.hatenablog.com/entry/2019/10/19/152007
WORKDIR /tmp
RUN apt update && apt install -y lsb-release \
    && apt remove -y libmariadb-dev-compat libmariadb-dev

RUN wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-common_8.0.18-1debian10_amd64.deb \
    https://dev.mysql.com/get/Downloads/MySQL-8.0/libmysqlclient21_8.0.18-1debian10_amd64.deb \
    https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-client-core_8.0.18-1debian10_amd64.deb \
    https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-community-client_8.0.18-1debian10_amd64.deb \
    https://dev.mysql.com/get/Downloads/MySQL-8.0/libmysqlclient-dev_8.0.18-1debian10_amd64.deb

RUN dpkg -i mysql-common_8.0.18-1debian10_amd64.deb \
    libmysqlclient21_8.0.18-1debian10_amd64.deb \
    mysql-community-client-core_8.0.18-1debian10_amd64.deb \
    mysql-community-client_8.0.18-1debian10_amd64.deb \
    libmysqlclient-dev_8.0.18-1debian10_amd64.deb

RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY ./Gemfile $APP_HOME/Gemfile
COPY ./Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install
COPY . $APP_HOME

EXPOSE  3000
