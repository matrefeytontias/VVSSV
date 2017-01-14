package scenes;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Text;
import com.haxepunk.utils.Draw;

class TitleScene extends Scene
{
	private var bgdx:Float;
	private var bgdy:Float;
	
	override public function begin()
	{
		add(new BackgroundScroller("graphics/titleBackground.png"));
		var options:TextOptions = { size:24, font:"font/PressStart2P.ttf", color:82 * 65536 + 255 * 256 + 243 };
#if !html5
		options.align = "center";
#else
		options.align = openfl.text.TextFormatAlign.CENTER;
#end
		var title = new Text("VENI VIDI\nSTILL STRUGGLING to VICI", options);
		options.size = 18;
		var playButton:VText, exitButton:VText;
		if(Std.random(2) < 1)
		{
			playButton = new VText("play", options, play, HXP.halfWidth, HXP.height * 3 / 4);
			exitButton = new VText("don't play", options, exit, HXP.halfWidth, HXP.height * 3 / 4 + playButton.height * 3 / 2);
		}
		else
		{
			playButton = new VText("don't exit", options, play, HXP.halfWidth, HXP.height * 3 / 4);
			exitButton = new VText("exit", options, exit, HXP.halfWidth, HXP.height * 3 / 4 + playButton.height * 3 / 2);
		}
		
		addGraphic(title, 0, (HXP.screen.width - title.width) / 2, HXP.screen.height / 4);
		add(playButton);
		add(exitButton);
	}
	
	private function play(_:String)
	{
		Main.getSound("menuSelect").play();
		HXP.scene = new LevelSelectScene();
	}
	
	private function exit(_:String)
	{
		#if !(flash || html5)
		Sys.exit(0);
		#end
	}
}