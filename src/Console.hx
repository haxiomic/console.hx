import haxe.macro.Context;
import haxe.macro.Expr;

class Console {

	static public var colorMode = guessConsoleFormatMode();

	@:noCompletion
	static public var logPrefix = '<b><gray>></gray></b> ';
	@:noCompletion
	static public var warnPrefix = '<b><yellow>></yellow></b> ';
	@:noCompletion
	static public var errorPrefix = '<b><red>></red></b> ';
	@:noCompletion
	static public var successPrefix = '<b><light_green>></light_green></b> ';
	@:noCompletion
	static public var debugPrefix = '<b><magenta>></magenta></b> ';

	static var argSeparator = ' ';

	macro static public function log(rest:Array<Expr>){
		return macro Console.printFormatted(Console.logPrefix + ${joinArgs(rest)}, Log);
	}

	macro static public function warn(rest:Array<Expr>){
		return macro Console.printFormatted(Console.warnPrefix + ${joinArgs(rest)}, Warn);
	}

	macro static public function error(rest:Array<Expr>){
		return macro Console.printFormatted(Console.errorPrefix + ${joinArgs(rest)}, Error);
	}

	macro static public function success(rest:Array<Expr>){
		return macro Console.printFormatted(Console.successPrefix + ${joinArgs(rest)}, Log);
	}

	// Only generates log call if -debug build flag is supplied
	macro static public function debug(rest:Array<Expr>){
		if(!Context.getDefines().exists('debug')) return macro null;
		var pos = Context.currentPos();
		return macro Console.printFormatted(Console.debugPrefix + '<magenta>${pos}:</magenta> ' + ${joinArgs(rest)}, Debug);
	}

	static public inline function print(s:String, outputStream:ConsoleOutputStream = Log){
		#if js
		switch outputStream {
			case Log, Debug: untyped __js__('console.log({0})', s);
			case Warn: untyped __js__('console.warn({0})', s);
			case Error: untyped __js__('console.error({0})', s);
		}
		#else
		switch outputStream {
			case Log, Debug, Warn: Sys.stdout().writeString(s + '\n');
			case Error: Sys.stderr().writeString(s + '\n');
		}
		#end

	}

