import haxe.macro.Context;
import haxe.macro.Expr;

class Console {

	static public var colorMode = guessConsoleFormatMode();

	@:noCompletion
	static public var logPrefix = '%{BOLD}%{BLUE}>%{-} ';
	@:noCompletion
	static public var warnPrefix = '%{BOLD}%{YELLOW}>%{-} ';
	@:noCompletion
	static public var errorPrefix = '%{BOLD}%{RED}>%{-} ';
	@:noCompletion
	static public var successPrefix = '%{BOLD}%{LIGHT_GREEN}>%{-} ';
	@:noCompletion
	static public var debugPrefix = '%{BOLD}%{MAGENTA}>%{-} ';

	static var argSeparator = ' ';
	static var formatPattern = ~/(\\)?%{([^}]*)}/g;


	macro static public function log(rest:Array<Expr>){
		return macro Console.printFormatted(Console.logPrefix + ${joinArgs(rest)} + '%{-}', Log);
	}

	macro static public function warn(rest:Array<Expr>){
		return macro Console.printFormatted(Console.warnPrefix + ${joinArgs(rest)} + '%{-}', Warn);
	}

	macro static public function error(rest:Array<Expr>){
		return macro Console.printFormatted(Console.errorPrefix + ${joinArgs(rest)} + '%{-}', Error);
	}

	macro static public function success(rest:Array<Expr>){
		return macro Console.printFormatted(Console.successPrefix + ${joinArgs(rest)} + '%{-}', Log);
	}

	// Only generates log call if -debug build flag is supplied
	macro static public function debug(rest:Array<Expr>){
		if(!Context.getDefines().exists('debug')) return macro null;
		var pos = Context.currentPos();
		return macro Console.printFormatted(Console.debugPrefix + '${pos}: ' + ${joinArgs(rest)} + '%{-}', Debug);
	}

	static public inline function print(s:String, outputStream:ConsoleOutputStream = Log){
		#if js
		switch outputStream {
			case Log, Debug: untyped __js__('console.log({0})', s);
			case Warn: untyped __js__('console.warn({0})', s);
			case Error: untyped __js__('console.error({0})', s);
		}
		#else
		trace(s);
		#end

	}

	/**
		# Parse and print formatted message to console

		- Formats are applied cumulatively with the syntax: %{<format flag>}
		- <format flag> is any one of the Console.FormatFlag strings, eg %{RED} (case in-sensitive)
		- Cumulative format is cleared with %{RESET}
		- Format tokens can be escaped with a backslash: \%{RED} will print '\%{RED}'
		- Invalid format flags are ignored (and removed from the string)
		- Several aliases exist for common formatting flags:
			%{-} => %{RESET}
			%{!} => %{INVERT}
			%{_} => %{UNDERLINE}
			%{*} => %{BOLD}
		- There are a few special cases for different console types
			- Browser consoles:
				- Hex color codes can be used to set the text color, e.g. %{#FF0000}
				- CSS style fields can be used, e.g. %{background-color: black; color: white}
	**/
	public static function printFormatted(s:String, outputStream:ConsoleOutputStream = Log){
		var browserFormatArguments = [];

		var result = formatPattern.map(s, function(e){
			// handle escaped flag \%{...}
			if (e.matched(1) != null) return e.matched(0).substring(1);

			var flag:FormatFlag = FormatFlag.fromString(StringTools.trim(e.matched(2)));

			switch colorMode {
				case AsciiTerminal:
					var asciiFormat = getAsciiFormat(flag);
					return asciiFormat == null ? '' : asciiFormat;

				case Browser:
					var browserFormat = getBrowserFormat(flag);

					if (browserFormat != null) {
						var reset = switch flag {
							case RESET: true;
							default: false;
						}

						if (reset) {
							browserFormatArguments.push(browserFormat);
						} else {
							// combine this format with the previous format
							var previousFormat = browserFormatArguments[browserFormatArguments.length - 1];
							var combinedFormat = (previousFormat == null ? '' : previousFormat) + '; ' + browserFormat;
							browserFormatArguments.push(combinedFormat);
						}

						return '%c';
					} else {
						return '';
					}

				case Disabled: return '';
			}
		});

		#if js
		if (colorMode == Browser) {
			var logArgs = [result].concat(browserFormatArguments);
			switch outputStream {
				case Log, Debug: untyped __js__('console.log.apply(console, {0})', logArgs);
				case Warn: untyped __js__('console.warn.apply(console, {0})', logArgs);
				case Error: untyped __js__('console.error.apply(console, {0})', logArgs);
			}
		} else {
			print(result, outputStream);
		}
		#else
		print(result, outputStream);
		#end
	}

	static inline function guessConsoleFormatMode():ConsoleFormatMode {
		#if js
		return untyped __typeof__(js.Browser.window) != 'undefined' ? Browser : AsciiTerminal;
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

	static function getAsciiFormat(name:FormatFlag):Null<String> return switch (name) {
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

	static function getBrowserFormat(name:FormatFlag):Null<String>{
		if ((name:String).charAt(0) == '#') {
			return 'color: $name';
		}

		return switch (name) {
			case RESET: '';

			case BOLD: 'font-weight: bold';
			case DIM: 'color: gray';
			case UNDERLINE: 'text-decoration: underline';
			case BLINK: 'text-decoration: blink';
			case INVERT: '-webkit-filter: invert(100%); filter: invert(100%)'; // not supported
			case HIDDEN: 'visibility: hidden'; // not supported

			case BLACK: 'color: black';
			case RED: 'color: red';
			case GREEN: 'color: green';
			case YELLOW: 'color: yellow';
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
			case BG_YELLOW: 'background-color: yellow';
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

			default: name;
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
	var Browser = 1;
	var Disabled = 2;
}

@:enum
abstract FormatFlag(String) to String {
	var RESET = 'RESET';
	var BOLD = 'BOLD';
	var DIM = 'DIM';
	var UNDERLINE = 'UNDERLINE';
	var BLINK = 'BLINK';
	var INVERT = 'INVERT';
	var HIDDEN = 'HIDDEN';
	var BLACK = 'BLACK';
	var RED = 'RED';
	var GREEN = 'GREEN';
	var YELLOW = 'YELLOW';
	var BLUE = 'BLUE';
	var MAGENTA = 'MAGENTA';
	var CYAN = 'CYAN';
	var WHITE = 'WHITE';
	var LIGHT_BLACK = 'LIGHT_BLACK';
	var LIGHT_RED = 'LIGHT_RED';
	var LIGHT_GREEN = 'LIGHT_GREEN';
	var LIGHT_YELLOW = 'LIGHT_YELLOW';
	var LIGHT_BLUE = 'LIGHT_BLUE';
	var LIGHT_MAGENTA = 'LIGHT_MAGENTA';
	var LIGHT_CYAN = 'LIGHT_CYAN';
	var LIGHT_WHITE = 'LIGHT_WHITE';
	var BG_BLACK = 'BG_BLACK';
	var BG_RED = 'BG_RED';
	var BG_GREEN = 'BG_GREEN';
	var BG_YELLOW = 'BG_YELLOW';
	var BG_BLUE = 'BG_BLUE';
	var BG_MAGENTA = 'BG_MAGENTA';
	var BG_CYAN = 'BG_CYAN';
	var BG_WHITE = 'BG_WHITE';
	var BG_LIGHT_BLACK = 'BG_LIGHT_BLACK';
	var BG_LIGHT_RED = 'BG_LIGHT_RED';
	var BG_LIGHT_GREEN = 'BG_LIGHT_GREEN';
	var BG_LIGHT_YELLOW = 'BG_LIGHT_YELLOW';
	var BG_LIGHT_BLUE = 'BG_LIGHT_BLUE';
	var BG_LIGHT_MAGENTA = 'BG_LIGHT_MAGENTA';
	var BG_LIGHT_CYAN = 'BG_LIGHT_CYAN';
	var BG_LIGHT_WHITE = 'BG_LIGHT_WHITE';

	@:from
	static public inline function fromString(str:String) {
		// handle aliases
		return switch str {
			case '-': RESET;
			case '!': INVERT;
			case '_': UNDERLINE;
			case '*': BOLD;
			default: untyped str.toUpperCase();
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