FROM debian:testing

ENV RAILS_LOG_TO_STDOUT 1
ARG RAILS_ENV=test

WORKDIR /app
EXPOSE 10003

RUN apt-get update -qq \
  && apt-get install -qq bundler chromium-driver libsqlite3-dev libxml2-dev libxslt-dev nodejs ruby ruby-dev zlib1g-dev

ADD vendor/cache /app/vendor/cache
ADD Gemfile Gemfile.lock  /app/
RUN bundle install --deployment --local -j 8

ADD . /app/

RUN bundle exec rails assets:precompile
RUN bundle exec rails db:migrate
RUN RAILS_ENV=test bundle exec rspec
