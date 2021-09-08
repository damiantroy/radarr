#!/usr/bin/env bash

# Select 'podman' or 'docker'
CONTAINER_RUNTIME=$(command -v podman 2> /dev/null || echo docker)

# Parameter handling
function usage() {
    echo "Usage: $(basename $0) -c <container_name> [-a <test|monitor>] [-p <package_file] [-t <temp_dir>]"
    exit 1
}

ACTION=test
TEMP_DIR=/var/tmp

while getopts "c:a:p:t:" OPT; do
    case "$OPT" in
        c) CONT_NAME=$OPTARG ;;
        a) ACTION=$OPTARG ;;
        p) PACKAGE_FILE=$OPTARG ;;
        t) TEMP_DIR=$OPTARG ;;
        *) usage ;;
    esac
done

if [[ -z "$CONT_NAME" ]]; then
    echo "Error: Missing container name (-c)." >&2
    echo
    usage
fi

if [[ -n "$PACKAGE_FILE" ]]; then
    FILE_FLAG="--file=$PACKAGE_FILE"
fi

# Temp handling
SNYK_TMP=$(mktemp -p "$TEMP_DIR" -d "snyk.XXXX")
echo $SNYK_TMP
function cleanup() {
    rm -rf $SNYK_TMP
}
trap cleanup EXIT

# Save the container to a file
${CONTAINER_RUNTIME} save "${CONT_NAME}" -o "${SNYK_TMP}/${CONT_NAME}"

# Scan the saved container with Snyk
snyk container "$ACTION" --project-name="${CONT_NAME}" \
    "docker-archive:${SNYK_TMP}/${CONT_NAME}" $FILE_FLAG

