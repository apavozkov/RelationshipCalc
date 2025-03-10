# Подход к расширяемости

## Добавление новых связей
- Новые связи можно добавлять в JSON-файл, следуя существующему формату.
- Для добавления потребуется лишь описание связи в виде комбинации родственных уровней, таких как `LIK(M)/ELDRE(W)`.
- Программа должна быть спроектирована так, чтобы при обновлении JSON-файла автоматически учитывать новые связи без изменения логики обработки.

## Редактирование существующих связей
- Можно изменить определения родственных отношений, уточняя или добавляя новые комбинации.
- Например, если потребуется уточнение термина "Сноха", можно обновить существующую запись без влияния на другие части системы.

## Гибкая система поиска
- Поиск связей строится на основе анализа цепочек родства, описанных в JSON.
- Программа должна уметь интерпретировать новые связи по заданным шаблонам.

# Расшифровка формата JSON и интерпретация

## Типы людей:
- `LIK(M)` — супруг (LIK = партнер, M = мужской пол).
- `LIK(W)` — супруга (W = женский пол).
- `UNG(M)` — сын (UNG = младшее поколение, M = мужской пол).
- `ELDRE(W)` — мать (ELDRE = старшее поколение, W = женский пол).

## Комбинации:
- `/` — обозначает родственную связь. Например, `LIK(W)/ELDRE(M)` означает «тесть» (мужчина из старшего поколения супруги).
- `&&` — альтернативные пути, например, «внук» может быть как по отцовской, так и по материнской линии.

## Примеры интерпретации:
- "Сноха": `UNG(M)/LIK(W)` — жена сына (невестка).
- "Тёща": `LIK(W)/ELDRE(W)` — мать супруги.
- "Дедушка": `ELDRE(W)/ELDRE(M)&&ELDRE(M)/ELDRE(M)` — возможны два варианта дедушки (по линии отца и по линии матери).

# Добавление новых родственных связей

## Добавление новых типов родства требует:
1. Определения шаблона для новой связи.
    - Например, если необходимо добавить понятие "Кузен" (двоюродный брат), оно может быть представлено как:
    ```json
    "Кузен": "ELDRE(M)/UNG(M)/UNG(M)"
    ```