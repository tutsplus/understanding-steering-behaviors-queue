package  
{
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	
	public class Boid extends MovieClip
	{
		public static const MAX_FORCE 			:Number = 5.4;
		public static const MAX_VELOCITY 		:Number = 6;
			
		// Collision avoidance
		public static const MAX_AVOID_AHEAD	 	:Number = 50;
		public static const AVOID_FORCE	 		:Number = 600;
		
		// Queuing
		public static const MAX_QUEUE_AHEAD	 	:Number = 30;
		public static const MAX_QUEUE_RADIUS	:Number = 30;
		
		// Separation
		public static const MAX_SEPARATION 		:Number = 2.0;
		public static const SEPARATION_RADIUS 	:Number = 30;
		
		public var position 	:Vector3D;
		public var velocity 	:Vector3D;
		public var desired 		:Vector3D;
		public var ahead 		:Vector3D;
		public var ahead2 		:Vector3D;
		public var steering 	:Vector3D;
		public var avoidance 	:Vector3D;
		public var braking 		:Vector3D;
		public var mass			:Number;
		
		public function Boid(posX :Number, posY :Number, totalMass :Number) {
			position 	= new Vector3D(posX, posY);
			velocity 	= new Vector3D(-1, -2);
			desired	 	= new Vector3D(0, 0); 
			steering 	= new Vector3D(0, 0); 
			ahead 		= new Vector3D(0, 0); 
			avoidance 	= new Vector3D(0, 0); 
			braking 	= new Vector3D(0, 0); 
			mass	 	= totalMass;
			
			truncate(velocity, MAX_VELOCITY);
			
			x = position.x;
			y = position.y;
			
			graphics.lineStyle(2, 0xffaabb);
			graphics.beginFill(0xFF0000);
			graphics.moveTo(0, 0);
			graphics.lineTo(0, -20);
			graphics.lineTo(10, 20);
			graphics.lineTo(-10, 20);
			graphics.lineTo(0, -20);
			graphics.endFill();
			
			graphics.moveTo(0, 0);
		}
		
		private function seek(target :Vector3D) :Vector3D {
			var force :Vector3D;
			
			desired = target.subtract(position);
			desired.normalize();
			desired.scaleBy(MAX_VELOCITY);
			
			force = desired.subtract(velocity);
			
			return force;
		}
		
		private function getNeighborAhead() :Boid {
			var i:int;
			var ret :Boid = null;
			var qa :Vector3D = velocity.clone();
			
			qa.normalize();
			qa.scaleBy(MAX_QUEUE_AHEAD);
			
			ahead = position.clone().add(qa);
			
			for (i = 0; i < Game.instance.boids.length; i++) {
				var neighbour :Boid = Game.instance.boids[i];
				var d :Number = distance(ahead, neighbour.position);
				
				if (neighbour != this && d <= MAX_QUEUE_RADIUS) {
					ret = neighbour;
					break;
				}
			}
			
			return ret;
		}
		
		private function queue() :Vector3D {
			var v :Vector3D = velocity.clone();
			var brake :Vector3D = new Vector3D();
						
			var neighbour :Boid = getNeighborAhead();

			if (neighbour != null) {
				brake.x = -steering.x * 0.8;
				brake.y = -steering.y * 0.8;
				
				v.scaleBy( -1);
				brake = brake.add(v);
				
				if (distance(position, neighbour.position) <= MAX_QUEUE_RADIUS) {
					velocity.scaleBy(0.3);
				}
			}
			
			// Used to render the brake force vector on the screen
			braking = brake;
			
			return brake;
		}
		
		// Link: http://gamedev.tutsplus.com/tutorials/implementation/the-three-simple-rules-of-flocking-behaviors-alignment-cohesion-and-separation/
		private function separation() :Vector3D {
			var force :Vector3D = new Vector3D();
			var neighborCount :int = 0;
			
			for (var i:int = 0; i < Game.instance.boids.length; i++) {
				var b :Boid = Game.instance.boids[i];
				
				if (b != this && distance(b, this) <= SEPARATION_RADIUS) {
					force.x += b.position.x - this.position.x;
					force.y += b.position.y - this.position.y;
					neighborCount++;
				}
			}
			
			if (neighborCount != 0) {
				force.x /= neighborCount;
				force.y /= neighborCount;
				
				force.scaleBy( -1);
			}
			
			force.normalize();
			force.scaleBy(MAX_SEPARATION);
			
			return force;
		}
		
		private function collisionAvoidance() :Vector3D {
			var tv :Vector3D = velocity.clone();
			tv.normalize();
			tv.scaleBy(MAX_AVOID_AHEAD * velocity.length / MAX_VELOCITY);
			
			ahead = position.clone().add(tv);
			
			var mostThreatening :Obstacle = null;
			
			for (var i:int = 0; i < Game.instance.obstacles.length; i++) {
				var obstacle :Obstacle = Game.instance.obstacles[i];
				var collision :Boolean = obstacle is Circle ? lineIntersecsCircle(position, ahead, obstacle as Circle) : lineIntersecsRectangle(position, ahead, obstacle as Rectangle);
				
				if (collision && (mostThreatening == null || distance(position, obstacle) < distance(position, mostThreatening))) {
					mostThreatening = obstacle;
				}
			}
			
			if (mostThreatening != null) {
				alpha = 0.4; // make the boid a little bit transparent to indicate it is colliding
				
				avoidance.x = ahead.x - mostThreatening.center.x;
				avoidance.y = ahead.y - mostThreatening.center.y;
				
				avoidance.normalize();
				avoidance.scaleBy(AVOID_FORCE);
			} else {
				alpha = 1; // make the boid opaque to indicate there is no collision.
				avoidance.scaleBy(0); // nullify the avoidance force
			}
			
			return avoidance;
		}
		
		private function distance(a :Object, b :Object) :Number {
			return Math.sqrt((a.x - b.x) * (a.x - b.x)  + (a.y - b.y) * (a.y - b.y));
		}
		
		private function lineIntersecsCircle(position :Vector3D, ahead :Vector3D, c :Circle) :Boolean {
			var tv :Vector3D = velocity.clone();
			tv.normalize();
			tv.scaleBy(MAX_AVOID_AHEAD * 0.5 * velocity.length / MAX_VELOCITY);
			
			ahead2 = position.clone().add(tv);
			return distance(c, ahead) <= c.radius || distance(c, ahead2) <= c.radius || distance(c, this) <= c.radius;
		}
		
		private function lineIntersecsRectangle(position :Vector3D, ahead :Vector3D, r :Rectangle) :Boolean {
			return (ahead.x >= r.x && ahead.x <= (r.x + r.w) && ahead.y >= r.y && ahead.y <= (r.y + r.height)) ||
				   (position.x >= r.x && position.x <= (r.x + r.w) && position.y >= r.y && position.y <= (r.y + r.height));
		}
		
		public function truncate(vector :Vector3D, max :Number) :void {
			var i :Number;

			i = max / vector.length;
			i = i < 1.0 ? i : 1.0;
			
			vector.scaleBy(i);
		}
		
		public function getAngle(vector :Vector3D) :Number {
			return Math.atan2(vector.y, vector.x);
		}
		
		public function update():void {
			var doorway :Vector3D = new Vector3D(Game.width / 2, -100);
			
			steering = seek(doorway);
			steering = steering.add(collisionAvoidance());
			steering = steering.add(queue());
			
			truncate(steering, MAX_FORCE);
			steering.scaleBy(1 / mass);
			
			velocity = velocity.add(steering);
			truncate(velocity, MAX_VELOCITY);
			
			position = position.add(velocity);
			
			x = position.x;
			y = position.y;
			
			// Adjust boid rodation to match the velocity vector.
			if(alpha >= 0.9) {
				rotation = 90 + (180 * getAngle(velocity)) / Math.PI;
			}
			
			if (y <= -5) {
				position.x = Game.width * Math.random();
				position.y = Game.height * 1.2;
			}
		}
	}
}