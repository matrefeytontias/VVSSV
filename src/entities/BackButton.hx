package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Stamp;
import com.haxepunk.utils.Input;

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
		if(collidePoint(x, y, scene.mouseX, scene.mouseY) && Input.mousePressed)
		{
			HXP.screen.scale = 1;
			HXP.scene = new scenes.LevelSelectScene();
		}
	}
}