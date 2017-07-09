package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Stamp;

class BackButton extends Entity
{
	public function new()
	{
		super();
		var img = new Stamp("graphics/goBackButton.png");
		x = HXP.screen.width / HXP.screen.scale - img.width - 4;
		y = 4;
		graphic = img;
		layer = 0;
		setHitbox(img.width, img.height);
	}
	
	override public function update()
	{
		if(Controls.entityHovered(this) && Controls.pressed)
		{
			HXP.screen.scale = 1;
			HXP.scene = new scenes.LevelSelectScene();
		}
	}
}