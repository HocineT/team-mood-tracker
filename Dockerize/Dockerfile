FROM ubuntu:14.04
LABEL Description="Team-mood-tracker (`master`) from ruby:2.2.4"

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  git \
  postgresql-client \
  nodejs \
  sqlite3\
  libsqlite3-dev \
  bundler \
  ruby \
  
&& rm -rf /var/lib/apt/lists/*


RUN mkdir -p /srv
WORKDIR /srv
RUN git clone https://github.com/starmer/team-mood-tracker.git
#RUN git clone https://github.com/HocineT/team-mood-tracker.git

WORKDIR /srv/team-mood-tracker

#using SQLITE no need for cumbersome PostgreSQL setup 
#COPY Gemfile Gemfile.lock ./ 
#RUN gem update bundler
RUN gem install bundler && bundle install --jobs 20 --retry 5
RUN rake db:migrate
# Copy the main application.
COPY . ./
#rails s

# Expose port 3000 to the Docker host, so we can access it 
# from the outside.
#EXPOSE 3000

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
