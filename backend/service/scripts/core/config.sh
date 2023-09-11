get_service_list() {
  local location="$(pwd)/service"
  service_source=(${location}/*)

  for file in "${service_source[@]}"; do
    if [[ -f "$file/main.go" ]]; then
      services+=(${file##*/})
    fi
  done

  echo ${services[@]}
}

SERVICE_LIST=($(get_service_list))