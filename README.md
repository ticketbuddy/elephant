# An Elephant never forgets!

Use this library to dynamically create a list of reminders.

#### Usage
```elixir
# Cannot schedule for within next 1 minute
Elephant.exec({1, :hour}, {Module, func, args})

# Schedule for a date in the distance future
Elephant.exec(DateTime.t(), {Module, func, args})
```

#### Design

##### Storage
An action is stored with a target `timestamp`, `failure_strategy`, `app_idempotency_key` and the `module`, `function` and `arguments`
that are used when the target time is reached.

If an action fails, the `failure_strategy` value is then used to determine what happens next.
- `:ignore` - will accept the failure.
- `{:retry, {5, :hours}}` - will retry until success every 5 hours.

The `app_idempotency_key` value is sent with every callback to ensure actions are only executed exactly once.
