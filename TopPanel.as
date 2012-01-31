package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	//import fl.controls.Button;
	
	
	public class TopPanel extends MovieClip {
		
		private var n:String;
		
		public var pic:pictureObj;
		public var sh:shapeObj;
		public var tx:textObj;
		public var scale:Number = 1;
		
		public function TopPanel() {
			
			picture_b.addEventListener(MouseEvent.CLICK, addObject);
			shape_b.addEventListener(MouseEvent.CLICK, addObject);
			text_b.addEventListener(MouseEvent.CLICK, addObject);
			

		}
		
		private function addObject(e:MouseEvent){
			
			n = e.target.name;
			var paper = MovieClip(parent).contentBg.paper;		
			
			if(n == "picture_b"){
				pic = new pictureObj();
				addChild(pic);
			}else if(n == "shape_b"){
				sh = new shapeObj();
				addChild(sh);
			}else if(n == "text_b"){
				tx = new textObj();
				addChild(tx);
			}
			
		}
/*		
		public function set zoom(e:MouseEvent){
			
			
			
		}*/
		
		
		
		
	}
	
}
