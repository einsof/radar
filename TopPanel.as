package  {
	
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.net.URLRequest;
	
	public class TopPanel extends MovieClip {
		
		private var main:MovieClip;
		private var n:String;
		
		public var pic:pictureObj;
		public var sh:shapeObj;
		public var tx:textObj;
		
		private var imgLoader:Loader;
		private var fr:FileReference;
		private var fileFilter:FileFilter;
		
		private var shapeLoader:Loader;
		
		private var historyObject:Object = null;
		
		public function TopPanel() {
			
			main = MovieClip(this.parent);
			
			backward_b.addEventListener(MouseEvent.CLICK, historyChange);
			forward_b.addEventListener(MouseEvent.CLICK, historyChange);
			
			picture_b.addEventListener(MouseEvent.CLICK, addObject);
			shape_b.addEventListener(MouseEvent.CLICK, addObject);
			text_b.addEventListener(MouseEvent.CLICK, addObject);
			
			delete_b.addEventListener(MouseEvent.CLICK, deleteObject);
			copy_b.addEventListener(MouseEvent.CLICK, copyObject);
			

		}
		
		private function historyChange(e:MouseEvent){
			
			n = e.target.name;
			//trace(main.history.currentNumber);
			
			if(n == "backward_b"){
				if(main.history.currentNumber < 0){
					return;
				}else{
					main.history.undo();
				}
				
			}else if(n == "forward_b"){
				if(main.history.currentNumber == main.history.currentLength - 1){
					return;
				}else{
					main.history.redo();
				}
				
			}
			
			historyObject = main.history.currentStep;
			
			if(historyObject){
				main.current = historyObject.o_target;
				
				if( historyObject.o_event == 'added' || historyObject.o_event == 'moved' || historyObject.o_event == 'transformed' || historyObject.o_event == 'textchange'){
					main.deselect();
					main.applyHistory( historyObject.o_target, historyObject.o_type, historyObject.o_layer, historyObject.o_matrix, historyObject.o_text );
					
					
				}else if( historyObject.o_event == 'deleted' ){
					
					main.deleteFromStage(); // удаляем удалённый пользователем (а не по истории) обьект 
					
				}
				
				if(main.history.currentNumber == main.history.currentLength - 1){
					trace("Это самый конец - значит деактивируем кнопку 'вперёд'");
				}

			}else{
				
				main.deleteFromStage();
				
				if(main.history.currentNumber == -1){
					trace("Это самое начало - значит деактивируем кнопку 'назад'");
				}
				
			}
			
			
			
			
		}
		
		private function addObject(e:MouseEvent){
			
			n = e.target.name;		
			
			// here we add class instances, not objects (objects adds at Objects.as)
			if(n == "picture_b"){
				
				fr = new FileReference();
				fr.addEventListener(Event.SELECT, onFileSelected);
				fileFilter = new FileFilter("JPG/PNG/GIF Files","*.jpeg; *.jpg; *.gif; *.png");
				fr.browse([fileFilter]);
				
			}else if(n == "shape_b"){
				
				sh = new shapeObj("123.swf");
				addChild(sh);
				
				/*shapeLoader = new Loader();
				shapeLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, shapeAdded);
				shapeLoader.load( new URLRequest("123.swf") );*/
				
			}else if(n == "text_b"){
				
				tx = new textObj("введите текст");
				addChild(tx);
			}
			
		}
		
		
		// --------------------- picture select functions ---------------------------//
		
		private function onFileSelected(e:Event):void{
			fr.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fr.addEventListener(ProgressEvent.PROGRESS, onProgress);
			fr.addEventListener(Event.COMPLETE, onFileLoaded);
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
		
		private function onFileLoaded(e:Event):void{
			
			var fileReference:FileReference = e.target as FileReference;
			var data:ByteArray = fileReference["data"];
			
			imgLoader = new Loader();
			imgLoader.loadBytes(data);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, photoAdded);

			fr.removeEventListener(Event.COMPLETE, onFileLoaded);
			fr.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fr.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			
		}
		
		private function onFileLoadError(e:Event):void{
			fr.removeEventListener(Event.COMPLETE, onFileLoaded);
			fr.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			fr.removeEventListener(ProgressEvent.PROGRESS, onProgress);
			trace("File load error");
		}
		
		private function onProgress(e:ProgressEvent):void{
			var percentLoaded:Number = e.bytesLoaded/e.bytesTotal*100;
			trace("loaded: "+percentLoaded+"%");
		}
		
		private function photoAdded(e:Event):void{
			
			imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, photoAdded);
			pic = new pictureObj(e.target.content.bitmapData);
			addChild(pic);
		}
		
		
		// --------------------- end picture select functions -----------------------//
		
		// ---------------------------------- *** -----------------------------------//
		
		// ------------------------ shape select functions --------------------------//
		
		
		/*public function shapeAdded(e:Event):void {
			
			var loader:Loader = Loader(e.target.loader);
            var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
			trace(e.target.content);
			
			shapeLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, shapeAdded);
			
			sh = new shapeObj(e.target.content);
			addChild(sh);
			
		}*/
		
		// ---------------------- end shape select functions ------------------------//

		
		
		private function deleteObject(e:MouseEvent):void{
			main.deleteObj();
		}
		
		private function copyObject(e:MouseEvent):void{
			main.copyObj();
		}
		
	}
	
}
