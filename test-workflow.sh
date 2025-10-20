#!/bin/bash

# ============================================
# Быстрое тестирование GitHub Actions локально
# ============================================

set -e

echo "================================================"
echo "🎭 Тестирование GitHub Actions локально"
echo "================================================"
echo ""

# Проверка установки act
if ! command -v act &> /dev/null; then
    echo "❌ act не установлен"
    echo ""
    echo "Установите act:"
    echo "  macOS: brew install act"
    echo "  Linux: curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash"
    echo ""
    exit 1
fi

echo "✅ act установлен: $(act --version)"
echo ""

# Меню выбора
echo "Что вы хотите сделать?"
echo ""
echo "  1) Просмотреть доступные jobs"
echo "  2) Запустить только Build"
echo "  3) Запустить только Extract Static"
echo "  4) Запустить только Deploy"
echo "  5) Запустить весь workflow"
echo "  6) Dry run (проверка без выполнения)"
echo ""
read -p "Выберите опцию (1-6): " choice

case $choice in
  1)
    echo ""
    echo "📋 Доступные jobs:"
    act -l
    ;;
  2)
    echo ""
    echo "🔨 Запуск job: build"
    act -j build -v
    ;;
  3)
    echo ""
    echo "📦 Запуск job: extract-static"
    act -j extract-static -v
    ;;
  4)
    echo ""
    echo "🚀 Запуск job: deploy"
    act -j deploy -v
    ;;
  5)
    echo ""
    echo "🔄 Запуск всего workflow"
    act push -v
    ;;
  6)
    echo ""
    echo "🔍 Dry run (проверка)"
    act -n
    ;;
  *)
    echo ""
    echo "❌ Неверный выбор"
    exit 1
    ;;
esac

echo ""
echo "================================================"
echo "✅ Готово!"
echo "================================================"
echo ""
echo "💡 Подробная документация:"
echo "   - ACT_SETUP.md - полная инструкция по act"
echo "   - DEPLOYMENT.md - общая документация деплоя"
echo ""

