package scriptutils;

import scriptutils.ConsoleColors;

@:publicFields
class Print{

	static var verboseMode:Bool = #if debug true #else false #end;
	static var singleLineMode:Bool = false;

	static function fatal(s:String){
		print('${BOLD}${RED}Fatal:${RESET} $s');
		Sys.exit(1);
	}

	static function error(s:String){
		print('${BOLD}${RED}Error:${RESET} $s');
	}

	static function warn(s:String){
		print('${BOLD}${YELLOW}Warning:${RESET} $s');
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
		if(singleLineMode){
			//clear line
			var stdout = Sys.stdout();
			stdout.writeString('\033[1K');
			stdout.flush();
			Sys.print('\r');

			Sys.print(s);
		}else{
			Sys.println(s);
		}
	}

	static function beginSingleLineMode(){
		singleLineMode = true;
	}

	static function endSingleLineMode(){
		singleLineMode = false;
		print('');
	}
	
}