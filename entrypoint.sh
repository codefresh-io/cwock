#! /bin/bash

while true; \
    do bin/rake db:create db:migrate \
            && rm -f /app/tmp/pids/server.pid \
            && bundle exec spring rails s -p 3000 -b '0.0.0.0' \
            && echo "Cwock shut down gracefully, restarting in 3s" \
            || echo "Cwock failed miserably, restarting in 3s"; \
       sleep 3;
done
