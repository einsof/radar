package  {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	import fl.events.InteractionInputType;
	
	public class ZoomSlider extends Slider {
		
		public function ZoomSlider() {
			super();
        	thumb.setSize(12, 18);
        	track.setSize(100, 6);
		}
		
		override protected function drawTicks():void {
			clearTicks();
			tickContainer = new Sprite();
			var divisor:Number = (maximum<1)?tickInterval/100:tickInterval;
			var l:Number = (maximum-minimum)/divisor;
			var dist:Number = _width/l;
			for (var i:uint=1;i<=l;i++) {
				var tick:DisplayObject = getDisplayObjectInstance(getStyleValue("tickSkin"));
				tick.x = (Math.round(dist/10)*10) * i;
				tick.y = (track.y - tick.height) + 5;
				tickContainer.addChild(tick);
			}
			addChildAt(tickContainer, 0);
		}
		
		override protected function doSetValue(val:Number, interactionType:String=null, clickTarget:String=null, keyCode:int=undefined):void {
			var oldVal:Number = _value;
			if (_snapInterval != 0 && _snapInterval != 1) { 
				var pow:Number = Math.pow(10, getPrecision(snapInterval));
				var snap:Number = _snapInterval * pow;
				var rounded:Number = Math.round(val * pow);
				var snapped:Number = Math.round(rounded / snap) * snap;
				var val:Number = snapped / pow;
				_value = Math.max(minimum, Math.min(maximum,val));
			} else {
				
				if(liveDragging && clickTarget != null){
					_value = (val> 45 && val < 55) ? 50 : Math.max(minimum, Math.min(maximum,val));
				}else{
					_value = Math.max(minimum, Math.min(maximum,val));
				}
			}
			if (oldVal != _value || interactionType == InteractionInputType.KEYBOARD) {
				dispatchEvent(new SliderEvent(SliderEvent.CHANGE, value, clickTarget, interactionType, keyCode));
			}
			
			positionThumb();
		}
		
		
		
	}
	
}
