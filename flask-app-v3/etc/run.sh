#!/bin/bash

set -x

set -eo pipefail

exec python3 wsgi.py
