# ⚡ Быстрый старт

## 1️⃣ Установка act (для локального тестирования)

```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

## 2️⃣ Настройка переменных (опционально)

Создайте файл `.env` в корне проекта:

```bash
cat > .env << 'ENVEOF'
STACK_NAME=app
NGINX_PORT=3000
APP_PORT_LOCAL=3001
GH_SHA=v1.0.0
ENVEOF
```

## 3️⃣ Запуск

### Вариант A: Полный цикл (локально)

```bash
./scripts
```

### Вариант B: По этапам

```bash
./build.sh           # Сборка образа
./extract-static.sh  # Извлечение статики
./deploy.sh          # Деплой
```

### Вариант C: Тестирование GH Actions

```bash
# Интерактивное меню
./test-workflow.sh

# Или напрямую
act -j build              # Только сборка
act -j extract-static     # Только статика
act -j deploy             # Только деплой
act push                  # Весь workflow
```

## 4️⃣ Проверка

```bash
# Проверить сервисы
docker service ls

# Проверить логи
docker service logs app_app -f

# Открыть в браузере
open http://localhost:3000
```

## 5️⃣ Остановка

```bash
docker stack rm app
```

## 📖 Документация

- **README.md** - Общий обзор проекта
- **DEPLOYMENT.md** - Полная инструкция по деплою
- **ACT_SETUP.md** - Подробно про act

## 🆘 Помощь

Если что-то не работает:

```bash
# Проверить Docker
docker ps

# Проверить образы
docker images | grep horizont-app

# Логи act
act -v > act.log 2>&1

# Очистить всё
docker stack rm app
docker system prune -a
```
