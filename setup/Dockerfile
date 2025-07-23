from ubuntu:latest
RUN apt-get update && apt-get install -y curl
COPY setup.sh .
USER root
RUN chmod +x setup.sh
CMD ["/bin/bash", "setup.sh"]