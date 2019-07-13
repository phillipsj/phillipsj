#! /usr/bin/env pwsh

podman run --rm -it -p 5080:5080 -v "$(pwd):/code/app:z" blog