import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Text;
import com.haxepunk.graphics.Text.TextOptions;
import com.haxepunk.utils.Input;

class VText extends Entity
{
	private var string:String;
    public var t:Text;
	public var enabled(default, set):Bool;
	private function set_enabled(v:Bool) : Bool
	{
		if(v == enabled)
			return v;
		if(v)
			t.color = 0xffffff;
		else
			t.color = 0x888888;
		return enabled = v;
	}
	private var hovering:Bool;
	private var cb:String -> Void;
	
	override public function new(s:String, o:TextOptions, _cb:String -> Void, _x:Float = 0, _y:Float = 0)
	{
		super(_x, _y);
		cb = _cb;
		t = new Text("[ " + s + " ]", o);
		t.text = s;
		t.centerOrigin();
		graphic = t;
		setHitboxTo(t);
		centerOrigin();
		string = s;
		hovering = false;
		enabled = true;
	}
	
	override public function update()
	{
		var c = collidePoint(x, y, HXP.scene.mouseX, HXP.scene.mouseY);
		if(enabled)
		{
			if(!hovering && c)
			{
				hovering = true;
				t.text = "[ " + string + " ]";
			}
			else if(hovering && !c)
			{
				hovering = false;
				t.text = string;
			}
			
			if(hovering && Input.mouseReleased)
				cb(name);
		}
		
		super.update();
	}
}