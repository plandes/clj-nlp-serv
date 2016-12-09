FROM java:8

COPY nlparse /usr/src/app/nlparse
COPY model /usr/src/app/model
WORKDIR /usr/src/app
CMD ["nlparse/bin/nlparse", "service", "-p", "9112"]
