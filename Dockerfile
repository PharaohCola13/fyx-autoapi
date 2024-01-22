# Container image that runs your code
FROM debian:latest

# RUN apt-get install latexmk texlive-latex-extra
RUN apt-get update
RUN apt-get install jq -y
RUN pip install sphinx sphinx-rtd-theme

COPY ./style.json /style.json
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT /entrypoint.sh $INPUT_TYPE $INPUT_DIR
