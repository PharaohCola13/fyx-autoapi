# Container image that runs your code
FROM python:latest

#RUN apt-get install python3
# RUN apt-get install latexmk texlive-latex-extra
RUN pip install sphinx sphinx-rtd-theme

COPY ./style /style

COPY ./api-gen.sh /api-gen.sh
COPY ./api-ref.sh /api-ref.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod -R +x /*.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT /entrypoint.sh $INPUT_TYPE $INPUT_DIR
