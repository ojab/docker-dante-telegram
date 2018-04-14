FROM ruby:alpine as config_builder
COPY dante_config_generator.rb .
RUN ruby dante_config_generator.rb

FROM alpine:latest
RUN echo '@edge http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
RUN apk add --no-cache --upgrade apk-tools@edge
RUN apk add --no-cache dante-server@edge
COPY --from=config_builder danted.conf /etc/sockd.conf
EXPOSE 1080
ENTRYPOINT ["sockd"]
