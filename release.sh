#!/bin/sh

docker build . -t ojab/dante-telegram:latest
docker push ojab/dante-telegram:latest

docker build . --build-arg with_users=true -t ojab/dante-telegram:with_users
docker push ojab/dante-telegram:with_users

docker build . --build-arg with_users=true --build-arg all_networks=true -t ojab/dante-telegram:all_networks
docker push ojab/dante-telegram:all_networks

docker build . --build-arg all_networks=true -t ojab/dante-telegram:yolo
docker push ojab/dante-telegram:yolo
