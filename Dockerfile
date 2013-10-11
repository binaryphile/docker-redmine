FROM binaryphile/redmine-2.3-stable:data
MAINTAINER Ted Lilley <ted.lilley@gmail.com>

#ENV DEBIAN_FRONTEND noninteractive
#ENV RAILS_ENV production
#ENV REDMINE_LANG en

RUN gem update --system
RUN gem install bundler

ADD Gemfile.local /redmine/
ADD unicorn.rb /redmine/config/

RUN bundle update

WORKDIR /redmine
CMD ["bundle", "exec", "unicorn_rails", "-c", "config/unicorn.rb", "-E", "production", "-D"]

