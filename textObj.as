package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;	
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.TextFieldType;
	
	public class textObj extends Objects {
		
		public var t:TextField;
		public var textSprite:Sprite;
		private var textCount:int = 1;

		public function textObj() {
			
			if (stage) textAdded();
			else addEventListener(Event.ADDED_TO_STAGE, textAdded);

		}
		
		private function textAdded(e:Event = null):void{
			
            var d_format:TextFormat = new TextFormat();
            d_format.font = "Verdana";
            d_format.color = 0x999999;
            d_format.size = 24;
			
			t = new TextField();
            t.autoSize = TextFieldAutoSize.LEFT;
			t.type = TextFieldType.INPUT;
			t.multiline = false;
            t.defaultTextFormat = d_format;
			t.text = "Введите текст";
			addChild(t);
			
			super.addToStage(t);

			t.name = "text" + textCount;
			textCount++;
			
			t.addEventListener(TextEvent.TEXT_INPUT, inputStart);
			//addEventListener(FocusEvent.FOCUS_IN, focusIsIn);

		}
		
		private function inputStart(e:TextEvent):void{
			
			MovieClip(parent.parent).tool.fitToTarget();
			
		}
		
		private function focusIsIn(e:FocusEvent):void{
			
			trace(e.target, e.target.getChildAt(0))
			
			e.target.removeEventListener(FocusEvent.FOCUS_IN, focusIsIn);
			e.target.addEventListener(TextEvent.TEXT_INPUT, inputStart);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, MovieClip(parent).tool.deselect);

			if(e.target.text == "Введите текст"){
				e.target.text = "";
			}

			
			e.target.addEventListener(FocusEvent.FOCUS_OUT, focusIsOut);
			
			
		}
			
		private function focusIsOut(e:FocusEvent){
			
			e.target.removeEventListener(FocusEvent.FOCUS_OUT, focusIsOut);
			MovieClip(parent).tool.deselect;
			
			if(e.target.text == ""){
				e.target.text = "Введите текст";
			}
			
			e.target.addEventListener(FocusEvent.FOCUS_IN, focusIsIn);
		}

	}
	
}
