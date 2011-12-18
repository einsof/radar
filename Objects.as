package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class Objects extends MovieClip {

		public function Objects() {

		}
		
		public function addToStage(obj:DisplayObject):void{

				obj.addEventListener(MouseEvent.MOUSE_DOWN, MovieClip(parent.parent).selectFunction);
				obj.x = (stage.stageWidth - obj.width)/2;
				obj.y = (stage.stageHeight - obj.height)/2;
				MovieClip(parent.parent).tool.setTarget(obj);

		}

	}
	
}
