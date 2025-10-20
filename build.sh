#!/bin/bash

# ============================================
# Скрипт сборки Docker образа
# ============================================

set -e

# Параметры
GH_SHA=${GH_SHA:-$(git tag --points-at HEAD)}
APP_PORT_LOCAL=${APP_PORT_LOCAL:-3001}

echo "================================================"
echo "Сборка Docker образа"
echo "================================================"
echo "GH_SHA: $GH_SHA"
echo "APP_PORT_LOCAL: $APP_PORT_LOCAL"
echo "Image: horizont-app:$GH_SHA"
echo "================================================"

echo ""
echo "Запуск сборки..."
docker build \
  -f docker/app/Dockerfile \
  --build-arg GH_SHA=$GH_SHA \
  --build-arg PORT=$APP_PORT_LOCAL \
  -t horizont-app:$GH_SHA \
  .

if [ $? -eq 0 ]; then
  echo ""
  echo "================================================"
  echo "✓ Образ успешно собран!"
  echo "================================================"
  echo "Image: horizont-app:$GH_SHA"
  echo "================================================"
else
  echo "Ошибка при сборке образа"
  exit 1
fi

