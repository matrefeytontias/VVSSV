package entities;

import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.Scene;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Spritemap;
import com.haxepunk.masks.Imagemask;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

import scenes.GameScene;

class Player extends Entity
{
	static private var SPEED = 3;
	
	private var gravityX:Int;
	private var gravityY:Int;
	private var sGravSwitchHit:Bool;
	private var dpGravSwitchHit:Bool;
	private var dmGravSwitchHit:Bool;
	private var gfx:Spritemap;
	private var cgfx:Image;
	private var grounded:Bool;
	public var hurt:Bool;
	private var blinkTimerBase:Float;
	
	// Respawn point
	public var respawnLeaf:{x:Int, y:Int};
	public var respawnX:Float;
	public var respawnY:Float;
	private var deaths:Int = 0;
	
    public function new()
	{
		super();
		gfx = new Spritemap("graphics/player.png", 10, 10);
		gfx.add("idle", [0]);
		gfx.add("walk", [0, 1], 10);
		graphic = gfx;
		cgfx = HWImage.c(new BitmapData(10, 10));
		cgfx.centerOrigin();
		mask = new Imagemask(cgfx);
		type = "player";
		layer = 0;
		hurt = true;
		switchMap();
	}

#if (android || ios)
	override public function added()
	{
		scene.add(new Underlay());
	}
#end
	
	public function switchMap()
	{
		// If the player died, reset the physics variables
		if(hurt)
		{
			gravityX = 0;
			gravityY = 1;
			sGravSwitchHit = false;
			dpGravSwitchHit = false;
			dmGravSwitchHit = false;
			grounded = false;
			hurt = false;
			visible = true;
			gfx.centerOrigin();
			updateGfx();
		}
	}
	
	public function setCheckpoint(_leaf:{x:Int, y:Int}, _x:Float, _y:Float)
	{
		respawnLeaf = {x:_leaf.x, y:_leaf.y};
		respawnX = _x;
		respawnY = _y;
	}
	
	public function loadCheckpoint(s:GameScene)
	{
		s.loadLeaf(respawnLeaf);
		x = respawnX;
		y = respawnY;
	}
	
	private function die()
	{
		if(!hurt)
		{
			Main.getSound("hurt").play();
			hurt = true;
			blinkTimerBase = haxe.Timer.stamp();
			HXP.alarm(1., reset);
			deaths++;
		}
	}
	
	private function reset(_:Dynamic)
	{
		loadCheckpoint(cast(scene, GameScene));
#if (android || ios)
		cast(scene.getInstance("underlay"), Underlay).rotate(true);
#end
	}
	
	override public function update()
	{
		// First, check for death animation
		if(hurt)
		{
			gfx.play("idle");
			visible = Std.int((haxe.Timer.stamp() - blinkTimerBase) / 0.1) % 2 > 0;
		}
		else
		{
			grounded = false;
			moveBy(SPEED * gravityX, SPEED * gravityY, GameScene.solidTypes);
			
			if(gravityX == 0)
			{
				var l = Controls.left, r = Controls.right;
				if(l && !r)
				{
					moveBy(-SPEED, 0, GameScene.solidTypes);
					gfx.flipped = true;
					if(grounded)
						gfx.play("walk");
				}
				else if(r && !l)
				{
					moveBy(SPEED, 0, GameScene.solidTypes);
					gfx.flipped = false;
					if(grounded)
						gfx.play("walk");
				}
				else
					gfx.play("idle");
			}
			else // gravityY == 0
			{
				if(Controls.up)
				{
					moveBy(0, -SPEED, GameScene.solidTypes);
					gfx.flipped = true;
					if(grounded)
						gfx.play("walk");
				}
				else if(Controls.down)
				{
					moveBy(0, SPEED, GameScene.solidTypes);
					gfx.flipped = false;
					if(grounded)
						gfx.play("walk");
				}
				else
					gfx.play("idle");
			}
			
			if(grounded && Controls.space)
				spacePressed();
			
			sGravSwitchHit = sGravSwitchHit && (collide("sswitch", x, y) != null);
			dpGravSwitchHit = dpGravSwitchHit && (collide("dpswitch", x, y) != null);
			dmGravSwitchHit = dmGravSwitchHit && (collide("dmswitch", x, y) != null);
		}
	}
	
