# TapVerse — сборка для виртуального iPhone

Не загружайте этот исходный архив непосредственно в Appetize. Сервис принимает ZIP, внутри которого находится **скомпилированный `TapVerse.app`**, а не `.xcodeproj` и `.swift`-файлы.

## Получение конечного файла без Mac

1. Распакуйте архив и загрузите всё содержимое в корень нового GitHub-репозитория.
2. Убедитесь, что загрузилась скрытая папка `.github`.
3. В GitHub откройте **Actions → Create TapVerse Appetize ZIP → Run workflow**.
4. После успешной сборки откройте **Releases**.
5. Скачайте из Assets файл **`TapVerse-Appetize.zip`**.
6. Не распаковывайте его. Загрузите ZIP непосредственно в Appetize или другой сервис, принимающий iOS Simulator `.app` bundle.

В правильном архиве на верхнем уровне находится `TapVerse.app`. Внутри него есть `Info.plist` и настоящий Mach-O executable `TapVerse`.
