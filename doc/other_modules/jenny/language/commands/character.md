# `<<character>>`

The **\<\<character\>\>** command declares a character with the given name, and one or more aliases
that can be used in the scripts.

The command has several purposes:

- it protects you from accidentally misspelling a character's name in your script;
- it allows a character to have *full name*, which doesn't have to be an ID;
- it allows declaring multiple aliases for the same character, which can be used in different
  nodes (an alias may even be in a different language than the full name);
- you can associate additional data with each character, which will then be available at runtime.

The format of this command is the following:

```yarn
<<character "FULL NAME" alias1 alias2...>>
```

The *full name* here is optional: if given, it will be considered *the* name of the character.
However, if the name is omitted, then the first alias will be considered the true character's name.
Each *alias* must be a valid ID, and at least one alias must be provided. For example:

```yarn
// A well-mannered seven-year-old girl, who nevertheless always gets into
// all kinds of zany adventures.
<<character Alice>>

// A magical cat known for his ability to grin majestically, and partially
// vanish. He is mad (by his own admission).
<<character "Cheshire Cat" Cat Cheshire>>

// A foul-tempered Queen, who is also a playing card. Described as
// "a blind fury", her favorite saying is "Off with their heads!".
// Not to be confused with Red Queen.
<<character "Queen of Hearts" Queen QoH QH>>
```

After a character is declared, any of its aliases can be used in the script: they will all refer
to the same `Character` object. At the same time, using a character without declaring it first is
not allowed (unless a special flag in `YarnProject` is set to allow this).

```yarn
title: Alice_and_the_Cat
---
Alice: But I don't want to go among mad people.
Cat:   Oh, you can't help that, we're all mad here. I'm mad. You're mad.
Alice: How do you know I'm mad?
Cat:   You must be, or you wouldn't have come here.
Alice: And how do you know that you're mad?
Cat:   To begin with, a dog's not mad. You grant that?
Alice: I suppose so.
Cat:   Well then, you see a dog growls when it's angry, and wags its tail \
       when it's pleased.
Cat:   Now, [i]I[/i] growl when I'm pleased, and wag my tail when I'm angry. \
       Therefore, I'm mad.
Alice: [i]I[/i] call it purring, not growling.
Cat:   Call it what you like.
===
```
