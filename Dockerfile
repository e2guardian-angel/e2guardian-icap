FROM alpine:3.12.1 as builder
WORKDIR /tmp/buid
ARG E2GUARDIAN_ROOT=/opt

RUN mkdir -p ${E2GUARDIAN_ROOT} \
  && apk add --update autoconf automake gcc cmake g++ zlib zlib-dev pcre2 pcre2-dev build-base gcc abuild binutils binutils-doc gcc-doc pcre pcre-dev git \
  && git clone https://github.com/justinschw/e2guardian.git \
  && cd e2guardian && ./autogen.sh && ./configure --prefix=${E2GUARDIAN_ROOT} && make && make install

FROM alpine:3.12.1
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>
ARG E2GUARDIAN_ROOT=/opt

COPY --from=builder /opt /opt

RUN mkdir -p ${E2GUARDIAN_ROOT}/var/log/e2guardian \
  && chown -R nobody:nobody ${E2GUARDIAN_ROOT}/ \
  && chmod a+rw ${E2GUARDIAN_ROOT}/var/log/e2guardian \
  && apk add --update pcre libgcc libstdc++ jq \
  && rm -rf /var/cache/apk/* \
  && cp ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf.orig \
  && cp ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf.orig \
  && sed -i "s/^\#*\s*icapport/icapport/g" ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*maxcontentfiltersize.*$/maxcontentfiltersize=4096/g" ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*maxcontentramcachescansize.*$/maxcontentramcachescansize=4096/g" ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*textmimetypes/textmimetypes/g" ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf \
  && cp ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardian.conf.mod \
  && cp ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf ${E2GUARDIAN_ROOT}/etc/e2guardian/e2guardianf1.conf.mod

WORKDIR /

ADD ./entrypoint.sh /entrypoint.sh
ADD ./confige2g.sh /confige2g.sh
RUN chmod +x /entrypoint.sh /confige2g.sh

EXPOSE 1344

ENTRYPOINT ["sh", "/entrypoint.sh"]
