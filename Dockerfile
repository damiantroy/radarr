# Base
FROM docker.io/rockylinux/rockylinux:8
LABEL maintainer="Damian Troy <github@black.hole.com.au>"
RUN dnf -y update && dnf clean all

# Common
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g ${PGID} videos && \
    useradd --no-log-init -u ${PUID} -g videos -d /config -M videos && \
    install -d -m 0755 -o videos -g videos /config /videos
ENV TZ=Australia/Melbourne
ENV LANG=C.UTF-8
COPY test.sh /usr/local/bin/

# App
RUN dnf -y install nmap-ncat gzip jq libicu && \
    dnf clean all
RUN curl -sLo /tmp/Radarr.master.linux-core-x64.tar.gz "http://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64" && \
    tar xzf /tmp/Radarr.master.linux-core-x64.tar.gz -C /opt && \
    chown -R "$PUID:$PGID" /opt/Radarr

# Runtime
VOLUME /config /videos
EXPOSE 7878
USER videos
CMD ["/opt/Radarr/Radarr","-nobrowser","-data=/config"]
