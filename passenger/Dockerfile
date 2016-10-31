FROM phusion/ruby-alpine:2.3.1

ARG PASSENGER_VERSION="5.0.30"

ENV PATH="/opt/passenger/bin:$PATH"

RUN apk add --no-cache --virtual build-deps binutils build-base linux-headers curl-dev pcre-dev && \
    apk add --no-cache -X http://dl-3.alpinelinux.org/alpine/edge/main libexecinfo libexecinfo-dev && \
    apk add --no-cache ca-certificates curl procps pcre libstdc++ && \
# Download and extract
    mkdir -p /opt && \
    curl -sSL https://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz | tar -xzf - -C /opt && \
    mv /opt/passenger-$PASSENGER_VERSION /opt/passenger && \
    export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo' && \
# Install gosu
    curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" && chmod +x /usr/local/bin/gosu && \
# Compile agent
    passenger-config compile-agent --auto --optimize && \
    passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
    passenger-config build-native-support && \
# Cleanup passenger src directory
    rm -rf /tmp/* && \
    mv /opt/passenger/src/ruby_supportlib /tmp && \
    mv /opt/passenger/src/nodejs_supportlib /tmp && \
    mv /opt/passenger/src/helper-scripts /tmp && \
    rm -rf /opt/passenger/src/* && \
    mv /tmp/* /opt/passenger/src/ && \
# Cleanup
    passenger-config validate-install --auto && \
    strip --strip-debug /opt/passenger/buildout/support-binaries/* && \
    apk del build-deps libexecinfo-dev && \
    rm -rf /tmp/* /opt/passenger/doc && \
# App directory
    mkdir -p /usr/src/app

ADD reaper.rb /bin/reaper
RUN chmod +x /bin/reaper

WORKDIR /usr/src/app
RUN addgroup -g 7999 app && adduser -u 7999 -D -G app app

EXPOSE 3000

ENTRYPOINT ["gosu app reaper", "--", "passenger", "start", "--no-install-runtime", "--no-compile-runtime", "--log-file=/dev/stdout"]
