package entities;

import com.haxepunk.graphics.Spritemap;

class FadeTile extends TileEntity
{
	private var s:Spritemap;
	public function new(x:Float = 0, y:Float = 0, tile:Int)
	{
		super(x, y, "fade", tile);
        s = new Spritemap("graphics/fade.png", 8, 8, function () { if(s.currentAnim == "fade") { scene.remove(this); } });
		s.add("idle", [0]);
        s.add("fade", [0, 1, 2, 3], 8);
        s.play("idle");
		graphic = s;
		mask = null;
		setHitboxTo(s);
		s.centerOrigin();
		centerOrigin();
		active = true;
	}
    
    public function fade()
    {
        s.play("fade");
    }
}
