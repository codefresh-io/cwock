FROM rails:4.2.5.1
# NOTE node for development (requirejs-rails precompile)
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev node
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

RUN mkdir /app
WORKDIR /app
ADD . /app

# XXX script this out as an ENTRYPOINT or something
CMD while true; \
    do bin/rake db:create db:migrate \
    && rm -f /app/tmp/pids/server.pid \
    && bin/rails s -p 3000 -b '0.0.0.0' \
    && echo "Cwock shut down gracefully, restarting in 3s" \
    || echo "Cwock failed miserably, restarting in 3s"; \
    sleep 3; done
