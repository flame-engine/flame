# `<<set>>`

The **\<\<set\>\>** command is used to update the value of an existing variable. The variable
must be declared with [\<\<declare\>\>][declare] or [\<\<local\>\>][local] before it can be used
in `<<set>>`.

The command `<<set>>` allows either regular assignment, or modifying assignment, like follows:

```yarn
// Regular assignment
<<set $VARIABLE = EXPRESSION>>
<<set $VARIABLE to EXPRESSION>>

// Modifying assignments
<<set $VARIABLE += EXPRESSION>>
<<set $VARIABLE -= EXPRESSION>>
<<set $VARIABLE *= EXPRESSION>>
<<set $VARIABLE /= EXPRESSION>>
<<set $VARIABLE %= EXPRESSION>>

// These modifying assignments are equivalent to the following:
<<set $VARIABLE = $VARIABLE + EXPRESSION>>
<<set $VARIABLE = $VARIABLE - EXPRESSION>>
<<set $VARIABLE = $VARIABLE * EXPRESSION>>
<<set $VARIABLE = $VARIABLE / EXPRESSION>>
<<set $VARIABLE = $VARIABLE % EXPRESSION>>
```

In all cases, the `EXPRESSION` must have the same type as the `$VARIABLE`. If not, a compile-time
error will be thrown.


## Examples

```yarn
<<declare $favorite_color as String>>

title: ColorQuiz
---
What is your favorite color?
-> White
   <<set $favorite_color to "White">>
-> Red
   <<set $favorite_color to "Red">>
-> Yellow
   <<set $favorite_color = "Yellow">>
-> Blue
   Oh, Nice! Which shade of blue?
   -> Azure
   -> Cerulean
   -> Lapis Lazuli
   Umm, I don't know how to spell that. I'll just put you down as "blue".
   <<set $favorite_color = "Blue">>
-> Black
   <<set $favorite_color = "Black">>
   That's mine too!
   <<set $affinity += 3>>
-> Prefer not to tell
   Aww... Maybe if I ask again really nicely?
   <<jump ColorQuiz>>
===
```


[declare]: declare.md
[local]: local.md
