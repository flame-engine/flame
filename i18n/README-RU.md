
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Минималистичный игровой движок на Flutter.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame/versions#prerelease" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout&include_prereleases" /></a>
  <a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/Test/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
</p>

---

[English](/README.md) | [简体中文](/i18n/README-ZH.md) | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md)

---

## О версии 1.0.0

Это релиз-кандидат версии 1.0.0 движка Flame. Эта версия не готова к использованию в продакшене, часть когда из документации не адаптирована под нее, кроме того, многое еще может поменяться перед релизом.

Используйте эту версию если хотите посмотреть каким будет Flame и оставить обратную связь по структуре или предложить новые фичи.

Используйте ветки `develop-v0.x` и `master-v0.x` для текущей 0.x версии. Новые функции не будут добавляться в v0 за исключением исправлений ошибок.

Текущая v1 версия - `1.0.0-rc3` на pub. Последняя стабильная версия - `0.29.0`. Не стесняйтесь выбрать ту, которая больше соответствует вашим требованиям.

---


## Документация

Обратите внимание, что документация в основной ветке этого репозитория новее, чем последняя выпущенная версия.

Тут вы можете найти документацию для других версий:
- Последняя стабильная версия: [Flame-engine website](https://flame-engine.org/)
- Последняя стабильная версия: [GitHub docs](https://github.com/flame-engine/flame/tree/master-v0.x/doc)
- Последняя версия v1.0.0: [GitHub docs](https://github.com/flame-engine/flame/tree/1.0.0-rc3/doc)

Окончательный вариант документации находится [здесь](doc/README.md).

Много примеров использования различных функций можно найти [тут](doc/examples), а хороший стартовый пример [тут](/example).

Официальный сайт Flame, тоже содержит документацию которую можно посмотреть [тут](https://flame-engine.org/).

## Помощь

У нас есть канал поддержки Flame в дискорде, присоединиться можно [тут](https://discord.gg/pxrBmy4).

Еще у нас есть [FAQ](FAQ.md), поэтому сначала поищите ответы на свои вопросы в нем.

## Цели

Цель этого проекта - предоставить полный набор стандартных решений для общих проблем встречающихся при разработке игр во Flutter.

В настоящее время Flame предоставляет вам:
 - игровой цикл
 - компонентно-объектную систему
 - физический движок (Forge2D, доступен через [flame_Forge2D](https://github.com/flame-engine/flame_Forge2D))
 - поддержка аудио
 - эффекты и частицы
 - поддержка жестов и ввода
 - изображения, спрайты и таблицы спрайтов
 - базовая поддержка Rive
 - и немного других функций которые сделают разработку легче

Вы можете использовать любые из них, так как все они, в разной степени независимы.

## Поддержка

Самый простой способ оказать нам поддержку - поставить проекту звезду.

Так же вы можете оказать нам финансовую поддержку став патроном на Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

Или сделав разовое пожертвование, купив нам кофе:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

Еще вы можете показать в своем репозитории что ваш проект сделан с использованием Flame, поместив туда один из бейджей:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Содействие

__ВНИМАНИЕ__: Мы работаем над доведением Flame до первой стабильной версии, обновления веток `0.x` заморожены, за исключением исправлений ошибок. Если вы хотите внести свой вклад в эту версию - убедитесь что это исправление ошибки. Для участия в стабильной ветке, ваш PR должен указывать на ветку `v1.0.0` и обязательно расскажите о своем вкладе в команде, которая доступна в [Discord](https://discord.gg/pxrBmy4).

Приветствуется любая помощь! Коментарии, предложения, проблемы, PRы.

Вы нашли ошибку или у вас есть предложения по улучшению Flame, откройте ишью и мы рaсcмотрим его как можно быстрее.

Хотите внести свой вклад создав PR? PRы всегда приветствуются, просто создайте его из ветки `develop` и следуйте [чеклисту](.github/pull_request_template.md) который будет доступен при создании PR.

## Как начать

Посмотрите хорошую серию статей/мануалов которую написал [Alekhin](https://github.com/japalekhin)

 - [Create a Mobile Game with Flutter and Flame – Beginner Tutorial](https://jap.alekhin.io/create-mobile-game-flutter-flame-beginner-tutorial)
 - [2D Casual Mobile Game Tutorial – Step by Step with Flame and Flutter (Part 1 of 5)](https://jap.alekhin.io/2d-casual-mobile-game-tutorial-flame-flutter-part-1)
 - [Game Graphics and Animation Tutorial – Step by Step with Flame and Flutter (Part 2 of 5)](https://jap.alekhin.io/game-graphics-and-animation-tutorial-flame-flutter-part-2)
 - [Views and Dialog Boxes Tutorial – Step by Step with Flame and Flutter (Part 3 of 5)](https://jap.alekhin.io/views-dialog-boxes-tutorial-flame-flutter-part-3)
 - [Scoring, Storage, and Sound Tutorial – Step by Step with Flame and Flutter (Part 4 of 5)](https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4)
 - [Game Finishing and Packaging Tutorial – Step by Step with Flame and Flutter (Part 5 of 5)](https://jap.alekhin.io/game-finishing-packaging-tutorial-flame-flutter-part-5)

Мы также предлагаем тщательно подобранный список игр, библиотек и статей на сайте [awesome-flame](https://github.com/flame-engine/awesome-flame).

Обратите внимание что некоторые статьи могут быть устаревшими, но все же они довольно полезны.

## Благодарности

 * [Blue Fire](https://patreon.com/bluefireoss), команда ответственная за поддержку Flame.
 * Все дружелюбные участники и люди которые помогают в сообществе.
 * [Luanpotter](https://github.com/luanpotter)'s основатель Flame и [audioplayers](https://github.com/luanpotter/audioplayer) библиотеки, которая является форком [rxlabz's](https://github.com/rxlabz/audioplayer).
 * Дарт порт [Box2D](https://github.com/google/box2d.dart).
