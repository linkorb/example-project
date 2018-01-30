FROM php:7.0-cli

COPY . /code
WORKDIR /code

CMD [ "php", "./bin/hello" ]
