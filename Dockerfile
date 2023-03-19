FROM alpine

RUN apk add --no-cache libgit2 \
 && apk add --no-cache libc-dev libgit2-dev make gcc git \
 && git clone git://git.codemadness.org/stagit \
 && cd stagit \
 && make \
 && make install \
 \
 && echo "cleanups..." \
 && cd / \
 && rm -rf stagit \
 && apk del --no-cache libc-dev libgit2-dev make gcc

COPY . /container/

CMD /container/generate.sh
