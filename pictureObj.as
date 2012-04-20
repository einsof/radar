package  {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.Bitmap;	
	import flash.display.BitmapData;
	
	public class pictureObj extends Objects {
		
		public var imageSprite:Sprite;
		private var _b:BitmapData;
		private var _clone:Boolean;

		public function pictureObj(b:BitmapData, clone:Boolean = false) {
			_b = b;
			_clone = clone;
			
			if (stage) setData();
			else addEventListener(Event.ADDED_TO_STAGE, setData);
		}
		
		private function setData(e:Event = null):void{
			
			imageSprite = new Sprite();
			imageSprite.addChild(new Bitmap(_b));
			super.addToStage(imageSprite, _clone);
			
		}

	}
	
}
