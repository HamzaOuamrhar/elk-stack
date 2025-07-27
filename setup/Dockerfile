FROM elasticsearch:8.17.5
COPY setup.sh .
USER root
RUN chmod +x setup.sh
ENTRYPOINT ["/bin/bash", "setup.sh"]