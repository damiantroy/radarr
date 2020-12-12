# Base
FROM centos:8
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
RUN dnf -y install dnf-plugins-core epel-release && \
    (dnf config-manager --set-enabled PowerTools || dnf config-manager --set-enabled powertools) && \
    dnf -y install nmap-ncat jq libicu mediainfo && \
    dnf clean all
RUN RELEASE=$(curl -s "https://radarr.servarr.com/v1/update/master/changes?os=linux" | jq -r '.[0].version') && \
    curl -sLo /tmp/Radarr.linux.tar.gz "https://radarr.servarr.com/v1/update/master/updatefile?version=${RELEASE}&os=linux&runtime=netcore&arch=x64" && \
    tar xzf /tmp/Radarr.linux.tar.gz -C /opt && \
    rm -f /tmp/Radarr.linux.tar.gz && \
    chown -R "$PUID:$PGID" /opt/Radarr

# Runtime
VOLUME /config /videos
EXPOSE 7878
USER videos
CMD ["/opt/Radarr/Radarr","-nobrowser","-data=/config"]
