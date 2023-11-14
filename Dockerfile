FROM eclipse-temurin:17-jre

ENV ACTIVEMQ_VERSION 5.18.3
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_TCP=61616 ACTIVEMQ_AMQP=5672 ACTIVEMQ_STOMP=61613 ACTIVEMQ_MQTT=1883 ACTIVEMQ_WS=61614 ACTIVEMQ_UI=8161
ENV SHA512_VAL=61abc4a08b9e1db6a5b1062bb1c839171e93bcb571817fd81744dd19874d713840bba99c7979d45bcb832d13ea01986b76fb11720f5ec63a0283e7d1934a33cc


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
