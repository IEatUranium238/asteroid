# Asteroid

Stupidly simple templating for Lua strings.

Asteroid simplifies string templating by using simple template syntax instead of `string.format` or concatenation. Designed for [Silvermoon](https://silvermoon.up.railway.app) HTML preprocessor, but it can be used in any Lua project.

## How to use

- Use `@name` to embed values
- Put a `!` if you need to stop reading input as value name, space also stops reading the value name
- Use `\` (`\\` if using raw strings in Lua) to escaping characters
- Make a template via `make_template` and then call it's `generate` method

## Installation

Install via Luarocks:

```bash
luarocks install asteroid
```

## Quick Start

```lua
local asteroid = require("asteroid")

local template = asteroid.make_template("Hello, @user!! You have @amount coins!")

print(template:generate({
  user = "John",
  amount = 100
})) -- Output: Hello, John! You have 100 coins!
```

## Functions

`asteroid.make_template(string, config)`

Creates a reusable template.

**Parameters:**

- `string` - String with values
- `config` - Configuration table (optional)

**Returns:** Template object with a `generate()` method

---

`template:generate(values, config)`

Generates output from a template.

**Parameters:**

- `values` - Table with replacement values
- `config` - Configuration table (optional)

**Returns:** Rendered string

## Examples

### Basic templating

```lua
local asteroid = require("asteroid")

local template = asteroid.make_template("@greeting, @name!!")

print(template:generate({
  greeting = "Hello",
  name = "John"
})) -- Output: Hello, John!
```

### Undefined values

```lua
local template = asteroid.make_template("User: @user, Credits: @credits", {
  allow_undefined = true
})

print(template:generate({
  user = "John"
}, {
  default_values = {
    credits = 0
  }
})) -- Output: User: John, Credits: 0
```

### Escaping

```lua
local template = asteroid.make_template("Email: @user\\@example.com")

print(template:generate({
  user = "johns.email"
})) -- Output: Email: johns.email@example.com
```

### Escaping function

```lua
local template = asteroid.make_template("User: @user", {
  allow_override = true
})

print(template:generate({
  user = "evil-string"
}, {
  escaper = function(value)
    if value == "evil-string" then
      return "safe-string"
    end

    return value
  end
})) -- Output: User: safe-string
```

## Configuration

Configuration can be set when creating a template or when generating output. Generator config overrides template config when `allow_override` is enabled, otherwise you will get an error.

| Option          | Type     | Default | Description                                                           |
| --------------- | -------- | ------- | --------------------------------------------------------------------- |
| allow_undefined | boolean  | false   | Allow undefined variables, uses `default` or `default_values` instead |
| allow_override  | boolean  | false   | Allow generator to override template configuration                    |
| default         | string   | "nil"   | Default value for undefined variables                                 |
| default_values  | table    | {}      | Variable specific default values                                      |
| escaper         | function | nil     | Custom function to process values before insertion                    |

## Contributing

Contributions are welcome! Please open a PR and I will review it.

## License

MIT – see [LICENSE](LICENSE)
