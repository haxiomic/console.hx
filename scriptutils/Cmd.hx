package scriptutils;

import scriptutils.Print.*;

@:publicFields
class Cmd{

	static function getCommandOutput(cmd:String, args:Array<String>):CmdOutput{
		var result = {
			stdout: '',
			stderr: '',
			success: false,
			exitCode: -1
		}
		var p = new sys.io.Process(cmd, args);
		try{
			result.exitCode = p.exitCode();
			result.stdout = p.stdout.readAll().toString();
			result.stderr = p.stderr.readAll().toString();
			switch result.exitCode{
				case 0: result.success = true;
				default:
					error('$cmd exited with code ${result.exitCode}');
			}
		}catch(e:Dynamic) error('exception executing $cmd: $e');
		p.close();

		return result;
	}

	static function printCommandOutputErrors(o:scriptutils.Cmd.CmdOutput){	
		o.stdout = StringTools.trim(o.stdout);
		o.stderr = StringTools.trim(o.stderr);
		if(o.stderr != '')
			error(o.stderr);
		if(!o.success && o.stdout != null)
			print(o.stdout);
	}
	
}

typedef CmdOutput = {
	var stdout:String;
	var stderr:String;
	var success:Bool;
	var exitCode:Int;
}