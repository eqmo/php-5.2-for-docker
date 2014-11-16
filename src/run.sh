#!/usr/bin/env bash

dnsLookup() {
  echo "$(host "${1}" | awk '/has address/ { print $4 }')"
}

if [ -z "${SSMTP_PORT_25_TCP}" ] && [ -n "${SSMTP_PORT_25_TCP_ADDR}" ] && [ -n "${SSMTP_PORT_25_TCP_PORT}" ]; then
  IP="$(dnsLookup "${SSMTP_PORT_25_TCP_ADDR}")"

  if [ ! -z "${IP}" ]; then
    SSMTP_PORT_25_TCP_ADDR="${IP}"
  fi

  SSMTP_PORT_25_TCP="tcp://${SSMTP_PORT_25_TCP_ADDR}:${SSMTP_PORT_25_TCP_PORT}"
fi

export FACTER_SSMTP_PORT_25_TCP="$(echo "${SSMTP_PORT_25_TCP}" | sed 's/tcp:\/\///')"

if [ -z "${MYSQLD_PORT_3306_TCP}" ] && [ -n "${MYSQLD_PORT_3306_TCP_ADDR}" ] && [ -n "${MYSQLD_PORT_3306_TCP_PORT}" ]; then
  IP="$(dnsLookup "${MYSQLD_PORT_3306_TCP_ADDR}")"

  if [ ! -z "${IP}" ]; then
    MYSQLD_PORT_3306_TCP_ADDR="${IP}"
  fi

  MYSQLD_PORT_3306_TCP="tcp://${MYSQLD_PORT_3306_TCP_ADDR}:${MYSQLD_PORT_3306_TCP_PORT}"
fi

export FACTER_MYSQLD_PORT_3306_TCP="$(echo "${MYSQLD_PORT_3306_TCP}" | sed 's/tcp:\/\///')"

puppet apply --modulepath=/src/run/modules /src/run/run.pp

/usr/bin/supervisord