package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.RenderMode;
import com.haxepunk.graphics.Image;
import com.haxepunk.masks.Imagemask;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class TileEntity extends Entity
{
	private var gfx:Image;
    @:access(haxepunk.ImageType)
	public function new(x:Float = 0, y:Float = 0, t:String, s:Int)
    {
        super(x, y);
		var r = new Rectangle((s % 4) * 8, Std.int(s / 4) * 8, 8, 8);
        gfx = new Image(Main.tileset, r);
		gfx.centerOrigin();
		graphic = gfx;
        type = t;
		var cgfx = HWImage.c(Main.tileset, r);
		cgfx.centerOrigin();
		mask = new Imagemask(cgfx);
		centerOrigin();
		active = false;
    }
}