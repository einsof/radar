package  {
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import fl.managers.StyleManager;
	import fl.containers.ScrollPane;
	import fl.core.InvalidationType;
	import fl.controls.UIScrollBar;
	import fl.data.DataProvider;
	
	
	public class ZoomScrollPane extends ScrollPane {
		
		
		public function ZoomScrollPane() {
			StyleManager.setStyle("scrollBarWidth",21);
			StyleManager.setStyle("scrollArrowHeight",21);
			//StyleManager.setComponentStyle(TileList,"scrollArrowHeight",25);
		}
		
		override protected function drawLayout():void {
			super.drawLayout();
			MovieClip(parent).coner_rect.visible = (vScrollBar || hScrollBar) ? true : false;
		}
		
		
	}
	
}
