###########################################
# build
###########################################
# FROM docker.io/fredericwernercc/mkdocs-material as dev
FROM squidfunk/mkdocs-material


RUN mkdir -p /home/appuser
RUN addgroup -S appuser && adduser -S appuser -G appuser -h /home/appuser

WORKDIR /home/appuser

RUN chown -R appuser:appuser /home/appuser
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


# Start mkdocs server in the background, it will watch for content changes
# Then start a loop that will pull content changes every so often
ENTRYPOINT [ "/bin/sh", "-c"]
CMD [ "mkdocs serve --dev-addr 0.0.0.0:8000 & echo Starting;\
        while true; do \
          echo git pull...;\
          git pull;\
          echo Sleep for 90 seconds, ZZZzzz...;\
          sleep 90;\
        done;" \
]
