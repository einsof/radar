package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	//import com.greensock.*;
	//import com.greensock.easing.*;
	
	
	public class Main extends MovieClip {
		
		public var topPanel:TopPanel;
		public var sideBar:SideBar;
		public var bottomPanel:BottomPanel;
		public var scrollStage:ScrollStage;
		public var aSp:ZoomScrollPane;
		public var contentBg:ScrollStage;
		public var currentZoom:Number = 1;
		
		
		// ------ TODO: разобраться с фокусом текстов, удалять объекты, менять точки регистрации ------ //
		
		public function Main() {
			if (stage) createInterface();
			else addEventListener(Event.ADDED_TO_STAGE, createInterface);
			stage.scaleMode= StageScaleMode.NO_SCALE;
			stage.align= StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
		}
		
		private function createInterface(e:Event = null){
			
			aSp = new ZoomScrollPane(); 
			aSp.source = contentBg;
			aSp.setSize(contentBg.width, contentBg.height); 
			aSp.move(side.width, top.height);
			addChild(aSp);

			contentBg.drawDocument(400, 300);
			contentBg.addTool();
		}
		
		public function zoomContent(num:Number):void{
			
			currentZoom = num;
			
			if(contentBg == null){ return; }
			
			contentBg.paper.scaleX = num;
			contentBg.paper.scaleY = num;
			contentBg.maskLayer.scaleX = num;
			contentBg.maskLayer.scaleY = num;
			if(contentBg.paper.width + 1 < contentBg.bg.width){
				contentBg.paper.x = (int)(contentBg.bg.width/2 - contentBg.paper.width/2);
				contentBg.maskLayer.x = (int)(contentBg.bg.width/2 - contentBg.maskLayer.width/2);
			}
			
			if(contentBg.paper.height + 1 < contentBg.bg.height){
				
				contentBg.paper.y = (int)(contentBg.bg.height/2 - contentBg.paper.height/2);
				contentBg.maskLayer.y = (int)(contentBg.bg.height/2 - contentBg.paper.height/2);
			}
			
			aSp.update();
			
		}
		
		public function deleteObj(obj:DisplayObject):void{
			
			removeChild(obj);
			
		}

		
	}
	
}
