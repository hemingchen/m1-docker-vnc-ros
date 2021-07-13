#!/bin/bash
. ./env_setup.sh

docker container stop "${CONTAINER_NAME}" || true
docker container rm "${CONTAINER_NAME}" || true
docker run \
    --name "${CONTAINER_NAME}" \
    -d \
    -p 5901:5901 -p 6901:6901 \
    "${IMG_NAME}" \
    -w \
    -r "${VNC_RESOLUTION}" \
    -d "${VNC_COL_DEPTH}" \
    -p "${VNC_PW}"