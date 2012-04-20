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
	import flash.geom.Matrix;
	
	public class textObj extends Objects {
		
		public var t:TextField;
		public var textSprite:Sprite;
		private var _textString:String;
		private var _clone:Boolean;
		private var matrix:Matrix;

		public function textObj(t:String, clone:Boolean = false) {
			_textString = t;
			_clone = clone;
			if (stage) textAdded();
			else addEventListener(Event.ADDED_TO_STAGE, textAdded);

		}
		
		private function textAdded(e:Event = null):void{
			
            var d_format:TextFormat = new TextFormat();
            d_format.font = new Helvetica().fontName;
            d_format.color = 0x999999;
            d_format.size = 26;
			
			textSprite = new Sprite();

			t = new TextField();
            t.autoSize = TextFieldAutoSize.LEFT;
			t.type = TextFieldType.INPUT;
			t.embedFonts = true;
			t.multiline = false;
            t.defaultTextFormat = d_format;
			t.text = _textString;
			t.selectable = true;
			//t.doubleClickEnabled = true;
			
			//textSprite.addChild(t);
			textSprite.mouseChildren = false;
			//addChild(textSprite);
			super.addToStage(t, _clone);
			
			t.addEventListener(Event.CHANGE, inputHandler);
			//t.addEventListener(MouseEvent.DOUBLE_CLICK, inputEnable);
			//t.addEventListener(MouseEvent.CLICK, selectTextInput);
			//t.addEventListener(TextEvent.TEXT_INPUT, focusIsIn);
		}
		
		private function inputHandler(e:Event):void{
			t.width += 20;
			MovieClip(this.root).manager.update();
			MovieClip(this.root).storeToHistory('textchange');
		}
		
		/*private function inputStart(e:TextEvent):void{
			trace(this.root, MovieClip(this.root).manager);
			MovieClip(this.root).manager.update();
			trace("inputStart");
		}*/
		
		private function inputEnable(e:MouseEvent):void{
			//trace("doubleclick!");
			// MovieClip(parent.parent).contentBg.tool.fitToTarget();
			//t.selectable = true;
			//t.setSelection(0, 0);
			//t.addEventListener(TextEvent.TEXT_INPUT, inputStart);
			
			
		}
		
		private function focusIsIn(e:TextEvent):void{
			
			trace(e.target);
			
			//e.target.removeEventListener(FocusEvent.FOCUS_IN, focusIsIn);
			//e.target.addEventListener(TextEvent.TEXT_INPUT, inputStart);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, MovieClip(parent.parent).tool.deselect);

			if(e.target.text == "Введите текст"){
				e.target.text = "";
			}

			
			e.target.addEventListener(FocusEvent.FOCUS_OUT, focusIsOut);
			
			
		}
			
		private function focusIsOut(e:FocusEvent){
			
			e.target.removeEventListener(FocusEvent.FOCUS_OUT, focusIsOut);
			//MovieClip(parent).tool.deselect;
			
			if(e.target.text == ""){
				e.target.text = "Введите текст";
			}
			
			e.target.addEventListener(FocusEvent.FOCUS_IN, focusIsIn);
		}

	}
	
}
