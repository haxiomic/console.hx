# Console.hx

Console.hx is a haxe logging utility for easy rich output in both native and browser consoles via a familiar HTML-like tag syntax.

For example:
````haxe
Console.log('<b>Don’t</> <red,u>Panic.</>');
````
This will print in your console something like:

![don't-panic](images/don't-panic.png)

(Depending on your console color settings). This will also work in a browser console when targeting the web.

### Installing

`haxelib install console.hx`

### Formatting

- Apply formatting with HTML-like tags it: \<b>**bold**\</b> or \<i>*italic*\</i>
- Close the last tag with shorthand \</>: \<b>**bold**</> not bold
- A double-closing tag like `<//>` will clear all active formatting
- Formatting can be combined into a single tag: \<b,i>***bold and italic***\</>
- Hex colors can be used (including CSS shorthand form), for example
  - `<#FF0000>Red Text</>`
  - `<bg#F00>Red Background</>`
- Whitespace is not allowed in tags, so `<b >` would be ignored and printed as-is
- Tags can be escaped with a leading backslash: `\<b>` would be printed as `<b>`
- CSS can be used when targeting web browsers: for example: `<{color: red; font-size: 20px}>Inline CSS</>`. These will have no affect on native consoles

### Available Tags

|           Tag Name           |              Description              |
| :--------------------------: | :-----------------------------------: |
|      `<reset>`, `<//>`       |     Clear all previous formatting     |
|            `</>`             |      Close last open formatting       |
|       `<bold>`, `<b>`        |            Format as bold             |
|      `<italic>`, `<i>`       |           Format as italic            |
|           `<dim>`            |             Dimmed color              |
|     `<underline>`, `<u>`     |               Underline               |
|          `<blink>`           |     Blink (*Native console only*)     |
|      `<invert>`, `<!>`       | Invert colors (*Native console only*) |
|          `<hidden>`          |   Hide text (*Native console only*)   |
|         `<#FF0000>`          |        Use hex for text color         |
|        `<bg#FF0000>`         |     Use hex for background color      |
|          `<black>`           |           Black text color            |
|           `<red>`            |            Red text color             |
|          `<green>`           |           Green text color            |
|          `<yellow>`          |           Yellow text color           |
|           `<blue>`           |            Blue text color            |
|         `<magenta>`          |          Magenta text color           |
|           `<cyan>`           |            Cyan text color            |
|          `<white>`           |           White text color            |
|  `<light_black>`, `<gray>`   |     Light black text color / gray     |
|        `<light_red>`         |         Light red text color          |
|       `<light_green>`        |        Light green text color         |
|       `<light_yellow>`       |        Light yellow text color        |
|        `<light_blue>`        |         Light blue text color         |
|      `<light_magenta>`       |       Light magenta text color        |
|        `<light_cyan>`        |         Light cyan text color         |
|       `<light_white>`        |        Light white text color         |
|         `<bg_black>`         |         Text background black         |
|          `<bg_red>`          |          Text background red          |
|         `<bg_green>`         |         Text background green         |
|        `<bg_yellow>`         |        Text background yellow         |
|         `<bg_blue>`          |         Text background blue          |
|        `<bg_magenta>`        |        Text background magenta        |
|         `<bg_cyan>`          |         Text background cyan          |
|         `<bg_white>`         |         Text background white         |
| `<bg_light_black>`, `<gray>` |  Text background light black / gray   |
|       `<bg_light_red>`       |       Text background light red       |
|      `<bg_light_green>`      |      Text background light green      |
|     `<bg_light_yellow>`      |     Text background light yellow      |
|      `<bg_light_blue>`       |      Text background light blue       |
|     `<bg_light_magenta>`     |     Text background light magenta     |
|      `<bg_light_cyan>`       |      Text background light cyan       |
|      `<bg_light_white>`      |      Text background light white      |

### Supported Targets

Formatting should work on mac, linux and browser consoles for all targets, however for built-in Windows consoles like Command Prompt and PowerShell, only Neko and C++ will produce colored output (assuming you're running a fairly recent build of Windows 10)

|             Target             |        Platform         | Supported  |
| :----------------------------: | :---------------------: | :--------: |
|               JS               | Chrome, Firefox, Safari |     ✔      |
| JS, C++, Neko, PHP, Python, HL |          MacOS          |     ✔      |
| JS, C++, Neko, PHP, Python, HL | Linux Common Terminals  |     ✔      |
|           C++, Neko            | Windows Command Prompt  |     ✔      |

