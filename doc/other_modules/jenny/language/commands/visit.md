# `<<visit>>`

The **\<\<visit\>\>** command temporarily puts the current node on hold, executes the target node,
and after it finishes, resumes execution of the previous node. This is similar to a function call
in many programming languages.

The `<<visit>>` command can be useful for splitting a large dialogue into several smaller nodes,
or for reusing some common dialogue lines in several nodes. For example:

```yarn
title: RoamingTrader1
---
<<if $roaming_trader_introduced>>
  Hello again, {$player}!
<<else>>
  <<visit RoamingTraderIntro>>
<<endif>>

-> What do you think about the Calamity?  <<if $calamity_started>>
   <<visit RoamingTrader_Calamity>>
-> Have you seen a weird-looking girl running by? <<if $quest_little_girl>>
   <<visit RoamingTrader_LittleGirl>>
-> What do you have for trade?
   <<OpenTrade>>

Pleasure doing business with you! #auto
===
```

The argument of this command is the id of the node to jump to. It can be given either as a plain
node ID, or as an expression in curly braces:

```yarn
<<visit {"RewardChoice_" + string($choice)}>>
```

If the expression evaluates at runtime to an unknown name, then a `NameError` exception will be
thrown.
