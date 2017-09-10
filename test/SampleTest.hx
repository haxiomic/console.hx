class SampleTest {

	macro static function readTextFile(path:String):ExprOf<String>{
		return macro $v{sys.io.File.getContent(path)};
	}

	static function main() {

		var logo:String = readTextFile('logo.txt');
		var logoFormatted = '';

		var hsv = new HSV(0, 100, 100);
		for (i in 0...logo.length) {
			var c = logo.charAt(i);
			if (c != '\n' && c != ' ' && c != '\t') {
				var hex = hsv.toHex();
				hsv.H += 2;
				hsv.H = hsv.H%360;
				logoFormatted += '<$hex>'+c+'</>';
			} else {
				logoFormatted += c;
			}
		}

		// var logoBg = '#FFF';
		// logoFormatted = '<bg$logoBg>' + logoFormatted.split('\n').join('</bg$logoBg>\n<bg$logoBg>') + '</bg$logoBg>';

 		Console.printlnFormatted(logoFormatted);        

		Console.println('');
		Console.log('<b><#FFFFFF>MAGIC</> <u><#9400D3>C</><#4B0082>O</><#0000FF>N</><#00FF00>S</><#FFFF00>O</><#FF7F00>L</><#FF0000>E</></u></b>');
		Console.println('');

		Console.log('<#fc2>Shorthand ███</><#ffcc22>███ Longhand</>');

		Console.log('Testing <bold>bold</bold> then <italic>italic</italic>, then <bold><italic>bold-italic</></>');

		Console.log('Testing <bold>Open Longhand Bold</b> with close shorthand');

		Console.log('<b><i><u>All decoration<//>');

		Console.printlnFormatted('<b><BLACK>black</> <RED>red</> <GREEN>green</> <YELLOW>yellow</> <BLUE>blue</> <MAGENTA>magenta</> <CYAN>cyan</> <WHITE>white</></>');
		Console.printlnFormatted('<b><light_BLACK>black</> <light_RED>red</> <light_GREEN>green</> <light_YELLOW>yellow</> <light_BLUE>blue</> <light_MAGENTA>magenta</> <light_CYAN>cyan</> <light_WHITE>white</></>');
		Console.printlnFormatted('<BLACK>███</><RED>███</><GREEN>███</><YELLOW>███</><BLUE>███</><MAGENTA>███</><CYAN>███</><WHITE>███</>');
		Console.printlnFormatted('<light_BLACK>███</><light_RED>███</><light_GREEN>███</><light_YELLOW>███</><light_BLUE>███</><light_MAGENTA>███</><light_CYAN>███</><light_WHITE>███</>');

		Console.printlnFormatted('<b><#9400D3>R</><#4B0082>A</><#0000FF>I</><#00FF00>N</><#FFFF00>B</><#FF7F00>O</><#FF0000>W</></b>');
		Console.printlnFormatted('!<!><b><#9400D3>R</><#4B0082>A</><#0000FF>I</><#00FF00>N</><#FFFF00>B</><#FF7F00>O</><#FF0000>W</></b></!>');
		Console.printlnFormatted('<#9400D3>███</><#4B0082>███</><#0000FF>███</><#00FF00>███</><#FFFF00>███</><#FF7F00>███</><#FF0000>███</>');

		Console.log('<cyan>Hello</> <b>World!</>');
		Console.warn('<u><yellow>Warning</yellow></>: ...');
		Console.error('<red><b>Error:</></> something went wrong');
		Console.success('<green>Success!</>');
		Console.debug('Some debug information');

		Console.printlnFormatted('<bold><underline>Bold and underlined</underline></bold> outsize');
		Console.printlnFormatted('<red><b>Bold and red</b> some red text. <light_white>WHITE</light_white> continued red text</red>');
		Console.printlnFormatted('To format you can use HTML-like tags, for example \\<b>BOLD\\</b>');
		Console.printlnFormatted('<light_green>What <b>about <b>Multiple</b> layers</b> of tags</light_green>');
		Console.printlnFormatted('<bold><underline>Bold and underlined and <!>inverted!</!></bold></underline>');
		Console.printlnFormatted('<red>Testing a <//>reset all!');
		Console.printlnFormatted('How do we get on with <bold><red>unclosed tags?');
		Console.println('plain string');
		Console.printlnFormatted('reseting ...<//> done');
		Console.printlnFormatted('<bg_green><black>Green Background?</bg_green></black>');
		Console.printlnFormatted('Secret <hidden>π</hidden> is delicious');

		Console.printlnFormatted('What about bad </red><red></red> < red>closing unopened< /red> tags? </_> and unknown tags <?>hmm</?>');

		Console.printlnFormatted('What about when you\'re trying to do math? a > bπ && a < b || > d');

		Console.log('Bold angle bracket: <b><</b>');
		Console.log('What <gray><b>about</> a</> short <red>hand</> for closing the last tag?');
		Console.log('This could enable <#FF0000><b>Custom</#FF0000> colors</>');
		Console.log('What about <bg_black><white><{background:black; font-size:20px; color:white}>inline with <b>bold</b></></white></bg_black> CSS? ');
		Console.log('Can we </>close nothing?');

		Console.warn('<yellow>Yellow</yellow>');
		Console.warn('<bg_yellow><light_white>Awesome</light_white></bg_yellow>');

		Console.log('<bg_light_white><black>BLACK</></> and <bg_black><light_white>WHITE</></>');

		Console.log('What about more advanced <bg#FF0000><#00FF00>Backgrounds</></>?');

		Console.log('And how do we deal with <#Invalid>custom colors</> like <#z>this?</>');

		Console.log('<b><#17a9f5>Nice Blue</> and a <#333333>grayscale</></> <#313030>different gray</>');
	}

}