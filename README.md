# An Elephant never forgets!

Use this library to dynamically create a list of reminders.

#### Usage
```elixir
# Cannot schedule for within next 1 minute
Elephant.remember({1, :hour}, {Module, func, args})

# Schedule for a date in the distance future
Elephant.remember(DateTime.t(), {Module, func, args})
```
