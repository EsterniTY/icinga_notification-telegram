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

icon="\xF0\x9F\x9A\xA8"
title=${type}

case "$(echo "$type" | tr '[:upper:]' '[:lower:]')" in
    "downtimestart") icon="\xF0\x9F\x95\x92"; title="Обслуживание началось" ;;
    "downtimeend") icon="\xF0\x9F\x95\x9B"; title="Обслуживание закончилось" ;;
    "downtimeremoved") icon="\xE2\x9D\x8E"; title="Обслуживание отменено" ;;
    "acknowledgement") icon="\xF0\x9F\x93\x8C"; title="Проблема подтверждена" ;;
    "problem") icon="\xE2\x80\xBC"; title="Проблема с хостом";;
    "recovery") icon="\xE2\x9C\x85"; title="Хост восстановился";;
    "custom") icon="\xF0\x9F\x92\xAC"; title="Сообщение" ;;
    "flappingstart") icon="\xF0\x9F\x94\x80"; title="Хост 'шатает'" ;;
    "flappingend") icon="\xF0\x9F\x94\x84"; title="Хост перестало 'шатать'";;
esac

case "$(echo "$host_state" | tr '[:upper:]' '[:lower:]')" in
    "up") state_icon="\xE2\x9C\x85"; state="доступен" ;;
    "down") state_icon="\xE2\x9D\x8C"; state="не доступен" ;;
    *) state_icon=""; state=${host_state} ;;
esac

T="$(
printf "${icon} *%s*\n\n" "${title}"
printf "*Хост*: %s (%s)\n" "${host_display_name}" "${host_address}"
printf "*Статус*: ${state_icon} %s\n" "${state}"
printf "*Дата/время*: %s\n" "${date_time}"
[[ "$(echo "$type" | tr '[:upper:]' '[:lower:]')" =~ ^(problem|recovery|custom)$ ]] &&
    printf "\n%sblock_language\n%s%s\n\n" '```' "${host_output}" '```'
[[ -n "${comment}" ]] &&
    printf "*Коментарий от* _%s_:\n%s" "${author}" "$comment"
)"

$curl --silent --output /dev/null $proxy \
    --data-urlencode "chat_id=${chat_id}" \
    --data-urlencode "parse_mode=Markdown" \
    --data-urlencode "disable_web_page_preview=true" \
    --data-urlencode "text=${T}" \
    "https://api.telegram.org/bot${token}/sendMessage"
