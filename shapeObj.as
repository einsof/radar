package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class shapeObj extends Objects {
		
		private var shapeLoader:Loader;
		public var shapeSprite:Sprite;
		private var shapeCount:int = 1;

		public function shapeObj() {
			shapeLoader = new Loader();
			shapeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, shapeAdded);
			shapeLoader.load( new URLRequest("123.swf") );
		}
		
		public function shapeAdded(e:Event):void {
			shapeSprite = new Sprite();
			shapeLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, shapeAdded);
			shapeSprite.addChild(e.target.content);
			addChild(shapeSprite);

			super.addToStage(shapeSprite);

			shapeSprite.name = "shape" + shapeCount;
			
			shapeCount++;
		}

	}
	
}
