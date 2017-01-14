package scenes;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Text;
import com.haxepunk.tweens.sound.SfxFader;
import com.haxepunk.utils.Data;

import openfl.geom.Rectangle;

import entities.BackButton;
import entities.Player;

class GameScene extends Scene
{
	static public var solidTypes(default, never) = ["level", "spike", "sswitch", "dpswitch", "dmswitch", "fade", "finish"];
	static private var limbNames(default, never) = ["Left foot", "Left leg", "Right foot", "Right leg", "Left hand", "Left arm", "Right hand", "Right arm", "Torso"];
	static public var currentLevelNum:Int;
	private var mapw(default, never):Int = 40;
	private var maph(default, never):Int = 30;
	private var player:Player;
	private var level:Level;
	private var levelTree:Array<Level>;
	private var levelNodes:Array<Array<Int>>;
	private var currentLeaf:{x:Int, y:Int};
	
	private var levelFinished:Bool;
	private var endAnimRect:Image = null;
	
	private var initialVolume:Float;
	
    public function new(levelNumber:Int)
	{
		super();
		currentLevelNum = levelNumber - 1;
		levelTree = new Array<Level>();
		
		var file = Level.loadLevelData("levels/map" + Std.string(levelNumber) + ".json");
		
		player = new Player();
		player.setCheckpoint(file.playerLeaf, file.playerX, file.playerY);
		player.x = file.playerX;
		player.y = file.playerY;
		
		var a:Array<String> = file.data;
		for(l in a)
		{
			var lvl = new Level(l, mapw, maph);
			levelTree.push(lvl);
		}
		levelNodes = file.levelNodes;
		currentLeaf = file.playerLeaf;
		level = levelTree[levelNodes[currentLeaf.y][currentLeaf.x]];
		levelFinished = false;
		
		HXP.screen.scale = 2;
		
		add(new BackgroundScroller("graphics/titleBackground.png"));
		add(level);
		add(player);
		add(new BackButton());
	}
	
	public function loadLeaf(l:{x:Int, y:Int})
	{
		currentLeaf.x = l.x;
		currentLeaf.y = l.y;
		var lvl = levelTree[levelNodes[currentLeaf.y][currentLeaf.x]];
		level.destroy();
		add(lvl);
		player.switchMap();
		level = lvl;
	}
	
	override public function update()
	{
		level.updateCollisions(player);
		super.update();
		if(!player.hurt)
		{
			if(!levelFinished)
			{
				// Level boundaries
				if(player.x < player.width / 2)
				{
					currentLeaf.x--;
					loadLeaf(currentLeaf);
					player.x = level.width - player.width / 2;
				}
				if(player.x > level.width - player.width / 2)
				{
					currentLeaf.x++;
					loadLeaf(currentLeaf);
					player.x = player.width / 2;
				}
				if(player.y < player.height / 2)
				{
					currentLeaf.y--;
					loadLeaf(currentLeaf);
					player.y = level.height - player.height / 2;
				}
				if(player.y > level.height - player.height / 2)
				{
					currentLeaf.y++;
					loadLeaf(currentLeaf);
					player.y = player.height / 2;
				}
			}
			else
			{
				// Play the end of level animation for any level that's not the last
				var w = endAnimRect.scale * endAnimRect.width / 2;
				if(endAnimRect.x - w >= 0 || endAnimRect.x + w < HXP.width)
					endAnimRect.scale += 2.;
				else
				{
					if(currentLevelNum < 9)
					{
						if(endAnimRect.alpha == 1.)
						{
							var t = new Text(limbNames[currentLevelNum] + " found !", {color:0xffffff});
							t.x = (HXP.width - t.width) / 2;
							t.y = HXP.halfHeight / 2;
							addGraphic(t);
							var r = new Rectangle(0, 0, 10, 21);
							for(k in 0 ... 9)
							{
								if(Data.readBool("level" + (k + 1), false))
								{
									r.x = k * 10;
									var i = new Image("graphics/limbs.png", r);
									i.centerOrigin();
									addGraphic(i, 0, HXP.halfWidth, HXP.height * 3 / 4);
								}
							}
							endAnimRect.alpha -= 0.025;
						}
						else if(endAnimRect.alpha > 0.)
							endAnimRect.alpha -= 0.025;
						else
						{
							endAnimRect.alpha = 0;
							levelFinished = false;
							HXP.alarm(3., function (_:Dynamic) { removeAll(); HXP.screen.scale = 1; HXP.scene = new LevelSelectScene(); });
						}
					}
					else
						HXP.scene = new EndCutscene();
				}
			}
		}
	}
	
	public function finishLevel(e:Entity)
	{
		if(!levelFinished)
		{
			if(currentLevelNum == 9)
			{
				Main.music.stop();
				Main.getSound("levelEnd").play();
			}
			else
			{
				initialVolume = Main.music.volume;
				Main.music.volume = 0;
				Main.getSound("levelEnd", resumeMusic).play();
			}
			Main.getSound("levelOnEnd").play();
			var ents = new Array<Entity>();
			getAll(ents);
			for(e in ents)
			{
				if(e.type != "background")
					remove(e);
			}
			endAnimRect = Image.createRect(10, 21);
			endAnimRect.centerOrigin();
			endAnimRect.x = e.x;
			endAnimRect.y = e.y;
			addGraphic(endAnimRect);
			levelFinished = true;
			if(currentLevelNum < 9)
			{
				Data.write("level" + (currentLevelNum + 1), true);
				Data.save("accessibleLevels");
			}
		}
	}
	
	private function resumeMusic()
	{
		var t = new SfxFader(Main.music);
		HXP.tweener.addTween(t);
		t.fadeTo(initialVolume, 1.);
	}
}
