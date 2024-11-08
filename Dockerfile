FROM openjdk:15-alpine

RUN \
	apk upgrade --no-cache \
	&& apk --no-cache add \
		bash \
		bash-completion \
		bash-doc \
		ca-certificates \
		curl \
		wget \
	&& update-ca-certificates
	
RUN apk add --no-cache \
        python3 \
	py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
        awscli 
	
RUN wget -O /tmp/CrushFTP9.zip https://www.crushftp.com/early9/CrushFTP9.zip
ADD ./setup.sh /var/opt/setup.sh

RUN chmod +x /var/opt/setup.sh

VOLUME [ "/var/opt/CrushFTP9" ]

ENTRYPOINT [ "/bin/bash", "/var/opt/setup.sh" ]
CMD ["-c"]

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -f ${CRUSH_ADMIN_PROTOCOL}://localhost:${CRUSH_ADMIN_PORT}/favivon.ico -H 'Connection: close' || exit 1

ENV CRUSH_ADMIN_PROTOCOL http
ENV CRUSH_ADMIN_PORT 8080

EXPOSE 21 443 22 2222 8080 8888 9022 9090
