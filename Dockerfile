FROM alpine:3.12.1 as builder
WORKDIR /tmp/buid
RUN apk add --update autoconf automake gcc cmake g++ zlib zlib-dev pcre2 pcre2-dev build-base gcc abuild binutils binutils-doc gcc-doc pcre pcre-dev git
RUN git clone https://github.com/e2guardian/e2guardian.git -b v5.3 && \
	cd e2guardian && ./autogen.sh && ./configure --prefix=/ --exec_prefix=/usr --datarootdir=/usr/share && make && make install

FROM alpine:3.12.1
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>

COPY --from=builder /etc/e2guardian /etc/e2guardian
COPY --from=builder /usr/sbin/e2guardian /usr/sbin/e2guardian
COPY --from=builder /usr/share/doc/e2guardian /usr/share/doc/e2guardian
COPY --from=builder /usr/share/e2guardian /usr/share/e2guardian
COPY --from=builder /usr/share/man/man8/e2guardian.8 /usr/share/man/man8/e2guardian.8

RUN mkdir /var/log/e2guardian
RUN chmod a+rw /var/log/e2guardian

RUN apk add --update pcre libgcc libstdc++ && \
	rm -rf /var/cache/apk/*

WORKDIR /

COPY e2guardian.conf /etc/e2guardian/e2guardian.conf
COPY e2guardianf1.conf /etc/e2guardian/e2guardianf1.conf

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1344

ENTRYPOINT ["sh", "/entrypoint.sh"]
