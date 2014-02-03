package  
{
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	
	public class Obstacle extends MovieClip {
		public var center :Vector3D;
		
		public function Obstacle() {
			center = new Vector3D();
		}
	}
}