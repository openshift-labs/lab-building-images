PYTHONUNBUFFERED=1
PYTHONIOENCODING=UTF-8
LC_ALL=en_US.UTF-8
LANG=en_US.UTF-8

export PYTHONUNBUFFERED
export PYTHONIOENCODING
export LC_ALL
export LANG

if [ -f /opt/app-root/venv/bin/activate ]; then
    . /opt/app-root/venv/bin/activate
fi
