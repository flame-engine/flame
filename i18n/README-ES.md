<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Motor minimalista para el desarrollo de videojuegos con Flutter.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame/versions#prerelease" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout&include_prereleases" /></a>
  <a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>
  <img src="https://github.com/flame-engine/flame/workflows/Test/badge.svg?branch=main&event=push" alt="Test" />
  <a title="Discord" href="https://discord.gg/pxrBmy4" ><img src="https://img.shields.io/discord/509714518008528896.svg" /></a>
</p>

---

[English](/README.md) | [简体中文](/i18n/README-ZH.md) | [Polski](/i18n/README-PL.md) | [Русский](/i18n/README-RU.md) | [Español](/i18n/README-ES.md)

---

## Acerca de 1.0.0

Nuestro objetivo es lanzar pronto la v1. Periódicamente lanzamos RCs (release candidates) a medida que el código evoluciona,
y estamos bastante complacidos en el punto que nos encontramos (aunque aún pueden existir cambios).

Favor de usar esta versión como un avance de la nueva versión de Flame y también para aportar feedback al equipo sobre
la nueva estructura y/o características.

La rama `main` es lo más próximo a una migración hacia la v1. La rama `master-v0.x` es el último lanzamiento v0
(en la cual aún estamos fusionando algunos parches y arreglos críticos).

La actual v1 lanzada es
<a title="Pub" href="https://pub.dev/packages/flame/versions#prerelease" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout&include_prereleases" /></a>
en pub. La última versión estable hasta ahora es
<a title="Pub" href="https://pub.dev/packages/flame" ><img src="https://img.shields.io/pub/v/flame.svg?style=popout" /></a>.
Siéntase libre de elegir la versión que mejor se adapte a sus necesidades.

---

## Documentación

Tome en cuenta que la documentación en la rama `main` de este repositorio es más nueva que la última versión lanzada.

Aquí puede encontrar la documentación para las diferentes versiones:
- Última versión estable: [Flame-engine website](https://flame-engine.org/)
- Última versión estable: [GitHub docs](https://github.com/flame-engine/flame/tree/master-v0.x/doc)
- Última versión v1.0.0: [GitHub docs](https://github.com/flame-engine/flame/tree/1.0.0-releasecandidate.11/doc)

La documentación completa se puede encontrar [aquí](https://github.com/flame-engine/flame/tree/main/doc).

Proporcionamos muchos ejemplos de diversas características que pueden ser probadas desde su navegador de Internet
[aquí](https://flame-engine.github.io/flame/). También puede examinar el código fuente de estos ejemplos [aquí](https://github.com/flame-engine/flame/tree/main/examples).

El sitio oficial de Flame, el cual también contiene la documentación se puede encontrar
[aquí](https://flame-engine.org/).

## Ayuda

Tenemos un canal de ayuda en el servidor de Discord Blue Fire, únete [aquí](https://discord.gg/pxrBmy4).

También contamos con un [FAQ](FAQ.md), por favor busque su respuesta primero ahí.

## Objetivos

El objetivo de este proyecto es la de ofrecer un conjunto completo y sin obstáculos de soluciones para
los problemas más comunes que comparten todos los desarrolladores de videojuegos en Flutter.

Actualmente te ofrece:
 - un ciclo de juego
 - un sistema de componentes/objectos
 - un motor de físicas (Forge2D, disponible con
 [flame_forge2d](https://github.com/flame-engine/flame_Forge2D))
 - soporte de audio
 - efectos y partículas
 - soporte de gestos y entradas
 - imágenes, sprites y sprite sheets
 - soporte básico de Rive
 - y algunas otras utilidades para facilitar el desarrollo

Puede utilizar cuales quiera que desee, ya que todas ellas son independientes

## Apoyo

La forma más simple de mostrar su apoyo a este proyecto es dando una estrella.

También puede apoyarnos convirtiéndose patrón en Patreon:

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

O realizando una única donación al comprarnos un café:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)

Además puede mostrar en su repositorio que su juego está hecho con Flame al utilizar una de las siguientes insignias:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Contribuyendo

__Advertencia__: Estamos trabajando en traer Flame a su primera versión estable, actualizaciones a versiones `0.x`
están detenidas, excepto por arreglo de fallos críticos. Si desea contribuir a esa versión, por favor
tenga esto presente, y utilice la rama `master-v0.x`. Para contribuciones a la v1, los PR deben apuntar
hacia la rama `main`. Si aún mantiene dudas, asegúrese de conversar sobre su contribución con el equipo, ya sea por
medio de un issue o [Discord](https://discord.gg/pxrBmy4).

¡Toda ayuda es apreciada! Comentarios, sugerencias, reporte de errores, PRs.

¿Ha encontrado algún error o tiene alguna sugerencia para mejorar Flame? Inicie un issue y lo
revisaremos lo antes posible.

¿Desea contribuir con un PR? Los PRs son siempre bienvenidos, sólo asegúrese de crearlo desde la
rama correcta (ver arriba) y completar el [checklist](.github/pull_request_template.md) que aparecerá
cuando se abra el PR.

## Empezando

Puede encontrar una colección de guías [aquí](./tutorials). Considere que estos tutoriales están basados
en la rama `main`. Para asegurarse que está en los tutoriales que corresponden a la versión que utiliza,
seleccione la etiqueta correcta de la versión utilizada.

Esta colección de guías es un trabajo en progreso, más guías y tutoriales serán agregados próximamente.

Además, ofrecemos una selecta lista de juegos, librerías y artículos en
[awesome-flame](https://github.com/flame-engine/awesome-flame).

Tome a consideración que algunos de los artículos podrían estar algo desactualizados, pero aún son de utilidad.

## Créditos

 - El [Flame Engine team](https://github.com/orgs/flame-engine/people), quienes están trabajando
 continuamente en mantener y mejorar Flame.
 - Todos los amables contribuidores y las personas que ayudan en la comunidad.
 - 
