#!/bin/sh

while read CSV; do
    LOGIN=$(echo $CSV | csvtool format '%(1)' -)
    PASSWORD=$(echo $CSV | csvtool format '%(2)' -)
    adduser -D -H -s /sbin/nologin -G nobody "${LOGIN}"
    echo "${LOGIN}:${PASSWORD}" | chpasswd
done
