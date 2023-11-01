#!/usr/local/bin/bash

type=""
author=""
comment=""

host_name=""
host_address=""
host_display_name=""
host_state=""
host_output=""

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
        --host-name) host_name="$2"; shift; shift ;;
        --host-display-name) host_display_name="$2"; shift; shift ;;
        --host-address) host_address="$2"; shift; shift ;;
        --host-state) host_state="$2"; shift; shift ;;
        --long-date-time) date_time="$2"; shift; shift ;;
        --host-output) host_output="$2"; shift; shift ;;
        --notification-author) author="$2"; shift; shift ;;
        --notification-comment) comment="$2"; shift; shift ;;
        --proxy) proxy="--proxy $2"; shift; shift; ;;
        *) shift ;;
    esac
done

[[ -z "${token}" ]] && { echo "No token. Use --token <arg>"; exit 1; }
[[ -z "${chat_id}" ]] && { echo "No chat id. Use --chat-id <arg>";  exit 1; }

[[ -z "${host_display_name}" ]] && host_display_name=$host_name
[[ -z "${host_address}" ]] && host_address="N/A"

case "$(echo "$host_state" | tr '[:upper:]' '[:lower:]')" in
    "up") state_icon="\xE2\x9C\x85" ;;
    "down") state_icon="\xE2\x9D\x8C" ;;
    *) state_icon="" ;;
esac

if [ "${host_display_name}" != "${host_address}" ]; then
	host="${host_display_name} (${host_address})"
else
	host="${host_display_name}"
fi

T="$(
printf "${state_icon} ${host}\n"
[[ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" =~ ^(problem|recovery|custom)$ ]] &&
    printf "\n%s\n%s%s\n\n" '```' "${host_output}" '```'
[[ -n "${comment}" ]] &&
    printf "*Коментарий от* _%s_:\n%s" "${author}" "$comment"
)"

$curl --silent --output /dev/null $proxy \
    --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "parse_mode=Markdown" \
    --data-urlencode "disable_web_page_preview=true" \
    --data-urlencode "text=${T}" \
    "https://api.telegram.org/bot${token}/sendMessage"
