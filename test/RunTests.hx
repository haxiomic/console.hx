class RunTests {

	static var builtDir = '_built';
	static var commonFlags = '-lib console.hx -dce full';

	static function main(){
		test('SampleTest');
		// test('LogStreamTest');
		// test('UnicodeTest');
	}

	static function test(name:String){
		trace('$name');
		testNeko(name);
		testNodeJS(name);
		testWebJS(name);
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
		var r = exec('haxe -main $name $commonFlags -lib hxnodejs -js $builtDir/$name.node.js');
		if (r.exit == 0) {
			Sys.command('node $builtDir/$name.node.js');
		} else {
			trace(r.stdout, r.stderr);
		}
	}

	static function testWebJS(name:String){
		trace('\tWebJS $name');
		var r = exec('haxe -main $name $commonFlags -js $builtDir/$name.js');
		if (r.exit != 0) {
			trace(r.stdout, r.stderr);
			return;
		}

		var js = sys.io.File.getContent('$builtDir/$name.js');
		var html = '<meta charset="utf8"><h1>Open Console</h1><script type="text/javascript">$js</script>';
		sys.io.File.saveContent('$builtDir/$name.html', html);
		trace('Generated $builtDir/$name.html');
	}

	static function testCPP(name:String){
		trace('\tC++ $name');
		trace('Compiling...');
		var exit = Sys.command('haxe -main $name $commonFlags -cpp $builtDir/cpp');
		if (exit == 0) {
			if (Sys.systemName() == 'Windows') {
				Sys.command('$builtDir\\cpp\\$name');
			} else {
				Sys.command('$builtDir/cpp/$name');
			}
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