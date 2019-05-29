# A Dockerfile for Blacklight
FROM centos:7.6.1810

MAINTAINER Cort Eyer

# Install Ruby and nodejs
RUN yum update -y
RUN yum install git-core curl deltarpm vim nano -y
RUN yum install automake libtool bison which -y
RUN yum install ruby -y
RUN gpg --keyserver hkp://eu.pool.sks-keyservers.net:80 --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"
RUN /bin/bash -l -c "rvm reload"
RUN /bin/bash -l -c "rvm requirements run"
RUN /bin/bash -l -c "rvm install 2.6"
RUN /bin/bash -l -c "rvm use 2.6 --default"
RUN yum install java-1.8.0-openjdk -y 
RUN curl -sL https://rpm.nodesource.com/setup_8.x | bash -
RUN yum install -y nodejs

#ENV PATH /usr/local/rvm/gems/ruby-*/bin:/usr/local/rvm/gems/ruby-*@global/bin:/usr/local/rvm/rubies/ruby-*/bin:$PATH:/usr/local/rvm/bin
#ENV GEM_PATH /usr/local/rvm/gems/ruby-*/bin:/usr/local/rvm/gems/ruby-*@global/bin:/usr/local/rvm/rubies/ruby-*/bin:$PATH:/usr/local/rvm/bin
#ENV GEM_HOME /usr/local/rvm/gems/ruby-*
ENV  BUNDLE_SILENCE_ROOT_WARNING=1

RUN /bin/bash -l -c "gem install bundler"
RUN /bin/bash -l -c "gem install rails"
RUN /bin/bash -l -c "gem install devise devise-guests"

# Download and install blacklight
WORKDIR /opt
#RUN rails new blacklight_disc
COPY . ./blacklight_discovery
WORKDIR /opt/blacklight_discovery
#COPY Gemfile Gemfile.lock ./

RUN /bin/bash -l -c "bundle update"
RUN /bin/bash -l -c "bundle install"
#RUN /bin/bash -l -c "rails generate blacklight:install --marc --devise"
RUN /bin/bash -l -c "rake db:migrate"

#RUN chmod -R 775 /usr/local/rvm/gems/ruby-*/gems/blacklight-marc-7.0.0.rc1/solr/conf

CMD SOLR_URL=http://solr:8983/solr/discovery 
CMD rm -f /opt/blacklight_discovery/tmp/pids/server.pid && /bin/bash -l -c "rails server -b '0.0.0.0'"
