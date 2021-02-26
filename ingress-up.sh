#!/usr/bin/env bash

INGRESS_FILE_YML="${TRAEFIK_YML:-docker-compose.yml}"
INGRESS_FILE_ACME="${TRAEFIK_ACME:-traefik/acme.json}"
INGRESS_FILE_BASIC_AUTH="${TRAEFIK_BASIC_AUTH:-traefik/basic-auth.htpasswd}"
INGRESS_FILE_CONF="${TRAEFIK_CONF:-traefik/traefik.yml}"
INGRESS_STACK_NAME="${STACK_NAME:-ingress}"

if [ -z "$1" ]; then
  echo "Email must be provided!"

  exit
fi

ingressCreateConfigIfNotExists() {
  local email=$1 && shift

  while [[ $# -gt 0 ]]
  do
    INGRESS_file=(${1//./ })
    INGRESS_file[0]=$(echo "${INGRESS_file[0]//// }" | awk '{ print $NF }')

    case "${INGRESS_file[0]}" in
      docker-compose)
        if [[ ! -f "$1" ]]; then
          echo " + $1 doesn't exist. Create"
          cp "traefik/${INGRESS_file[0]}.example.${INGRESS_file[1]}" "${INGRESS_FILE_YML}"
        else
          echo " • $1 exists. Skip"
        fi
        shift
        ;;
      acme)
        if [[ ! -f "$1" ]]; then
          echo " + $1 doesn't exist. Create"
          cp "traefik/${INGRESS_file[0]}.example.${INGRESS_file[1]}" "${INGRESS_FILE_ACME}"
          chmod 0600 "${INGRESS_FILE_ACME}"
        else
          echo " • $1 exists. Skip"
        fi
        shift
        ;;
      basic-auth)
        if [[ ! -f "$1" ]]; then
          echo " + $1 doesn't exist. Create"
          cp "traefik/${INGRESS_file[0]}.example.${INGRESS_file[1]}" "${INGRESS_FILE_BASIC_AUTH}"
        else
          echo " • $1 exists. Skip"
        fi
        shift
        ;;
      traefik)
        if [[ ! -f "$1" ]]; then
          echo " + $1 doesn't exist. Create"
          cp "traefik/${INGRESS_file[0]}.example.${INGRESS_file[1]}" "${INGRESS_FILE_CONF}"
          sed 's/your_email_here@example.com/'"$email"'/g' -i "${INGRESS_FILE_CONF}"
        else
          echo " • $1 exists. Skip"
        fi
        shift
        ;;
    esac
  done
}

ingressConfigure() {
  echo "Starting configure:"

  ingressCreateConfigIfNotExists "$1" "${INGRESS_FILE_YML}" "${INGRESS_FILE_ACME}" "${INGRESS_FILE_CONF}" "${INGRESS_FILE_BASIC_AUTH}"
}

ingressUp() {
  echo "Running $INGRESS_STACK_NAME stack"

  docker stack up -c docker-compose.yml "$INGRESS_STACK_NAME"
}

main() {
  ingressConfigure "$1"
  ingressUp
}

main "$@"
