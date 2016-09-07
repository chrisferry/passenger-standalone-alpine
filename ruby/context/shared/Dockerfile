FROM alpine:3.4

ENV PASSENGER_VERSION="5.0.30" \
    PATH="/opt/passenger/bin:$PATH"

# Run when Alpine cdn is down
# RUN sed -i -e 's/dl-cdn/dl-4/g' /etc/apk/repositories

COPY packages /packages
ARG RUBY_VERSION=ruby_version_missing
RUN apk add --allow-untrusted --no-cache \
	/packages/x86_64/ruby-libs-$RUBY_VERSION*.apk \
	/packages/x86_64/ruby-$RUBY_VERSION*.apk

# RUN apk add --no-cache ruby
# RUN apk add --no-cache --virtual build-deps binutils build-base ruby-dev linux-headers curl-dev pcre-dev ruby-rake && \
#     apk add --no-cache -X http://dl-3.alpinelinux.org/alpine/edge/main libexecinfo libexecinfo-dev && \
#     apk add --no-cache ca-certificates curl procps pcre libstdc++ && \
# # Download and extract
#     mkdir -p /opt && \
#     curl -sSL https://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz | tar -xzf - -C /opt && \
#     mv /opt/passenger-$PASSENGER_VERSION /opt/passenger && \
#     export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo' && \
# # Install gosu
#     curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.4/gosu-amd64" && chmod +x /usr/local/bin/gosu && \
# # Compile agent
#     passenger-config compile-agent --auto --optimize && \
#     passenger-config install-standalone-runtime --auto --url-root=fake --connect-timeout=1 && \
#     passenger-config build-native-support && \
# # Cleanup passenger src directory
#     rm -rf /tmp/* && \
#     mv /opt/passenger/src/ruby_supportlib /tmp && \
#     mv /opt/passenger/src/nodejs_supportlib /tmp && \
#     mv /opt/passenger/src/helper-scripts /tmp && \
#     rm -rf /opt/passenger/src/* && \
#     mv /tmp/* /opt/passenger/src/ && \
# # Cleanup
#     passenger-config validate-install --auto && \
#     strip --strip-debug /opt/passenger/buildout/support-binaries/* && \
#     apk del build-deps libexecinfo-dev && \
#     rm -rf /tmp/* /opt/passenger/doc && \
# # App directory
#     mkdir -p /usr/src/app
# 
# # Node.JS Section
# ENV NODE_VERSION=v6.4.0 NPM_VERSION=2
# RUN apk add libgcc libstdc++ && \
#     apk add --virtual node-deps --no-cache curl make gcc g++ python linux-headers paxctl gnupg && \
#     gpg --keyserver ha.pool.sks-keyservers.net --recv-keys \
#       9554F04D7259F04124DE6B476D5A82AC7E37093B \
#       94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
#       0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
#       FD3A5288F042B6850C66B31F09FE44734EB7990E \
#       71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
#       DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
#       C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
#       B9AE9905FFD7803F25714661B63B535A4C206CA9 && \
#     curl -o node-${NODE_VERSION}.tar.gz -sSL https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.tar.gz && \
#     curl -o SHASUMS256.txt.asc -sSL https://nodejs.org/dist/${NODE_VERSION}/SHASUMS256.txt.asc && \
#     gpg --verify SHASUMS256.txt.asc && \
#     grep node-${NODE_VERSION}.tar.gz SHASUMS256.txt.asc | sha256sum -c - && \
#     tar -zxf node-${NODE_VERSION}.tar.gz && \
#     cd node-${NODE_VERSION} && \
#     export GYP_DEFINES="linux_use_gold_flags=0" && \
#     ./configure --prefix=/usr --without-npm && \
#     NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
#     make -j${NPROC} -C out mksnapshot BUILDTYPE=Release && \
#     paxctl -cm out/Release/mksnapshot && \
#     make -j${NPROC} && \
#     make install && \
#     paxctl -cm /usr/bin/node && \
#     cd / && \
#     apk del node-deps && \
#     rm -rf /node-${NODE_VERSION}.tar.gz /SHASUMS256.txt.asc /node-${NODE_VERSION} \
#       /usr/share/man /tmp/* /var/cache/apk/* /root/.gnupg
# 
ADD reaper.rb /bin/reaper
RUN chmod +x /bin/reaper

WORKDIR /usr/src/app
RUN addgroup -g 7999 app && adduser -u 7999 -D -G app app

EXPOSE 3000

ENTRYPOINT ["gosu app reaper", "--", "passenger", "start", "--no-install-runtime", "--no-compile-runtime", "--log-file=/dev/stdout"]
