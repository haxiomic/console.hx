class Basic {

	static function main() {

		/**
		Console.log('1 (log)');
		Console.success('2 (success)');
		Console.warn('3 (warn)');
		Console.error('4 (error)');
		Console.warn('5 (warn)');
		Console.log('6 (log)');

		Console.log('<red><b>  ¥ · £ · € · $ · ¢ · ₡ · ₢ · ₣ · ₤ · ₥ · ₦ · ₧ · ₨ · ₩ · ₪ · ₫ · ₭ · ₮ · ₯ · ₹ <//>');
		/**/
		
		/**/
		Console.print('');
		Console.log('<b><#FFFFFF>MAGIC</> <u><#9400D3>C</><#4B0082>O</><#0000FF>N</><#00FF00>S</><#FFFF00>O</><#FF7F00>L</><#FF0000>E</></u></b>');
		Console.print('');

		Console.log('<#fc2>Shorthand ███</><#ffcc22>███ Longhand</>');

		Console.printFormatted('<b><BLACK>black</> <RED>red</> <GREEN>green</> <YELLOW>yellow</> <BLUE>blue</> <MAGENTA>magenta</> <CYAN>cyan</> <WHITE>white</></>');
		Console.printFormatted('<b><light_BLACK>black</> <light_RED>red</> <light_GREEN>green</> <light_YELLOW>yellow</> <light_BLUE>blue</> <light_MAGENTA>magenta</> <light_CYAN>cyan</> <light_WHITE>white</></>');
		Console.printFormatted('<BLACK>███</><RED>███</><GREEN>███</><YELLOW>███</><BLUE>███</><MAGENTA>███</><CYAN>███</><WHITE>███</>');
		Console.printFormatted('<light_BLACK>███</><light_RED>███</><light_GREEN>███</><light_YELLOW>███</><light_BLUE>███</><light_MAGENTA>███</><light_CYAN>███</><light_WHITE>███</>');

		Console.printFormatted('<b><#9400D3>R</><#4B0082>A</><#0000FF>I</><#00FF00>N</><#FFFF00>B</><#FF7F00>O</><#FF0000>W</></b>');
		Console.printFormatted('!<!><b><#9400D3>R</><#4B0082>A</><#0000FF>I</><#00FF00>N</><#FFFF00>B</><#FF7F00>O</><#FF0000>W</></b></!>');
		Console.printFormatted('<#9400D3>███</><#4B0082>███</><#0000FF>███</><#00FF00>███</><#FFFF00>███</><#FF7F00>███</><#FF0000>███</>');

		Console.log('<cyan>Hello</> <b>World!</>');
		Console.warn('<u><yellow>Warning</yellow></>: ...');
		Console.error('<red><b>Error:</></> something went wrong');
		Console.success('<green>Success!</>');
		Console.debug('Some debug information');

		Console.printFormatted('<bold><underline>Bold and underlined</underline></bold> outsize');
		Console.printFormatted('<red><b>Bold and red</b> some red text. <light_white>WHITE</light_white> continued red text</red>');
		Console.printFormatted('To format you can use HTML-like tags, for example \\<b>BOLD\\</b>');
		Console.printFormatted('<light_green>What <b>about <b>Multiple</b> layers</b> of tags</light_green>');
		Console.printFormatted('<bold><underline>Bold and underlined and <!>inverted!</!></bold></underline>');
		Console.printFormatted('<red>Testing a <//>reset all!');
		Console.printFormatted('How do we get on with <bold><red>unclosed tags?');
		Console.print('plain string');
		Console.printFormatted('reseting ...<//> done');
		Console.printFormatted('<bg_green><black>Green Background?</bg_green></black>');
		Console.printFormatted('Secret <hidden>π</hidden> is delicious');

		Console.printFormatted('What about bad </red><red></red> < red>closing unopened< /red> tags? </_> and unknown tags <?>hmm</?>');

		Console.printFormatted('What about when you\'re trying to do math? a > b && a < b || > d');

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

		/**/
	}

}