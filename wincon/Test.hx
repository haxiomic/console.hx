class Test {
	
	static function main(){
		Sys.println('Start');

		var enableVTT:Void->Bool = neko.Lib.load('../ndll/Windows/wincon', 'enableVTT', 0);

		Sys.println(enableVTT());
		Sys.println('\033[38;5;2mThis should be green!\033[m');
	}

}