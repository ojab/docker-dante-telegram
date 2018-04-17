dante config can be built with
```
ruby dante_config_generator.rb [FILENAME]
```
result will be written into `FILENAME` (`danted.conf` by default) and can be found [in the repo](danted.conf).

`ruby` on the host is not needed for building docker image, config is generated inside docker.

Only Telegram IPs (i. e. IPs administered by MNT-TELEGRAM, pulled from [RIPE NCC database](https://www.ripe.net/))
and domains (telegram.dog, telegram.me, telegram.org, stel.com, t.me) are accessible, all other traffic is forbidden.

Docker image can be pulled from [Docker hub](https://hub.docker.com/r/ojab/dante-telegram/)
```
docker pull ojab/dante-telegram:latest # only Telegram networks without authentication
docker pull ojab/dante-telegram:with_users # Telegram & banned Amazon/Google networks, with authentication
docker pull ojab/dante-telegram:all_networks # All IPv4 networks accessible, with authentication
docker pull ojab/dante-telegram:yolo # All IPv4 networks accessible, without any authentication
```
default username is `telegram`, password is `}FCKrhw%,|vT$Yjr`. If you want to add other users or change password, you should rebuild image youself, see [User management](#user-management) below.


## Demo

```sh
docker-compose build
# localhost:1080 — ojab/dante-telegram:latest
# localhost:1081 — ojab/dante-telegram:with_users
# localhost:1082 — ojab/dante-telegram:all_networks
# localhost:1083 — ojab/dante-telegram:yolo
docker-compose up
curl --socks5 localhost:1080 http://web.telegram.org/
curl --socks5 localhost:1081 http://web.telegram.org/ # fails
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@google.com:1081' # fails
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@web.telegram.org:1081' http://web.telegram.org/
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@google.com:1082'
curl -i --socks5 google.com:1083
```
feel free to start/use resulting docker image however you want

If you need any other feature or have issues with images, feel free to [create a github issue](https://github.com/ojab/docker-dante-telegram/issues/new) or pull request.


## User management

Just add `user,password` pairs to `users.csv` and build images with `docker build . --build-arg with_users=true`. Note, even while `users.csv` is not used in final image build, it's copied to intermediate image (`users_builder` in Dockerfile) and retained in it's cache. So if you want to be on the safe side — you should remove cache after build.
