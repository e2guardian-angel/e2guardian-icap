#e2guardian-icap-pi
======================
This is a docker container made for raspberry pi that contains e2guardian to be configured as an ICAP server.
I am creating this docker image as part of a solution for a content filter with squid and e2guardian.

Baseimage
======================
debian:buster

### Quickstart 
```bash
docker run --name e2guardian -d \
  --publish 1344:1344 \
  --volume /path/to/e2gaurdian/lists:/etc/e2guardian/lists \
  jusschwa/e2guardian-icap-pi
```

### For use with squid
```bash
docker network create e2guardian
# Start squid here

docker run --name e2guardian -d \
  --publish 1344:1344 \
  --network e2guardian
  --volume /path/to/e2gaurdian/lists:/etc/e2guardian/lists \
  --name e2guardian
  jusschwa/e2guardian-icap-pi
```
