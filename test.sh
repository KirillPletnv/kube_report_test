#!/bin/bash

#Download file
URL="https://raw.githubusercontent.com/GreatMedivack/files/master/list.out"
ORIG_FILE="temp_list.out"
wget -q "$URL" -O "$ORIG_FILE"

#Create server name (РїРѕ СѓРјРѕР»С‡Р°РЅРёСЋ "default_server")
SERVER_NAME="${1:-default_server}"
DATE=$(date +"%d_%m_%Y")

#Create output filename
FAILED_FILE="${SERVER_NAME}_${DATE}_failed.out"
RUNNING_FILE="${SERVER_NAME}_${DATE}_running.out"
REPORT_FILE="${SERVER_NAME}_${DATE}_report.out"
ARCHIVE_FILE="${SERVER_NAME}_${DATE}.tar.gz"
ARCHIVE_DIR="archives"

#Create services file with erors (Error РёР»Рё CrashLoopBackOff)
grep -E 'Error|CrashLoopBackOff' "$ORIG_FILE" | \
awk '{print $1}' | \
sed -E 's/(-[^-]{6,10}-[^-]{5,6})$//' > "$FAILED_FILE"

#Create runing services file (Running)
grep 'Running' "$ORIG_FILE" | \
awk '{print $1}' | \
sed -E 's/(-[^-]{6,10}-[^-]{5,6})$//' > "$RUNNING_FILE"

#Create report file
RUNNING_COUNT=$(wc -l < "$RUNNING_FILE")
FAILED_COUNT=$(wc -l < "$FAILED_FILE")
USERNAME=$(whoami)
CURRENT_DATE=$(date +"%d/%m/%y")
{
    echo "РљРѕР»РёС‡РµСЃС‚РІРѕ СЂР°Р±РѕС‚Р°СЋС‰РёС… СЃРµСЂРІРёСЃРѕРІ: $RUNNING_COUNT"
    echo "РљРѕР»РёС‡РµСЃС‚РІРѕ СЃРµСЂРІРёСЃРѕРІ СЃ РѕС€РёР±РєР°РјРё: $FAILED_COUNT"
    echo "РРјСЏ СЃРёСЃС‚РµРјРЅРѕРіРѕ РїРѕР»СЊР·РѕРІР°С‚РµР»СЏ: $USERNAME"
    echo "Р”Р°С‚Р°: $CURRENT_DATE"
} > "$REPORT_FILE"

#Create access
chmod a+r "$REPORT_FILE"

#Create archive
mkdir -p "$ARCHIVE_DIR"
if [ ! -f "${ARCHIVE_DIR}/${ARCHIVE_FILE}" ]; then
    tar -czf "${ARCHIVE_DIR}/${ARCHIVE_FILE}" \
        "$FAILED_FILE" "$RUNNING_FILE" "$REPORT_FILE"
fi

#Remove original file
rm -f "$ORIG_FILE" "$FAILED_FILE" "$RUNNING_FILE" "$REPORT_FILE"

#Archive check
if tar -tzf "${ARCHIVE_DIR}/${ARCHIVE_FILE}" >/dev/null 2>&1; then
    echo "РђСЂС…РёРІ СЃРѕР·РґР°РЅ СѓСЃРїРµС€РЅРѕ: ${ARCHIVE_DIR}/${ARCHIVE_FILE}"
    exit 0
else
    echo "РћС€РёР±РєР°: Р°СЂС…РёРІ РїРѕРІСЂРµР¶РґРµРЅ" >&2
    exit 1
fi
