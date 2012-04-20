package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextLineMetrics;
	import flash.events.MouseEvent;
	//import flash.geom.Matrix;
	//import flash.events.KeyboardEvent;
	//import flash.ui.Keyboard;
	
	public class Objects extends MovieClip {
		
		private var main:MovieClip;
		private var maxWidth:int;
		private var maxHeight:int;
		private static var padding:int = 20; // padding
		private var r:Number; //ratio
		private var paper:MovieClip;
		private var now:Date = new Date();
		private var linemetrics:TextLineMetrics;
		private var _isClone:Boolean;
		private var _obj:DisplayObject;
		private var _objType:String;
		//private var matrix:Matrix;
		private var nowString:String;

		public function Objects() {

		}
		
		public function addToStage(obj:DisplayObject, isClone:Boolean = false):void{
			

			this._obj = obj;
			_isClone = isClone;
			
			// links
			main = MovieClip(parent.parent);
			paper = main.contentBg.paper;
			
			// deactivate active object
			if(main.isActive){
				main.manager.deactivate();
				stage.focus = main.contentBg.bg;
			}
			
			// date for objects name
			nowString = "" + now.getHours() + "." + now.getMinutes() + "." + (now.getSeconds() >= 10 ? now.getSeconds() : "0" + now.getSeconds());


			if(obj is TextField){ // if object is text
				
				_objType = "TextField";
				obj.name = "text_";
				
			}else if(Sprite(obj).getChildAt(0) is Bitmap){ // if object is picture
				
				_objType = "Bitmap";
				obj.name = "image_";
				
				maxWidth = paper.width - padding*2;
				maxHeight = paper.height - padding*2;
				if(obj.width > maxWidth || obj.height > maxHeight) resizeMe(obj, maxWidth, maxHeight);
			
			}else if(Sprite(obj).getChildAt(0) is MovieClip){ // if object is shape
				
				_objType = "Shape";
				obj.name = "shape_" + obj.name + "_";
				
			}
			
			obj.name += nowString;
			
			trace(obj.name + " was added");

			paper.addChild(obj);
			main.initChild(obj);

			if(!_isClone){
				obj.x = (paper.width - obj.width)*.5;
				obj.y = (paper.height - obj.height)*.5;
			}

			main.activateOne(obj, _objType);
			
			if(_isClone) main.setCopyMatrix();
			
			main.storeToHistory( "added" );

		}

		
/*		private function resizeMe(mc:DisplayObject, maxW:int, maxH:int=0, constrainProportions:Boolean = true):void{
			trace(mc.scaleX, mc.scaleY);
			maxH = maxH == 0 ? maxW : maxH;
			mc.width = maxW;
			mc.height = maxH;
			trace(mc.scaleX, mc.scaleY);
			if (constrainProportions) {
				mc.scaleX < mc.scaleY ? mc.scaleY = mc.scaleX : mc.scaleX = mc.scaleY;
			}
		}*/
		
		private function resizeMe(mc:DisplayObject, maxW:int, maxH:int):void{
			
			r = mc.height / mc.width; //calculation ratio
			
			if (mc.width > maxW) {
				mc.width = maxW;
				mc.height = Math.round(mc.width * r);
			}
			if (mc.height > maxH) {
				mc.height = maxH;
				mc.width = Math.round(mc.height / r);
			}
		}
		
		
		
	}
	
}
