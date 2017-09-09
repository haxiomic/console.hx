/*
	Credit Oscar C. S., https://github.com/oscarcs/nxColor
*/

class HSV
{
	public var H:Float;
	public var S:Float;
	public var V:Float;
	
	public function new(H:Float, S:Float, V:Float) {
		this.H = loop(H, 360);
		this.S = S;
		this.V = V;
	}

	public function toHex():String {
		var H:Float = this.H / 360;
		var S:Float = this.S / 100;
		var V:Float = this.V / 100;
		var R:Float;
		var G:Float;
		var B:Float;
		var hVar:Float, iVar:Float, var1:Float, var2:Float, var3:Float, rVar:Float, gVar:Float, bVar:Float;
		
		if (S == 0) 
		{
			R = V * 255;
			G = V * 255;
			B = V * 255;
		}
		else 
		{
			hVar = H * 6;
			iVar = Math.floor(hVar);
			var1 = V * (1 - S);
			var2 = V * (1 - S * (hVar - iVar));
			var3 = V * (1 - S * (1 - (hVar - iVar)));

			if (iVar == 0) { rVar = V; gVar = var3; bVar = var1; }
			else if (iVar == 1) { rVar = var2; gVar = V; bVar = var1; }
			else if (iVar == 2) { rVar = var1; gVar = V; bVar = var3; }
			else if (iVar == 3) { rVar = var1; gVar = var2; bVar = V; }
			else if (iVar == 4) { rVar = var3; gVar = var1; bVar = V; }
			else { rVar = V; gVar = var1; bVar = var2; };

			R = rVar * 255;
			G = gVar * 255;
			B = bVar * 255;
		}

		return '#' +
			StringTools.hex(Math.round(R), 2) +
			StringTools.hex(Math.round(G), 2) +
			StringTools.hex(Math.round(B), 2);
	}

	static function loop(x:Float, length:Float):Float { 
		if (x < 0)
			x = length + x % length;

		if (x >= length)
			x %= length;
		return x;
	}
}
