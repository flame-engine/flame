# `<<wait>>`

The **\<\<wait\>\>** command forces the dialogue engine to wait for the specified duration
(in seconds) before resuming the dialogue. The number of seconds can be 0, but cannot be negative.
This command takes a single argument, which must be a numeric expression. For example:

```yarn
// Wait for a quarter of a second
<<wait 0.25>>

// Wait for the amount of time given by the $delay variable
<<wait $delay>>
```
