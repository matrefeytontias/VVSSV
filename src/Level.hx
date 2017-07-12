import com.haxepunk.Entity;
import com.haxepunk.HXP;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;

import entities.*;

class Level extends Entity
{
	// Tiles correspondances
	static public var TILE_SPIKES(default, never) = 0;
	static public var TILE_SWITCHES(default, never) = 4;
	static public var TILE_DIAGSWITCHES(default, never) = 6;
	static public var TILE_FADE(default, never) = 8;
	static public var TILE_FINISH(default, never) = 9;
	static public var TILE_WALL(default, never) = 12;
	static public var TILES_HANDLE(default, never) = 8;
	static private var TILES_CLASSES:Array<Class<TileEntity>> = [ entities.Spike, entities.Spike, entities.Spike, entities.Spike, entities.SSwitch, entities.SSwitch, entities.DSwitch, entities.DSwitch ];
	
    private var tilemap:Tilemap;
	
	private var linked:Array<Array<TileEntity>>;
	private var fades:Array<FadeTile>;
	private var endTile:EndTile;
	
	static inline public function loadLevelData(path:String) : Dynamic
	{
		return haxe.Json.parse(openfl.Assets.getText(path));
	}
	
	public function new(data:String, w:Int, h:Int)
	{
		super();
		tilemap = new Tilemap("graphics/tileset.png", w * 8, h * 8, 8, 8);
		tilemap.loadFromString(data);
		graphic = tilemap;
		var grid = new Grid(w * 8, h * 8, 8, 8);
		mask = grid;
		for(j in 0 ... h)
		{
			for(i in 0 ... w)
				grid.setTile(i, j, tilemap.getTile(i, j) >= TILE_WALL);
		}
		type = "level";
		layer = 1;
		setHitbox(grid.columns * grid.tileWidth, grid.rows * grid.tileHeight);
	}
	
	override public function added()
	{
		collidable = true;
		linked = new Array<Array<TileEntity>>();
		for(k in 0 ... TILES_HANDLE)
		{
			linked.push(new Array<TileEntity>());
			for(l in 0 ... 9)
			{
				linked[k].push(Type.createInstance(TILES_CLASSES[k], [0, 0, k]));
				scene.add(linked[k][l]);
				linked[k][l].collidable = false;
				linked[k][l].visible = false;
			}
		}
		
		// Spawn fade blocks and the victory point
		fades = new Array<FadeTile>();
		for(j in 0 ... tilemap.rows)
		{
			for(i in 0 ... tilemap.columns)
			{
				var c = tilemap.getTile(i, j);
				if(c == TILE_FADE)
					fades.push(scene.add(new FadeTile(i * 8 + 4, j * 8 + 4, c)));
				else if(c == TILE_FINISH)
					scene.add(endTile = new EndTile(i * 8 + 4, j * 8 + 4, c));
			}
		}
	}
	
	// Moves test entities on the 9 map cells around and under the player
	public function updateCollisions(p:Player)
	{
		// Reset everything
		for(a in linked)
		{
			for(e in a)
			{
				e.collidable = false;
				e.visible = false;
			}
		}
		
		var startX = Std.int(Math.max(p.x / 8 - 1, 0)), endX = Std.int(Math.min(startX + 2, tilemap.columns - 1));
		var startY = Std.int(Math.max(p.y / 8 - 1, 0)), endY = Std.int(Math.min(startY + 2, tilemap.rows - 1));
		var k = 0;
		
		for(j in startY ... endY + 1)
		{
			for(i in startX ... endX + 1)
			{
				var c = tilemap.getTile(i, j);
				if(c < 0)
					continue; // empty cell
				else if(c < TILES_HANDLE)
				{
					linked[c][k].x = i * 8 + 4;
					linked[c][k].y = j * 8 + 4;
					linked[c][k].collidable = true;
					linked[c][k].visible = true;
				}
				k++;
			}
		}
	}
	
	public function destroy()
	{
		collidable = false;
		scene.remove(this);
		for(a in linked)
		{
			for(e in a)
			{
				e.collidable = false;
				scene.remove(e);
			}
			HXP.clear(a);
		}
		HXP.clear(linked);
		
		for(f in fades)
		{
			f.collidable = false;
			scene.remove(f);
		}
		HXP.clear(fades);
		if(endTile != null)
			scene.remove(endTile);
	}
	
	public function t(x:Float, y:Float) : Int
	{
		return tilemap.getTile(Std.int(x / tilemap.tileWidth), Std.int(y / tilemap.tileHeight));
	}
}
