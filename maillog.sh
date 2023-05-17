#!/bin/bash

# Проверяем, не запущен ли уже скрипт
if pidof -o %PPID -x "$0"; then
   echo "Скрипт уже запущен"
   exit 1
fi

# Настройки скрипта
LOG_FILE="/var/log/nginx/access.log"
EMAIL="example@example.com"

# Формируем письмо
EMAIL_BODY="Список IP адресов (с наибольшим количеством запросов):\n"
EMAIL_BODY+=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10)
EMAIL_BODY+="\n\nСписок запрашиваемых URL (с наибольшим количеством запросов):\n"
EMAIL_BODY+=$(awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -n 10)
EMAIL_BODY+="\n\nОшибки веб-сервера/приложения:\n"
EMAIL_BODY+=$(grep -E '50[0-9]' "$LOG_FILE" | awk '{print $9, $7}')
EMAIL_BODY+="\n\nСписок всех кодов HTTP ответа:\n"
EMAIL_BODY+=$(awk '{print $9}' "$LOG_FILE" | sort | uniq -c)

# Отправляем письмо
echo -e "$EMAIL_BODY" | mail -s "Статистика Nginx" "$EMAIL"

exit 0