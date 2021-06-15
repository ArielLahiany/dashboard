# Sets node:alpine as the builder.
FROM node:alpine as builder

# Updates and installs required Linux dependencies.
RUN set -eux; \
    apk update; \
    apk upgrade; \
    rm -rf /var/cache/apk/*

# Installs required Node dependencies.
COPY package*.json /saleor/
WORKDIR /saleor
RUN npm install

# Defines new group and user for security reasons.
RUN addgroup -S saleor && adduser -S -G saleor saleor

# Copies the source code from the host into the container.
COPY --chown=saleor:saleor . /saleor
WORKDIR /saleor

ARG APP_MOUNT_URI
ARG API_URI
ARG STATIC_URL
ENV API_URI ${API_URI:-http://django:8000/graphql/}
ENV APP_MOUNT_URI ${APP_MOUNT_URI:-/dashboard/}
ENV STATIC_URL ${STATIC_URL:-/dashboard/}

# Executes npm build script.
RUN STATIC_URL=${STATIC_URL} API_URI=${API_URI} APP_MOUNT_URI=${APP_MOUNT_URI} npm run build

# Sets nginx:alpine as the final image.
FROM nginx:alpine

# Copies the build from the main builder.
COPY --from=builder /saleor/build/ /saleor/

# Copies Nginx default configuration file.
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# Sets the main working directory.
WORKDIR /saleor

# Expose the deafult port for Salor Dashboard.
EXPOSE 9000

# Change to the new user for security reasons.
USER saleor
