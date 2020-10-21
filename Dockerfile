#
# MariaDB Dockerfile
#
# https://github.com/dockerfile/mariadb
#

# Pull base image.
FROM ubuntu:focal

ENV MARIADB_MAJOR 10.5
ENV MARIADB_VERSION 10.5.6
ENV MYSQL_ROOT_PASSWORD mysecretpassword
ENV MYSQL_DATADIR /var/lib/mysql

# Install MariaDB.
RUN apt-get update -y

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Stockholm /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get install -y gnupg2  lsb-core

RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys F1656F24C74CD1D8 && \
  echo "deb https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-10.5.6/repo/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/mariadb.list && \
  apt-get update && \
  apt-get install -y mariadb-server && \
  rm -rf /var/lib/apt/lists/* && \
  sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
  echo "mysqld_safe &" > /tmp/config && \
  echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
  echo "mysql -e 'GRANT ALL PRIVILEGES ON *.* TO \"root\"@\"%\" WITH GRANT OPTION;'" >> /tmp/config && \
  echo "mysql -e 'FLUSH PRIVILEGES;'" >> /tmp/config && \
  bash /tmp/config && \
  rm -f /tmp/config

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]


# Define mountable directories.
VOLUME ["/etc/mysql", "/var/lib/mysql"]

# Define working directory.
WORKDIR /

# Define default command.
CMD ["mysqld_safe"]

# Expose ports.
EXPOSE 3306
