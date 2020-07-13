FROM alpine

RUN apk add --no-cache libgit2 \
 && apk add --no-cache libc-dev libgit2-dev make gcc git \
 && git clone git://git.codemadness.org/stagit \
 && cd stagit \
 && make \
 && make install \
 && cd / \
 && rm -rf stagit \
 && apk del --no-cache libc-dev libgit2-dev make gcc git

COPY build.sh /build.sh

CMD /build.sh
