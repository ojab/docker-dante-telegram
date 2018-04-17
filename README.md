dante config can be built with
```
ruby dante_config_generator.rb [FILENAME]
```
result will be written into `FILENAME` (`danted.conf` by default) and can be found in the repo: [unauthenticated config](danted.conf) (with only Telegram IPs without authentication) and [authenticated config](danted_authenticated.conf) (with username/password authentication and additional banned Amazon/Google IPs).

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
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@localhost:1081' http://google.com # fails
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@localhost:1081' http://web.telegram.org/
curl -i --socks5 'telegram:}FCKrhw%,|vT$Yjr@localhost:1082' http://google.com
curl -i --socks5 localhost:1083 http://google.com
```
feel free to start/use resulting docker image however you want

If you need any other feature or have issues with images, feel free to [create a github issue](https://github.com/ojab/docker-dante-telegram/issues/new) or pull request.


## User management

Just add `user,password` pairs to `users.csv` and build images with `docker build . --build-arg with_users=true`. Note, even while `users.csv` is not used in final image build, it's copied to intermediate image (`users_builder` in Dockerfile) and retained in it's cache. So if you want to be on the safe side — you should remove cache after build.

If you have ruby installed, you can use rake rask to add/remove/replace/list users:
```sh
# Adds user `ojab` with password `fakepassword`
$ rake "users:add[ojab, fakepassword]"
# Removes user `ojab`
$ rake "users:remove[ojab]"
# Adds user `ojab` with random password
rake "users:add[ojab]"
# Replaces ojab's password with `fakepassword2`
$ rake "users:replace[ojab, fakepassword2]"
# List all users
$ rake "users:list"
tg://socks?server=vpn.example.com&port=1080&user=telegram&pass=}FCKrhw%,|vT$Yjr
tg://socks?server=vpn.example.com&port=1080&user=ojab&pass=fakepassword2
# List all users with server
$ rake "users:list[telegram.example.com]"
tg://socks?server=telegram.example.com&port=1080&user=telegram&pass=}FCKrhw%,|vT$Yjr
tg://socks?server=telegram.example.com&port=1080&user=ojab&pass=fakepassword2
# Signle user can be shown using grep
$ rake "users:list" | grep ojab
tg://socks?server=vpn.example.com&port=1080&user=ojab&pass=fakepassword2
