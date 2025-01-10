###########################################
# build
###########################################
FROM docker.io/fredericwernercc/mkdocs-material as dev

# COPY docs ./docs
# COPY mkdocs.yml .
RUN mkdir -p /home/appuser
RUN addgroup -S appuser && adduser -S appuser -G appuser -h /home/appuser

WORKDIR /home/appuser
# COPY . .
RUN chown -R appuser:appuser /home/appuser
# RUN chmod -R u+rwx /home/appuser
USER appuser

RUN git config --global user.name "Tony Gilkerson"
RUN git config --global user.email "tonygilkerson@yahoo.com"
RUN git clone https://github.com/tonygilkerson/cafe.git

WORKDIR /home/appuser/cafe

RUN python3 -m venv .vdockerenv
RUN source .vdockerenv/bin/activate
RUN pip3 install mkdocs-material
RUN pip3 install mkdocs-mermaid2-plugin
RUN mkdocs build --clean


EXPOSE 8000
ENTRYPOINT [ "/bin/sh", "-c"]
CMD [ "mkdocs serve --dev-addr 0.0.0.0:8000 & echo Starting;\
        while true; do \
          echo git pull...;\
          git pull;\
          sleep 15;\
        done;" \
]
# mkdocs serve --dev-addr 0.0.0.0:8000 &; \