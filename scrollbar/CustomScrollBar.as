package scrollbar
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	public class CustomScrollBar extends MovieClip
	{
		private var _controlerV:MovieClip;
		private var _controlerH:MovieClip;
		
		private var _upV:MovieClip;
		private var _doV:MovieClip;
		private var _sliderV:MovieClip;
		private var _sliderBgV:MovieClip;
		
		private var _leftH:MovieClip;
		private var _rightH:MovieClip;
		private var _sliderH:MovieClip;
		private var _sliderBgH:MovieClip;
		
		private var _width:Number = 100;
		private var _height:Number = 250;
		private var _position:String = CustomScrollBarPositions.VERTICAL;
		private var _showHandCursor:Boolean = true;
		
		private var _mySkin:myScrollSkin;
		private var _currentPressedButton:MovieClip;
		private var _dragLimitV:Rectangle;
		private var _dragLimitH:Rectangle;
		private var _VminY:Number;
		private var _VmaxY:Number;
		private var _HminY:Number;
		private var _HmaxY:Number;
		private var remainingH:Number = 0;
		private var remainingW:Number = 0;
		private var scrollTimer:Timer = new Timer(10);
		
		private var _theContent_mc:Sprite;
		private var _theContentHolder_mc:MovieClip = new MovieClip();
		private var _theMask:Sprite;

		public function CustomScrollBar(theContent:Sprite)
		{
			// save the content to be scrolled
			_theContent_mc = theContent;
		}
		
		public function set speed(a:Number):void
		{
			scrollTimer.delay = a;
		}
		
		public function set w(a:Number):void
		{
			_width = a;
		}
		
		public function get w():Number
		{
			return _width;
		}
		
		public function set h(a:Number):void
		{
			_height = a;
		}
		
		public function get h():Number
		{
			return _height;
		}
		
		public function set position(a:String):void
		{
			_position = a;
		}
		
		public function get position():String
		{
			return _position;
		}
		
		public function set showHandCursor(a:Boolean):void
		{
			_showHandCursor = a;
		}
		
		public function get showHandCursor():Boolean
		{
			return _showHandCursor;
		}
		
		// THE WHOLE PROCESS ACTUALLY STARTS FROM HERE...
		public function finalize():void
		{
			// introduce the skin design
			_mySkin = new myScrollSkin();
			
			_controlerV = _mySkin.V;
			_controlerH = _mySkin.H;
			
			_upV = _mySkin.V.up_mc;
			_doV = _mySkin.V.down_mc;
			_sliderBgV = _mySkin.V.bg_mc;
			_sliderV = _mySkin.V.slider_mc;
			
			_leftH = _mySkin.H.up_mc;
			_rightH = _mySkin.H.down_mc;
			_sliderBgH = _mySkin.H.bg_mc;
			_sliderH = _mySkin.H.slider_mc;
			
			this.addChild(_mySkin);
			
			// set the buttonMode
			if(_showHandCursor){
				_sliderV.buttonMode = true;
				_doV.buttonMode = true;
				_upV.buttonMode = true;
				
				_sliderH.buttonMode = true;
				_rightH.buttonMode = true;
				_leftH.buttonMode = true;
			}
			
			// set the scrollbar's elements' positions
			setPositions();
			
			// wait till this is added to the stage then listen for events
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function addedToStageHandler(e:Event=null):void
		{
			_currentPressedButton = _sliderV;
			
			addEventListener(Event.ENTER_FRAME, contentMover);
			
			_sliderV.addEventListener(MouseEvent.MOUSE_OVER, over);
			_sliderV.addEventListener(MouseEvent.MOUSE_OUT, out);
			_sliderV.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_sliderV.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			
			_sliderH.addEventListener(MouseEvent.MOUSE_OVER, over);
			_sliderH.addEventListener(MouseEvent.MOUSE_OUT, out);
			_sliderH.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_sliderH.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			
			_doV.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_doV.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			_doV.addEventListener(MouseEvent.MOUSE_OVER, over);
			_doV.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			_upV.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_upV.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			_upV.addEventListener(MouseEvent.MOUSE_OVER, over);
			_upV.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			_rightH.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_rightH.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			_rightH.addEventListener(MouseEvent.MOUSE_OVER, over);
			_rightH.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			_leftH.addEventListener(MouseEvent.MOUSE_DOWN, pressed);
			_leftH.stage.addEventListener(MouseEvent.MOUSE_UP, released);
			_leftH.addEventListener(MouseEvent.MOUSE_OVER, over);
			_leftH.addEventListener(MouseEvent.MOUSE_OUT, out);
			
			_theContentHolder_mc.addEventListener(MouseEvent.MOUSE_WHEEL, wheely);
			//this.addChild(_theContentHolder_mc);
			
			
		}
		
		private function setPositions():void
		{
			// draw the mask
			_theMask = new Sprite();
			_theMask.graphics.beginFill(0x990000);
			_theMask.graphics.drawRect(0,0, _width, _height);
			_theMask.graphics.endFill();
			this.addChild(_theMask);
			
			// set the positions of controlers
			switch(_position){
				case CustomScrollBarPositions.VERTICAL:
					
					// hide the horizontal one
					_controlerH.visible = false;
					
					// set buttons
					setVpositions();
					
					//set max and min movement area for the slider
					setVrectangle();
					
				break;
				case CustomScrollBarPositions.HORIZONTAL:
					
					// hide the vertical one
					_controlerV.visible = false;
					
					// set buttons
					setHpositions();
					
					//set max and min movement area for the slider
					setHrectangle();
					
				break;
				case CustomScrollBarPositions.AUTO:
					
					// set buttons
					setVpositions();
					setHpositions();
					
					//set max and min movement area for the slider
					setVrectangle();
					setHrectangle();
					
				break;
			}
			
			// Now add the content and actually show it under the scrollaber
			_theContentHolder_mc.addChild(_theContent_mc);
			_theContentHolder_mc.mask = _theMask;
		}
		
		private function setVpositions(){
			_controlerV.x = _width;
			_controlerV.y = 0;
			_sliderBgV.height = _height;
			_upV.x = 0;
			_upV.y = 0;
			_doV.x = 0;
			_doV.y = _height;
			_sliderV.x = 0;
			_sliderV.y = _upV.height;
			_sliderV.scroller_main.y = 3;
		}
		
		private function setHpositions(){
			_controlerH.x = 0;
			_controlerH.y = _controlerH.height + _height;
			_sliderBgH.height = _width;
			_leftH.x = _rightH.width;
			_leftH.y = 0;
			_rightH.x = _rightH.width;
			_rightH.y = _width;
			_sliderH.x = _leftH.width;
			_sliderH.y = _leftH.width;
			_sliderH.scroller_main.y = 3;
		}
		
		private function setVrectangle():void
		{
			_VminY = _upV.height;
			_VmaxY = _doV.y - _doV.height - _upV.height - _sliderV.height + 1;
			_dragLimitV = new Rectangle(0, _VminY, 0, _VmaxY); // Set the rectangle for drag
		}
		
		private function setHrectangle():void
		{
			_HminY = _leftH.height;
			_HmaxY = _rightH.y - _rightH.height - _leftH.height - _sliderH.height + 1;
			_dragLimitH = new Rectangle(_leftH.width, _HminY, 0, _HmaxY); // Set the rectangle for drag
		}
		
		private function released(e:MouseEvent):void
		{
			if(_currentPressedButton == _sliderV || _currentPressedButton == _sliderH){
				_currentPressedButton.stopDrag();
			}
			
			if(_currentPressedButton != e.target){
				_currentPressedButton.gotoAndStop(1);
			}
			
			scrollTimer.removeEventListener(TimerEvent.TIMER, timerUp);
			scrollTimer.removeEventListener(TimerEvent.TIMER, timerDo);
			scrollTimer.removeEventListener(TimerEvent.TIMER, timerLeft);
			scrollTimer.removeEventListener(TimerEvent.TIMER, timerRight);
		}
		
		private function over(e:MouseEvent):void
		{
			if(!e.buttonDown){
				e.currentTarget.gotoAndStop(2);
			}
		}
		
		private function out(e:MouseEvent):void
		{
			if(!e.buttonDown){
				e.currentTarget.gotoAndStop(1);
			}
		}
		
		private function pressed(e:MouseEvent):void
		{
			_currentPressedButton = e.currentTarget as MovieClip;
			
			if(_currentPressedButton == _sliderV){
				
				e.currentTarget.startDrag(false, _dragLimitV);
				
			}else if(_currentPressedButton == _sliderH){
				
				e.currentTarget.startDrag(false, _dragLimitH);
				
			}else if(_currentPressedButton == _upV){
				
				scrollTimer.start();
				scrollTimer.addEventListener(TimerEvent.TIMER, timerUp);
				
			}else if(_currentPressedButton == _doV){
				
				scrollTimer.start();
				scrollTimer.addEventListener(TimerEvent.TIMER, timerDo);
				
			}else if(_currentPressedButton == _leftH){
				
				scrollTimer.start();
				scrollTimer.addEventListener(TimerEvent.TIMER, timerLeft);
				
			}else if(_currentPressedButton == _rightH){
				
				scrollTimer.start();
				scrollTimer.addEventListener(TimerEvent.TIMER, timerRight);
				
			}
		}
		
		private function timerUp(e:TimerEvent):void{
			if(_sliderV.y > _VminY){
				_sliderV.y -= 2;
			}else{
				scrollTimer.removeEventListener(TimerEvent.TIMER, timerUp);
			}
		}
		private function timerDo(e:TimerEvent):void{
			if(_sliderV.y - _upV.height < _VmaxY){
				_sliderV.y += 2;
			}else{
				scrollTimer.removeEventListener(TimerEvent.TIMER, timerDo);
			}
		}
		
		private function timerRight(e:TimerEvent):void{
			if(_sliderH.y - _rightH.height < _HmaxY){
				_sliderH.y += 2;
			}else{
				scrollTimer.removeEventListener(TimerEvent.TIMER, timerRight);
			}
		}
		
		private function timerLeft(e:TimerEvent):void{
			if(_sliderH.y > _HminY){
				_sliderH.y -= 2;
			}else{
				scrollTimer.removeEventListener(TimerEvent.TIMER, timerLeft);
			}
		}
		
		private function wheely(e:MouseEvent):void{
			if(e.delta > 0){
				if(_sliderV.y > _VminY){
					_sliderV.y -= 15;
					if(_sliderV.y < _VminY){
						_sliderV.y = _VminY;
					}
				}
			}else if(e.delta < 0){
				if(_sliderV.y - _upV.height < _VmaxY){
					_sliderV.y += 15;
					if(_sliderV.y - _upV.height > _VmaxY){
						_sliderV.y = _VmaxY + _upV.height;
					}
				}
			}
		}
		
		protected function contentMover(e:Event):void
		{
			var perCent:Number;
			var newY:Number;
			var newX:Number;
			
			// enable the button
			_theContentHolder_mc.mouseEnabled = true;
			_theContentHolder_mc.mouseChildren = true;
			_controlerV.mouseChildren = true;
			_controlerH.mouseChildren = true;
			
			// Show the Scrollbar only if its needed
			if(_position == CustomScrollBarPositions.VERTICAL && _theContentHolder_mc.height > _height){
				
				_controlerV.visible = true;
				
				perCent = ((_sliderV.y - _upV.height) / (_sliderBgV.height - _doV.height - _sliderV.height - _upV.height)) * 100;
				newY = (remainingH / 100) * perCent;
				
				_theContentHolder_mc.y = 0 + _theContentHolder_mc.y + ((-newY)-_theContentHolder_mc.y) / 5;
				remainingH = _theContentHolder_mc.height - _theMask.height;
				
			}else if(_position == CustomScrollBarPositions.HORIZONTAL && _theContentHolder_mc.width > _width){
				
				_controlerH.visible = true;
				
				perCent = ((_sliderH.y - _leftH.height) / (_sliderBgH.height - _rightH.height - _sliderH.height - _leftH.height)) * 100;
				newX = (remainingW / 100) * perCent;
				
				_theContentHolder_mc.x = 0 + _theContentHolder_mc.x + ((-newX)-_theContentHolder_mc.x) / 5;
				remainingW = _theContentHolder_mc.width - _theMask.width;
				
			}else if(_position == CustomScrollBarPositions.AUTO){
				
				if(_theContentHolder_mc.height > _height){
					
					_controlerV.visible = true;
					
					perCent = ((_sliderV.y - _upV.height) / (_sliderBgV.height - _doV.height - _sliderV.height - _upV.height)) * 100;
					newY = (remainingH / 100) * perCent;
					
					_theContentHolder_mc.y = 0 + _theContentHolder_mc.y + ((-newY)-_theContentHolder_mc.y) / 5;
					remainingH = _theContentHolder_mc.height - _theMask.height;
					
				}else {
					
					// disable the buttons
					_theContentHolder_mc.mouseEnabled = false;
					_controlerV.mouseChildren = false;
					_controlerV.visible = false;
					
				}
				
				if(_theContentHolder_mc.width > _width){
					
					_controlerH.visible = true;
					
					perCent = ((_sliderH.y - _leftH.height) / (_sliderBgH.height - _rightH.height - _sliderH.height - _leftH.height)) * 100;
					newX = (remainingW / 100) * perCent;
					
					_theContentHolder_mc.x = 0 + _theContentHolder_mc.x + ((-newX)-_theContentHolder_mc.x) / 5;
					remainingW = _theContentHolder_mc.width - _theMask.width;
					
				}else{
					
					// disable the buttons
					_theContentHolder_mc.mouseEnabled = false;
					_controlerH.mouseChildren = false;
					_controlerH.visible = false;
					
				}
				
			}else{
				
				// disable the buttons
				_theContentHolder_mc.mouseEnabled = false;
				_controlerV.mouseChildren = false;
				_controlerV.visible = false;
				_controlerH.mouseChildren = false;
				_controlerH.visible = false;
				
			}
			
			// control the slider length
			var ratioV:Number = Math.round((_theMask.height / _theContentHolder_mc.height)*100);
			var maxScrollV:Number = _sliderBgV.height - (_upV.height + _doV.height);
			_sliderV.scroller_main.height = (int)(maxScrollV * (ratioV / 100) - 6);
			_sliderV.scroller_top.height = 3;
			_sliderV.scroller_bottom.height = 3;
			_sliderV.scroller_bottom.y = _sliderV.scroller_main.y + _sliderV.scroller_main.height + 3;
			_sliderV.scroller_stripes.y = _sliderV.scroller_main.y + _sliderV.scroller_main.height / 2 - (_sliderV.scroller_stripes.height / 2) + 1;
			setVrectangle();
			
			var ratioH:Number = Math.round((_theMask.width / _theContentHolder_mc.width)*100);
			var maxScrollH:Number = _sliderBgH.height - (_leftH.height + _rightH.height);
			_sliderH.scroller_main.height = (int)(maxScrollH * (ratioH / 100) - 6);
			_sliderH.scroller_top.height = 3;
			_sliderH.scroller_bottom.height = 3;
			_sliderH.scroller_bottom.y = _sliderH.scroller_main.y + _sliderH.scroller_main.height + 3;
			_sliderH.scroller_stripes.y = _sliderH.scroller_main.y + _sliderH.scroller_main.height / 2 - (_sliderH.scroller_stripes.height / 2) + 1;
			setHrectangle();
		}
	}
}