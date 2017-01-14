import com.haxepunk.Engine;
import com.haxepunk.HXP;
import com.haxepunk.Sfx;
import com.haxepunk.graphics.Image;
import com.haxepunk.screen.UniformScaleMode;
import com.haxepunk.screen.UniformScaleMode.UniformScaleType;
import com.haxepunk.utils.Data;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

// import scenes.TitleScene;
import scenes.*;

class Main extends Engine
{
	static private var soundExt(default, never):String = #if flash "mp3" #else "ogg" #end;
	static public var tileset:BitmapData;
	static public var music:Sfx;
	override public function init()
	{
#if debug
		HXP.console.enable(haxepunk.debug.Console.TraceCapture.Yes,com.haxepunk.utils.Key.C);
		HXP.console.debugDraw = true;
#end
		HXP.stage.quality = openfl.display.StageQuality.LOW; // keep the sweet sweet pixels
		HXP.screen.scaleMode = new UniformScaleMode(UniformScaleType.Letterbox);
		tileset = openfl.Assets.getBitmapData("graphics/tileset.png"); // WARNING : forces BitmapData
		music = getSound("idk");
		
		Data.load("accessibleLevels");
		// doesn't matter if the file doesn't exist as all bool reads are false by default
		
		HXP.scene = new IntroCutscene();
	}

	public static function getTileImage(t:Int)
	{
		return new Image(tileset, new Rectangle((t % 8) * 8, Std.int(t / 8) * 8, 8, 8));
	}
	
	public static inline function getSound(name:String, ?complete:Void -> Void)
	{
		return new Sfx("audio/" + soundExt + "/" + name + "." + soundExt, complete);
	}
	
	public static function main()
	{
		new Main();
	}

}