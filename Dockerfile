FROM eclipse-temurin:21-jre

ENV ACTIVEMQ_VERSION 5.18.6
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV SHA512_VAL=75db49bfa830075fc2a808991e6f7bd59e3c9cbcee3acd74916b619c41ec47d1750c1f87b913f6d79361b72702a8e0cc8d79fb8301d0fbcb4ccb87ecc6578378


ENV ACTIVEMQ_HOME /opt/activemq

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /opt && \
    wget --no-verbose https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz  -O $ACTIVEMQ-bin.tar.gz &&\
    # Validate checksum
    if [ "$SHA512_VAL" != "$(sha512sum $ACTIVEMQ-bin.tar.gz | awk '{print($1)}')" ];\
    then \
        echo "sha512 values doesn't match! exiting."  && \
        exit 1; \
    fi; \
    tar -xvzf $ACTIVEMQ-bin.tar.gz -C /opt && \
    rm $ACTIVEMQ-bin.tar.gz && \
    mv /opt/$ACTIVEMQ $ACTIVEMQ_HOME && \
    addgroup --system activemq && \
    adduser --system --no-create-home --ingroup activemq --home $ACTIVEMQ_HOME activemq && \
    chown -R activemq:activemq $ACTIVEMQ_HOME && \
    chown -h activemq:activemq $ACTIVEMQ_HOME

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

USER activemq
WORKDIR $ACTIVEMQ_HOME

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE $ACTIVEMQ_TCP $ACTIVEMQ_AMQP $ACTIVEMQ_STOMP $ACTIVEMQ_MQTT $ACTIVEMQ_WS $ACTIVEMQ_UI


#CMD ["/bin/sh", "-c", "bin/activemq console"]
