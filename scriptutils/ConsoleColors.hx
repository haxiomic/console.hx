package scriptutils;

@:enum
abstract ConsoleColors(String){
	//Console format escape strings
	var BLACK = '\033[38;5;'+ColorCodes.BLACK_CODE+'m';
	var RED = '\033[38;5;'+ColorCodes.RED_CODE+'m';
	var GREEN = '\033[38;5;'+ColorCodes.GREEN_CODE+'m';
	var YELLOW = '\033[38;5;'+ColorCodes.YELLOW_CODE+'m';
	var BLUE = '\033[38;5;'+ColorCodes.BLUE_CODE+'m';
	var MAGENTA = '\033[38;5;'+ColorCodes.MAGENTA_CODE+'m';
	var CYAN = '\033[38;5;'+ColorCodes.CYAN_CODE+'m';
	var WHITE = '\033[38;5;'+ColorCodes.WHITE_CODE+'m';
	var BRIGHT_BLACK = '\033[38;5;'+ColorCodes.BRIGHT_BLACK_CODE+'m';
	var BRIGHT_RED = '\033[38;5;'+ColorCodes.BRIGHT_RED_CODE+'m';
	var BRIGHT_GREEN = '\033[38;5;'+ColorCodes.BRIGHT_GREEN_CODE +'m';
	var BRIGHT_YELLOW = '\033[38;5;'+ColorCodes.BRIGHT_YELLOW_CODE +'m';
	var BRIGHT_BLUE = '\033[38;5;'+ColorCodes.BRIGHT_BLUE_CODE +'m';
	var BRIGHT_MAGENTA = '\033[38;5;'+ColorCodes.BRIGHT_MAGENTA_CODE +'m';
	var BRIGHT_CYAN = '\033[38;5;'+ColorCodes.BRIGHT_CYAN_CODE +'m';
	var BRIGHT_WHITE = '\033[38;5;'+ColorCodes.BRIGHT_WHITE_CODE +'m';
	var BOLD = '\033[1m';
	var RESET = '\033[m';
}

@:publicFields
private class ColorCodes{
	static inline var BLACK_CODE = 0;
	static inline var RED_CODE = 1;
	static inline var GREEN_CODE = 2;
	static inline var YELLOW_CODE = 3;
	static inline var BLUE_CODE = 4;
	static inline var MAGENTA_CODE = 5;
	static inline var CYAN_CODE = 6;
	static inline var WHITE_CODE = 7;
	static inline var BRIGHT_BLACK_CODE = 8;
	static inline var BRIGHT_RED_CODE = 9;
	static inline var BRIGHT_GREEN_CODE = 10;
	static inline var BRIGHT_YELLOW_CODE = 11;
	static inline var BRIGHT_BLUE_CODE = 12;
	static inline var BRIGHT_MAGENTA_CODE = 13;
	static inline var BRIGHT_CYAN_CODE = 14;
	static inline var BRIGHT_WHITE_CODE = 15;
}