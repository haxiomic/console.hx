/**
 * Console.ts
 * 
 * HTML-like console formatting in the browser and native console in Node.js
 * 
 * - Apply formatting with HTML-like tags: `<b>bold</b>`
 * - A closing tag without a tag name can be used to close the last-open format tag `</>` so `<b>bold</>` will also work
 * - Tags are case-insensitive
 * - A double-closing tag like `<//>` will clear all active formatting
 * - Multiple tags can be combined with comma separation, `<b,i>bold-italic</>`
 * - Whitespace is not allowed in tags, so `<b >` would be ignored and printed as-is
 * - Tags can be escaped with a leading backslash: `\<b>` would be printed as-is
 * - Unknown tags are skipped and will not show up in the output
 * - For browser targets, CSS fields and colors can be used, for example: `<{color: red; font-size: 20px}>Inline CSS</>` or `<#FF0000>Red Text</#FF0000>`. These will have no affect on native consoles
 * 
 * Ported from Console.hx https://github.com/haxiomic/console.hx
 * 
 * @author haxiomic (George Corney)
 * @version 1.0.0
 */
export namespace Console {

	export enum OutputStream {
		Log,
		Warn,
		Error,
		Debug,
	}

	export enum FormatMode {
		AsciiTerminal,
		BrowserConsole,
		Disabled,
	}

	export let formatMode = determineFormatMode();

	export let logPrefix = '<b,gray>><//> ';
	export let warnPrefix = '<b,yellow>><//> ';
	export let errorPrefix = '<b,red>></b> ';
	export let successPrefix = '<b,light_green>><//> ';
	export let debugPrefix = '<b,magenta>><//> ';
	export let argSeparator = ' ';

	export function log(...args: any[]){
		printlnFormatted(logPrefix + args.join(argSeparator), OutputStream.Log);
	}

	export function warn(...args: any[]){
		printlnFormatted(warnPrefix + args.join(argSeparator), OutputStream.Warn);
	}

	export function error(...args: any[]){
		printlnFormatted(errorPrefix + args.join(argSeparator), OutputStream.Error);
	}

	export function success(...args: any[]){
		printlnFormatted(successPrefix + args.join(argSeparator), OutputStream.Log);
	}

	export function debug(...args: any[]){
		// get stack trace
		let stack = new Error().stack;

		if (stack != null) {
			// get line number of caller
			let lineNumber = stack.split('\n')[2].split(':')[1];
			// get file name of caller
			let fileName = stack.split('\n')[2].split(':')[0].split('/').pop();
			// print debug message
			printlnFormatted(debugPrefix + fileName + ':' + lineNumber + ' ' + args.join(argSeparator), OutputStream.Debug);
		} else {
			printlnFormatted(debugPrefix + args.join(argSeparator), OutputStream.Debug);
		}
	}

	export function examine(...args: any[]){
		// use node's util.inspect to print objects
		for (let arg of args) {
			if (typeof arg === 'object') {
				// check if we have require
				if (typeof require === 'undefined') {
					printlnFormatted(logPrefix + JSON.stringify(arg), OutputStream.Log);
				} else {
					printlnFormatted(logPrefix + require('util').inspect(arg, { depth: null, colors: true }), OutputStream.Log);
				}
			} else {
				printlnFormatted(logPrefix + arg, OutputStream.Log);
			}
		}
	}

	export function printlnFormatted(s = '', outputStream?: OutputStream){
		return printFormatted(s + '\n', outputStream);
	}

	export function println(s = '', outputStream?: OutputStream){
		return print(s + '\n', outputStream);
	}

	export function printFormatted(s: string, outputStream: OutputStream = OutputStream.Log) {
		let result = format(s, formatMode);

		if (formatMode === FormatMode.AsciiTerminal) {
			print(result.formatted, outputStream);
		} else if (formatMode === FormatMode.BrowserConsole) {
			switch (outputStream) {
				case OutputStream.Log:
					console.log(result.formatted, ...result.browserFormatArguments);
					break;
				case OutputStream.Warn:
					console.warn(result.formatted, ...result.browserFormatArguments);
					break;
				case OutputStream.Error:
					console.error(result.formatted, ...result.browserFormatArguments);
					break;
				case OutputStream.Debug:
					console.debug(result.formatted, ...result.browserFormatArguments);
					break;
			}
		}
	}