	/**
		# Parse formatted message and print to console
		- Apply formatting with HTML-like tags it: _\<b>_**bold**_\</b>_
		- Tags are case-insensitive
		- A closing tag without a tag name can be used to close the last-open format tag `</>` so _\<b>_**bold**_\</>_ will also work
		- A double-closing tag like `<//>` will clear all active formatting
		- Whitespace is not allowed in tags, so `<b >` would be ignored and printed as-is
		- Tags can be escaped with a leading backslash: `\<b>` would be printed as-is
		- Unknown tags are skipped and will not show up in the output
		- For browser targets, CSS fields and colors can be used, for example: `<{color: red; font-size: 20px}>Inline CSS</>` or `<#FF0000>Red Text</#FF0000>`. These will have no affect on native consoles
	**/
	static var formatTagPattern = ~/(\\)?<(\/)?([^>{}\s]*|{[^>}]*})>/g;
	public static function printFormatted(s:String, outputStream:ConsoleOutputStream = Log){
		s = s + '<//>';// Add a reset all to the end to prevent splitting formatting to subsequent lines

		var activeFormatFlagStack = new List<FormatFlag>();
		var browserFormatArguments = [];

		var result = formatTagPattern.map(s, function(e){
			// handle escaped flag \<b>
			if (e.matched(1) != null) return e.matched(0).substring(1);

			var flag:FormatFlag = FormatFlag.fromString(e.matched(3));
			var open = e.matched(2) == null;

			if (flag == RESET) {
				// clear formating
				activeFormatFlagStack.clear();
			} else {
				if (open) {
					activeFormatFlagStack.add(flag);
				} else {
					if (flag != '') {
						activeFormatFlagStack.remove(flag);
					} else {
						// We've got a shorthand to close the last tag: </>
						activeFormatFlagStack.remove(activeFormatFlagStack.last());
					}
				}
			}

			switch colorMode {
				case AsciiTerminal:
					return getAsciiFormat(RESET) + activeFormatFlagStack.map(function(f) return getAsciiFormat(f)).filter(function(s) return s != null).join('');
				case BrowserConsole:
					browserFormatArguments.push(activeFormatFlagStack.map(function(f) return getBrowserFormat(f)).filter(function(s) return s != null).join('; '));
					return '%c';
				case Disabled:
					return '';
			}
		});

		// for browser consoles we need to call console.log with formatting arguments
		#if js
		if (colorMode == BrowserConsole) {
			var logArgs = [result].concat(browserFormatArguments);
			switch outputStream {
				case Log, Debug: untyped __js__('console.log.apply(console, {0})', logArgs);
				case Warn: untyped __js__('console.warn.apply(console, {0})', logArgs);
				case Error: untyped __js__('console.error.apply(console, {0})', logArgs);
			}
			return;
		}
		#end

		// otherwise we can print with inline escape codes
		print(result, outputStream);
	}

	static inline function guessConsoleFormatMode():ConsoleFormatMode {
		#if js
		return untyped __typeof__(js.Browser.window) != 'undefined' ? BrowserConsole : AsciiTerminal;
		#else
		return AsciiTerminal;
		#end
	}

	static function joinArgs(rest:Array<Expr>):ExprOf<String> {
		var msg:Expr = macro '';
		for(i in 0...rest.length){
			var e = rest[i];
			msg = macro $msg + $e;
			if (i != rest.length - 1){
				msg = macro $msg + '$argSeparator';
			}
		}
		return msg;
	}

	static function getAsciiFormat(name:FormatFlag):Null<String> {
		// custom hex color
		if ((name:String).charAt(0) == '#') {
			var bestAsciiColor = hexToAsciiColorCode((name:String).substr(1));
			if (bestAsciiColor != null) {
				return '\033[38;5;' + bestAsciiColor + 'm';
			}
		}

		// custom hex background
		if ((name:String).substr(0, 3) == 'bg#') {
			var bestAsciiColor = hexToAsciiColorCode((name:String).substr(3));
			if (bestAsciiColor != null) {
				return '\033[48;5;' + bestAsciiColor + 'm';
			}
		}

		return switch (name) {
			case RESET: '\033[m';

			case BOLD: '\033[1m';
			case DIM: '\033[2m';
			case UNDERLINE: '\033[4m';
			case BLINK: '\033[5m';
			case INVERT: '\033[7m';
			case HIDDEN: '\033[8m';

			case BLACK: '\033[38;5;' + ASCII_BLACK_CODE + 'm';
			case RED: '\033[38;5;' + ASCII_RED_CODE + 'm';
			case GREEN: '\033[38;5;' + ASCII_GREEN_CODE + 'm';
			case YELLOW: '\033[38;5;' + ASCII_YELLOW_CODE + 'm';
			case BLUE: '\033[38;5;' + ASCII_BLUE_CODE + 'm';
			case MAGENTA: '\033[38;5;' + ASCII_MAGENTA_CODE + 'm';
			case CYAN: '\033[38;5;' + ASCII_CYAN_CODE + 'm';
			case WHITE: '\033[38;5;' + ASCII_WHITE_CODE + 'm';
			case LIGHT_BLACK: '\033[38;5;' + ASCII_LIGHT_BLACK_CODE + 'm';
			case LIGHT_RED: '\033[38;5;' + ASCII_LIGHT_RED_CODE + 'm';
			case LIGHT_GREEN: '\033[38;5;' + ASCII_LIGHT_GREEN_CODE + 'm';
			case LIGHT_YELLOW: '\033[38;5;' + ASCII_LIGHT_YELLOW_CODE + 'm';
			case LIGHT_BLUE: '\033[38;5;' + ASCII_LIGHT_BLUE_CODE + 'm';
			case LIGHT_MAGENTA: '\033[38;5;' + ASCII_LIGHT_MAGENTA_CODE + 'm';
			case LIGHT_CYAN: '\033[38;5;' + ASCII_LIGHT_CYAN_CODE + 'm';
			case LIGHT_WHITE: '\033[38;5;' + ASCII_LIGHT_WHITE_CODE + 'm';

			case BG_BLACK: '\033[48;5;' + ASCII_BLACK_CODE + 'm';
			case BG_RED: '\033[48;5;' + ASCII_RED_CODE + 'm';
			case BG_GREEN: '\033[48;5;' + ASCII_GREEN_CODE + 'm';
			case BG_YELLOW: '\033[48;5;' + ASCII_YELLOW_CODE + 'm';
			case BG_BLUE: '\033[48;5;' + ASCII_BLUE_CODE + 'm';
			case BG_MAGENTA: '\033[48;5;' + ASCII_MAGENTA_CODE + 'm';
			case BG_CYAN: '\033[48;5;' + ASCII_CYAN_CODE + 'm';
			case BG_WHITE: '\033[48;5;' + ASCII_WHITE_CODE + 'm';
			case BG_LIGHT_BLACK: '\033[48;5;' + ASCII_LIGHT_BLACK_CODE + 'm';
			case BG_LIGHT_RED: '\033[48;5;' + ASCII_LIGHT_RED_CODE + 'm';
			case BG_LIGHT_GREEN: '\033[48;5;' + ASCII_LIGHT_GREEN_CODE + 'm';
			case BG_LIGHT_YELLOW: '\033[48;5;' + ASCII_LIGHT_YELLOW_CODE + 'm';
			case BG_LIGHT_BLUE: '\033[48;5;' + ASCII_LIGHT_BLUE_CODE + 'm';
			case BG_LIGHT_MAGENTA: '\033[48;5;' + ASCII_LIGHT_MAGENTA_CODE + 'm';
			case BG_LIGHT_CYAN: '\033[48;5;' + ASCII_LIGHT_CYAN_CODE + 'm';
			case BG_LIGHT_WHITE: '\033[48;5;' + ASCII_LIGHT_WHITE_CODE + 'm';
		}
	}

	/*
		Find the best matching ascii color code for a given hex string
		- Ascii 256-color terminals support a subset of 24-bit colors
		- This includes 216 colors and 24 grayscale values
	*/
	static function hexToAsciiColorCode(hex:String):Null<Int> {
		var r = Std.parseInt('0x'+hex.substr(0, 2));
		var g = Std.parseInt('0x'+hex.substr(2, 2));
		var b = Std.parseInt('0x'+hex.substr(4, 2));

		if (r != null && g != null & b!= null) {
			// Find the nearest value's index in the set
			// A metric like ciede2000 would be better, but this will do for now
			inline function nearIdx(c:Int, set:Array<Int>){
				var delta = Math.POSITIVE_INFINITY;
				var index = -1;
				for (i in 0...set.length) {
					var d = Math.abs(c - set[i]);
					if (d < delta) {
						delta = d;
						index = i;
					}
				}
				return index;
			}

			inline function clamp(x:Int, min:Int, max:Int){
				return Math.max(Math.min(x, max), min);
			}

			// Colors are index 16 to 231 inclusive = 216 colors
			// Steps are in spaces of 40 except for the first which is 95
			// (0x5f + 40 * (n - 1)) * (n > 0 ? 1 : 0)
			var colorSteps = [0x00, 0x5f, 0x87, 0xaf, 0xd7, 0xff];
			var ir = nearIdx(r, colorSteps), ig = nearIdx(g, colorSteps), ib = nearIdx(b, colorSteps);
			var ier = Math.abs(r - colorSteps[ir]), ieg = Math.abs(g - colorSteps[ig]), ieb = Math.abs(b - colorSteps[ib]);
			var averageColorError = ier + ieg + ieb;

			// Gray scale values are 232 to 255 inclusive = 24 colors
			// Steps are in spaces of 10
			// 0x08 + 10 * n = c
			var jr = Math.round((r - 0x08) / 10), jg = Math.round((g - 0x08) / 10), jb = Math.round((b - 0x08) / 10);
			var jer = Math.abs(r - clamp((jr * 10 + 0x08), 0x08, 0xee));
			var jeg = Math.abs(g - clamp((jg * 10 + 0x08), 0x08, 0xee));
			var jeb = Math.abs(b - clamp((jb * 10 + 0x08), 0x08, 0xee));
			var averageGrayError = jer + jeg + jeb;

			// If we hit an exact grayscale match then use that instead
			if (averageGrayError < averageColorError && r == g && g == b) {
				var grayIndex = jr + 232;
				return grayIndex;
			} else {
				var colorIndex = 16 + ir*36 + ig*6 + ib;
				return colorIndex;
			}
		}

		return null;
	}

	static function getBrowserFormat(name:FormatFlag):Null<String> {
		// custom hex color
		if ((name:String).charAt(0) == '#') {
			return 'color: $name';
		}

		// custom hex background
		if ((name:String).substr(0, 3) == 'bg#') {
			return 'background-color: ${(name:String).substr(2)}';
		}

		// inline CSS
		if ((name:String).charAt(0) == '{') {
			// return content as-is but remove enclosing braces
			return (name:String).substr(1, (name:String).length - 2);
		}

		return switch (name) {
			case RESET: '';

			case BOLD: 'font-weight: bold';
			case DIM: 'color: gray';
			case UNDERLINE: 'text-decoration: underline';
			case BLINK: 'text-decoration: blink'; // not supported
			case INVERT: '-webkit-filter: invert(100%); filter: invert(100%)'; // not supported
			case HIDDEN: 'visibility: hidden'; // not supported

			case BLACK: 'color: black';
			case RED: 'color: red';
			case GREEN: 'color: green';
			case YELLOW: 'color: gold';
			case BLUE: 'color: blue';
			case MAGENTA: 'color: magenta';
			case CYAN: 'color: cyan';
			case WHITE: 'color: whiteSmoke';

			case LIGHT_BLACK: 'color: gray';
			case LIGHT_RED: 'color: salmon';
			case LIGHT_GREEN: 'color: lightGreen';
			case LIGHT_YELLOW: 'color: lightYellow';
			case LIGHT_BLUE: 'color: lightBlue';
			case LIGHT_MAGENTA: 'color: lightPink';
			case LIGHT_CYAN: 'color: lightCyan';
			case LIGHT_WHITE: 'color: white';

			case BG_BLACK: 'background-color: black';
			case BG_RED: 'background-color: red';
			case BG_GREEN: 'background-color: green';
			case BG_YELLOW: 'background-color: gold';
			case BG_BLUE: 'background-color: blue';
			case BG_MAGENTA: 'background-color: magenta';
			case BG_CYAN: 'background-color: cyan';
			case BG_WHITE: 'background-color: whiteSmoke';
			case BG_LIGHT_BLACK: 'background-color: gray';
			case BG_LIGHT_RED: 'background-color: salmon';
			case BG_LIGHT_GREEN: 'background-color: lightGreen';
			case BG_LIGHT_YELLOW: 'background-color: lightYellow';
			case BG_LIGHT_BLUE: 'background-color: lightBlue';
			case BG_LIGHT_MAGENTA: 'background-color: lightPink';
			case BG_LIGHT_CYAN: 'background-color: lightCyan';
			case BG_LIGHT_WHITE: 'background-color: white';
		}
	}

}

