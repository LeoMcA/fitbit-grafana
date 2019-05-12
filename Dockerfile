FROM ruby:alpine
RUN mkdir /myapp
WORKDIR /myapp
RUN gem install bundler:2.0.1
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
COPY fitbit-export.rb .
CMD ["bundle", "exec", "./fitbit-export.rb", "-o", "0.0.0.0"]
