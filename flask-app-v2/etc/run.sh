#!/bin/bash

export PATH=$HOME/.local/bin:$PATH

export FLASK_APP=app.py

exec flask run --host=0.0.0.0 --port=8080
