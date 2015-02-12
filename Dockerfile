FROM zooniverse/ruby:2.2.0

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends autoconf automake libboost-all-dev libffi-dev git-core && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /cellect_panoptes
ADD . /cellect_panoptes

RUN bundle install --without development
RUN chmod +x /cellect_panoptes/start

EXPOSE 80

ENTRYPOINT /cellect_panoptes/start
