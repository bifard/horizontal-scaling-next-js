#!/bin/bash

# ============================================
# Скрипт деплоя Docker Stack
# ============================================

set -e

# Параметры
STACK_NAME=${STACK_NAME:-app}
NGINX_PORT=${NGINX_PORT:-3000}
APP_PORT_LOCAL=${APP_PORT_LOCAL:-3001}
GH_SHA=${GH_SHA:-$(git tag --points-at HEAD)}

echo "================================================"
echo "Деплой Docker Stack"
echo "================================================"
echo "STACK_NAME: $STACK_NAME"
echo "NGINX_PORT: $NGINX_PORT"
echo "APP_PORT_LOCAL: $APP_PORT_LOCAL"
echo "GH_SHA: $GH_SHA"
echo "================================================"

echo ""
echo "Запуск деплоя..."
STACK_NAME=$STACK_NAME \
NGINX_PORT=$NGINX_PORT \
APP_PORT_LOCAL=$APP_PORT_LOCAL \
GH_SHA=$GH_SHA \
docker stack deploy --prune -c ./docker/docker-stack.yml "$STACK_NAME"

if [ $? -eq 0 ]; then
  echo ""
  echo "================================================"
  echo "✓ Деплой успешно завершен!"
  echo "================================================"
  echo "Nginx доступен на порту: $NGINX_PORT"
  echo "Приложение работает на порту: $APP_PORT_LOCAL"
  echo "Stack: $STACK_NAME"
  echo "================================================"
else
  echo "Ошибка при деплое стека"
  exit 1
fi

