<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Silnik gry oparty na Flutter.
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


## Dokumentacja

Pełna dokumentacja Flame znajduje się na
[docs.flame-engine.org](https://docs.flame-engine.org/).

Aby zmienić wersję dokumentacji, użyj selektora wersji za pomocą `version:` na górze strony.

**Uwaga**: Dokumentacja znajdująca się na gałęzi main jest nowsza, niż dokumentacja udostępniona na stronie docs.

Inne przydatne linki:
 - [Oficjalna strona Flame](https://flame-engine.org/).
 - [Przykłady](https://examples.flame-engine.org/) większości funkcji, które można wypróbować z poziomu twojej przeglądarki.
 - [Poradniki](https://tutorials.flame-engine.org/) - Prosty samouczek na początek.
 - [Dokumentacja API](https://pub.dev/documentation/flame/latest/) - Wygenerowana dokumentacja API dartdoc.


## Pomoc

Społeczność Flame jest na [serwerze Discord Blue Fire's](https://discord.gg/5unKpdQD78), gdzie możesz zadać jakiekolwiek pytanie związane z Flame.

Jeśli czujesz się bardziej komfortowo ze StackOverflow, możesz również utworzyć tam pytanie. Dodaj
[tag Flame](https://stackoverflow.com/questions/tagged/flame), aby każdy, kto śledzi tag, mógł pomóc.


## Cechy

Celem Flame Engine jest dostarczenie kompletnego zestawu nietuzinkowych rozwiązań typowych problemów, które mogą być do siebie podobne dla gier opracowanych z Flutter.

Oto niektóre z kluczowych dostępnych funkcji:

 - Pętla gry.
 - System komponent/obiekt (FCS).
 - Efekty i cząsteczki.
 - Wykrywanie kolizji.
 - Obsługa gestów i wprowadzania danych.
 - Obrazy, duszki (sprites) i arkusze duszka.
 - Ogólne narzędzia ułatwiające programowanie.

Oprócz tych funkcji możesz wzmocnić Flame pakietami bridge. Dzięki tym bibliotekom będziesz mógł uzyskać dostęp do powiązań z innymi pakietami, w tym z niestandardowymi komponentami i pomocnikami Flame, aby integracja była bezproblemowa.

Flame oficjalnie udostępnia biblioteki bridge do następujących pakietów:

- [flame_audio](https://github.com/flame-engine/flame/tree/main/packages/flame_audio) dla
  [AudioPlayers](https://github.com/bluefireteam/audioplayers): Odtwarzaj wiele plików audio jednocześnie.
- [flame_bloc](https://github.com/flame-engine/flame/tree/main/packages/flame_bloc) dla
  [Bloc](https://github.com/felangel/bloc): Biblioteka zarządzania przewidywalnym stanem.
- [flame_fire_atlas](https://github.com/flame-engine/flame/tree/main/packages/flame_fire_atlas) dla
  [FireAtlas](https://github.com/flame-engine/fire-atlas): Twórz atlasy tekstur do gier.
- [flame_forge2d](https://github.com/flame-engine/flame/tree/main/packages/flame_forge2d) dla
  [Forge2D](https://github.com/flame-engine/forge2d): Silnik fizyki Box2D.
- [flame_lint](https://github.com/flame-engine/flame/tree/main/packages/flame_lint) -
  Nasz zestaw zasad (`analysis_options.yaml`) linting.
- [flame_oxygen](https://github.com/flame-engine/flame/tree/main/packages/flame_oxygen) dla
  [Oxygen](https://github.com/flame-engine/oxygen): Lekki framework Entity Component System (ECS).
- [flame_rive](https://github.com/flame-engine/flame/tree/main/packages/flame_rive) dla
  [Rive](https://rive.app/): Twórz interaktywne animacje.
- [flame_svg](https://github.com/flame-engine/flame/tree/main/packages/flame_svg) dla
  [flutter_svg](https://github.com/dnfield/flutter_svg): Rysuj pliki SVG w Flutter.
- [flame_tiled](https://github.com/flame-engine/flame/tree/main/packages/flame_tiled) dla
  [Tiled](https://www.mapeditor.org/): Edytor poziomów mapy kafelkowej 2D.


## Sponsorzy

Top sponsorzy Flame Engine:

[![Very Good Ventures](https://raw.githubusercontent.com/flame-engine/flame/main/media/unicorn_two_toned.png)](https://verygood.ventures/)

[![Cypher Stack](https://raw.githubusercontent.com/flame-engine/flame/main/media/logo_cypherstack.png)](https://cypherstack.com/)

Chcesz sponsorować Flame? Sprawdź nasz Patreon w sekcji poniżej lub skontaktuj się z nami na Discordzie.


## Wsparcie

Najprostszym sposobem na okazanie nam swojego wsparcia jest nadanie projektowi gwiazdki.

Możesz również wesprzeć nas stając się patronem na Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

Lub dokonując jednorazowej darowizny kupując nam kawę:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

Możesz również pokazać w swoim repozytorium, że twoja gra została stworzona z Flame, używając jednej z następujących odznak:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-272727.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```


## Współtworzenie

Znalazłeś błąd lub masz sugestię, jak wzmocnić Flame? Otwórz issue, a my zajmiemy się nim tak szybko, jak to możliwe.

Chcesz przyczynić się w rozwój swoim wkładem poprzez PR? PR są zawsze mile widziane, tylko upewnij się, że tworzysz go z odpowiedniej gałęzi (main) i podążaj za [checklistą](.github/pull_request_template.md), która pojawi się po otwarciu PR.

W przypadku większych zmian lub jeśli masz wątpliwości, porozmawiaj o swoim wkładzie z zespółem. Za pośrednictwem issue, dyskusji na GitHubie lub skontaktuj się z zespołem za pomocą
[serwera Discord](https://discord.gg/pxrBmy4).


## Pierwsze kroki

Prosty samouczek na początek można znaleźć na
[tutorials.flame-engine.org](https://tutorials.flame-engine.org) i przykłady większości funkcji w
Flame można znaleźć na [examples.flame-engine.org](https://examples.flame-engine.org). Aby uzyskać dostęp do kodu dla każdego przykładu, naciśnij przycisk `< >` w prawym górnym rogu.


### Wyróżnione samouczki społeczności

- Serie od @Devowl's Flutter & Flame:
  - [Step 1: Stwórz swoją grę](https://medium.com/flutter-community/flutter-flame-step-1-create-your-game-b3b6ee387d77)
  - [Step 2: Podstawy gry](https://medium.com/flutter-community/flutter-flame-step-2-game-basics-48b4493424f3)
  - [Step 3: Sprites oraz inputs](https://blog.devowl.de/flutter-flame-step-3-sprites-and-inputs-7ca9cc7c8b91)
  - [Step 4: Collisions & Viewport](https://blog.devowl.de/flutter-flame-step-4-collisions-viewport-ff2da048e3a6)
  - [Step 5: Generowanie poziomów i kamera](https://blog.devowl.de/flutter-flame-step-5-level-generation-camera-62a060a286e3 )

- Inne samouczki:
  - Artykuł od @Vguzzi [Budowanie gier we Flutter z Flame](https://www.raywenderlich.com/27407121-building-games-in-flutter-with-flame-getting-started)
  - Serie YouTube od @DevKage's z [Dino run tutorial](https://www.youtube.com/playlist?list=PLiZZKL9HLmWOmQgYxWHuOHOWsUUlhCCOY)

Oferujemy wyselekcjonowaną listę gier, bibliotek i artykułów na stronie
[awesome-flame](https://github.com/flame-engine/awesome-flame).

Pamiętaj, że niektóre artykuły mogą być nieco nieaktualne, ale nadal mogą być przydatne.


## Uznanie

 - Zespół [Blue Fire](https://github.com/orgs/bluefireteam/people), który nieustannie pracuje nad utrzymaniem i ulepszaniem Flame oraz jego ekosystemu.
 - Wszyscy sympatyczni współtwórcy i ludzie, którzy pomagają w społeczności.
