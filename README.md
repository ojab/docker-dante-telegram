dante config can be built with
```
ruby dante_config_generator.rb [FILENAME]
```
result will be written into `FILENAME` (`danted.conf` by default)

Docker image can be pulled from [Docker hub](https://hub.docker.com/r/ojab/dante-telegram/)
```
docker pull ojab/dante-telegram
```

Simple demo:
```sh
docker-compose build
docker-compose up
curl --socks5 localhost:1080 http://web.telegram.org/
```
feel free to start/use resulting docker image however you want