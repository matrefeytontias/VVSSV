package entities;

import com.haxepunk.HXP;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;

import openfl.geom.Rectangle;

import scenes.GameScene;

class EndTile extends TileEntity
{
	private var anim:Image;
    public function new(x:Float = 0, y:Float = 0, tile:Int)
	{
		super(x, y, "end", tile);
		anim = Image.createRect(10, 21, 0xffffff);
		if(GameScene.currentLevelNum < 9)
		{
			var s = new Image("graphics/limbs.png", new Rectangle(GameScene.currentLevelNum * 10, 0, 10, 21));
			graphic = new Graphiclist([anim, s]);
			s.centerOrigin();
		}
		else
			graphic = anim;
		mask = null;
		setHitboxTo(anim);
		anim.centerOrigin();
		centerOrigin();
		active = true;
		type = "finish";
	}
	
	override public function update()
	{
		super.update();
		anim.scale = Math.cos(haxe.Timer.stamp() * Math.PI) * 0.5 + 1.;
		var t = haxe.Timer.stamp();
		t -= Math.floor(t);
		anim.angle =com.haxepunk.utils.Ease.cubeInOut(t) * 360;
		anim.color = HXP.getColorHSV(Math.cos(haxe.Timer.stamp()) * 0.5 + 0.5, 1., 1.);
	}
}