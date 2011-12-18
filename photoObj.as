package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class photoObj extends Objects {
		
		private var imgLoader:Loader;
		public var imageSprite:Sprite;
		private var imgCount:int = 1;

		public function photoObj() {
			imgLoader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, photoAdded);
			imgLoader.load( new URLRequest("test.jpg") );
		}
		
		private function photoAdded(e:Event):void{
			
			imageSprite = new Sprite();
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, photoAdded);
			imageSprite.addChild(e.target.content);
			addChild(imageSprite);
			
			super.addToStage(imageSprite);
			imageSprite.name = "img" + imgCount;
			
			imgCount++;
		}

	}
	
}
