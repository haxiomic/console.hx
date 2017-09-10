class Test {
	
	static function main(){
		Console.log('Start');

		var sum:Int->Int->Int = neko.Lib.load('wincon', 'sum', 2);

		Console.log(sum(1,2));

		if (sum(1,2)==3){
			Console.success('OK!');
		}
	}

}