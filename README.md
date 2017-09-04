# Console.hx

Console.hx is a haxe logging utility for easy rich output in both native and browser consoles

Example:
````haxe
Console.log('<b>Don’t</b> <red><u>Panic.</u></red>');
````
Will print in your console something like:

![don't-panic](images/don't-panic.png)

(depending on your console color settings). This will also work in a browser console when targeting the web

### Formatting

- HTML-like tags to enable a format flag and disable it: e.g. 

  **\<b>bold\</b>** not bold
- Whitespace is not allowed in tags, so `<b >` would be ignored and printed as-is
- Unknown tags are skipped and will not show up in the output
- Available tags
| Tag Name            | Description                           |
| ------------------- | ------------------------------------- |
| \<reset>, \<//>     | Clear all previous formatting         |
| \<bold>, \<b>       | Format as bold                        |
| \<dim>              | Dimmed color                          |
| \<underline>, \<u>  | Underline                             |
| \<blink>            | Blink (*Native console only*)         |
| \<invert>, \<!>     | Invert colors (*Native console only*) |
| \<hidden>           | Hide text (*Native console only*)     |
| \<black>            | Black text color                      |
| \<red>              | Red text color                        |
| \<green>            | Green text color                      |
| \<yellow>           | Yellow text color                     |
| \<blue>             | Blue text color                       |
| \<magenta>          | Magenta text color                    |
| \<cyan>             | Cyan text color                       |
| \<white>            | White text color                      |
| \<light_black>      | Light black text color                |
| \<light_red>        | Light red text color                  |
| \<light_green>      | Light green text color                |
| \<light_yellow>     | Light yellow text color               |
| \<light_blue>       | Light blue text color                 |
| \<light_magenta>    | Light magenta text color              |
| \<light_cyan>       | Light cyan text color                 |
| \<light_white>      | Light white text color                |
| \<bg_black>         | Text background black                 |
| \<bg_red>           | Text background red                   |
| \<bg_green>         | Text background green                 |
| \<bg_yellow>        | Text background yellow                |
| \<bg_blue>          | Text background blue                  |
| \<bg_magenta>       | Text background magenta               |
| \<bg_cyan>          | Text background cyan                  |
| \<bg_white>         | Text background white                 |
| \<bg_light_black>   | Text background light black           |
| \<bg_light_red>     | Text background light red             |
| \<bg_light_green>   | Text background light green           |
| \<bg_light_yellow>  | Text background light yellow          |
| \<bg_light_blue>    | Text background light blue            |
| \<bg_light_magenta> | Text background light magenta         |
| \<bg_light_cyan>    | Text background light cyan            |
| \<bg_light_white>   | Text background light white           |