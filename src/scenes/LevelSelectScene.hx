package scenes;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.Sfx;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Data;

class LevelSelectScene extends Scene
{
	private var bg:Backdrop;
	private var bgdx:Float;
	private var bgdy:Float;
	
	override public function begin()
	{
		if(!Main.music.playing)
		{
			Main.music.loop();
			Main.music.volume = 0.25;
		}
		add(new BackgroundScroller("graphics/titleBackground.png"));
		bgdx = (Std.random(2) * 2 - 1) * (Std.random(2) + 1);
		bgdy = ((Math.abs(bgdx) % 2) + 1) * (Std.random(2) * 2 - 1);
		var options:TextOptions = { size:24, font:"font/PressStart2P.ttf", color:82 * 65536 + 255 * 256 + 243 };
#if !html5
		options.align = "center";
#else
		options.align = openfl.text.TextFormatAlign.CENTER;
#end
		var title = new Text("Select level", options);
		options.size = 18;
		
		addGraphic(title, 0, (HXP.screen.width - title.width) / 2, HXP.screen.height / 4);
		
		// Generate volume bar and credits
		add(new VolumeBarWidget());
		add(new CreditsMarquee());
		
		// Generate level buttons
		var disp = true;
		for(k in 0 ... 10)
		{
			var lvl = new VText(Std.string(k+1), options, loadLevel, HXP.screen.width * ((k % 5) + 1) / 6);
			lvl.y = HXP.screen.height * 3 / 4 + Std.int(k / 5) * lvl.height * 3 / 2;
			lvl.name = Std.string(k+1);
			lvl.enabled = disp;
			add(lvl);
			disp = Data.readBool("level" + (k + 1), false);
		}
		
		// Generate 'back' button
		add(new VText("Back", options, goBack, HXP.screen.width / 2, HXP.screen.height * 9 / 10));
	}
	
	private function loadLevel(n:String)
	{
		HXP.scene = new GameScene(Std.parseInt(n));
	}
	
	private function goBack(_:String)
	{
		HXP.scene = new TitleScene();
	}
}

class CreditsMarquee extends Entity
{
	static private var credits(default, never):String = "Code : Matrefeytontias - Levels : ScottTheIdeaGuy - GFX : Matrefeytontias (from VVVVVV) - Music : ScottTheIdeaGuy - SFX : Terry Cavanagh (thanks to YYYYYY) - check out IdeaBomb on Twitter we're cool !";
	public function new()
	{
		super();
		x = HXP.screen.width;
		var text = new Text(credits);
		graphic = text;
		setHitboxTo(text);
	}
	
	override public function update()
	{
		x -= 2;
		if(x <= -width)
			x = HXP.screen.width;
	}
}

class VolumeBarWidget extends Entity
{
	private var text:Text;
	private var outline:Image;
	private var fill:Image;
	private var moving:Bool;
	
	public function new()
	{
		super();
		text = new Text("Volume");
		outline = new Image("graphics/volumeBar.png");
		fill = Image.createRect(1, 16, 0xaaaaaa);
		fill.x = fill.y = 4;
		setHitbox(100, 16, -4, -4);
		fill.scaleX = HXP.volume * 100;
		x = (HXP.screen.width - outline.width) / 2;
		y = (HXP.screen.height - outline.height) / 2;
		text.x = (width - text.width) / 2;
		text.y = -text.height - 4;
		graphic = new Graphiclist([text, outline, fill]);
		moving = false;
	}
	
	override public function update()
	{
		if(Controls.pressed && collidePoint(x, y, HXP.screen.mouseX, HXP.screen.mouseY))
			moving = true;
		
		if(moving)
		{
			fill.scaleX = Math.min(Math.max(0, HXP.screen.mouseX - (x + fill.x)), 100);
			HXP.volume = fill.scaleX / 100;
			moving = Controls.pressing;
		}
	}
}
