import com.haxepunk.Entity;
import com.haxepunk.graphics.Backdrop;

class BackgroundScroller extends Entity
{
    private var dx:Float;
    private var dy:Float;
    
    public function new(path:String)
    {
        super();
        graphic = new Backdrop(path);
        dx = (Std.random(2) * 2 - 1) * (Std.random(2) + 1);
		dy = ((Math.abs(dx) % 2) + 1) * (Std.random(2) * 2 - 1);
		layer = 1;
		type = "background";
    }
    
    override public function update()
    {
        x += dx;
        y += dy;
    }
}