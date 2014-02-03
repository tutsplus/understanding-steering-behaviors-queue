package  
{
	public class Rectangle extends Obstacle
	{
		public var w :Number;
		public var h: Number;
		
		public function Rectangle(posX :Number, posY :Number, width :Number, height :Number) {
			x = posX;
			y = posY;
			w = width;
			h = height;
			center.x = x + w / 2;
			center.y = y + h / 2;
			
			graphics.lineStyle(2, 0xffaabb);
			graphics.drawRect(0, 0, w, h);
		}
	}
}