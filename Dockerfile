FROM ruby:alpine as config_builder
COPY dante_config_generator.rb .
ARG with_users
ARG all_networks
RUN ruby dante_config_generator.rb

FROM python:3-alpine as users_builder
RUN apk add --no-cache --virtual .build-deps build-base \
    && pip3 install csvkit \
    && apk del --purge .build-deps \
    && rm -rf /tmp/* \
    /usr/includes/* \
    /usr/share/man/* \
    /usr/src/* \
    /var/cache/apk/* \
    /var/tmp/*
COPY users.csv add_users.sh ./
ARG with_users
RUN [ -z "${with_users+x}" ] || cat users.csv | sh add_users.sh
RUN rm users.csv

FROM alpine:latest
RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN apk add --no-cache --upgrade apk-tools@edge
RUN apk add --no-cache dante-server@edge
COPY --from=config_builder danted.conf /etc/sockd.conf
COPY --from=users_builder /etc/passwd /etc/shadow /etc/
EXPOSE 1080
ENTRYPOINT ["sockd"]
