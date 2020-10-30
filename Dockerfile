# Base
FROM centos:7
LABEL maintainer="Damian Troy <github@black.hole.com.au>"
RUN yum -y update && yum clean all

# Common
VOLUME /config
ENV PUID=1001
ENV PGID=1001
RUN groupadd -g ${PGID} videos && \
    useradd --no-log-init -u ${PUID} -g videos -d /config -M videos
ENV TZ=Australia/Melbourne
COPY test.sh /usr/local/bin/

# App
VOLUME /videos
EXPOSE 7878
RUN yum -y install epel-release && \
    yum -y install nmap-ncat jq mono-core mono-devel mono-locale-extras curl mediainfo && \
    yum clean all
RUN URL=$(curl -s "https://api.github.com/repos/Radarr/Radarr/releases" |jq -r 'first( .[].assets[] | select( .name | endswith("linux.tar.gz") ).browser_download_url )') && \
    curl -sLo /tmp/Radarr.linux.tar.gz "$URL" && \
    tar xzf /tmp/Radarr.linux.tar.gz -C /opt && \
    rm -f /tmp/Radarr.linux.tar.gz && \
    chown -R ${PUID}:${PGID} /opt/Radarr

# Runtime
USER videos
CMD ["/usr/bin/mono","--debug","/opt/Radarr/Radarr.exe","-nobrowser"]

