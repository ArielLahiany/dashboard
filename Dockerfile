## Sets node:alpine as the builder.
#FROM node:alpine as builder
#
## Updates and installs required Linux dependencies.
#RUN set -eux; \
#    apk update; \
#    apk upgrade; \
#    apk add --no-cache \
#        nano \
#    ; \
#    rm -rf /var/cache/apk/*
#
## Installs required Node dependencies.
#COPY package*.json /saleor/
#WORKDIR /saleor
#RUN npm install
#
## Defines new group and user for security reasons.
#RUN addgroup -S saleor && adduser -S -G saleor saleor
#
## Copies the source code from the host into the container.
#COPY --chown=saleor:saleor . /saleor
#WORKDIR /saleor
#
#ARG APP_MOUNT_URI
#ARG API_URI
#ARG STATIC_URL
#ENV API_URI ${API_URI:-http://django:8000/graphql/}
#ENV APP_MOUNT_URI ${APP_MOUNT_URI:-/dashboard/}
#ENV STATIC_URL ${STATIC_URL:-/dashboard/}
#
## Executes npm build script.
#RUN STATIC_URL=${STATIC_URL} API_URI=${API_URI} APP_MOUNT_URI=${APP_MOUNT_URI} npm run build
#
## Expose the deafult port for Salor Dashboard.
#EXPOSE 9000
#
## Change to the new user for security reasons.
#USER saleor

FROM node:latest
WORKDIR /dashboard
COPY package*.json /dashboard/
RUN npm install
COPY . /dashboard
ARG APP_MOUNT_URI
ARG API_URI
ARG STATIC_URL
ENV API_URI ${API_URI:-http://django:8000/graphql/}
ENV APP_MOUNT_URI ${APP_MOUNT_URI:-/}
ENV STATIC_URL ${STATIC_URL:-/}
EXPOSE 9000
CMD npm start -- --host 0.0.0.0
