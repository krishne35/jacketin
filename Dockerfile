FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic
WORKDIR /app
# set version label
ARG BUILD_DATE
ARG VERSION
ARG JACKETT_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config" \
PORT=9117

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	jq \
	libicu60 \
	libssl1.0 \
	wget && \
 echo "**** install jackett ****" && \
 mkdir -p \
	/app/Jackett && \
 if [ -z ${JACKETT_RELEASE+x} ]; then \
	JACKETT_RELEASE=$(curl -sX GET "https://api.github.com/repos/Jackett/Jackett/releases/latest" \
	| jq -r .tag_name); \
 fi && \
 curl -o \
 /tmp/jacket.tar.gz -L \
	"https://github.com/Jackett/Jackett/releases/download/${JACKETT_RELEASE}/Jackett.Binaries.LinuxAMDx64.tar.gz" && \
 tar xf \
 /tmp/jacket.tar.gz -C \
	/app/Jackett --strip-components=1 && \
 echo "**** fix for host id mapping error ****" && \
 chown -R root:root /app/Jackett && \
 echo "**** save docker image version ****" && \
 echo "${VERSION}" > /etc/docker-image && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

COPY ./config /config
EXPOSE 9117
CMD exec /app/Jackett/jackett --NoRestart --NoUpdates -p $PORT
