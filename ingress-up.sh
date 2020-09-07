#!/usr/bin/env bash

INGRESS_FILE_ACME="${TRAEFIK_ACME:-./traefik/acme.json}"
INGRESS_FILE_CONF="${TRAEFIK_CONF:-./traefik/traefik.yml}"
INGRESS_STACK_NAME="${STACK_NAME:-ingress}"

if [ -z "$1" ]; then
  echo "Email must be provided!"

  exit
fi

ingressConfigure() {
  echo "Starting configure:"

  local email=$1

  if [ ! -f "$INGRESS_FILE_ACME" ]; then
    echo "$INGRESS_FILE_ACME doesn't exist. Copy it and change the rights"

    cp traefik/acme.example.json "$INGRESS_FILE_ACME"
    chmod 0600 "$INGRESS_FILE_ACME"
  else
    echo "$INGRESS_FILE_ACME exists. Skip"
  fi

  if [ ! -f "$INGRESS_FILE_CONF" ]; then
    echo "$INGRESS_FILE_CONF doesn't exist. Copy it and change email"

    cp traefik/traefik.example.yml "$INGRESS_FILE_CONF"
    sed 's/your_email_here@example.com/'"$email"'/g' -i "$INGRESS_FILE_CONF"
  else
    echo "$INGRESS_FILE_CONF exists. Skip"
  fi
}

ingressUp() {
  echo "Running $INGRESS_STACK_NAME stack"

  docker stack up -c docker-ingress.yml "$INGRESS_STACK_NAME"
}

ingressConfigure "$1"
ingressUp