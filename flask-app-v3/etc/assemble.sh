#!/bin/bash

python3 -m venv /opt/app-root

source /opt/app-root/bin/activate

pip3 install --no-cache-dir --upgrade pip setuptools wheel

pip3 install --no-cache-dir -r requirements.txt

fix-permissions /opt/app-root
