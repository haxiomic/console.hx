# Console.hx

Console.hx is a haxe console and logging utility for simple and cross-platform rich console output

Example:
````haxe
Console.log('%{BOLD}Don’t%{-} %{RED}%{UNDERLINE}Panic.');
````
Will print something like:

![don't-panic](images/don't-panic.png)

In your console (depending on your console color settings). This will also work in a web browser console when targeting js

### Formatting
- Formats are applied cumulatively with the syntax: `%{<format flag>}`
- <format flag> is any one of the Console.FormatFlag strings, eg `%{RED}` (case in-sensitive)
- Cumulative format is cleared with `%{RESET}`
- Format tokens can be escaped with a backslash: `\%{RED}` will print '\%{RED}'
- Invalid format flags are ignored (and removed from the string)
- Several aliases exist for common formatting flags:
  - `%{-} => %{RESET}`
  - `%{!} => %{INVERT}`
  - `%{_} => %{UNDERLINE}`
  - `%{*} => %{BOLD}`
- There are a few special cases for different console types
  - Browser consoles:
    - Hex color codes can be used to set the text color, e.g. `%{#FF0000}`
    - CSS style fields can be used, e.g. `%{background-color: black; color: white}`