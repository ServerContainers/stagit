FROM alpine as builder

RUN apk add --no-cache libc-dev libgit2-dev make gcc git \
 && git clone git://git.codemadness.org/stagit \
 && cd stagit \
 && git log -1 | grep Date: > /version \
 && make \
 && make install

FROM alpine

COPY --from=builder /usr/local/bin/stagit /usr/local/bin/stagit
COPY --from=builder /usr/local/bin/stagit-index /usr/local/bin/stagit-index
COPY --from=builder /version /version

RUN apk add --no-cache git libgit2

COPY . /container/

CMD /container/generate.sh
