FROM ruby:3.1

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install

COPY . /app

CMD ["ruby server.rb"]
