package scriptutils;

import scriptutils.ConsoleColors;

@:publicFields
class Print{

	static var verboseMode:Bool = false;
	static var silent:Bool = false;
	static var singleLineMode:Bool = false;
	static var prefixNextLine:String = '';

	static function fatal(s:String){
		printError('${BOLD}${BRIGHT_RED}Fatal:${RESET} $s');
		if(singleLineMode)
			endSingleLineMode();
		Sys.exit(1);
	}

	static function error(s:String){
		printError('${BOLD}${RED}Error:${RESET} $s');
	}

	static function warn(s:String){
		printError('${BOLD}${YELLOW}Warning:${RESET} $s');
	}

	static function info(s:String){
		print('${BOLD}${CYAN}Info:${RESET} $s');
	}

	static function verbose(s:String){
		if(!verboseMode) return;
		print('$s');
	}

	static function success(s:String){
		print('${BOLD}${GREEN}Success:${RESET} $s');
	}

	static function title(s:String){
		print('${BOLD}${BRIGHT_WHITE}-- $s --${RESET}');
	}

	static function print(s:String){
		if(silent) return;

		s = prefixNextLine + s;

		if(singleLineMode){
			clearLine();
			Sys.print(s);
		}else{
			Sys.println(s);
		}

		prefixNextLine = '';
	}

	static function printError(s:String){
		if(silent) return;

		s = prefixNextLine + s;

		if(singleLineMode){
			clearLine();
			Sys.stderr().writeString(s);
		}else{
			Sys.stderr().writeString('$s\n');
		}

		prefixNextLine = '';
	}

	static function clearLine(){
		//clear line
		var stdout = Sys.stdout();
		stdout.writeString('\033[1K');
		stdout.flush();
		Sys.print('\r');
	}

	static function beginSingleLineMode(){
		singleLineMode = true;
	}

	static function endSingleLineMode(newline:Bool = true){
		singleLineMode = false;
		if(newline) print('');
	}
	
}