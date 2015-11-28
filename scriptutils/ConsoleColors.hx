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

@:enum
abstract ColorCodes(Int){
	var BLACK_CODE = 0;
	var RED_CODE = 1;
	var GREEN_CODE = 2;
	var YELLOW_CODE = 3;
	var BLUE_CODE = 4;
	var MAGENTA_CODE = 5;
	var CYAN_CODE = 6;
	var WHITE_CODE = 7;
	var BRIGHT_BLACK_CODE = 8;
	var BRIGHT_RED_CODE = 9;
	var BRIGHT_GREEN_CODE = 10;
	var BRIGHT_YELLOW_CODE = 11;
	var BRIGHT_BLUE_CODE = 12;
	var BRIGHT_MAGENTA_CODE = 13;
	var BRIGHT_CYAN_CODE = 14;
	var BRIGHT_WHITE_CODE = 15;
}