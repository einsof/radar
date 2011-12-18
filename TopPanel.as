package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import fl.controls.Button;
	
	
	public class TopPanel extends MovieClip {
		
		private var n:String;
		
		public var ph:photoObj;
		public var sh:shapeObj;
		public var tx:textObj;
		
		public function TopPanel() {
			
			photo_b.addEventListener(MouseEvent.CLICK, addObject);
			shape_b.addEventListener(MouseEvent.CLICK, addObject);
			text_b.addEventListener(MouseEvent.CLICK, addObject);

		}
		
		private function addObject(e:MouseEvent){
			
			n = e.target.name;
			
			if(n == "photo_b"){
				ph = new photoObj();
				addChild(ph);
			}else if(n == "shape_b"){
				sh = new shapeObj();
				addChild(sh);
			}else if(n == "text_b"){
				tx = new textObj();
				addChild(tx);
			}
			
			
			
			
		}
		
	}
	
}
