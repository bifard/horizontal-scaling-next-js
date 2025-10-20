# 🎭 Эмуляция GitHub Actions локально

## Установка `act`

`act` - инструмент для локального запуска GitHub Actions workflows.

### macOS (Homebrew)

```bash
brew install act
```

### Linux

```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Или через Docker

```bash
alias act="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/workspace -w /workspace nektos/act"
```

## 🚀 Использование

### Просмотр доступных jobs

```bash
act -l
```

### Запуск всего workflow

```bash
# Запустить workflow при push (с тегом)
act push

# Запустить с ручным триггером
act workflow_dispatch
```

### Запуск конкретного job

```bash
# Только сборка
act -j build

# Только извлечение статики
act -j extract-static

# Только деплой
act -j deploy
```

### Запуск с переменными окружения

```bash
act workflow_dispatch \
  -s APP_PORT_LOCAL=3002 \
  -s NGINX_PORT=8080
```

### Запуск с входными параметрами

```bash
act workflow_dispatch \
  --input app_port=3002 \
  --input nginx_port=8080
```

### Режим отладки

```bash
# Детальный вывод
act -v

# Очень детальный вывод
act -vv

# Запуск с интерактивным shell при ошибке
act --shell
```

## 🔧 Конфигурация

### Создание `.actrc` для настроек по умолчанию

```bash
cat > .actrc << 'EOF'
# Использовать большие образы (ближе к настоящему GitHub Actions)
-P ubuntu-latest=catthehacker/ubuntu:full-latest

# Показывать больше информации
-v
EOF
```

### Использование secrets

```bash
# Создать файл с секретами
cat > .secrets << 'EOF'
DOCKER_USERNAME=myuser
DOCKER_PASSWORD=mypassword
SSH_KEY=my-ssh-key
EOF

# Запустить с секретами
act -s-file .secrets
```

### Переменные окружения

```bash
# Создать .env файл
cat > .env << 'EOF'
APP_PORT_LOCAL=3001
NGINX_PORT=3000
STACK_NAME=app
EOF

# Запустить с env файлом
act --env-file .env
```

## 📝 Примеры использования

### Полный цикл локально

```bash
# 1. Проверить синтаксис workflow
act -l

# 2. Запустить только сборку
act -j build

# 3. Если успешно - запустить весь workflow
act push
```

### Тестирование с разными параметрами

```bash
# Тест с портом 3002
act workflow_dispatch --input app_port=3002

# Тест с другим стеком
STACK_NAME=test-app act push
```

### Dry-run (проверка без выполнения)

```bash
act -n
```

## ⚠️ Ограничения `act`

1. **Не все Actions поддерживаются** - некоторые официальные actions могут работать иначе
2. **Артефакты** - загрузка/скачивание артефактов работает локально
3. **Секреты** - нужно предоставлять вручную через `.secrets`
4. **Матричные билды** - могут работать медленнее
5. **Кэширование** - работает иначе чем в реальном GitHub

## 🎯 Рекомендуемый workflow локальной разработки

```bash
# 1. Разработка и тестирование скриптов напрямую
./build.sh
./extract-static.sh
./deploy.sh

# 2. Когда скрипты работают - тестируем через act
act -j build

# 3. Если build успешен - тестируем полный цикл
act push

# 4. После успешного теста - пушим в GitHub
git add .
git commit -m "feat: update deployment"
git push
```

## 🐛 Отладка

### Проблемы с Docker

```bash
# Проверить доступность Docker socket
ls -la /var/run/docker.sock

# Если нет прав
sudo chmod 666 /var/run/docker.sock
```

### Проблемы с образами

```bash
# Использовать более легкий образ (быстрее, но меньше инструментов)
act -P ubuntu-latest=node:18

# Использовать полный образ (медленнее, но ближе к GitHub)
act -P ubuntu-latest=catthehacker/ubuntu:full-latest
```

### Логи и отладка

```bash
# Сохранить логи в файл
act -v > act.log 2>&1

# Запустить конкретный шаг
act -j build --step "Build Docker image"
```

## 📊 Сравнение: act vs реальный GitHub Actions

| Аспект    | act (локально)      | GitHub Actions         |
| --------- | ------------------- | ---------------------- |
| Скорость  | ⚡ Быстрее          | Медленнее (cold start) |
| Окружение | Ваша машина         | GitHub runners         |
| Секреты   | Локальный .secrets  | GitHub Secrets         |
| Артефакты | Локальная FS        | GitHub Storage         |
| Кэш       | Docker cache        | GitHub Cache           |
| Стоимость | ✅ Бесплатно        | Минуты лимита          |
| Отладка   | ⭐ Проще (локально) | Сложнее                |

## 🎓 Best Practices

1. **Разрабатывайте скрипты независимо** - они должны работать как в act, так и отдельно
2. **Используйте переменные окружения** - для гибкости настройки
3. **Тестируйте через act** - перед пушем в GitHub
4. **Держите workflow простыми** - сложная логика в скриптах, не в yaml
5. **Используйте артефакты** - для передачи данных между jobs

## 🔗 Полезные ссылки

- [act GitHub](https://github.com/nektos/act)
- [act документация](https://nektosact.com/)
- [GitHub Actions документация](https://docs.github.com/en/actions)
- [Примеры workflows](https://github.com/actions/starter-workflows)
