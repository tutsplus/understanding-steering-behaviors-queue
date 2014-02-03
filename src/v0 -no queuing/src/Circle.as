package  
{
	import flash.geom.Vector3D;
	
	public class Circle extends Obstacle
	{
		public var radius :Number;
		
		public function Circle(posX :Number, posY :Number, r :Number) {
			radius = r;
			x = posX;
			y = posY;
			
			center.x = x;
			center.y = y;

			graphics.lineStyle(2, 0xffaabb);
			graphics.drawCircle(0, 0, r);
		}
	}
}