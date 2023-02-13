FROM alpine:latest
MAINTAINER Justin Schwartzbeck <justinmschw@gmail.com>
ARG E2GUARDIAN_ROOT=/
ARG GUARDIAN_GROUP=guardian.angel
ARG VERSION

RUN apk add --update e2guardian \
  && rm -rf /var/cache/apk/* \
  && mkdir /var/run/e2guardian \
  && chown -R e2guard:e2guard  /var/run/e2guardian \
  && mv /etc/e2guardian/lists/example.group /etc/e2guardian/lists/${GUARDIAN_GROUP} \
  && cp /etc/e2guardian/e2guardian.conf /etc/e2guardian/e2guardian.conf.orig \
  && cp /etc/e2guardian/e2guardianf1.conf /etc/e2guardian/e2guardianf1.conf.orig \
  && sed -i "s/^\#*\s*icapport/icapport/g" /etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*maxcontentfiltersize.*$/maxcontentfiltersize=4096/g" /etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*maxcontentramcachescansize.*$/maxcontentramcachescansize=4096/g" /etc/e2guardian/e2guardian.conf \
  && echo "pidfilename = '/var/run/e2guardian/e2guardian.pid'" >> /etc/e2guardian/e2guardian.conf \
  && sed -i "s/^\#*\s*textmimetypes/textmimetypes/g" /etc/e2guardian/e2guardianf1.conf \
  && sed -i "s~^\.Define.*~.Define LISTDIR </etc/e2guardian/lists/${GUARDIAN_GROUP}>~g" /etc/e2guardian/e2guardianf1.conf

WORKDIR /

ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENV E2GVERSION ${VERSION}

EXPOSE 1344

USER e2guard

ENTRYPOINT ["sh", "/entrypoint.sh"]
