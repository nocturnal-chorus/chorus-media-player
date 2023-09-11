#!/usr/bin/env bash
changed_service() {
  declare -A services
  for item in "$@"; do
    if [[ ${item#backend/service/*} != ${item} ]]; then
      tmp=${item#backend/service/*}
      module=${tmp%%/*}
      if [ -a "backend/service/${module}/main.go" ]; then
        services[${module}]="-"
      fi
    fi
  done
  echo ${!services[@]}
}

changed_service "$@"
# ./backend/service/scripts/core/tools.sh $(git diff --name-only 4dd8040df035f7a644cda042bba3d45ad4e6fece HEAD)