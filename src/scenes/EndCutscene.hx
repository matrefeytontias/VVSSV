package scenes;

import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.graphics.Text;
import com.haxepunk.tweens.misc.VarTween;
import com.haxepunk.tweens.motion.LinearMotion;

import openfl.geom.Rectangle;

import entities.Dialog;

class EndCutscene extends Scene
{
    private var fadeImg:Image;
	private var endText:Text;
	private var alphaTween:VarTween;
	private var bg:BackgroundScroller;
	private var tilemap:Level;
	private var player:Spritemap;
	private var positionTween:VarTween;
	private var character:Image;
	private var punchTween:LinearMotion;
	private var dialog:Dialog;
	static private var dialogText(default, never):Array<String> = [
		"I did it !",
		"My limbs are all back ! Feels good to be whole again !",
		"Wait, who is that ?",
		":decreaseAlpha",
		"Wow, so you really did it !",
		"I didn't think you'd be able to recover all
your limbs that quickly. I'm impressed !",
		":switchAnchors",
		"What do you mean ? Do you have
something to do with this ?",
		":switchAnchors",
		"Actually, I caused this collapse back in that room !",
		"I wanted to see how hard you were ready to try
and rescue your friends, because you see ...",
		"What really matters in the end is
the power of friendship !",
		":switchAnchors",
		":showRegret",
		"Oh boy ...",
		":switchAnchors",
		":makeDialogBusy",
		"Yes, because nothing matters if you don't have friends
to rely on. You see, it makes me think of a story that
happened to me when I was, oh, very little. As a matter
of facts, I was running in the forest with a few trusty
yet fiery friends when ...",
		"Hum, what are you doing ?",
		":punchThatShit",
		"Well. Now that that's sorted, let's go and find my friends already."
	];
	
	public function new()
	{
		super();
		bg = new BackgroundScroller("graphics/titleBackground.png");
		add(bg);
		
		var file = Level.loadLevelData("levels/outro.json");
		tilemap = new Level(file.data[0], 40, 30);
		add(tilemap);
		
		player = new Spritemap("graphics/introPlayer.png", 10, 21);
		player.add("idle", [2]);
		player.add("happy", [3]);
		player.play("happy");
		player.x = file.playerX;
		player.y = Std.int(file.playerY / 8 + 2) * 8 - player.height;
		addGraphic(player);
		
		character = new Image("graphics/introPlayer.png", new Rectangle(30, 0, 10, 21));
		character.x = HXP.width - player.x;
		character.y = player.y;
		character.flipped = true;
		addGraphic(character);
		
		positionTween = new VarTween(skipBigAssDialog);
		HXP.tweener.addTween(positionTween);
		
		punchTween = new LinearMotion();
		punchTween.x = character.x;
		punchTween.y = character.y;
		HXP.tweener.addTween(punchTween);
		
		fadeImg = Image.createRect(HXP.width, HXP.height, 0xffffff);
		alphaTween = new VarTween(switchAnchors, com.haxepunk.Tween.TweenType.OneShot);
		HXP.tweener.addTween(alphaTween);
		addGraphic(fadeImg);
		
		endText = new Text("Thanks for playing !", {color:0});
		endText.x = (HXP.width - endText.width) / 2;
		endText.y = (HXP.height - endText.height) / 2;
		endText.alpha = 0;
		addGraphic(endText);
		
		dialog = new Dialog(dialogText, this, {x:player.x, y:player.y, w:player.width, h:player.height});
		dialog.layer = -1;
		HXP.alarm(1., function (_:Dynamic) { add(dialog); });
	}
	
	override public function update()
	{
		super.update();
		if(dialog.scene != null)
		{
			if(!dialog.busy && Controls.space)
			{
				Main.getSound("menuSelect").play();
				if(dialog.next())
				{
					// end of cutscene, deal with it
					remove(dialog);
					alphaTween = new VarTween(backToTitle, com.haxepunk.Tween.TweenType.OneShot);
					HXP.tweener.addTween(alphaTween);
					alphaTween.tween(fadeImg, "alpha", 1., 1.);
				}
			}
		}
		character.x = punchTween.x;
		character.y = punchTween.y;
	}
	
	public function switchAnchors(?_:Dynamic)
	{
		dialog.busy = false;
		dialog.anchor.x = HXP.width - dialog.anchor.x;
		dialog.next();
	}
	
	private function skipBigAssDialog(?_:Dynamic)
	{
		dialog.next();
		dialog.busy = false;
	}
	
	private function backToTitle(_:Dynamic)
	{
		Main.getSound("levelEnd").play();
		alphaTween = new VarTween();
		HXP.tweener.addTween(alphaTween);
		alphaTween.tween(endText, "alpha", 1., 1.);
		HXP.alarm(5., function (_:Dynamic) { HXP.screen.scale = 1; HXP.scene = new TitleScene(); });
	}
	
	// Event functions
	
	public function decreaseAlpha()
	{
		alphaTween.tween(fadeImg, "alpha", 0., 2.);
		dialog.busy = true;
	}
	
	public function showRegret()
	{
		player.play("idle");
		dialog.next();
	}
	
	public function makeDialogBusy()
	{
		dialog.busy = true;
		dialog.next();
		positionTween.tween(player, "x", character.x - player.width * 2, 2.);
	}
	
	public function punchThatShit()
	{
		Main.getSound("punch").play();
		dialog.busy = true;
		punchTween.setMotion(character.x, character.y, HXP.width * 2, character.y, 1.);
		HXP.alarm(1.5, function (_:Dynamic) { player.play("happy"); dialog.busy = false; dialog.next(); });
	}
}
