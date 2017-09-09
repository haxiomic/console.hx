class RunTests {

	static var builtDir = '_built';
	static var commonFlags = '-cp "../src" -dce full';

	static function main(){
		test('SampleTest');
		test('LogStreamTest');
		test('UnicodeTest');
	}

	static function test(name:String){
		trace('$name');
		testNeko(name);
		testNodeJS(name);
		testCPP(name);
	}

	static function testNeko(name:String){
		trace('\tNeko $name');
		var r = exec('haxe -main $name $commonFlags -neko $builtDir/$name.n');
		if (r.exit == 0) {
			Sys.command('neko $builtDir/$name.n');
		} else {
			trace(r.stdout, r.stderr);
		}
	}

	static function testNodeJS(name:String){
		trace('\tNodeJS $name');
		var r = exec('haxe -main $name $commonFlags -lib hxnodejs -js $builtDir/$name.js');
		if (r.exit == 0) {
			Sys.command('node $builtDir/$name.js');
		} else {
			trace(r.stdout, r.stderr);
		}
	}

	static function testCPP(name:String){
		trace('\tC++ $name');
		trace('Compiling...');
		var r = exec('haxe -main $name $commonFlags -cpp $builtDir/cpp');
		if (r.exit == 0) {
			Sys.command('$builtDir/cpp/$name');
		} else {
			trace(r.stdout, r.stderr);
		}
	}

	static function exec(cmd: String, ?args:Array<String>) {
		var p = new sys.io.Process(cmd, args);
		var exit = p.exitCode(true);
		var stdout = p.stdout.readAll().toString();
		var stderr = p.stderr.readAll().toString();
		p.close();
		return {
			exit: exit,
			stdout: stdout,
			stderr: stderr
		}
	}

}