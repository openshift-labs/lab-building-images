#!/bin/bash

set -x

set -eo pipefail

pip3 install --no-cache-dir -r requirements.txt

fix-permissions /opt/app-root
