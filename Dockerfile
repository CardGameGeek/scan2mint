# Download imagemagick script from Fred Winehouse
FROM debian:latest as fredwinehouse
WORKDIR /app
RUN apt update && apt install curl --no-install-recommends --ignore-missing --quiet --assume-yes
RUN mkdir -p /app/scripts
RUN curl --output /app/scripts/accentedges --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=accentedges&dirname=accentedges"
RUN curl --output /app/scripts/adaptivegamma --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=adaptivegamma&dirname=adaptivegamma"
RUN curl --output /app/scripts/aspect --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=aspect&dirname=aspect"
RUN curl --output /app/scripts/autocolor --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=autocolor&dirname=autocolor"
RUN curl --output /app/scripts/autolevel --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=autolevel&dirname=autolevel"
RUN curl --output /app/scripts/autotrim --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=autotrim&dirname=autotrim"
RUN curl --output /app/scripts/binomialedge --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=binomialedge&dirname=binomialedge"
RUN curl --output /app/scripts/duotonemap --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=duotonemap&dirname=duotonemap"
RUN curl --output /app/scripts/enrich --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=enrich&dirname=enrich"
RUN curl --output /app/scripts/noisecleaner --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=noisecleaner&dirname=noisecleaner"
RUN curl --output /app/scripts/notch --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=notch&dirname=notch"
RUN curl --output /app/scripts/otsuthresh --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=otsuthresh&dirname=otsuthresh"
RUN curl --output /app/scripts/phashes --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=phashes&dirname=phashes"
RUN curl --output /app/scripts/phashcompare --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=phashcompare&dirname=phashcompare"
RUN curl --output /app/scripts/phashconvert --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=phashconvert&dirname=phashconvert"
RUN curl --output /app/scripts/redist --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=redist&dirname=redist"
RUN curl --output /app/scripts/retinex --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=retinex&dirname=retinex"
RUN curl --output /app/scripts/space2 --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=space2&dirname=space2"
RUN curl --output /app/scripts/spectrum --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=spectrum&dirname=spectrum"
RUN curl --output /app/scripts/textdeskew --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=textdeskew&dirname=textdeskew"
RUN curl --output /app/scripts/xtract --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=xtract&dirname=xtract"
COPY src/scripts/deskew /app/scripts/deskew
RUN chmod 755 /app/scripts/*
RUN curl --output /app/scripts/fredwinehouse_license.html --silent --show-error --url "http://www.fmwconcepts.com/imagemagick/index.php"
RUN echo "The scripts in this folder are the creative work of Fred Winehouse. Information about distribution and reuse of his scripts can be found here: http://www.fmwconcepts.com/imagemagick/index.php" >> /app/scripts/license.md


# Prepare Directory structure
FROM alpine:latest as preperation
WORKDIR /app
RUN	mkdir -p /app/destination \
	mkdir -p /app/source && \
	mkdir -p /app/stage0 && \
	mkdir -p /app/staging && \
	touch me
COPY src/Makefile /app
COPY src/pushsource.sh /app
COPY src/processqueue.sh /app

# Copy all necessary configfiles to the right spot
FROM scratch as configuration
WORKDIR /etc
COPY src/redis.conf redis/redis.conf
COPY src/supervisord.conf supervisord.conf
COPY src/incron.conf incron/incron.conf
COPY src/incron.d/scan2mint incron/incron.d/scan2mint



# Install all required packages on top of debian
# ATTN: Structured into several Layers, so installations that depend on each other
#       are grouped together.
#       The dpkg.cfg.d hack will keep the image cleaner (and smaller as well) at the
#       cost of several warnings during the build process. Other packages might fail
#       alltogether, so this isn't a general solution for fusing several services into
#       one image.
FROM debian:latest as apt
COPY src/dpkg.cfg.d/ignore_trash /etc/dpkg/dpkg.cfg.d
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
                bc \
                imagemagick \
		gawk && \
    rm -rf /var/lib/apt/lists/*
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
                incron && \
    rm -rf /etc/incron.allow /etc/incron.conf /etc/incron.d /etc/incron.deny \
    rm -rf /var/lib/apt/lists/*
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
                make && \
    rm -rf /var/lib/apt/lists/*
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
		redis-server \
		redis-tools && \
    rm -rf /var/lib/apt/lists/*
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
		supervisor && \
    rm -rf /var/lib/apt/lists/*
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
		procps \
		vim && \
    rm -rf /var/lib/apt/lists/*
# make incrond from source (0.5.12) and hopefully install over apted version (0.5.10)
RUN apt update && \
    apt install --no-install-recommends --ignore-missing --quiet --assume-yes \
                ca-certificates \
                curl \
		g++ && \
    cd /usr/local/src && \
    curl --output /usr/local/src/master.tar.gz --silent --show-error --location --url "https://github.com/ar-/incron/archive/master.tar.gz" && \
    tar -xvzf master.tar.gz && \
    rm master.tar.gz && \
    cd /usr/local/src/incron-master && \
    make -j2 install && \
    cd / && \
    rm -rf /usr/local/src/incron-master && \
    apt remove --quiet --assume-yes \
		ca-certificates \
                curl \
                g++
# cleanup unnecessaty packages
RUN apt update && \
    apt autoremove --quiet --assume-yes && \
    rm -rf /var/lib/apt/lists/*
    



# Blend everything together
FROM apt
LABEL description="scan2mint runs a series of filter scripts on scanned gaming or sports cards."
LABEL license="All imagemagick scripts are written by Fred Winehouse. Please refer to http://www.fmwconcepts.com/imagemagick/index.php for his license information."
LABEL maintainer="mike.hofmann@webax.de"
WORKDIR /app
COPY --from=fredwinehouse /app .
COPY --from=preperation /app .
COPY --from=configuration /etc /etc
COPY --from=preperation /app .
VOLUME /app/source /app/destination
ENV PATH /app/scripts:$PATH
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

