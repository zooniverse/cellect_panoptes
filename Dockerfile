FROM ruby:2.4-slim-jessie

WORKDIR /cellect_panoptes

ENV DEBIAN_FRONTEND noninteractive

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV CONFIGURE_OPTS --disable-install-rdoc --enable-shared

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
  autoconf automake build-essential \
      libboost-all-dev libffi-dev \
      git-core libpq-dev && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./Gemfile /cellect_panoptes/
ADD ./Gemfile.lock /cellect_panoptes/

RUN bundle install --without development test

ADD ./ /cellect_panoptes

RUN chmod +x /cellect_panoptes/cellect_start

EXPOSE 80

CMD [ "bundle", "exec", "./cellect_start" ]
