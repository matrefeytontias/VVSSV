import haxepunk.Entity;
#if (android || ios)
import haxepunk.HXP;
import haxepunk.utils.Touch;

import openfl.events.TouchEvent;
#else
import haxepunk.utils.Input;
import haxepunk.utils.Key;
#end

class Controls
{
#if (android || ios)
	static public function init()
    {
        HXP.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		HXP.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
        HXP.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
    }
	
	static public function update()
	{
		for (touchId in _touchOrder) _touches[touchId].update();
		
		var i = 0;
		while(i < _touchOrder.length)
		{
			var touchId = _touchOrder[i], touch = _touches[touchId];
			if(touch.released && !touch.pressed)
			{
				_touches.remove(touchId);
				_touchOrder.remove(touchId);
			}
			else ++i;
		}
	}
	
	// Counts how many touches verify the condition
	static private function touchesAmount(f:Touch -> Bool) : Int
	{
		var r = 0;
		for(t in _touches.iterator())
			r += f(t) ? 1 : 0;
		return r;
	}
	
	// If at least one touch verifies the condition
	static private function atLeastOneTouch(f:Touch -> Bool) : Bool
	{
		for(t in _touches.iterator())
			if(f(t))
				return true;
		return false;
	}
	
	// If at least one touch is in one of the 4 screen quadrants
	// left - right ; top - down <=> false - true
	static private function atLeastOneTouchInRect(lr:Null<Bool>, td:Null<Bool>) : Bool
	{
		return atLeastOneTouch(function (t:Touch) return lr != null ? (t.sceneX > HXP.halfWidth) == lr : (t.sceneY > HXP.halfHeight) == td);
	}
	
	static public function entityHovered(e:Entity) : Bool
	{
		return atLeastOneTouch(function (t:Touch) return e.collidePoint(e.x, e.y, t.sceneX, t.sceneY));
	}
	
	static public var left(get, never):Bool;
	static private function get_left() : Bool { return Controls.atLeastOneTouchInRect(false, null); }
	static public var right(get, never):Bool;
	static private function get_right() : Bool { return Controls.atLeastOneTouchInRect(true, null); }
	static public var up(get, never):Bool;
	static private function get_up() : Bool { return Controls.atLeastOneTouchInRect(null, false); }
	static public var down(get, never):Bool;
	static private function get_down() : Bool { return Controls.atLeastOneTouchInRect(null, true); }
	static public var space(get, never):Bool;
	static private function get_space() : Bool { return Controls.touchesAmount(function (t:Touch) return !t.released) > 1; }
	static public var nextDialog(get, never):Bool;
	static private function get_nextDialog() : Bool { return pressed; }
	static public var skip(get, never):Bool;
	static private function get_skip() : Bool { return Controls.touchesAmount(function (t:Touch) return !t.released) > 1; }
	static public var pressing(get, never):Bool;
	static private function get_pressing() : Bool { return Controls.atLeastOneTouch(function (t:Touch) return !t.released); }
	static public var pressed(get, never):Bool;
	static private function get_pressed() : Bool { return Controls.atLeastOneTouch(function (t:Touch) return t.pressed); }
	static public var released(get, never):Bool;
	static private function get_released() : Bool { return Controls.atLeastOneTouch(function (t:Touch) return t.released); }
    
    static private function onTouchBegin(e:TouchEvent)
	{
		var touchPoint = new Touch(e.stageX / HXP.screen.fullScaleX, e.stageY / HXP.screen.fullScaleY, e.touchPointID);
		_touches.set(e.touchPointID, touchPoint);
		_touchOrder.push(e.touchPointID);
	}

	static private function onTouchMove(e:TouchEvent)
	{
		// maybe we missed the begin event sometimes?
		if (_touches.exists(e.touchPointID))
		{
			var point = _touches.get(e.touchPointID);
			point.x = e.stageX / HXP.screen.fullScaleX;
			point.y = e.stageY / HXP.screen.fullScaleY;
		}
	}

	static private function onTouchEnd(e:TouchEvent)
	{
		if (_touches.exists(e.touchPointID))
		{
			_touches.get(e.touchPointID).released = true;
		}
    }
	
	static private var _touches:Map<Int, Touch> = new Map<Int, Touch>();
	static private var _touchOrder:Array<Int> = new Array<Int>();
#else
	static public function init()
	{
		Input.define("down", [ Key.S, Key.DOWN ]);
		Input.define("left", [ Key.A, Key.Q, Key.LEFT ]);
		Input.define("right", [ Key.D, Key.RIGHT ]);
		Input.define("up", [ Key.W, Key.Z, Key.UP ]);
		Input.define("space", [ Key.SPACE ]);
		Input.define("skip", [ Key.S ]);
	}
	
	static public function entityHovered(e:Entity) : Bool
	{
		return e.collidePoint(e.x, e.y, e.scene.mouseX, e.scene.mouseY);
	}
	
	static public var left(get, never):Bool;
	static private function get_left() : Bool { return Input.check("left"); }
	static public var right(get, never):Bool;
	static private function get_right() : Bool { return Input.check("right"); }
	static public var up(get, never):Bool;
	static private function get_up() : Bool { return Input.check("up"); }
	static public var down(get, never):Bool;
	static private function get_down() : Bool { return Input.check("down"); }
	static public var space(get, never):Bool;
	static private function get_space() : Bool { return Input.pressed("space"); }
	static public var nextDialog(get, never):Bool;
	static private function get_nextDialog() : Bool { return space; }
	static public var skip(get, never):Bool;
	static private function get_skip() : Bool { return Input.pressed("skip"); }
	static public var pressing(get, never):Bool;
	static private function get_pressing() : Bool { return Input.mouseDown; }
	static public var pressed(get, never):Bool;
	static private function get_pressed() : Bool { return Input.mousePressed; }
	static public var released(get, never):Bool;
	static private function get_released() : Bool { return Input.mouseReleased; }
#end
}
