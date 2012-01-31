package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class Objects extends MovieClip {
		
		private var maxWidth:int;
		private var maxHeight:int;
		private static var padding:int = 20; // padding
		private var r:Number; //ratio
		private var paper:MovieClip;
		private var now:Date = new Date();


		public function Objects() {

		}
		
		public function addToStage(obj:DisplayObject):void{
			
			paper = MovieClip(parent.parent).contentBg.paper;
				
				if(obj is Sprite){ // if object is picture
				
					maxWidth = paper.width - padding*2;
					maxHeight = paper.height - padding*2;
				
					if(obj.width > maxWidth || obj.height > maxHeight){
						resizeMe(obj, maxWidth, maxHeight);
					}
					
					obj.name = "image_" + now.getHours() + "." + now.getMinutes() + "." + (now.getSeconds() >= 10 ? now.getSeconds() : "0" + now.getSeconds());
				}
				
				obj.addEventListener(MouseEvent.MOUSE_DOWN, MovieClip(parent.parent).contentBg.selectFunction);
				obj.x = ( paper.width - obj.width)*.5;
				obj.y = ( paper.height - obj.height)*.5;
				
				paper.addChild(obj);

				MovieClip(parent.parent).contentBg.tool.setTarget(obj);
				//MovieClip(parent.parent).tool.fitToTarget();

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
