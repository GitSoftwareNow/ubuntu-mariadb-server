#!/bin/bash
set -e

if [ ! -d "$MYSQL_DATADIR/mysql" ]; then
  echo 'Running mysql_install_db ...'
  mysql_install_db --datadir="$MYSQL_DATADIR"
  echo 'Finished mysql_install_db'

  tempSqlFile='/tmp/mysql-first-time.sql'
  cat > "$tempSqlFile" <<-EOSQL
DELETE FROM mysql.user ;
CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
DROP DATABASE IF EXISTS test ;
EOSQL

  if [ "$MYSQL_DATABASE" ]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "$tempSqlFile"
  fi

  if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
    echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$tempSqlFile"

    if [ "$MYSQL_DATABASE" ]; then
      echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "$tempSqlFile"
    fi
  fi

  echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
  set -- "$@" --init-file="$tempSqlFile"
fi

chown -R mysql:mysql "$MYSQL_DATADIR"

exec "$@"
