FROM zooniverse/ruby:2.1.5

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

WORKDIR /cellect_panoptes

ADD . /cellect_panoptes

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends autoconf automake libboost-all-dev libffi-dev git-core && \
    apt-get clean && \
    bundle install && \
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chmod +x /cellect_panoptes/start

ENTRYPOINT /cellect_panoptes/start
