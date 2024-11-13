#!/usr/bin/env bash

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# OpenCRVS is also distributed under the terms of the Civil Registration
# & Healthcare Disclaimer located at http://opencrvs.org/license.
#
# Copyright (C) The OpenCRVS Authors located at https://github.com/opencrvs/opencrvs-core/blob/master/AUTHORS.

# Log a message.
function log {
  echo "[+] $1"
}

# Log a message at a sub-level.
function sublog {
  echo "   ⠿ $1"
}

# Log an error.
function err {
  echo "[x] $1" >&2
}

# Poll the 'elasticsearch' service until it responds with HTTP code 200.
function wait_for_elasticsearch {
  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}' "http://${elasticsearch_host}:9200/" )

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local output

  # retry for max 300s (60*5s)
  for _ in $(seq 1 60); do
    output="$(curl "${args[@]}" || true)"
    if [[ "${output: -3}" -eq 200 ]]; then
      result=0
      break
    fi

    sleep 5
  done

  if ((result)); then
    echo -e "\n${output::-3}"
  fi

  return $result
}

# Verify that the given Elasticsearch user exists.
function check_user_exists {
  local username=$1

  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
    "http://${elasticsearch_host}:9200/_security/user/${username}"
    )

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local -i exists=0
  local output

  output="$(curl "${args[@]}")"
  if [[ "${output: -3}" -eq 200 || "${output: -3}" -eq 404 ]]; then
    result=0
  fi
  if [[ "${output: -3}" -eq 200 ]]; then
    exists=1
  fi

  if ((result)); then
    echo -e "\n${output::-3}"
  else
    echo "$exists"
  fi

  return $result
}

# Set password of a given Elasticsearch user.
function update_user {
  local username=$1
  local password=$2
  local role=${3:-}

  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  if [[ -n "${role:-}" ]]; then
    local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
      "http://${elasticsearch_host}:9200/_security/user/${username}"
      '-X' 'PUT'
      '-H' 'Content-Type: application/json'
      '-d' "{\"password\" : \"${password}\",\"roles\":[\"${role}\"]}}"
    )
  else
    local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
      "http://${elasticsearch_host}:9200/_security/user/${username}/_password"
      '-X' 'POST'
      '-H' 'Content-Type: application/json'
      '-d' "{\"password\" : \"${password}\"}"
    )
  fi

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local output

  output="$(curl "${args[@]}")"
  if [[ "${output: -3}" -eq 200 ]]; then
    result=0
  fi

  if ((result)); then
    echo -e "\n${output::-3}\n"
  fi

  return $result
}

# Create the given Elasticsearch user.
function create_user {
  local username=$1
  local password=$2
  local role=$3

  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
    "http://${elasticsearch_host}:9200/_security/user/${username}"
    '-X' 'POST'
    '-H' 'Content-Type: application/json'
    '-d' "{\"password\":\"${password}\",\"roles\":[\"${role}\"]}"
    )

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local output

  output="$(curl "${args[@]}")"
  if [[ "${output: -3}" -eq 200 ]]; then
    result=0
  fi

  if ((result)); then
    echo -e "\n${output::-3}\n"
  fi

  return $result
}

# Ensure that the given Elasticsearch role is up-to-date, create it if required.
function ensure_role {
  local name=$1
  local body=$2

  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
    "http://${elasticsearch_host}:9200/_security/role/${name}"
    '-X' 'PUT'
    '-H' 'Content-Type: application/json'
    '-d' "$body"
    )

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local output

  output="$(curl "${args[@]}")"
  if [[ "${output: -3}" -eq 200 ]]; then
    result=0
  fi

  if ((result)); then
    echo -e "\n${output::-3}\n"
  fi

  return $result
}

function ensure_settings {
  local body=$1

  local elasticsearch_host="${ELASTICSEARCH_HOST:-elasticsearch}"

  local -a args=( '-s' '-D-' '-m15' '-w' '%{http_code}'
    "http://${elasticsearch_host}:9200/_settings"
    '-X' 'PUT'
    '-H' 'Content-Type: application/json'
    '-d' "$body"
  )

  if [[ -n "${ELASTIC_PASSWORD:-}" ]]; then
    args+=( '-u' "elastic:${ELASTIC_PASSWORD}" )
  fi

  local -i result=1
  local output

  output="$(curl "${args[@]}")"
  if [[ "${output: -3}" -eq 200 ]]; then
    result=0
  fi

  if ((result)); then
    echo -e "\n${output::-3}\n"
  fi

  return $result
}
