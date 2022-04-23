<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Минималистичный игровой движок на Flutter.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---

[English](/README.md) | [简体中文](/i18n/README-ZH.md) | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md) | [Español](/i18n/README-ES.md) | [日本語](/i18n/README-JA.md)

---

## Документация

Полная документация по Flame находится тут:
[docs.flame-engine.org](https://docs.flame-engine.org/).

Чтобы изменить версию документации, воспользуйтесь выпадающим списком `version:` в верху страницы.

**Примечание**: Документация находящаяся в ветке main новее чем документация в релизной ветке.

Другие полезные ссылки:
- [Официальный сайт Flame](https://flame-engine.org/).
- [Примеры](https://examples.flame-engine.org/) большинство функций которые можно опробовать в браузере.
- [Уроки](https://tutorials.flame-engine.org/) - Простые уроки позволяющие начать изучение движка.
- [Справка API](https://pub.dev/documentation/flame/latest/) - Сгенерированная dartdoc справка по API.


## Помощь

Группа поддержки находится на [Blue Fire's Discord сервере](https://discord.gg/5unKpdQD78) где вы можете задать
связанные с Flame вопросы.

Если вам удобнее использовать StackOverflow, вы так же можете задать свой вопрос там, добавив
[тэг Flame](https://stackoverflow.com/questions/tagged/flame), чтобы любой кто его отслеживает, смог бы помочь.

## Функционал

Цель движка Flame Engine - предоставить набор стандартных решений для большинства проблем, которые могут быть
общими при разработке игр на Flutter.

Основные предоставляемые функции:

- Игровой цикл
- Компонентно-объектную систему (FCS)
- Эффекты и частицы
- Обнаружение столкновений
- Обработка жестов и ввода
- Изображения, анимация, спрайты и таблицы спрайтов
- Общие утилиты упрощающие разработку

Помимо этих функций, вы можете дополнить Flame связанными пакетами. Через эти библиотеки вы сможете получить доступ
к функционалу других пакетов, содержащих сторонние компоненты Flame или дополнительные утилиты.

Flame официально предоставляет связанные библиотеки для следующих компонентов:

- [flame_audio](https://github.com/flame-engine/flame/tree/main/packages/flame_audio) для
  [AudioPlayers](https://github.com/bluefireteam/audioplayers): Воспроизведение нескольких аудиофайлов одновременно.
- [flame_bloc](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc) для
  [Bloc](https://github.com/felangel/bloc): Библиотека управления состоянием.
- [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas) для
  [FireAtlas](https://github.com/flame-engine/fire-atlas): Создание атласов структур для игр.
- [flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) для
  [Forge2D](https://github.com/flame-engine/forge2d): Физический движок Box2D.
- [flame_lint](https://github.com/flame-engine/flame/tree/main/packages/flame_lint) -
  Наши правила линтинга (`analysis_options.yaml`).
- [flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) для
  [Oxygen](https://github.com/flame-engine/oxygen): Легковесный фреймверк Entity Component System (ECS).
- [flame_rive](https://github.com/flame-engine/flame/tree/main/packages/flame_rive) для
  [Rive](https://rive.app/): Создание интерактивной анимации.
- [flame_svg](https://github.com/flame-engine/flame/tree/main/packages/flame_svg) для
  [flutter_svg](https://github.com/dnfield/flutter_svg): Отрисовка SVG файлов на Flutter.
- [flame_tiled](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled) для
  [Tiled](https://www.mapeditor.org/): Редактор уровней для 2D тайловой карты.


## Спонсоры

Лучшие спонсоры движка Flame:

[![Very Good Ventures](/media/unicorn_two_toned.png)](https://verygood.ventures/)

[![Cypher Stack](/media/logo_cypherstack.png)](https://cypherstack.com/)

Хотите спонсировать Flame? Обратите внимание на наш Patreon в следующем разделе, или свяжитесь с нами через Discord.


## Поддержка

Самый простой способ оказать нам поддержку - поставить проекту звезду.

Так же вы можете оказать нам финансовую поддержку став патроном на Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

Или сделав разовое пожертвование, купив нам кофе:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

Еще вы можете показать в своем репозитории что ваш проект сделан с использованием Flame, поместив туда один из бейджей:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Содействие

Вы нашли ошибку или у вас есть предложение как улучшить Flame? Откройте ишью и мы рассмотрим его как можно скорее.

Хотите внести свой вклад создав PR? PRы всегда приветствуются, просто создайте его из правильной ветки (`main`) и 
следуйте [чеклисту](.github/pull_request_template.md) который будет доступен при создании PR.

Для больших изменений и/или если у вас есть сомнения, обязательно посоветуйтесь с сообществом. Либо создав ишью
на GitHub, либо свяжитесь с нами через [Discord](https://discord.gg/pxrBmy4)


## Как начать

Простое руководство по разработке можно найти тут
[tutorials.flame-engine.org](https://tutorials.flame-engine.org), а примеры большинства функций Flame 
тут [examples.flame-engine.org](https://examples.flame-engine.org). Для того чтобы увидеть код любого из примеров, 
нажмите кнопку `< >` в верхнем правом углу.


### Рекомендуемые сообществом уроки

- Серия @Devowl's Flutter & Flame:
    - [Step 1: Создание вашей игры](https://medium.com/flutter-community/flutter-flame-step-1-create-your-game-b3b6ee387d77)
    - [Step 2: Основы игры](https://medium.com/flutter-community/flutter-flame-step-2-game-basics-48b4493424f3)
    - [Step 3: Спрайты и ввод](https://blog.devowl.de/flutter-flame-step-3-sprites-and-inputs-7ca9cc7c8b91)
    - [Step 4: Столкновение и область видимости](https://blog.devowl.de/flutter-flame-step-4-collisions-viewport-ff2da048e3a6)
    - [Step 5: Генерация уровня и камера](https://blog.devowl.de/flutter-flame-step-5-level-generation-camera-62a060a286e3 )

- Другие уроки:
    - @Vguzzi's статья [Создание игра на Flutter используя Flame](https://www.raywenderlich.com/27407121-building-games-in-flutter-with-flame-getting-started)
    - @DevKage's Серия видео на YouTube [Dino run tutorial](https://www.youtube.com/playlist?list=PLiZZKL9HLmWOmQgYxWHuOHOWsUUlhCCOY)

Мы предлагаем модерируемый список игр и уроков по адресу
[awesome-flame](https://github.com/flame-engine/awesome-flame).

Обратите внимание, что некоторые статьи могут быть хоть и немного устаревшими, но все же полезными.


## Благодарности

- [Blue Fire](https://github.com/orgs/bluefireteam/people), команда которая постоянно работает над
улучшением Flame и его экосистемы.
- Все дружественно настроенные участники и люди, которые помогают сообществу.
