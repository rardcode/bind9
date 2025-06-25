# Named / Bind9 dns server
Dns server based on Debian.

## Quick reference
* Where to file issues:
[GitHub](https://github.com/rardcode/bind9)

* Supported architectures: amd64 , armv7 , arm64v8

## How to use
### After first run it make conf file in `./data` dir. Change it with your parameters and ... relauch it!

### ...by docker run:
```
docker run --rm -d \
--net host \
-v ./data:/data \
-e TZ=Europe/Rome \
--name bind9 rardcode/bind9
```

### ...by docker-compose file:
```
services:
  bind9:
    image: rardcode/bind9
    container_name: bind9
    environment:
      - TZ=Europe/Rome
    volumes:
    - ./data:/data
    ports:
    - 127.0.0.1:53:53/udp
    restart: unless-stopped
```
## Changelog
v1.0.0 - 25.06.2025
- Debian v. 12.11
- bind9 v. 1:9.18.33-1~deb12u2
