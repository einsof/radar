package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import uk.soulwire.utils.display.Alignment;
	import uk.soulwire.utils.display.DisplayUtils;
	import flash.display.PixelSnapping;	
	import flash.display.Bitmap;	
	import flash.display.BitmapData;	 
	import flash.geom.Rectangle;	

	
	public class pictureObj extends Objects {
		
		private var imgLoader:Loader;
		public var imageSprite:Sprite;
		private var fr:FileReference;
		private var fileFilter:FileFilter;

		public function pictureObj() {
			fr = new FileReference();
			fr.addEventListener(Event.SELECT, onFileSelected);
			fileFilter = new FileFilter("JPG/PNG/GIF Files","*.jpeg; *.jpg; *.gif; *.png");
			fr.browse([fileFilter]);
		}
		
		private function onFileSelected(e:Event){

			// This callback will be called if there's error during uploading
			fr.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);

			// Optional callback to track progress of uploading
			fr.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			// This callback will be called when the file is uploaded and ready to use
			fr.addEventListener(Event.COMPLETE, onFileLoaded);

			// Tells the FileReference to load the file
			fr.load();

			if (fr.size > 8388608){
				// 10 MB - 10 485 760 byte; 10 Mb - 1 310 720 byte;
				// 8MB - 8 388 608 byte;
				trace("File is up to 10 MB");
				fr.cancel();
				trace("Uploading canceled!");
			} else {
				trace("Picture size: " + fr.size);
			}
		}
		
		private function onFileLoaded(e:Event){
			
			var fileReference:FileReference = e.target as FileReference;
			var data:ByteArray = fileReference["data"];
			
			trace("File loaded");
			
			imgLoader = new Loader();
			imgLoader.loadBytes(data);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, photoAdded);
			
			fr.removeEventListener(Event.COMPLETE, onFileLoaded);
			fr.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fr.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			
		}
		
		private function onFileLoadError(e:Event){
			fr.removeEventListener(Event.COMPLETE, onFileLoaded);
			fr.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fr.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			trace("File load error");
		}
		
		private function onProgress(e:ProgressEvent){
			
			var percentLoaded:Number = e.bytesLoaded/e.bytesTotal*100;
			trace("loaded: "+percentLoaded+"%");
		}
		
		private function photoAdded(e:Event):void{
			
			imageSprite = new Sprite();
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, photoAdded);

			imageSprite.addChild(e.target.content);
			super.addToStage(imageSprite);
		}
		

		

	}
	
}
