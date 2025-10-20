#!/bin/bash

# ============================================
# Скрипт извлечения статики из образа в volume
# Запускается после сборки образа, перед деплоем
# ============================================

set -e

# Параметры
GH_SHA=${GH_SHA:-$(git tag --points-at HEAD)}
STACK_NAME=${STACK_NAME:-app}
VOLUME_NAME="${STACK_NAME}_next_static"

echo "================================================"
echo "Извлечение статики из образа"
echo "================================================"
echo "GH_SHA: $GH_SHA"
echo "Image: horizont-app:$GH_SHA"
echo "Volume: $VOLUME_NAME"
echo "================================================"

# Создать временный контейнер из образа
echo ""
echo "[1/4] Создание временного контейнера..."
CONTAINER_ID=$(docker create horizont-app:$GH_SHA)
echo "Container ID: $CONTAINER_ID"

# Прочитать BUILD_ID из образа
echo ""
echo "[2/4] Чтение BUILD_ID..."
BUILD_ID=$(docker cp $CONTAINER_ID:/app/.next/BUILD_ID - | tar xO)
echo "BUILD_ID: $BUILD_ID"

# Скопировать статику на хост
echo ""
echo "[3/4] Копирование статики на хост..."
docker cp $CONTAINER_ID:/app/.next/static ./temp-static

# Удалить временный контейнер
docker rm $CONTAINER_ID

# Создать volume если его нет
docker volume create "$VOLUME_NAME" || true

# Загрузить статику в volume
echo ""
echo "[4/4] Загрузка статики в volume..."
docker run --rm \
  -e BUILD_ID="$BUILD_ID" \
  -v "${VOLUME_NAME}:/dst" \
  -v "$PWD/temp-static":/src:ro \
  alpine:3.20 sh -c '
    echo "Создание структуры каталогов..."
    mkdir -p "/dst/$BUILD_ID/_next"
    echo "Копирование файлов..."
    cp -a /src "/dst/$BUILD_ID/_next/static"
    echo "Проверка структуры:"
    ls -la "/dst/$BUILD_ID/_next/"
  '

# Очистить временные файлы
rm -rf ./temp-static

echo ""
echo "================================================"
echo "✓ Статика успешно извлечена в volume!"
echo "================================================"
echo "Volume: $VOLUME_NAME"
echo "Path: /dst/$BUILD_ID/_next/static"
echo "================================================"

