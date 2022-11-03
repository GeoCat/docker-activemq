FROM eclipse-temurin:17

ENV ACTIVEMQ_VERSION 5.17.2
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV SHA512_VAL=7c6ee4c1a9f58ccaa374d8528255d55c181c3402855fe06202bb30f722bdbd69a2cebaf0eded67324f94b4158b6d8d97b621d8730d92676e51b982ed4fc8a7b0


ENV ACTIVEMQ_HOME /opt/activemq

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
