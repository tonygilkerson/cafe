# ###########################################
# # build docs
# ###########################################
FROM python:3.9 as docs

WORKDIR /build
# build docs
COPY . .

# Install deps
RUN pip install mkdocs-alabaster
# RUN pip install mkdocs-material
RUN pip install mkdocs-mermaid2-plugin
# RUN pip install mkdocs-simple-plugin

# build docs
RUN mkdocs build

###########################################
# package up only the app
###########################################
FROM bitnami/nginx:1.23

COPY nginx_server_block.conf /opt/bitnami/nginx/conf/server_blocks/nginx_server_block.conf
WORKDIR /app
# copy docs build from docs stage
COPY --from=docs /build/site .
EXPOSE 8080
