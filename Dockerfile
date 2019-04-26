FROM node:6.11

ENV TINI_VERSION v0.15.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ARG user=esproxy
ARG uid=10000

ENV HOME /home/${user}
RUN useradd -c "Proxy User" -d $HOME -u ${uid} -g node -m ${user}

USER ${user}

RUN mkdir -p /home/${user}/app
WORKDIR /home/${user}/app

ENV NODE_ENV production
ADD package.json /home/${user}/app/
RUN npm install && npm cache clean
COPY . /home/${user}/app

# Add Tini
ENTRYPOINT ["/tini", "bin/aws-es-proxy", "--"]
EXPOSE 9200