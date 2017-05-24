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
CMD ["bash", "entrypoint.sh"]
