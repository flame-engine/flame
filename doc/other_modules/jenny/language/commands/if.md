# `<<if>>`

The **\<\<if\>\>** command evaluates its condition, and based on that decides which statements to
execute next. This is equivalent to `if` keyword in most programming languages. This command may
have multiple parts, which look as follows:

```yarn
<<if condition1>>
  statements1...
<<elseif condition2>>
  statements2...
<<else>>
  statementsN...
<<endif>>
```

- The conditions within each command must have boolean type.
- There could be any number of `<<elseif>>` blocks.
- The `<<elseif>>` blocks and `<<else>>` are optional.
- The final `<<endif>>` is mandatory.
- The statements within each block must be indented.

At runtime, the condition within the `if` block is evaluated first. If it turns out to be `true`,
then the dialogue proceeds with executing `statements1`, and no other conditions are evaluated nor
other statement blocks executed. However, if `condition1` evaluated to `false`, then `condition2`
is calculated. If it is true, then the dialogue runner will execute `statements2`, and if false it
will fall-through into the `else` block and execute `statementsN`. In the end, the dialogue will
proceed to statements that occur after the final `<<endif>>`.


## Example

In this dialogue a *Guard* will greet you differently depending on your reputation with the
citizens of the area. If your reputation falls below −100, you'll be attacked on sight.

```yarn
title: GuardGreeting
---
<<if $reputation >= 100>>
  Guard: Hail to the savior of the people!
<<elseif $reputation >= 30>>
  Guard: Nice to meet you, sir!
<<elseif $reputation >= 0>>
  Guard: Hello
<<elseif $reputation > -30>>
  Guard: I'm keeping an eye on you...
<<elseif $reputation > -100>>
  Guard: You filthy scum!
<<else>>
  Guard: You'll pay for your crimes! #auto
  <<attack>>
<<endif>>
===
```
