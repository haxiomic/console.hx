class Main {

	static function main(){
		Console.log('Start');

		var sum:Int->Int->Int = neko.Lib.load("wincon-vtt","sum",2);

		Console.log(sum(1, 2));

	}

}