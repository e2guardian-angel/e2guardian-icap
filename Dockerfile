FROM alpine:3.12.1 as builder
WORKDIR /tmp/buid
ARG E2GUARDIAN_ROOT=/opt/e2guardian

RUN mkdir -p ${E2GUARDIAN_ROOT} \
  && apk add --update autoconf automake gcc cmake g++ zlib zlib-dev pcre2 pcre2-dev build-base gcc abuild binutils binutils-doc gcc-doc pcre pcre-dev git \
  && git clone https://github.com/justinschw/e2guardian.git \
  && cd e2guardian && ./autogen.sh && ./configure --prefix=${E2GUARDIAN_ROOT} && make && make install

FROM alpine:3.12.1
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>
ARG E2GUARDIAN_ROOT=/opt/e2guardian

COPY --from=builder /opt /opt

RUN mkdir -p ${E2GUARDIAN_ROOT}/var/log/e2guardian \
  && chown -R nobody:nobody ${E2GUARDIAN_ROOT}/ \
  && chmod a+rw ${E2GUARDIAN_ROOT}/var/log/e2guardian \
  && apk add --update pcre libgcc libstdc++ \
  && rm -rf /var/cache/apk/*

WORKDIR /

COPY e2guardian.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf
COPY e2guardianf1.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1344

ENTRYPOINT ["sh", "/entrypoint.sh"]
