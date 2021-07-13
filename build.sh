#!/bin/bash
. ./env_setup.sh

docker build --tag "${IMG_NAME}" .