package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.StageAlign;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.net.URLRequest;
	import com.senocular.display.transform.*;
	
	
	public class Main extends MovieClip {
		
		public var bg:Sprite;
		public var topPanel:TopPanel;
		public var tool:TransformTool;
		public var rm:RegistrationManager;
		
		
		// ------ TODO: грузить фото, использовать внешний класс для загрузки текстов ------ //
		// ------ разобраться с фокусом текстов, удалять объекты, менять точки регистрации ------ //
		// ------ панель функций, zoom ------ //
		
		public function Main() {
			if (stage) createInterface();
			else addEventListener(Event.ADDED_TO_STAGE, createInterface);
			stage.scaleMode= StageScaleMode.NO_SCALE;
			stage.align= StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
			
		}
		
		private function createInterface(e:Event = null){
			addBg();
			addTopPanel();
			addTool();
		}
		
		private function addTopPanel():void{
			topPanel = new TopPanel();
			addChild(topPanel);
		}
		
		private function addTool():void{
			
			rm = new RegistrationManager();
			rm.defaultUV = new Point(0.5,0.5);
			rm.enabled = false;
			tool = new TransformTool(new ControlSetEinsof, rm);
			tool.negativeScaling = false;
			tool.restrictRotation();
			
			//tool.autoRaise = true;
			addChild(tool);
			
		}
		
		public function selectFunction(e:MouseEvent):void{
		
			//trace(e.target.name, e.target.x, e.target.y, e.target.width, e.target.height, e.target.rotation, e.target.alpha);
		
			if(e.target is TextField){
				trace("3 - " + e.target, e.target.name);
			}else if(e.target.numChildren){
				trace("1 - " + e.target.getChildAt(0), e.target.name);
			}else {
				trace("2 - " + e.target, e.target.name);
			};
		
			/*if(e.target.numChildren){
				trace("1 :" + e.target.name, e.target.getChildAt(0));
			}else{
				trace("2 :" + e.target.name, e.target);
			}*/
		
			
			tool.target = e.target as DisplayObject;
			tool.select(e);
		}
		
		public function addBg():void{
			
			bg = new Sprite();
			bg.graphics.beginFill(0xffffff);
			bg.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			bg.graphics.endFill();
			addChildAt(bg,0);

			bg.addEventListener(MouseEvent.MOUSE_DOWN, deselect);
			
		}
		
		public function deselect(e:MouseEvent):void{
			
			tool.setTarget(null, null);
			stage.focus = bg;
			
		}

		
	}
	
}
