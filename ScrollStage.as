package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import fl.containers.ScrollPane; 
	import fl.controls.ScrollPolicy;  
	//import com.pcthomatos.utilities.SpriteRegPoint;
	import flash.text.TextField;
	import com.senocular.display.transform.*;
	
	public class ScrollStage extends MovieClip {
		
		private var stageWidth:int;
		private var stageHeight:int;
		private var bottomSquare:Sprite;
		public var doc:MovieClip;
		public var paper:Sprite;
		public var maskLayer:Sprite;
		private var dropShadow:DropShadowFilter;
		private var padding:int = 100;
		public var paperSprite:Sprite;
		public var tool:TransformTool;
		public var rm:RegistrationManager;
		public var current:DisplayObject;

		public function ScrollStage() {
			if(stage){
				drawBg(null);
				
			}else{
				addEventListener(Event.ADDED_TO_STAGE, drawBg);
			}
		}
		
		private function drawBg(e:Event) {		
			
			addEventListener(MouseEvent.MOUSE_DOWN, deselect);
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
		
		public function addTool():void{

			rm = new RegistrationManager();
			rm.defaultUV = new Point(0.5,0.5);
			rm.enabled = false;
			tool = new TransformTool(new ControlSetEinsof, rm);
			tool.negativeScaling = false;
			tool.restrictRotation();
			
			tool.autoRaise = true;
			paper.addChild(tool);			
		}
		
		public function selectFunction(e:MouseEvent):void{
		
			if(e.target is TextField){
				trace("3 - " + e.target, e.target.name);
			}else if(e.target.numChildren){
				trace("1 - " + e.target.getChildAt(0), e.target, e.target.name);
			}else {
				trace("2 - " + e.target, e.target.name);
			};
			
			
			tool.target = e.target as DisplayObject;
			tool.select(e);
			current = tool.target;
			//tool.fitToTarget();
		}
		
		public function deselect(e:MouseEvent):void{
			if((e.target is MovieClip)){
				tool.setTarget(null, null);
				stage.focus = bg;
			}
			
		}

	}
	
}
