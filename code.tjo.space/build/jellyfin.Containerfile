ARG VERSION
FROM ghcr.io/jellyfin/jellyfin:${VERSION}

ENV JELLYFIN_CONFIG_DIR=/config
ENV JELLYFIN_DATA_DIR=/config/data
ENV JELLYFIN_LOG_DIR=/config/log
ENV JELLYFIN_CACHE_DIR=/config/cache

COPY ./jellyfin/config.json /jellyfin/jellyfin-web/config.json

RUN sed 's|</body>|<script defer src="https://tjo.space/js/navbar-injector.js"></script></body>|' -i /jellyfin/jellyfin-web/index.html
