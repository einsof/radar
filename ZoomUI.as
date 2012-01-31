package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import fl.events.SliderEvent;
	import fl.controls.Slider;
	
	public class ZoomUI extends MovieClip {
		
		private var currentPercent:int = 100;	
		private var newPercent:int;
		
		public function ZoomUI() {
			if(stage){
				init(null);
				
			}else{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
			
		}
		
		private function init(e:Event){
			slider.enabled = false;
			slider.liveDragging = true;
			slider.minimum = 5;
			slider.maximum = 100;
			slider.snapInterval = 0;
			slider.tickInterval = 50;
			slider.addEventListener(SliderEvent.CHANGE, valueChanged);
			
			plusButton.addEventListener(MouseEvent.CLICK, clickZoomButtons);
			minusButton.addEventListener(MouseEvent.CLICK, clickZoomButtons);
			
		}
		
		private function valueChanged(e:SliderEvent):void{
			currentPercent = numberToPercent(e.value);
			zoom(currentPercent);
			
		}
		
		private function clickZoomButtons(e:MouseEvent):void{
			newPercent = currentPercent;
			
			switch(e.target.name){
				case "plusButton":
						newPercent = (newPercent % 5 != 0) ? Math.ceil(newPercent/10)*10 : newPercent + 10;
					break;
				case "minusButton":
						if(newPercent >= 20){
							newPercent = (newPercent % 5 != 0) ? Math.floor(newPercent/10)*10 : newPercent - 10;
						}
					break;
			}
			
			slider.value = percentToNumber(newPercent);
			
		}
		
		// и тут таки зумим
		private function zoom(percent:int):void{
			var mainStage:MovieClip = MovieClip(this.parent.parent);
			mainStage.zoomContent(roundTofixed(percent*0.01, 1));
			//trace("Zooming in " + percent + " %. ScaleX = " + roundTofixed(percent*0.01, 1) + "; ScaleY = " + roundTofixed(percent*0.01, 1));
			zoomLabel.text = percent + " %"
		}
		
		// округляет до знака после запятой
		private function roundTofixed(num:Number, n:int):Number {
			var m = Math.pow(10,n);
			return Math.round(num*m)/m;
		}
		
		// переводит числа в проценты
		private function numberToPercent(num:Number):int{
			if(num <= 50){
				return num*2;
			}else{
				return 100 + (num-50)*8;
			}
		}
		
		// переводит проценты в числа
		private function percentToNumber(num:int):Number{
			if(num <= 100){
				return num/2;
			}else{
				return (num-100)/8 + 50;
			}
		}
		
	}
	
}
