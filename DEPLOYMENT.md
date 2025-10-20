# 🚀 Инструкция по деплою

## Структура скриптов

Проект разделен на модульные скрипты для удобного использования в CI/CD:

```
├── build.sh          # 1️⃣ Сборка Docker образа
├── extract-static.sh # 2️⃣ Извлечение статики в volume
├── deploy.sh         # 3️⃣ Деплой Docker Stack
└── scripts           # 🔄 Полный цикл (вызывает все три)
```

## 📦 Переменные окружения

Все скрипты поддерживают следующие переменные:

| Переменная       | По умолчанию                  | Описание                          |
| ---------------- | ----------------------------- | --------------------------------- |
| `GH_SHA`         | `$(git tag --points-at HEAD)` | Версия/тег для образа             |
| `APP_PORT_LOCAL` | `3001`                        | Порт приложения внутри контейнера |
| `NGINX_PORT`     | `3000`                        | Внешний порт Nginx                |
| `STACK_NAME`     | `app`                         | Имя Docker Stack                  |

## 🎯 Использование

### Локальная разработка (полный цикл)

```bash
# Запустить все этапы последовательно
./scripts

# Или с кастомными параметрами
NGINX_PORT=8080 APP_PORT_LOCAL=3002 ./scripts
```

### CI/CD (GitHub Actions) - раздельные джобы

#### Job 1: Сборка образа

```yaml
- name: Build Docker image
  run: ./build.sh
  env:
    GH_SHA: ${{ github.sha }}
    APP_PORT_LOCAL: 3001
```

#### Job 2: Извлечение статики

```yaml
- name: Extract static files
  run: ./extract-static.sh
  env:
    GH_SHA: ${{ github.sha }}
    STACK_NAME: app
```

#### Job 3: Деплой

```yaml
- name: Deploy stack
  run: ./deploy.sh
  env:
    GH_SHA: ${{ github.sha }}
    NGINX_PORT: 3000
    APP_PORT_LOCAL: 3001
    STACK_NAME: app
```

### Отдельные скрипты

```bash
# Только сборка образа
GH_SHA=v1.0.0 APP_PORT_LOCAL=3001 ./build.sh

# Только извлечение статики
GH_SHA=v1.0.0 ./extract-static.sh

# Только деплой
GH_SHA=v1.0.0 NGINX_PORT=3000 APP_PORT_LOCAL=3001 ./deploy.sh
```

## 🏗️ Архитектура

### Dockerfile

- **ARG PORT**: Передается при сборке через `--build-arg PORT=3001`
- **ENV PORT**: Устанавливается в контейнере для Next.js
- **EXPOSE ${PORT}**: Документирует используемый порт

### docker-stack.yml

- **environment.PORT**: Получает значение из `APP_PORT_LOCAL`
- **ports**: Маппинг `9000:${APP_PORT_LOCAL}` (внешний:внутренний)
- **volumes.next_static**: Общий volume для статики между сервисами

### Потоки данных

```
build.sh
  ├─> Собирает образ с PORT=$APP_PORT_LOCAL
  └─> Тегирует как horizont-app:$GH_SHA

extract-static.sh
  ├─> Создает временный контейнер из образа
  ├─> Извлекает BUILD_ID и статику
  └─> Загружает в volume next_static

deploy.sh
  ├─> Передает PORT=$APP_PORT_LOCAL в контейнер
  ├─> Монтирует volume next_static
  └─> Запускает Docker Stack
```

## ⚙️ Настройка портов

Порт приложения задается в двух местах:

1. **При сборке** (build.sh):

   ```bash
   --build-arg PORT=$APP_PORT_LOCAL
   ```

2. **При запуске** (docker-stack.yml):
   ```yaml
   environment:
     - PORT=${APP_PORT_LOCAL}
   ```

Next.js автоматически использует переменную окружения `PORT` для запуска сервера.

## 🔍 Проверка

После деплоя проверьте статус:

```bash
# Проверить сервисы
docker service ls

# Проверить логи
docker service logs app_app -f

# Проверить nginx
docker service logs app_nginx -f

# Проверить volume
docker run --rm -v app_next_static:/data alpine ls -la /data
```

## 🐛 Отладка

```bash
# Проверить образ
docker images | grep horizont-app

# Проверить сеть
docker network ls | grep alnet

# Проверить volume
docker volume ls | grep next_static

# Остановить stack
docker stack rm app
```

## 🎭 Локальное тестирование GitHub Actions

Для эмуляции GitHub Actions локально используйте **`act`**:

```bash
# Установить act (macOS)
brew install act

# Просмотреть доступные jobs
act -l

# Запустить конкретный job
act -j build
act -j extract-static
act -j deploy

# Запустить весь workflow
act push

# С кастомными параметрами
act workflow_dispatch --input app_port=3002 --input nginx_port=8080
```

📖 **Подробная инструкция**: см. [ACT_SETUP.md](./ACT_SETUP.md)

## 📝 Примечания

- Все скрипты используют `set -e` для остановки при ошибках
- GH_SHA по умолчанию берется из git tag на текущем коммите
- Volume `next_static` создается автоматически если не существует
- Статика хранится в структуре `/dst/$BUILD_ID/_next/static`
- Workflow файл: [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)
