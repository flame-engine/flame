# YarnSpinner language

**YarnSpinner** is the language in which `.yarn` files are written. You can check out the
[official documentation] for the YarnSpinner language, however, here we will be describing the
**Jenny** implementation, which may not contain all the original features, but may also contain
some that were not implemented in the YarnSpinner yet.

[official documentation]: https://docs.yarnspinner.dev/getting-started/writing-in-yarn


## Yarn files

Any Yarn project will contain one or more `.yarn` files. These are plain text files in UTF-8
encoding. As such, they can be edited in any text editor or IDE.

Having multiple `.yarn` files helps you better organize your project, but Jenny doesn't impose any
requirements on the number of files or their relationship.

Each `.yarn` file may contain **comments**, **tags**, **[commands]**, and **[nodes]**.
For example:

```yarn
// This is a comment
// The line below, however, is a tag:
# Chapter 1d

<<declare $visited_graveyard = false>>
<<declare $money = 25>>  // is this too much?

title: Start
---
// Node content
===
```

[commands]: commands/commands.md
[nodes]: nodes.md


### Comments

A comment starts with `//` and continues until the end of the line. All the text inside a comment
will be completely ignored by Jenny as if it wasn't there.

There are no multi-line comments in YarnSpinner.


### Tags

File-level tags start with a `#` and continue until the end of the line. A tag can be used to
include some per-file custom project metadata. These tags are not interpreted by Jenny in any way.


### Commands

The commands are explained in more details [later][commands], but at this point it is
worth pointing out that only a limited number of commands are allowed at the root level of a file
(that is, outside of nodes). Currently, these commands are:

- `<<declare>>`
- `<<character>>`

The commands outside of nodes are compile-time instructions, that is they are executed during the
compilation of a YarnProject.


### Nodes

Nodes represent the main bulk of content in a yarn file, and are explained in a dedicated
[section][nodes]. There could be multiple nodes in a single file, placed one after another.
No special separator is needed between nodes: as soon as one node ends, the next one can begin.


```{toctree}
:hidden:

Nodes        <nodes.md>
Lines        <lines.md>
Options      <options.md>
Commands     <commands/commands.md>
Expressions  <expressions.md>
```
