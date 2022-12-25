# Commands

The **commands** are special instructions surrounded with double angle-brackets: `<<stop>>`. There
are both *built-in* and *user-defined* commands.

The **built-in** commands are those that are supported by the YarnSpinner runtime itself. Typically
they would alter the execution of the dialogue, or perform a similar dialogue-related function. The
full list of such commands is given below.

The **user-defined** commands are those that you yourself create and then use within your yarn
scripts. For a full description of these commands, see the document on [user-defined commands].


## Built-in commands


### Variables

**[\<\<declare\>\>](declare.md)**
: Declares a global variable.

**[\<\<local\>\>](local.md)**
: Declares a local variable.

**[\<\<set\>\>](set.md)**
: Updates the value of a variable (either local or global).


### Control flow

**[\<\<if\>\>](if.md)**
: Conditionally executes certain statements. This is equivalent to the **if** keyword in most
  programming languages.

**[\<\<jump\>\>](jump.md)**
: Switches execution to another node.

**[\<\<stop\>\>](stop.md)**
: Stops executing the current node.

**[\<\<visit\>\>](visit.md)**
: Temporarily jumps to another node, and then comes back.

**[\<\<wait\>\>](wait.md)**
: Pauses the dialogue for the specified amount of time.


[user-defined commands]: user_defined_commands.md

```{toctree}
:hidden:

<<declare>>            <declare.md>
<<if>>                 <if.md>
<<jump>>               <jump.md>
<<local>>              <local.md>
<<set>>                <set.md>
<<stop>>               <stop.md>
<<visit>>              <visit.md>
<<wait>>               <wait.md>
User-defined commands  <user_defined_commands.md>
```