@:enum
abstract ConsoleOutputStream(Int) {
	var Log = 0;
	var Warn = 2;
	var Error = 3;
	var Debug = 4;
}

@:enum
abstract ConsoleFormatMode(Int) {
	var AsciiTerminal = 0;
	var BrowserConsole = 1;
	var Disabled = 2;
}

@:enum
abstract FormatFlag(String) to String {
	var RESET = 'reset';
	var BOLD = 'bold';
	var DIM = 'dim';
	var UNDERLINE = 'underline';
	var BLINK = 'blink';
	var INVERT = 'invert';
	var HIDDEN = 'hidden';
	var BLACK = 'black';
	var RED = 'red';
	var GREEN = 'green';
	var YELLOW = 'yellow';
	var BLUE = 'blue';
	var MAGENTA = 'magenta';
	var CYAN = 'cyan';
	var WHITE = 'white';
	var LIGHT_BLACK = 'light_black';
	var LIGHT_RED = 'light_red';
	var LIGHT_GREEN = 'light_green';
	var LIGHT_YELLOW = 'light_yellow';
	var LIGHT_BLUE = 'light_blue';
	var LIGHT_MAGENTA = 'light_magenta';
	var LIGHT_CYAN = 'light_cyan';
	var LIGHT_WHITE = 'light_white';
	var BG_BLACK = 'bg_black';
	var BG_RED = 'bg_red';
	var BG_GREEN = 'bg_green';
	var BG_YELLOW = 'bg_yellow';
	var BG_BLUE = 'bg_blue';
	var BG_MAGENTA = 'bg_magenta';
	var BG_CYAN = 'bg_cyan';
	var BG_WHITE = 'bg_white';
	var BG_LIGHT_BLACK = 'bg_light_black';
	var BG_LIGHT_RED = 'bg_light_red';
	var BG_LIGHT_GREEN = 'bg_light_green';
	var BG_LIGHT_YELLOW = 'bg_light_yellow';
	var BG_LIGHT_BLUE = 'bg_light_blue';
	var BG_LIGHT_MAGENTA = 'bg_light_magenta';
	var BG_LIGHT_CYAN = 'bg_light_cyan';
	var BG_LIGHT_WHITE = 'bg_light_white';

	@:from
	static public inline function fromString(str:String) {
		// handle aliases
		return switch str.toLowerCase() {
			case '/': RESET;
			case '!': INVERT;
			case 'u': UNDERLINE;
			case 'b': BOLD;
			case 'gray': LIGHT_BLACK;
			case 'bg_gray': BG_LIGHT_BLACK;
			case transformed: untyped transformed;
		}
	}
}

@:enum
abstract AsciiColorCodes(Int){
	var ASCII_BLACK_CODE = 0;
	var ASCII_RED_CODE = 1;
	var ASCII_GREEN_CODE = 2;
	var ASCII_YELLOW_CODE = 3;
	var ASCII_BLUE_CODE = 4;
	var ASCII_MAGENTA_CODE = 5;
	var ASCII_CYAN_CODE = 6;
	var ASCII_WHITE_CODE = 7;
	var ASCII_LIGHT_BLACK_CODE = 8;
	var ASCII_LIGHT_RED_CODE = 9;
	var ASCII_LIGHT_GREEN_CODE = 10;
	var ASCII_LIGHT_YELLOW_CODE = 11;
	var ASCII_LIGHT_BLUE_CODE = 12;
	var ASCII_LIGHT_MAGENTA_CODE = 13;
	var ASCII_LIGHT_CYAN_CODE = 14;
	var ASCII_LIGHT_WHITE_CODE = 15;
}