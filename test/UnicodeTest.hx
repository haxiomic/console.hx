class UnicodeTest {
	
	static function main() {

		title('Latin-1 Supplement');
		Console.printlnFormatted(unicodeTestBlock(0x00A0, 0x00FF));

		title('Latin-1 Extended-A');
		Console.printlnFormatted(unicodeTestBlock(0x0100, 0x017F));

		title('Latin-1 Extended-B');
		Console.printlnFormatted(unicodeTestBlock(0x0180, 0x024F));
		
		title('Greek and Coptic');
		Console.printlnFormatted(unicodeTestBlock(0x0370, 0x03FF));

		title('Block Elements');
		Console.printlnFormatted(unicodeTestBlock(0x2580, 0x259F));

		title('Shapes');
		Console.printlnFormatted(unicodeTestBlock(0x25A0, 0x25FF));

		title('Misc Symbols');
		Console.printlnFormatted(unicodeTestBlock(0x2600, 0x26FF));

		title('Hiragana');
		Console.printlnFormatted(unicodeTestBlock(0x3040, 0x309F));

		title('Katakana');
		Console.printlnFormatted(unicodeTestBlock(0x30A0, 0x30FF));
	}

	static inline function title(str:String){
		Console.printlnFormatted('<cyan> -- <b>$str</b> --</cyan>');
	}

	static inline function unicodeChar(code):String{
		var u = new haxe.Utf8(1);
		u.addChar(code);
		return u.toString();
	}

	static function unicodeTestBlock(start:Int, end:Int) {
		var result = '';

		var hsv = new HSV(0, 100, 100);

		var c = 1;
		for(i in start...end){

			var hex = hsv.toHex();

			result += '<${hex}>' + unicodeChar(i) + '</>';

			if (c % 40 == 0) result += '\n';

			c++;
			hsv.H += 10;
			hsv.H = hsv.H%360;
		}
		result += '\n';
		result += '\n';
		return result;
	}

}