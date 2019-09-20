#!/bin/bash
# Docker entrypoint script.

while ! pg_isready -q -h $PG_HOST -p $PG_PORT -U $PG_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

./bin/beespot_backend eval "BeespotBackend.Release.migrate"
echo "Database created."

exec ./bin/beespot_backend start