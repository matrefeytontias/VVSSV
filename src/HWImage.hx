import com.haxepunk.HXP;
import com.haxepunk.RenderMode;
import com.haxepunk.Graphic.ImageType;
import com.haxepunk.graphics.Image;
import com.haxepunk.ds.Either;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;

class HWImage
{
	@:access(com.haxepunk.ImageType)
	static public function c(bd:BitmapData, ?clipRect:Rectangle) : Image
	{
		return new Image(HXP.renderMode == RenderMode.HARDWARE ? new ImageType(Left(bd)) : bd, clipRect);
	}
}
