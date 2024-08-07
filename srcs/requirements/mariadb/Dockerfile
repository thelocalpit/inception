FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y mariadb-server

COPY ./conf/mdb-conf.sh /mdb-conf.sh
COPY ./conf/my_custom.cnf /etc/mysql/conf.d/

RUN chmod 755 /mdb-conf.sh

ENTRYPOINT ["/bin/bash", "/mdb-conf.sh"]
