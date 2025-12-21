ARG VERSION
FROM ghcr.io/jellyfin/jellyfin:${VERSION}

ENV JELLYFIN_CONFIG_DIR=/config
ENV JELLYFIN_DATA_DIR=/config/data
ENV JELLYFIN_LOG_DIR=/config/log
ENV JELLYFIN_CACHE_DIR=/config/cache

COPY ./jellyfin/config.json /jellyfin/jellyfin-web/config.json

#RUN sed 's|</body>|<script defer data-api="https://tjo.space/api/event" data-domain="media.tjo.space" src="https://tjo.space/js/script.js"></script></body>|' -i /jellyfin/jellyfin-web/index.html
