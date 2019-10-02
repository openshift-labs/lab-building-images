#!/bin/bash

set -x

set -eo pipefail

pip3 install --no-cache-dir warpdrive==0.31.0

warpdrive build

warpdrive fixup /opt/app-root
