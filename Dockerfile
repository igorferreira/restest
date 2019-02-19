# Based on:
# - https://github.com/jshimko/meteor-launchpad/blob/master/Dockerfile
# - https://github.com/meteor/galaxy-images/blob/master/ubuntu/Dockerfile
FROM ubuntu

# Default Meteor version if not defined at build time; see ../build.sh
ARG METEOR_VERSION=1.6

ENV HOME /opt/src
ENV SCRIPTS_FOLDER /docker
ENV APP_SOURCE_FOLDER /opt/src
ENV APP_BUNDLE_FOLDER /opt/bundle

RUN mkdir -p ${HOME}

WORKDIR ${HOME}

COPY . ${HOME}

# Install dependencies, based on https://github.com/jshimko/meteor-launchpad/blob/master/scripts/install-deps.sh (only the parts we plan to use)
RUN apt-get update && \
	apt-get install --assume-yes apt-transport-https ca-certificates && \
	apt-get install --assume-yes --no-install-recommends build-essential bsdtar bzip2 curl git python

# Install Meteor
RUN curl https://install.meteor.com --output ${HOME}/install-meteor.sh && \
	# Set the release version in the install script
	sed --in-place "s/RELEASE=.*/RELEASE=\"$METEOR_VERSION\"/g" /tmp/install-meteor.sh && \
	# Replace tar with bsdtar in the install script; https://github.com/jshimko/meteor-launchpad/issues/39
	sed --in-place "s/tar -xzf.*/bsdtar -xf \"\$TARBALL_FILE\" -C \"\$INSTALL_TMPDIR\"/g" /tmp/install-meteor.sh && \
	# Install Meteor
	printf "\n[-] Installing Meteor $METEOR_VERSION...\n\n" && \
	sh ${HOME}/install-meteor.sh
	# sh /tmp/install-meteor.sh 

# Fix permissions warning; https://github.com/meteor/meteor/issues/7959
ENV METEOR_ALLOW_SUPERUSER true

# Copy entrypoint and dependencies
#COPY ./docker $SCRIPTS_FOLDER/

# Install entrypoint dependencies
#RUN cd $SCRIPTS_FOLDER && \
#	meteor npm install

RUN meteor npm install

EXPOSE 3000

CMD npm start