#!/usr/local/bin/bash

type=""
author=""
comment=""

host_name=""
host_address=""
host_display_name=""

service_name=""
service_display_name=""
service_state=""
service_output=""

token=""
chat_id=""
proxy=""

date_time=""

curl=$(which curl)
[[ ! -f "${curl}" ]] && { echo "Curl binary not found"; exit 1; }

while [[ $# -gt 0 ]]; do
    case $1 in
        --token) token="$2"; shift; shift ;;
        --chat-id) chat_id="$2"; shift; shift ;;
        --type) type="$2"; shift; shift ;;
        --service-name) service_name="$2"; shift; shift ;;
        --host-name) host_name="$2"; shift; shift ;;
        --host-display-name) host_display_name="$2"; shift; shift ;;
        --host-address) host_address="$2"; shift; shift ;;
        --service-state) service_state="$2"; shift; shift ;;
        --long-date-time) date_time="$2"; shift; shift ;;
        --service-output) service_output="$2"; shift; shift ;;
        --notification-author) author="$2"; shift; shift ;;
        --notification-comment) comment="$2"; shift; shift ;;
        --service-display-name) service_display_name="$2"; shift; shift ;;
        --proxy) proxy="--proxy $2"; shift; shift; ;;
        *) shift ;;
      esac
done

[[ -z "${token}" ]] && { echo "No token. Use --token <arg>"; exit 1; }
[[ -z "${chat_id}" ]] && { echo "No chat id. Use --chat-id <arg>";  exit 1; }

[[ -z "${host_display_name}" ]] && host_display_name=$host_name
[[ -z "${service_display_name}" ]] && service_display_name=$service_name

case "$(echo "$service_state" | tr '[:upper:]' '[:lower:]')" in
    "ok") state_icon="\xE2\x9C\x85" ;;
    "warning") state_icon="\xE2\x9A\xA0" ;;
    "critical") state_icon="\xF0\x9F\x9A\xA8" ;;
    "unknown") state_icon="\xE2\x81\x89" ;;
    *) state_icon="" ;;
esac

T="$(
printf "${state_icon} %s / %s\n" "${host_display_name}" "${service_display_name}"
# printf "%s\n" "${date_time}"
[[ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" =~ ^(problem|recovery|custom)$ ]] &&
    printf "\n%s\n%s%s\n\n" '```' "${service_output}" '```'
[[ -n "${comment}" ]] &&
    printf "*Коментарий от* _%s_:\n%s" "${author}" "$comment"
)"

$curl --silent --output /dev/null $proxy \
    --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "text=${T}" \
    --data-urlencode "parse_mode=Markdown" \
    --data-urlencode "disable_web_page_preview=true" \
    "https://api.telegram.org/bot${token}/sendMessage"
