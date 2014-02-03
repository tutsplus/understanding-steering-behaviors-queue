package  
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;

	public class Game extends MovieClip
	{
		public static var mouse 		:Vector3D 	= new Vector3D(100, 100);
		public static var width 		:Number 	= 0;
		public static var height 		:Number 	= 0;
		public static var showForces 	:Boolean 	= false;
		
		public static var instance 		:Game;
		
		public var boids 				:Vector.<Boid> 		= new Vector.<Boid>;
		public var obstacles 			:Vector.<Obstacle> 	= new Vector.<Obstacle>;
		public var forces 				:Sprite;
		
		public function Game() {
			Game.instance = this;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e :Event = null) :void {
			var i :int, boid :Boid, obstacle :Obstacle;
			
			Game.width = stage.stageWidth;
			Game.height = stage.stageHeight;
			
			reset();
			
			// Add two walls to build the "doorway".
			obstacle = new Rectangle(0, Game.height * 0.05, 230, 80);
			addChild(obstacle);
			obstacles.push(obstacle);
			
			obstacle = new Rectangle(360, Game.height * 0.05, 300, 80);
			addChild(obstacle);
			obstacles.push(obstacle);
			
			// Add boids
			for (i = 0; i < 60; i++) {
				boid = new Boid(Game.width * Math.random(), Game.height + Math.random() * 200, 20 +  Math.random() * 20);
				
				addChild(boid);
				boids.push(boid);
			}
			
			forces = new Sprite();
			addChild(forces);
			
			stage.addEventListener(MouseEvent.CLICK, toggleShowForces);
			
			addChild(new GenerateButton());
		}
		
		private function toggleShowForces(e: Event) :void {
			showForces = !showForces;
		}
		
		public function reset() :void {
			while (numChildren) {
				removeChildAt(0);
			}
			boids.length = 0;
			obstacles.length = 0;
			showForces = false;
			
			stage.removeEventListener(MouseEvent.CLICK, toggleShowForces);
		}
		
		public function update():void {
			var i :int;
			
			forces.graphics.clear();
			
			for (i = 0; i < boids.length; i++) { 
				boids[i].update();
				drawForces(boids[i]);
			}
		}
		
		private function drawForces(boid :Boid) :void {
			var velocity :Vector3D = boid.velocity.clone();
			var steering :Vector3D = boid.steering.clone();
			var avoidance :Vector3D = boid.avoidance.clone();
			var braking :Vector3D = boid.braking.clone();
			
			velocity.normalize();
			steering.normalize();
			avoidance.normalize();
			braking.normalize();
			
			// Force vectors
			if (showForces) {
				drawForceVector(boid, velocity, 0x00FF00);
				drawForceVector(boid, braking, 0xFF0000);
				drawPoint(boid.ahead, 0xFF5000);
				drawCircle(boid.position, 0x323232, Boid.MAX_QUEUE_RADIUS);	
				drawCircle(boid.ahead, 0xFF5000, Boid.MAX_QUEUE_RADIUS);	
			}
		}
		
		private function drawCircle(force :Vector3D, color :uint, radius :Number) :void {
			forces.graphics.lineStyle(1, color);
			forces.graphics.drawCircle(force.x, force.y, radius);
		}
		
		private function drawPoint(force :Vector3D, color :uint) :void {
			forces.graphics.lineStyle(1, 0x323232);
			forces.graphics.beginFill(color);
			forces.graphics.drawCircle(force.x, force.y, 6);
			forces.graphics.endFill();
		}
		
		private function drawForceVector(boid :Boid, force :Vector3D, color :uint, scale :Number = 100) :void {
			forces.graphics.moveTo(boid.x, boid.y);
			forces.graphics.lineStyle(2, color, 1);
			forces.graphics.lineTo(boid.x + force.x * scale, boid.y + force.y * scale);
		}
	}
}