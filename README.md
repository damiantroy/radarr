# Radarr Movie Manager CentOS Container

## Configuration

| Command | Config   | Description
| ------- | -------- | -----
| ENV     | PUID     | UID of the runtime user (Default: 1001)
| ENV     | PGID     | GID of the runtime group (Default: 1001)
| ENV     | TZ       | Timezone (Default: Australia/Melbourne)
| VOLUME  | /videos  | Videos directory, including 'downloads/'
| VOLUME  | /config  | Configuration directory
| EXPOSE  | 7878/tcp | HTTP port for web interface

## Instructions

Build and run:
```shell script
PUID=1001
PGID=1001
TZ=Australia/Melbourne
VIDEOS_DIR=/videos
RADARR_CONFIG_DIR=/etc/config/radarr
RADARR_IMAGE=localhost/radarr # Or damiantroy/radarr if deploying from docker.io

sudo mkdir -p ${VIDEOS_DIR} ${RADARR_CONFIG_DIR}
sudo chown -R ${PUID}:${PGID} ${VIDEOS_DIR} ${RADARR_CONFIG_DIR}

# You can skip the 'build' step if deploying from docker.io
sudo podman build -t radarr .

sudo podman run -d \
    --pod video \
    --name=radarr \
    -e PUID=${PUID} \
    -e PGID=${PGID} \
    -e TZ=${TZ} \
    -v ${RADARR_CONFIG_DIR}:/config:Z \
    -v ${VIDEOS_DIR}:/videos:z \
    ${RADARR_IMAGE}
```
