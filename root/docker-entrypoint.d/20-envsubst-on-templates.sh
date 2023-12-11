#!/bin/sh
# shellcheck shell=dash

set -e

ME=$(basename "$0")

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

auto_envsubst() {
  local template_dir="$NWTF_CONFIG_DIR"
  local file_ext="${NGINX_ENVSUBST_FILE_EXTENSION:-.conf}"
  local output_dir="${NGINX_ENVSUBST_OUTPUT_DIR:-/etc/nginx}"
  local filter="${NGINX_ENVSUBST_FILTER:-}"

  local template defined_envs relative_path output_path subdir
  defined_envs=$(printf '${%s} ' $(awk "END { for (name in ENVIRON) { print ( name ~ /${filter}/ ) ? name : \"\" } }" < /dev/null ))
  [ -d "$template_dir" ] || return 0
  if [ ! -w "$output_dir" ]; then
    entrypoint_log "$ME: ERROR: $template_dir exists, but $output_dir is not writable"
    return 0
  fi
  find "$template_dir" -follow -type f -name "*$file_ext" -print | while read -r template; do
    relative_path="${template#"$template_dir/"}"
    output_path="$output_dir/$relative_path"
    subdir=$(dirname "$relative_path")
    # create a subdirectory where the template file exists
    mkdir -p "$output_dir/$subdir"
    entrypoint_log "$ME: Running envsubst on $template to $output_path"
    envsubst "$defined_envs" < "$template" > "$output_path"
  done
}

auto_envsubst

exit 0
