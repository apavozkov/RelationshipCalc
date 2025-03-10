*version 2.1*

# Синтаксис DSL "RSFL"

### Структура файла
Файл в формате JSON состоит из:
  - Ключей = названий родственников относительно входного имени;
  - Значений = формул, описывающих путь к соответствующему родственнику по генеалогическому древу;

### Структура формулы
Формула состоит из шагов, описывающих маршрут алгоритма по генеалогическому древу, а также вспомогательных символов. <br>
<br>
**Шаги включают в себя указатели направлений**: <br>
 - ELDRE - шаг в сторону предков;
 - UNG - шаг в сторону потомков;
 - LIK - шаг в сторону супруга; <br>
 
**Также шаги включают в себя указатели гендера** (ставятся в круглых скобках после указателей направления): <br>
 - M - мужчина;
 - W - женщина; <br>

**Получается список возможных шагов в формулах:** <br>
 - ELDRE(M);
 - ELDRE(W);
 - UNG(M);
 - UNG(W);
 - LIK(M);
 - LIK(W); <br>

**Шаги внутри формулы разделяются знаком "/".** <br> 
Пример: ELDRE(M)/LIK(W). <br>

**Простые формулы внутри сложной разделяются знаком "&&".** Таких разделителей в 1 сложной формуле может быть сколько угодно. <br> 
Пример: ELDRE(M)/UNG(M)&&ELDRE(W)/UNG(M). <br>
Такой разделитель сделан для случаев, когда к 1 типу родственника можно дойти по древу разными маршрутами. В примере дана формула для родного брата относительно имени на входе программы. К нему можно дойти как через мать, так и через отца. Формулы обрабатываются отдельно и их результаты потом складываются. Механизм также может быть использован в случае нестандартных входных данных. Например, в файле input.txt есть только связи "Отец-Ребёнок" и "Супруг-Супруга", соответственно мать по формуле "ELDRE(W)" не может быть найдена. Для этого указывается альтернативный маршрут "ELDRE(M)/LIK(W)", который покажет верный результат. Итоговая формула для этого случая будет выглядеть так: ELDRE(W)&&ELDRE(M)/LIK(W).

### Дополнительно
 - Шаг "UNG" автоматически подразумевает возможность наличия нескольких людей одного типа на промежуточном и/или конечном шаге формулы, алгоритм должен учитывать и правильно обрабатывать такой случай. Для других шагов такой вариант недопустим.