	export function print(s: string = '', outputStream: OutputStream = OutputStream.Log) {
		if (formatMode == FormatMode.AsciiTerminal) {
			// write direct to stdout/stderr
			switch (outputStream) {
				case OutputStream.Log:
				case OutputStream.Debug:
					process.stdout.write(s);
					break;
				case OutputStream.Warn:
				case OutputStream.Error:
					process.stderr.write(s);
					break;
			}
		} else {
			// write to console
			switch (outputStream) {
				case OutputStream.Log:
					console.log(s);
					break;
				case OutputStream.Warn:
					console.warn(s);
					break;
				case OutputStream.Error:
					console.error(s);
					break;
				case OutputStream.Debug:
					console.debug(s);
					break;
			}
		}
	}

	export function stripFormatting(s: string) {
		return format(s, FormatMode.Disabled).formatted;
	}

	const formatTagPattern = /(\\)?<(\/)?([^><{}\s]*|{[^}<>]*})>/g;
	export function format(s: string, formatMode: FormatMode) {
		s = s + '<//>';// Add a reset all to the end to prevent overflowing formatting to subsequent lines

		let activeFormatFlagStack = new Array<FormatFlag>();
		let groupedProceedingTags = new Array<Int>();
		let browserFormatArguments = new Array<string>();

		function addFlag(flag: FormatFlag, proceedingTags: Int) {
			activeFormatFlagStack.push(flag);
			groupedProceedingTags.push(proceedingTags);
		}

		function removeFlag(flag: FormatFlag) {
			let i = activeFormatFlagStack.indexOf(flag);
			if (i != -1) {
				let proceedingTags = groupedProceedingTags[i];
				// remove n tags
				activeFormatFlagStack.splice(i - proceedingTags, proceedingTags + 1);
				groupedProceedingTags.splice(i - proceedingTags, proceedingTags + 1);
			}
		}

		function resetFlags() {
			activeFormatFlagStack = [];
			groupedProceedingTags = [];
		}

		let result = s.replace(formatTagPattern, (wholeMatch, ...args) => {
			// args from 0 to 2 are the match, the escaped flag, and the open flag
			let matched = args as [string, string, string];

			let escaped = matched[0] != null;
			if (escaped) {
				return wholeMatch;
			}

			let open = matched[1] == null;
			let tags = matched[2].split(',');

			// handle </> and <//>
			if (!open && tags.length == 1) {
				if (tags[0] == '') {
					// we've got a shorthand to close the last tag: </>
					let last = activeFormatFlagStack[activeFormatFlagStack.length - 1];
					removeFlag(last);
				} else if (formatFlagFromString(tags[0]) == FormatFlag.RESET) {
					resetFlags();
				} else {
					// handle </*>
					let flag = formatFlagFromString(tags[0]);
					if (flag != null) {
						removeFlag(flag);
					}
				}
			} else {
				let proceedingTags = 0;
				for (let tag of tags) {
					let flag = formatFlagFromString(tag);
					if (flag == null) return wholeMatch; // unhandled tag, don't treat as formatting
					if (open) {
						addFlag(flag, proceedingTags);
						proceedingTags++;
					} else {
						removeFlag(flag);
					}
				}
			}

			// since format flags are cumulative, we only need to add the last item if it's an open tag
			switch (formatMode) {
				case FormatMode.AsciiTerminal:
					// since format flags are cumulative, we only need to add the last item if it's an open tag
					if (open) {
						if (activeFormatFlagStack.length > 0) {
							let lastFlagCount: Int = groupedProceedingTags[groupedProceedingTags.length - 1] + 1;
							let asciiFormatString = '';
							for (let i = 0; i < lastFlagCount; i++) {
								let idx = groupedProceedingTags.length - 1 - i;
								asciiFormatString += getAsciiFormat(activeFormatFlagStack[idx]);
							}
							return asciiFormatString;
						} else {
							return '';
						}
					} else {
						return getAsciiFormat(FormatFlag.RESET) +
								activeFormatFlagStack.map(getAsciiFormat)
								.filter(s => s != null)
								.join('');
					}
				case FormatMode.BrowserConsole:
					browserFormatArguments.push(
						activeFormatFlagStack.map(getBrowserFormat)
						.filter(s => s != null)
						.join(';')
					);
					return '%c';
				case FormatMode.Disabled:
					return '';
			}
		});

		return {
			formatted: result,
			browserFormatArguments: browserFormatArguments,
		}
	}

	function determineFormatMode(): FormatMode {
		// if we have a window object, we're in a browser
		if (typeof window !== 'undefined') {
			return FormatMode.BrowserConsole;
		} else {
			// check for terminal color support
			if (process.stdout.isTTY) {
				return FormatMode.AsciiTerminal;
			} else {
				return FormatMode.Disabled;
			}
		}
	}

	type Int = number;

	enum FormatFlag {
		RESET = 'reset',
		BOLD = 'bold',
		ITALIC = 'italic',
		DIM = 'dim',
		UNDERLINE = 'underline',
		BLINK = 'blink',
		INVERT = 'invert',
		HIDDEN = 'hidden',
		BLACK = 'black',
		RED = 'red',
		GREEN = 'green',
		YELLOW = 'yellow',
		BLUE = 'blue',
		MAGENTA = 'magenta',
		CYAN = 'cyan',
		WHITE = 'white',
		LIGHT_BLACK = 'light_black',
		LIGHT_RED = 'light_red',
		LIGHT_GREEN = 'light_green',
		LIGHT_YELLOW = 'light_yellow',
		LIGHT_BLUE = 'light_blue',
		LIGHT_MAGENTA = 'light_magenta',
		LIGHT_CYAN = 'light_cyan',
		LIGHT_WHITE = 'light_white',
		BG_BLACK = 'bg_black',
		BG_RED = 'bg_red',
		BG_GREEN = 'bg_green',
		BG_YELLOW = 'bg_yellow',
		BG_BLUE = 'bg_blue',
		BG_MAGENTA = 'bg_magenta',
		BG_CYAN = 'bg_cyan',
		BG_WHITE = 'bg_white',
		BG_LIGHT_BLACK = 'bg_light_black',
		BG_LIGHT_RED = 'bg_light_red',
		BG_LIGHT_GREEN = 'bg_light_green',
		BG_LIGHT_YELLOW = 'bg_light_yellow',
		BG_LIGHT_BLUE = 'bg_light_blue',
		BG_LIGHT_MAGENTA = 'bg_light_magenta',
		BG_LIGHT_CYAN = 'bg_light_cyan',
		BG_LIGHT_WHITE = 'bg_light_white',
	}

	function formatFlagFromString(str: string): FormatFlag {
		str = str.toLowerCase();

		// normalize hex colors
		if (str.charAt(0) == '#' || str.substring(0, 3) == 'bg#') {
			let hIdx = str.indexOf('#');
			let hex = str.substring(hIdx + 1);

			// expand shorthand hex
			if (hex.length == 3) {
				let a = hex.split('');
				hex = [a[0], a[0], a[1], a[1], a[2], a[2]].join('');
			}

			// validate hex
			if((/[^0-9a-f]/i).test(hex) || hex.length < 6) {
				// hex contains a non-hexadecimal character or it's too short
				return '' as any; // return empty flag, which has no formatting rules
			}

			let normalized = str.substring(0, hIdx) + '#' + hex;

			return normalized as any;
		}

		// handle aliases
		switch (str) {
			case '/': return FormatFlag.RESET;
			case '!': return FormatFlag.INVERT;
			case 'u': return FormatFlag.UNDERLINE;
			case 'b': return FormatFlag.BOLD;
			case 'i': return FormatFlag.ITALIC;
			case 'gray': return FormatFlag.LIGHT_BLACK;
			case 'bg_gray': return FormatFlag.BG_LIGHT_BLACK;
			default: return str as any;
		}
	}

	enum AsciiColorCodes {
		ASCII_BLACK_CODE =  0,
		ASCII_RED_CODE =  1,
		ASCII_GREEN_CODE =  2,
		ASCII_YELLOW_CODE =  3,
		ASCII_BLUE_CODE =  4,
		ASCII_MAGENTA_CODE =  5,
		ASCII_CYAN_CODE =  6,
		ASCII_WHITE_CODE =  7,
		ASCII_LIGHT_BLACK_CODE =  8,
		ASCII_LIGHT_RED_CODE =  9,
		ASCII_LIGHT_GREEN_CODE =  10,
		ASCII_LIGHT_YELLOW_CODE =  11,
		ASCII_LIGHT_BLUE_CODE =  12,
		ASCII_LIGHT_MAGENTA_CODE =  13,
		ASCII_LIGHT_CYAN_CODE =  14,
		ASCII_LIGHT_WHITE_CODE =  15,
	}

	function getAsciiFormat(flag:FormatFlag): string {
		// octal escape \033 is not allowed in strict mode
		// instead use \x1b
		switch (flag) {
			case FormatFlag.RESET: return '\x1b[m';

			case FormatFlag.BOLD: return '\x1b[1m';
			case FormatFlag.DIM: return '\x1b[2m';
			case FormatFlag.ITALIC: return '\x1b[3m';
			case FormatFlag.UNDERLINE: return '\x1b[4m';
			case FormatFlag.BLINK: return '\x1b[5m';
			case FormatFlag.INVERT: return '\x1b[7m';
			case FormatFlag.HIDDEN: return '\x1b[8m';

			case FormatFlag.BLACK: return '\x1b[38;5;' + AsciiColorCodes.ASCII_BLACK_CODE + 'm';
			case FormatFlag.RED: return '\x1b[38;5;' + AsciiColorCodes.ASCII_RED_CODE + 'm';
			case FormatFlag.GREEN: return '\x1b[38;5;' + AsciiColorCodes.ASCII_GREEN_CODE + 'm';
			case FormatFlag.YELLOW: return '\x1b[38;5;' + AsciiColorCodes.ASCII_YELLOW_CODE + 'm';
			case FormatFlag.BLUE: return '\x1b[38;5;' + AsciiColorCodes.ASCII_BLUE_CODE + 'm';
			case FormatFlag.MAGENTA: return '\x1b[38;5;' + AsciiColorCodes.ASCII_MAGENTA_CODE + 'm';
			case FormatFlag.CYAN: return '\x1b[38;5;' + AsciiColorCodes.ASCII_CYAN_CODE + 'm';
			case FormatFlag.WHITE: return '\x1b[38;5;' + AsciiColorCodes.ASCII_WHITE_CODE + 'm';
			case FormatFlag.LIGHT_BLACK: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_BLACK_CODE + 'm';
			case FormatFlag.LIGHT_RED: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_RED_CODE + 'm';
			case FormatFlag.LIGHT_GREEN: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_GREEN_CODE + 'm';
			case FormatFlag.LIGHT_YELLOW: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_YELLOW_CODE + 'm';
			case FormatFlag.LIGHT_BLUE: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_BLUE_CODE + 'm';
			case FormatFlag.LIGHT_MAGENTA: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_MAGENTA_CODE + 'm';
			case FormatFlag.LIGHT_CYAN: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_CYAN_CODE + 'm';
			case FormatFlag.LIGHT_WHITE: return '\x1b[38;5;' + AsciiColorCodes.ASCII_LIGHT_WHITE_CODE + 'm';

			case FormatFlag.BG_BLACK: return '\x1b[48;5;' + AsciiColorCodes.ASCII_BLACK_CODE + 'm';
			case FormatFlag.BG_RED: return '\x1b[48;5;' + AsciiColorCodes.ASCII_RED_CODE + 'm';
			case FormatFlag.BG_GREEN: return '\x1b[48;5;' + AsciiColorCodes.ASCII_GREEN_CODE + 'm';
			case FormatFlag.BG_YELLOW: return '\x1b[48;5;' + AsciiColorCodes.ASCII_YELLOW_CODE + 'm';
			case FormatFlag.BG_BLUE: return '\x1b[48;5;' + AsciiColorCodes.ASCII_BLUE_CODE + 'm';
			case FormatFlag.BG_MAGENTA: return '\x1b[48;5;' + AsciiColorCodes.ASCII_MAGENTA_CODE + 'm';
			case FormatFlag.BG_CYAN: return '\x1b[48;5;' + AsciiColorCodes.ASCII_CYAN_CODE + 'm';
			case FormatFlag.BG_WHITE: return '\x1b[48;5;' + AsciiColorCodes.ASCII_WHITE_CODE + 'm';
			case FormatFlag.BG_LIGHT_BLACK: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_BLACK_CODE + 'm';
			case FormatFlag.BG_LIGHT_RED: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_RED_CODE + 'm';
			case FormatFlag.BG_LIGHT_GREEN: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_GREEN_CODE + 'm';
			case FormatFlag.BG_LIGHT_YELLOW: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_YELLOW_CODE + 'm';
			case FormatFlag.BG_LIGHT_BLUE: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_BLUE_CODE + 'm';
			case FormatFlag.BG_LIGHT_MAGENTA: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_MAGENTA_CODE + 'm';
			case FormatFlag.BG_LIGHT_CYAN: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_CYAN_CODE + 'm';
			case FormatFlag.BG_LIGHT_WHITE: return '\x1b[48;5;' + AsciiColorCodes.ASCII_LIGHT_WHITE_CODE + 'm';
			// return empty string when ascii format flag is not known
			default: return '';
		}
	}

	function getBrowserFormat(flag:FormatFlag): string | null {
		// custom hex color
		if (flag.charAt(0) == '#') {
			return `color: ${flag}`;
		}

		// custom hex background
		if (flag.substring(0, 3) == 'bg#') {
			return `background-color: ${flag.substring(2)}`;
		}

		// inline CSS - browser consoles only
		if (flag.charAt(0) == '{') {
			// return content as-is but remove enclosing braces
			// return flag.substr(1, flag.length - 2);
			return flag.substring(1, flag.length - 1);
		}

		switch (flag) {
			case FormatFlag.RESET: return '';

			case FormatFlag.BOLD: return 'font-weight: bold';
			case FormatFlag.ITALIC: return 'font-style: italic';
			case FormatFlag.DIM: return 'color: gray';
			case FormatFlag.UNDERLINE: return 'text-decoration: underline';
			case FormatFlag.BLINK: return 'text-decoration: blink'; // not supported
			case FormatFlag.INVERT: return '-webkit-filter: invert(100%); filter: invert(100%)'; // not supported
			case FormatFlag.HIDDEN: return 'visibility: hidden; color: white'; // not supported

			case FormatFlag.BLACK: return 'color: black';
			case FormatFlag.RED: return 'color: red';
			case FormatFlag.GREEN: return 'color: green';
			case FormatFlag.YELLOW: return 'color: #f5ba00';
			case FormatFlag.BLUE: return 'color: blue';
			case FormatFlag.MAGENTA: return 'color: magenta';
			case FormatFlag.CYAN: return 'color: cyan';
			case FormatFlag.WHITE: return 'color: whiteSmoke';

			case FormatFlag.LIGHT_BLACK: return 'color: gray';
			case FormatFlag.LIGHT_RED: return 'color: salmon';
			case FormatFlag.LIGHT_GREEN: return 'color: lightGreen';
			case FormatFlag.LIGHT_YELLOW: return 'color: #ffed88';
			case FormatFlag.LIGHT_BLUE: return 'color: lightBlue';
			case FormatFlag.LIGHT_MAGENTA: return 'color: lightPink';
			case FormatFlag.LIGHT_CYAN: return 'color: lightCyan';
			case FormatFlag.LIGHT_WHITE: return 'color: white';

			case FormatFlag.BG_BLACK: return 'background-color: black';
			case FormatFlag.BG_RED: return 'background-color: red';
			case FormatFlag.BG_GREEN: return 'background-color: green';
			case FormatFlag.BG_YELLOW: return 'background-color: gold';
			case FormatFlag.BG_BLUE: return 'background-color: blue';
			case FormatFlag.BG_MAGENTA: return 'background-color: magenta';
			case FormatFlag.BG_CYAN: return 'background-color: cyan';
			case FormatFlag.BG_WHITE: return 'background-color: whiteSmoke';
			case FormatFlag.BG_LIGHT_BLACK: return 'background-color: gray';
			case FormatFlag.BG_LIGHT_RED: return 'background-color: salmon';
			case FormatFlag.BG_LIGHT_GREEN: return 'background-color: lightGreen';
			case FormatFlag.BG_LIGHT_YELLOW: return 'background-color: lightYellow';
			case FormatFlag.BG_LIGHT_BLUE: return 'background-color: lightBlue';
			case FormatFlag.BG_LIGHT_MAGENTA: return 'background-color: lightPink';
			case FormatFlag.BG_LIGHT_CYAN: return 'background-color: lightCyan';
			case FormatFlag.BG_LIGHT_WHITE: return 'background-color: white';
			// return empty string for unknown format
			default: return '';
		}
	}

	function regexMap(pattern: RegExp, str: string, mapFn: (substring: string, ...args: Array<any>) => string): string {
		return str.replace(pattern, mapFn);
	}

}