package  {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.display.StageAlign;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.FocusEvent;
	import flash.events.EventPhase;
	import flash.ui.Keyboard;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.utils.*;
	import flash.geom.Rectangle;
	import flash.system.Capabilities; // version check for scale9Grid bug
	//import com.greensock.*;
	//import com.greensock.easing.*;
	
	import com.segfaultlabs.ui.Mouse;
	import com.segfaultlabs.events.TransformEvent;
	import com.segfaultlabs.transform.TransformMode;
	import com.segfaultlabs.transform.SingleTransformer;
	import com.segfaultlabs.transform.MultipleTransformer;	
	import com.segfaultlabs.transform.TransformManager;
	
	import com.abrahamyan.util.CursorManager;
	
	public class Main extends MovieClip {
		
		public var topPanel:TopPanel;
		public var sideBar:SideBar;
		public var bottomPanel:BottomPanel;
		public var scrollStage:ScrollStage;
		public var aSp:ZoomScrollPane;
		public var contentBg:ScrollStage;
		public var currentZoom:Number = 1;
		private var zoomXmove:int;
		private var zoomYmove:int;
		
		private var _isActive:Boolean = false;
		private var _current:DisplayObject;
		private var _currentType:String;
		private var _currentChild:DisplayObject;
		private var _currentMatrixChange:Sprite;
		private var _copyString:String;
		private var applyMatrix:Matrix;
		
		public var manager : TransformManager;
		public var singleTransformer : SingleTransformer;
		public var multipleTransformer : MultipleTransformer;
		
		private var scaleCursor : MovieClip = new CursorScale();
		private var rotationCursor : MovieClip = new CursorRotation();
		private var moveCursor : MovieClip = new CursorMove();
		
		private var isDrag:Boolean = false;
		
		private var offsetX:Number;
		private var offsetY:Number;
		
		public var history : HistoryManager;
		
		
		// ------ TODO: допилить курсоры, грузить картинки через сервер, сделать панельки для картинок и для шейпов, разобраться с фокусом текстов ------ //
		
		public function Main() {
			if (stage) createInterface();
			else addEventListener(Event.ADDED_TO_STAGE, createInterface);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.stageFocusRect = false;
		}
		
		private function createInterface(e:Event = null){
			
			aSp = new ZoomScrollPane(); 
			aSp.source = contentBg;
			aSp.setSize(contentBg.width, contentBg.height); 
			aSp.move(side.width, top.height);
			addChild(aSp);

			contentBg.drawDocument(400, 300);
			
			//initialize mouse
			Mouse.initialize( stage );
			addEventListener(MouseEvent.MOUSE_DOWN, deselect);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			
			//setup transform manager buttons
			TransformManager.centerIcon = loaderInfo.applicationDomain.getDefinition("tmCenterBtn") as Class;
			TransformManager.dotIcon = loaderInfo.applicationDomain.getDefinition("tmBtn") as Class;
			
			manager = new TransformManager();
			manager.blendMode = BlendMode.NORMAL;
			manager.addEventListener( TransformEvent.TRANSFORM_CURSOR, transformCursorHandler );
			manager.addEventListener( TransformEvent.TRANSFORM_COMMIT, transformCursorHandler );
			
			multipleTransformer = new MultipleTransformer(null);
			singleTransformer = new SingleTransformer(null);

			CursorManager.init(stage);
			
			history = HistoryManager.getInstance;
			
		}
		
		/*
		* Adding cursors on mouseover
		*/
		
		protected function transformCursorHandler( evt:TransformEvent ):void {

			CursorManager.removeCursor();
			
			if ( evt.type == TransformEvent.TRANSFORM_CURSOR )
			trace(manager.curButton, manager.cursorAngle, manager.RotationX);
			
			
			switch ( evt.mode ) {
				case TransformMode.MODE_SCALE:
						switch(manager.curButton){
							case "btn0":
							case "btn2":
									
									scaleCursor.gotoAndStop(1);
									CursorManager.setCursor(scaleCursor, 0, 0, manager.RotationX);
									//trace("right cursor");
									break;
							case "btn1":
							case "btn3":
									scaleCursor.gotoAndStop(2);
									CursorManager.setCursor(scaleCursor, 0, 0, manager.RotationX);
									//trace("left cursor");
									break;
						}
					break;
				case TransformMode.MODE_SCALEX:
						scaleCursor.gotoAndStop(3);
						CursorManager.setCursor(scaleCursor, 0, 0, manager.RotationX);
					break;
				case TransformMode.MODE_SCALEY:
						scaleCursor.gotoAndStop(4);
						CursorManager.setCursor(scaleCursor, 0, 0, manager.RotationX);
					break;
				case TransformMode.MODE_ROTATE:
						CursorManager.setCursor(new CursorRotation());
					break;
			}
			
			//CursorManager.rotation = manager.RotationX;

			// positionHandleHint( scaleCursor, evt.target.x, evt.target.y );
			
			if( evt.type == 'transformCommit' && !Mouse.isDown ){
				storeToHistory( "transformed" );
			}
		}
		
		private function positionHandleHint( _hint:MovieClip, xpos:uint = 0, ypos:uint = 0 ):void
			{
				var xoffset = (mouseX < manager.centrer.x) ? -10 : 10;
				var yoffset = (mouseY < manager.centrer.y) ? -10 : 10;
				_hint.x = (xpos || mouseX) + xoffset;
				_hint.y = (ypos || mouseY) + yoffset; 
				if (xoffset > 0 && yoffset < 0) {
					_hint.rotation = 0;
				}   else if (xoffset > 0 && yoffset > 0){
					_hint.rotation = 90;
				}   else if (xoffset < 0 && yoffset > 0){
					_hint.rotation = 180;
				}   else{
					_hint.rotation = -90;
				}
			}
		
		/*
		* Listeners for each objects on the stage (spesially be usefull with templates)
		*/
		
		public function initChild( obj:DisplayObject ):void {
			obj.addEventListener( MouseEvent.MOUSE_DOWN, mouseDownHandler );
			obj.addEventListener( MouseEvent.MOUSE_UP, mouseUpHandler );
			obj.addEventListener( KeyboardEvent.KEY_DOWN, keyHandler );
			stage.focus = InteractiveObject(obj);
		}
		
		
		/*
		* Zooming work stage with content
		*/
		
		public function zoomContent(num:Number):void{
			
			if(contentBg == null){ return; }
			
			contentBg.paper.scaleX = num;
			contentBg.paper.scaleY = num;
			contentBg.maskLayer.scaleX = num;
			contentBg.maskLayer.scaleY = num;
			
			if(contentBg.paper.width + 1 < contentBg.bg.width){
				zoomXmove = (int)(contentBg.bg.width/2 - contentBg.paper.width/2);
				contentBg.paper.x = zoomXmove;
				contentBg.maskLayer.x = zoomXmove;
			}
			
			if(contentBg.paper.height + 1 < contentBg.bg.height){
				zoomYmove = (int)(contentBg.bg.height/2 - contentBg.paper.height/2);
				contentBg.paper.y = zoomYmove;
				contentBg.maskLayer.y = zoomYmove;
			}

			aSp.update();
			manager.update();
			
			currentZoom = num;
			
		}

		
		public function get current():DisplayObject{
			return _current;
		}
		
		public function set current(c:DisplayObject):void{
			_current = c;
		}
		
		public function get currentType():String{
			return _currentType;
		}
		
		public function set currentType(c:String):void{
			_currentType = c;
		}
		
		public function get isActive():Boolean{
			return _isActive;
		}
		
		public function set isActive(act:Boolean):void{
			_isActive = act;
		}
		

		
		public function activateOne( obj:DisplayObject, oType:String ):void{
			
			_current = obj;
			_currentType = oType;
			singleTransformer.data = _current;
			_isActive = true;
			stage.focus = InteractiveObject(_current);

			if (_currentType == "Bitmap") {
				manager.activate( singleTransformer, contentBg, contentBg.paper, TransformMode.MODE_ALLOW_ALL, 4 );
			}else{
				manager.activate( singleTransformer, contentBg, contentBg.paper, TransformMode.MODE_ALLOW_ALL, 8 );
			}
			
			
		}
		
		
		/*
		* Check object type
		*/
		
		private function checkType( obj : DisplayObject ):String{
			if ( obj is TextField ) {
				return "TextField";
			}else if ( obj is Sprite ) {
				return Sprite(obj).getChildAt(0) is MovieClip ? "Shape" : "Bitmap";
			}else return "";
		}
		
		/*
		* Drag&Drop functions
		*/
		
		private function mouseDownHandler(e:MouseEvent):void{
			
			if ( e.eventPhase == EventPhase.BUBBLING_PHASE ) return;
			
			_current = e.target as DisplayObject;
			_currentType = checkType(_current);
			
			manager.deactivate();
			activateOne(e.target as DisplayObject, checkType(_current));

			offsetX = mouseX - e.target.x - manager.centrer.x;
			offsetY = mouseY - e.target.y - manager.centrer.y;
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, objectMove );
	
			isDrag = true;
		}
		
		private function mouseUpHandler(e:MouseEvent):void{
			
			if(stage.hasEventListener( MouseEvent.MOUSE_MOVE )) stage.removeEventListener( MouseEvent.MOUSE_MOVE, objectMove );
			
			isDrag = false;
			CursorManager.removeCursor();
			
			storeToHistory( "moved" );
		}
		
		private function objectMove(e:MouseEvent):void{

			if(Mouse.isDown && isDrag){
				CursorManager.setCursor(moveCursor);
				_current.x = mouseX - offsetX - manager.centrer.x;
				_current.y = mouseY - offsetY - manager.centrer.y;
				manager.update();
			}else{
				stage.removeEventListener( MouseEvent.MOUSE_MOVE, objectMove );
			}
			
		}
		
		
		/*
		* Delete on key interaction
		*/
		
		private function keyHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.DELETE){
				deleteObj();
				stage.focus = contentBg.bg;
			}
			
		}
		
		/*
		* Deactivation. If stage, or some other object (not tool) is clicked - deactivating tool
		*/
		
		public function deselect(e:MouseEvent = null):void {
			if(isActive){
				if(e != null){
					if(e.target is MovieClip && e.target != _current){
						manager.deactivate();
						stage.focus = contentBg.bg;
						isActive = false;
					}
				}else{
					manager.deactivate();
					stage.focus = contentBg.bg;
					isActive = false;
				}
			}
		}
		
		
		
		/*
		* Delete function
		*/
		
		public function deleteObj():void{

			if(_current && isActive){
				
				storeToHistory( "deleted" );
				deleteFromStage()
			}
		}
		
		public function deleteFromStage():void{
				
			if(isActive) manager.deactivate();
			// stage.focus = contentBg.bg;
			contentBg.paper.removeChild(_current);
			trace(contentBg.paper.contains(_current));
			// _current = null;
		}
		
		
		/*
		* Copy function
		*/
		
		public function copyObj():void{
			
			if(_current && isActive){
				
				applyMatrix = _current.transform.matrix.clone();
				
				if(_currentType == "Bitmap"){
					var bit:Bitmap = Bitmap(Sprite(_current).getChildAt(0));
					top.pic = new pictureObj(bit.bitmapData.clone(), true);
					top.addChild(top.pic);
					
				}else if(_currentType == "Shape"){
					
					// cut "shape_" string from name to get shape url
					top.sh = new shapeObj(_current.name.split("_")[1], true);
					top.addChild(top.sh);
					
					
				}else if(_currentType == "TextField"){
					top.tx = new textObj(TextField(_current).text, true);
					top.addChild(top.tx);
				}
			}
		}
		
		/** Apply matrix to clone object */
		
		public function setCopyMatrix():void {			
			_current.transform.matrix = applyMatrix;
			_current.x += 20;
			_current.y += 20;
			manager.update();
		}
		
		/** Apply records from history */
		
		public function applyHistory( obj:DisplayObject, otype:String, layer:int, historyMatrix:Matrix, otext:String ):void {
			// проверяем не был ли обьект удалён
			if(!contentBg.paper.contains(obj)){
				contentBg.paper.addChildAt(obj, layer);
			}
			
			_current.transform.matrix = historyMatrix;
			
			if( otype == 'TextField' ){
				TextField(_current).text = otext;
			}

		}
		
		public function storeToHistory( evt:String ):void{

			history.storeChages({o_target: _current,
							o_layer: contentBg.paper.getChildIndex(_current),
							o_name: _current.name,
							o_type: _currentType,
							o_event: evt,
							o_text: ( _currentType == 'TextField' ) ? TextField(_current).text : "",
							o_matrix: _current.transform.matrix.clone()
							});
			
		}


		
	}
	
}
