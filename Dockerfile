FROM binaryphile/redmine-2.3-stable:bundle
MAINTAINER Ted Lilley <ted.lilley@gmail.com>

#ENV DEBIAN_FRONTEND noninteractive
#ENV RAILS_ENV production
ENV REDMINE_LANG en

RUN cd redmine && bundle exec rake generate_secret_token
RUN cd redmine && bundle exec rake db:migrate
RUN cd redmine && bundle exec rake redmine:load_default_data

WORKDIR /redmine
ENTRYPOINT ["bundle", "exec", "rails", "s"]

