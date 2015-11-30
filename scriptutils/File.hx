package scriptutils;

import haxe.io.Path;

@:publicFields
class File{

	static function createDirectories(path:String){
		path = Path.directory(path);

		if(path == '') return;

		var p = path.split('/');

		var toCreate = new Array<String>();

		while(p.length > 0){
			try{
				if(sys.FileSystem.isDirectory(p.join('/')))
					break;
			}catch(e:Dynamic){}
			toCreate.unshift(p.join('/'));
			p.pop();
		}

		for(p in toCreate){
			sys.FileSystem.createDirectory(p);
		}
	}

	static function delete(path: String): Void {
		if (sys.FileSystem.exists(path)) {
			if (sys.FileSystem.isDirectory(path)) {
				for (entry in sys.FileSystem.readDirectory(path)) {
					delete(path + "/" + entry);
				}
				sys.FileSystem.deleteDirectory(path);
			} else {
				sys.FileSystem.deleteFile(path);
			}
		}
	}

}