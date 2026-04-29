FROM ruby:3.2.2-slim

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile* ./
RUN bundle install

COPY . .

EXPOSE 9292

CMD ["bash", "-lc", "bundle exec rake db:migrate && bundle exec rackup -p 9292 -o 0.0.0.0"]
