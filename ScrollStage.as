package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	public class ScrollStage extends MovieClip {
		
		public var paper:MovieClip;
		public var maskLayer:MovieClip;
		private var dropShadow:DropShadowFilter;

		public function ScrollStage() {
			
		}
		
		public function drawDocument(docW:int, docH:int) {

			paper = new MovieClip();
			paper.graphics.beginFill(0xffffff);
			//paper.graphics.lineStyle(6, 0xFF0000);
			paper.graphics.drawRect(0, 0, docW, docH);
			paper.graphics.endFill();
			paper.x = bg.width/2 - docW/2;
			paper.y = bg.height/2 - docH/2;
			
			bg.addChild(paper);
			
			dropShadow = new DropShadowFilter(0, 45, 0, 0.2, 8, 8);
			paper.filters = [dropShadow];
			
			maskLayer = new MovieClip();
			maskLayer.graphics.beginFill(0x000000, 0);
			maskLayer.graphics.drawRect(0, 0, docW, docH);
			maskLayer.graphics.endFill();
			maskLayer.x = bg.width/2 - docW/2;
			maskLayer.y = bg.height/2 - docH/2;
			
			bg.addChild(maskLayer);
			paper.mask = maskLayer;
			//maskLayer.alpha = 0.1;
		}
		
		
		
		
		
		

	}
	
}
