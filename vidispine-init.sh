#!/usr/bin/env -S bash -ex
# (More info available via `man bash`)
# -x      Print the command before running it.
# -e      Exit immediately if a command returns a non-zero status.

vidispine db ping # verify connection
vidispine db migrate
vidispine db check # should succeed
vidispine serve

sleep 100 && curl -X POST "http://localhost:8080/APIinit/"
