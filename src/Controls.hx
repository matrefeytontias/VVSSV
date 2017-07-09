import haxepunk.utils.Input;
import haxepunk.utils.Key;

class Controls
{
#if (android || ios)
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
	static public var skip(get, never):Bool;
	static private function get_skip() : Bool { return Input.pressed("skip"); }
#end
}
