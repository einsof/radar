package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class shapeObj extends Objects {
		
		private var shapeLoader:Loader;
		public var shapeSprite:Sprite;
		private var _shapeUrl:String;
		private var _clone:Boolean;

		public function shapeObj(u:String, clone:Boolean = false) {
			_shapeUrl = u;
			_clone = clone;
			if (stage) loadShape();
			else addEventListener(Event.ADDED_TO_STAGE, loadShape);
		}
		
		private function loadShape(e:Event = null) {		
			shapeLoader = new Loader();
			shapeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, shapeAdded);
			shapeLoader.load( new URLRequest(_shapeUrl) );
		}
		
		private function shapeAdded(e:Event):void {
			shapeSprite = new Sprite();
			shapeLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, shapeAdded);
			shapeSprite.addChild(e.target.content);
			
			addChild(shapeSprite);
			shapeSprite.name = _shapeUrl;
			super.addToStage(shapeSprite, _clone);
			
		}
		
		

	}
	
}
