#!/usr/bin/env bash

HOME_PATH=$(
  cd $(dirname ${0})
  pwd
)

SERVICE_PATH=${HOME_PATH}/service
PROTO_PATH=${HOME_PATH}/proto

main() {
  case "$1" in
    gateway)
      "${PROTO_PATH}"/gen-stub "${@:2}"
      ;;
    proto)
      "${PROTO_PATH}"/gen-stub "${@:2}"
      ;;
    service)
      "${SERVICE_PATH}"/scripts/build "${@:2}"
      ;;
    *)
    help
      ;;
  esac
}

help() {
  echo "$0 option"
  echo -e "\nOptions:"
  echo "    service proto gateway business consumer"
  exit 1
}

main "$@"
