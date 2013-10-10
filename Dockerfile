FROM ubuntu:precise
MAINTAINER Ted Lilley <ted.lilley@gmail.com>

EXPOSE 3001

ENV DEBIAN_FRONTEND noninteractive
#ENV RAILS_ENV production
ENV REDMINE_LANG en

RUN echo "deb http://ubuntu.wikimedia.org/ubuntu precise main restricted universe multiverse" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y git wget build-essential libpq-dev libmagickwand-dev libsqlite3-dev imagemagick libxslt-dev libxml2-dev libmysqlclient-dev
RUN wget -O ruby-install-0.3.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.3.0.tar.gz
RUN tar -xzvf ruby-install-0.3.0.tar.gz
RUN cd ruby-install-0.3.0 && make install
RUN ruby-install -i /usr/local/ ruby 2.0.0-p247
RUN gem update --system
RUN gem install bundler
RUN git clone git://github.com/redmine/redmine
RUN cd redmine && git checkout 2.3-stable
RUN cd redmine && bundle install --without test
ADD database.yml /redmine/config/
RUN cd redmine && bundle exec rake generate_secret_token
RUN cd redmine && bundle exec rake db:migrate
RUN cd redmine && bundle exec rake redmine:load_default_data
RUN mkdir /redmine/public/plugin_assets

WORKDIR /redmine
CMD ["bundle", "exec", "rails", "s", "-p", "3001"]
