FROM alpine

RUN apk add --no-cache libc-dev libgit2-dev make gcc git \
 && git clone git://git.codemadness.org/stagit \
 && cd stagit \
 && make \
 && make install

COPY build.sh /build.sh

CMD /build.sh
