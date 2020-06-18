[![Pub](https://img.shields.io/pub/v/flame.svg?style=popout)](https://pub.dartlang.org/packages/flame) ![Test](https://github.com/flame-engine/flame/workflows/Test/badge.svg?branch=master&event=push) [![Discord](https://img.shields.io/discord/509714518008528896.svg)](https://discord.gg/pxrBmy4)

_Jest to nieoficjalne tłumaczenie. W chwili tłumaczenia wersja v0.22.0._

<img src="https://i.imgur.com/vFDilXT.png" width="400">

[English](https://github.com/flame-engine/flame) | [简体中文](README-ZH.md) | [Polski](https://github.com/mbiesiad/flame/blob/pl_PL/README-PL.md)

Minimalistyczny silnik gry Flutter.

## Pomoc

Mamy kanał pomocy Flame na Discord Fireslime, dołącz do niego [tutaj](https://discord.gg/pxrBmy4).

Mamy też najczęściej zadawane pytania - [FAQ](FAQ.md), więc najpierw wyszukaj tam swoje pytanie.

## Cele

Celem tego projektu jest dostarczenie kompletnego zestawu nietypowych rozwiązań dla typowych problemów, z którymi każda gra opracowana we Flutter będzie się dzielić.

Obecnie zapewnia elementy takie jak:
  - pętla gry
  - system komponent/obiekt
  - dołącza silnik fizyki (box2d)
  - wsparcie audio
  - efekty i cząstki
  - obsługa gestów i wprowadzania danych
  - obrazy, duszki (sprites) i arkusze duszka
  - podstawowe wsparcie Rive
  - i kilka innych narzędzi ułatwiających programowanie

Możesz użyć dowolnego z nich, ponieważ wszystkie są nieco niezależne.

## Wsparcie

Najprostszym sposobem, aby pokazać nam swoje wsparcie, jest przyznanie gwiazdki (star) dla projektu.

Możesz nas wesprzeć, zostając patronem na Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/fireslime)

Lub przekazując jakąś darowiznę, kupując nam kawę:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/fireslime)

Możesz również pokazać w swoim repozytorium, że twoja gra została wykonana przy użyciu Flame'a, używając jednej z następujących odznak:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Współtworzenie

Każda pomoc jest mile widziana! Komentarze, sugestie, issues, PR.

Jeśli znalazłeś błąd lub masz sugestię, jak ulepszyć Flame, otwórz issue, a my zajmiemy się nim jak najszybciej.

Czy chcesz przyczynić się do projektu tworząc PR? PR są zawsze mile widziane, po prostu utwórz je z gałęzi `develop` i postępuj zgodnie z [listą kontrolną](.github/pull_request_template.md) która pojawi się po otwarciu.

## Rozpocznij
Sprawdź tę wspaniałą serię artykułów/samouczków napisanych przez [Alekhin](https://github.com/japalekhin)

 - [Utwórz grę mobilną za pomocą Flutter'a i Flame'a - tutorial dla początkujących](https://jap.alekhin.io/create-mobile-game-flutter-flame-beginner-tutorial)
 - [Samouczek 2D na urządzenia mobilne - krok po kroku z Flame i Flutter (część 1 z 5)](https://jap.alekhin.io/2d-casual-mobile-game-tutorial-flame-flutter-part-1)
 - [Samouczek grafiki i animacji gry - krok po kroku z Flame i Flutter (część 2 z 5)](https://jap.alekhin.io/game-graphics-and-animation-tutorial-flame-flutter-part-2)
 - [Samouczek widoków i okien dialogowych - krok po kroku z Flame i Flutter (część 3 z 5)](https://jap.alekhin.io/views-dialog-boxes-tutorial-flame-flutter-part-3)
 - [Samouczek dotyczący przyznawania punktów, przechowywania i dźwięku - krok po kroku z Flame i Flutter (część 4 z 5)](https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4)
 - [Samouczek wykańczania i pakowania - krok po kroku z Flame i Flutter (część 5 z 5)](https://jap.alekhin.io/game-finishing-packaging-tutorial-flame-flutter-part-5)

Oferujemy również wyselekcjonowaną listę gier, bibliotek i artykułów na stronie [awesome-flame](https://github.com/flame-engine/awesome-flame).

Pamiętaj, że niektóre artykuły mogą być nieco nieaktualne, ale nadal są przydatne.

## Dokumentacja

Pełna dokumentacja znajduje się [tutaj](doc/README.md).

Wiele przykładów różnych funkcji można znaleźć [tutaj](doc/examples), a dobry przykład na start można znaleźć [tutaj](/example).

Oficjalną stronę Flame, która zawiera również dokumentację, można znaleźć [tutaj](https://flame-engine.org/).

## Uznanie

 * [Fireslime](https://fireslime.xyz), zespół odpowiedzialny za utrzymanie Flame'a.
 * Wszyscy życzliwi współtwórcy i ludzie, którzy pomagają w społeczności.
 * [Luanpotter](https://github.com/luanpotter)'a (założyciel Flame) biblioteka [audioplayers](https://github.com/luanpotter/audioplayer) lib, która z kolei jest rozwidlona (zforkowana) z [rxlabz's](https://github.com/rxlabz/audioplayer).
 * Port Dart w [Box2D](https://github.com/google/box2d.dart).
