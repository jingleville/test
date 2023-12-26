FROM ruby:3.1.2-alpine

ARG RAILS_ROOT=/Edstein
ARG PACKAGES="vim openssl-dev postgresql-dev build-base curl nodejs yarn less tzdata git postgresql-client bash screen gcompat"

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $PACKAGES

RUN gem install bundler

RUN mkdir $RAILS_ROOT
WORKDIR $RAILS_ROOT

COPY Gemfile ./
RUN bundle install --jobs 5

ADD . $RAILS_ROOT
ENV PATH=$RAILS_ROOT/bin:${PATH}

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]