package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class GenerateButton extends MovieClip 
	{
		private var text :TextField;
		
		public function GenerateButton() 
		{
			x = Game.width - 80;
			y = Game.height - 60;
			
			text = new TextField();
			text.text = "Reload";
			text.textColor = 0xffffff;
			text.x = 15;
			text.y = 10;
			text.mouseEnabled = false;
			
			addChild(text);
			
			graphics.lineStyle(2, 0xcfcfcf);
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 70, 40);
			graphics.endFill();
			
			addEventListener(MouseEvent.CLICK, function(e :Event) :void {
				Game.instance.init();
			});
		}
	}
}