	private function spacePressed()
	{
		Main.getSound(sGravSwitchHit || dpGravSwitchHit || dmGravSwitchHit ? "jump2" : "jump").play();
		gravityX *= -1;
		gravityY *= -1;
		gfx.play("idle");
		updateGfx();
	}
	
	private function diagPGravSwitch()
	{
		Main.getSound("jump2").play();
		var t = gravityX;
		gravityX = -gravityY;
		gravityY = -t;
		updateGfx();
#if (android || ios)
		cast(scene.getInstance("underlay"), Underlay).rotate();
#end
	}
	
	private function diagMGravSwitch()
	{
		Main.getSound("jump2").play();
		var t = gravityX;
		gravityX = gravityY;
		gravityY = t;
		updateGfx();
#if (android || ios)
		cast(scene.getInstance("underlay"), Underlay).rotate();
#end
	}
	
	private function updateGfx()
	{
		if(gravityX == 0)
		{
			gfx.angle = 0;
			gfx.scaleX = 1;
			gfx.scaleY = gravityY < 0 ? -1 : 1;
		}
		else // gravityY == 0
		{
			gfx.angle = 90;
			gfx.scaleX = -1;
			gfx.scaleY = gravityX < 0 ? -1 : 1;
		}
		cgfx.angle = gfx.angle;
		cgfx.scaleX = gfx.scaleX;
		cgfx.scaleY = gfx.scaleY;
		centerOrigin();
	}
	
	override public function moveCollideX(e:Entity) : Bool
	{
		switch(e.type)
		{
		case "spike":
			die();
			return false;
		case "sswitch":
			if(!sGravSwitchHit)
			{
				sGravSwitchHit = true;
				spacePressed();
			}
			return false;
		case "dpswitch":
			if(!dpGravSwitchHit)
			{
				dpGravSwitchHit = true;
				diagPGravSwitch();
			}
			return false;
		case "dmswitch":
			if(!dmGravSwitchHit)
			{
				dmGravSwitchHit = true;
				diagMGravSwitch();
			}
			return false;
		case "fade":
			if(gravityY == 0)
			{
				grounded = true;
				var a = new Array<FadeTile>();
				collideInto("fade", x + gravityX, y, a);
				for(e in a)
					e.fade();
				HXP.clear(a);
			}
			return true;
		case "level":
			if(gravityY == 0)
				grounded = true;
			return true;
		case "finish":
			cast(scene, GameScene).finishLevel(e);
			return false;
		default:
			return false;
		}
	}
	
	override public function moveCollideY(e:Entity) : Bool
	{
		switch(e.type)
		{
		case "spike":
			die();
			return false;
		case "sswitch":
			if(!sGravSwitchHit)
			{
				sGravSwitchHit = true;
				spacePressed();
			}
			return false;
		case "dpswitch":
			if(!dpGravSwitchHit)
			{
				dpGravSwitchHit = true;
				diagPGravSwitch();
			}
			return false;
		case "dmswitch":
			if(!dmGravSwitchHit)
			{
				dmGravSwitchHit = true;
				diagMGravSwitch();
			}
			return false;
		case "fade":
			if(gravityX == 0)
			{
				grounded = true;
				var a = new Array<FadeTile>();
				collideInto("fade", x, y + gravityY, a);
				for(e in a)
					e.fade();
				HXP.clear(a);
			}
			return true;
		case "level":
			if(gravityX == 0)
				grounded = true;
			return true;
		case "finish":
			cast(scene, GameScene).finishLevel(e);
			return false;
		default:
			return false;
		}
	}
}

#if (android || ios)
class Underlay extends Entity
{
	private var u1:Image;
	private var u2:Image;
	
	public function new()
	{
		super(HXP.halfWidth, HXP.halfHeight);
		var d = Std.int(Math.max(HXP.screen.width, HXP.screen.height) / 2);
		u1 = Image.createRect(d, d, 0xff0000, 0.25);
		u2 = Image.createRect(d, d, 0x0000ff, 0.25); 
		u1.originY = u2.originY = d / 2;
		u1.angle = 180;
		graphic = new Graphiclist([u1, u2]);
		graphic.scrollX = graphic.scrollY = 0;
		layer = 1;
		name = "underlay";
	}
	
	public function rotate(?reset:Bool)
	{
		var a = (u1.angle + 90) % 180;
		u1.angle = reset ? 180 : a + 180;
		u2.angle = reset ? 0 : a;
	}
}
#end