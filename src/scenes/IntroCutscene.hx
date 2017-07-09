package scenes;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.Sfx;
import com.haxepunk.HXP.Position;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Text;
import com.haxepunk.tweens.misc.NumTween;
import com.haxepunk.tweens.sound.SfxFader;

import openfl.geom.Rectangle;

import entities.Dialog;

class IntroCutscene extends Scene
{
	private var bg:BackgroundScroller;
	private var level:Level;
	private var fadeImg:Image;
	private var alphaTween:NumTween;
	private var shitFallin:Bool = false;
	private var baseTime:Float = 0.;
	private var player:Spritemap;
	private var dialogText(default, null):Array<String> = [
		"Damn it, I'm sick of this !",
		"This is impossible, why can't I just jump\nand go through like a normal person !",
		":showAnger",
		"MMMMMMMMM !!!",
		"F*** this, I'm going home !",
		":showRegrets",
		"What's happening ?",
		":destroyShit",
		"AAAAAAAAAAAARGH !!!",
		"What ... what happened ? The environment\ncollapsed and ... wow, everything changed ...",
		":showSurprise",
		"Huh !? My limbs fell off during the collapsing !?",
		"Well that sure is going to help me jump\naround ...",
		"On the bright side, the path is now free !",
		"Let's see what awaits us there ..."
	];
	private var dialog:Dialog;
	private var transitioning:Bool = false;
	
	private var rumbleSound:Sfx;
	private var collapseSound:Sfx;
	
    public function new()
    {
        super();
		
		HXP.screen.scale = 2;
		
		rumbleSound = Main.getSound("rumble");
		collapseSound = Main.getSound("collapse");
		
		bg = new BackgroundScroller("graphics/titleBackground.png");
		add(bg);
		
        var file = Level.loadLevelData("levels/intro1.json");
		level = new Level(file.data[0], 40, 30);
		add(level);
		
		fadeImg = Image.createRect(HXP.width + 16, HXP.height + 16, 0xffffff, 0.);
		fadeImg.x = fadeImg.y = -8;
		alphaTween = new NumTween(displaySecondScene);
		HXP.tweener.addTween(alphaTween);
		addGraphic(fadeImg, -1);
		
		player = new Spritemap("graphics/introPlayer.png", 10, 21);
		player.add("idle", [0]);
		player.add("angry", [1]);
		player.add("oshit", [2]);
		player.play("idle");
		player.x = file.playerX;
		player.y = Std.int(file.playerY / 8 + 2) * 8 - player.height;
		addGraphic(player);
		
		dialog = new Dialog(dialogText, this, {x:player.x, y:player.y, w:player.width, h:player.height});
		add(dialog);
		
		var skipInstruction = new Text(#if (android || ios) "Two fingers touch to skip" #else "[S] skip intro" #end, {size:8});
		var e = addGraphic(skipInstruction);
		e.x = (HXP.halfWidth - skipInstruction.width) / 2;
		e.y = HXP.halfHeight * 7 / 8;
		HXP.alarm(3, function (_:Dynamic) { remove(e); });
    }
	
	override public function update()
	{
		super.update();
		if(!transitioning)
		{
			if(!shitFallin)
			{
				if(!dialog.busy)
				{
					if(Controls.nextDialog)
					{
						Main.getSound("menuSelect").play();
						if(dialog.next())
						{
							remove(dialog);
							// transition
							player.play("walking");
							transitioning = true;
							alphaTween = new NumTween(launchTitleScreen);
							HXP.tweener.addTween(alphaTween);
							alphaTween.tween(0., 1., (HXP.width - player.x) / (60 * 1.5));
						}
					}
				}
			}
			else
			{
				add(new FallingSpike(HXP.random < 0.5 ? HXP.random * (player.x - 8) : HXP.random * (HXP.width - 8 - player.x - player.width) + player.x + player.width));
				if(haxe.Timer.stamp() - baseTime > 2.)
					fadeImg.alpha = alphaTween.value;
			}
		}
		else
		{
			fadeImg.alpha = alphaTween.value;
			player.x += 1.5;
		}
		
		if(Controls.skip)
			launchTitleScreen();
	}
	
	private function launchTitleScreen(?_:Dynamic)
	{
		HXP.screen.scale = 1.;
		HXP.screen.shakeStop();
		// Just in case
		collapseSound.stop();
		rumbleSound.stop();
		HXP.scene = new TitleScene();
	}
	
	private function displaySecondScene(_:Dynamic)
	{
		removeAll();
		HXP.screen.shakeStop();
		add(bg);
		addGraphic(fadeImg, -1);
		var file = Level.loadLevelData("levels/intro2.json");
		level = new Level(file.data[0], 40, 30);
		add(level);
		player = new Spritemap("graphics/player.png", 10, 10);
		player.add("idle", [0]);
		player.add("walking", [0, 1], 10);
		player.play("idle");
		player.x = file.playerX;
		player.y = Std.int(file.playerY / 8 + 2) * 8 - player.height;
		addGraphic(player);
		alphaTween = new NumTween(launchSecondScene);
		HXP.tweener.addTween(alphaTween);
		alphaTween.tween(1., 0., 1.);
	}
	
	private function launchSecondScene(_:Dynamic)
	{
		shitFallin = false;
		dialog.busy = false;
		var sf = new SfxFader(collapseSound, function (_:Dynamic) { collapseSound.stop(); });
		HXP.tweener.addTween(sf);
		sf.fadeTo(0., 1.);
		sf = new SfxFader(rumbleSound, function (_:Dynamic) { rumbleSound.stop(); });
		HXP.tweener.addTween(sf);
		sf.fadeTo(0., 1.);
		add(dialog);
		dialog.next();
	}
	
	// Dialog events
	// public so the dialog can access it
	
	public function showAnger()
	{
		dialog.busy = true;
		dialog.next();
		player.play("angry");
		HXP.screen.shake(4, 1.);
		HXP.alarm(2., function(_:Dynamic) { dialog.busy = false; dialog.next(); });
	}
	
	public function showRegrets()
	{
		dialog.busy = true;
		remove(dialog);
		rumbleSound.loop();
		player.play("oshit");
		HXP.screen.shake(4, 100.);
		add(new SurpriseNotif(player));
		HXP.alarm(2., function(_:Dynamic) { dialog.busy = false; add(dialog); dialog.next(); });
	}
	
	public function destroyShit()
	{
		dialog.busy = shitFallin = true;
		collapseSound.loop();
		HXP.alarm(2., function(_:Dynamic) { alphaTween.tween(0., 1., 1.); });
		baseTime = haxe.Timer.stamp();
		dialog.next();
	}
	
	public function showSurprise()
	{
		dialog.busy = true;
		remove(dialog);
		var e = new SurpriseNotif(player);
		add(e);
		HXP.alarm(1., function(_:Dynamic) { add(dialog); dialog.next(); dialog.busy = false; });
	}
}

class FallingSpike extends Entity
{
	private var dy:Float;
	public function new(x:Float)
	{
		super(x, -8 - HXP.random * 8);
		graphic = Main.getTileImage(0);
		dy = 4. + HXP.random * 4;
	}
	
	override public function update()
	{
		y += dy;
		if(y > HXP.height)
			scene.remove(this);
	}
}
