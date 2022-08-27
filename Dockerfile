# Container image that runs your code
FROM python:latest

#RUN apt-get install python3
# RUN apt-get install latexmk texlive-latex-extra
RUN pip install sphinx sphinx-rtd-theme

COPY ./api-gen.sh /api-gen.sh
COPY ./api-ref.sh /api-ref.sh
COPY ./api-test.sh /api-test.sh
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /api-gen.sh /api-ref.sh /api-test.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT /entrypoint.sh $INPUT_TYPE $INPUT_DIR
