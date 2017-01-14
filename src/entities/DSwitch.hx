package entities;

class DSwitch extends TileEntity
{
	public function new(x:Float = 0, y:Float = 0, tile:Int)
	{
		super(x, y, tile == 6 ? "dpswitch" : "dmswitch", tile);
	}
}