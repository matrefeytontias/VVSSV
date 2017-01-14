package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;

import openfl.geom.Rectangle;

class Dialog extends Entity
{
	static private var coords(default, null):Array<Int> = [ 4, 4, 1, 4, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4, 4, 1, 4, 4 ];
	private var root:Dynamic;
	private var w:Int;
	private var h:Int;
	private var slices:Array<Image>;
	private var text:Array<String>;
	private var t:Text;
	private var nextCursor:Image;
	private var currentDialog:Int;
	
	public var busy:Bool;
	public var anchor:{x:Float, y:Float, w:Int, h:Int};
	
	private function makeScales(_w:Int, _h:Int) : {w:Int, h:Int}
	{
		return {w:_w == 1 ? w : 1, h:_h == 1 ? h : 1};
	}
	
	public function new(_text:Array<String>, functionsRoot:Dynamic, a:{x:Float, y:Float, w:Int, h:Int})
	{
		super();
		text = _text;
		root = functionsRoot;
		t = new Text(text[0], {size:8});
		anchor = a;
		
		nextCursor = new Image("graphics/nextCursor.png");
		
		var r = new Rectangle(0, 0, 0, 0);
		var coords = [ 4, 4, 1, 4, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4, 1, 4, 4, 4 ];
		slices = new Array<Image>();
		var g = new Graphiclist();
		for(k in 0 ... 9)
		{
			r.width = coords[k * 2];
			r.height = coords[k * 2 + 1];
			slices.push(new Image("graphics/9slice.png", r));
			g.add(slices[k]);
			r.x += r.width;
			if(r.x >= 9)
			{
				r.x %= 9;
				r.y += r.height;
			}
		}
		
		g.add(t);
		g.add(nextCursor);
		graphic = g;
		currentDialog = 0;
		next();
		layer = 1;
	}
	
	override public function update()
	{
		super.update();
		nextCursor.alpha = busy ? 0. : 1.;
		nextCursor.x = width - nextCursor.width;
		nextCursor.y = height - nextCursor.height + Math.sin(haxe.Timer.stamp() * Math.PI * 2) * 2;
	}
	
	private function reinit()
	{
		t.text = text[currentDialog];
		w = t.textWidth;
		h = t.textHeight;
		var r = new Rectangle(0, 0, 0, 0);
		var coords = [ 4, 4, 1, 4, 4, 4, 4, 1, 1, 1, 4, 1, 4, 4, 1, 4, 4, 4 ];
		for(k in 0 ... 9)
		{
			r.width = coords[k * 2];
			r.height = coords[k * 2 + 1];
			slices.push(new Image("graphics/9slice.png", r));
			var dim = makeScales(Std.int(r.width), Std.int(r.height));
			slices[k].scaleX = dim.w;
			slices[k].scaleY = dim.h;
			r.x += r.width;
			if(r.x >= 9)
			{
				r.x %= 9;
				r.y += r.height;
			}
		}
		slices[4].x = slices[4].y = 0;
		slices[0].x = slices[3].x = slices[6].x = slices[4].x - slices[0].scaledWidth;
		slices[0].y = slices[1].y = slices[2].y = slices[4].y - slices[0].scaledHeight;
		slices[8].x = slices[5].x = slices[2].x = slices[4].x + slices[4].scaledWidth;
		slices[8].y = slices[7].y = slices[6].y = slices[4].y + slices[4].scaledHeight;
		setHitbox(Std.int(slices[0].scaledWidth + slices[1].scaledWidth + slices[2].scaledWidth),
			Std.int(slices[0].scaledHeight + slices[3].scaledHeight + slices[6].scaledHeight));
		x = Math.min(anchor.x + anchor.w, HXP.width - width);
		y = anchor.y - height;
	}
	
	// Returns true if the dialog is over
	public function next() : Bool
	{
		if(currentDialog < text.length)
		{
			// Run a command (starting with ':') or display text
			if(text[currentDialog].charAt(0) == ':')
			{
				currentDialog++;
				var f:Void -> Void = Reflect.field(root, text[currentDialog - 1].substr(1));
				Reflect.callMethod(root, f, []);
			}
			else
			{
				reinit();
				currentDialog++;
			}
			return false;
		}
		return true;
	}
}


class SurpriseNotif extends Entity
{
	private var t:Text;
	public function new(parent:Image)
	{
		t = new Text("!");
		super(parent.x + parent.width / 2 - t.width / 2, parent.y - t.height);
		graphic = t;
	}
	
	override public function update()
	{
		super.update();
		y -= 0.5;
		if(t.alpha > 0.)
			t.alpha -= 0.05;
		else
			scene.remove(this);
	}
}