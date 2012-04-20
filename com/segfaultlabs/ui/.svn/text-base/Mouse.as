package com.segfaultlabs.ui {
	
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	
	import mx.states.State;
	

	/**
	 * @author Mateusz Malczak
	 */
	public class Mouse extends EventDispatcher 
	{
		private static var mouse : Mouse = null;
		
		private var op_   : Point;
		
		private var btn_  : Boolean;
		private var cpos_ : Point;
		private var opos_ : Point;
		private var dpos_ : Point;
		
		private var _stage : Stage;
		private var _globalListeners : Object;		
		private var _globalData : Object;
		
		public static function get instanceOf():Mouse
		{
				if ( mouse==null ) initialize(null);
			return mouse;
		};
		
		public static function initialize( stage:Stage ):Mouse
		{			
			mouse = new Mouse( stage );
			return mouse;
		};
		
		static public function set cursor( val:String ):void { flash.ui.Mouse.cursor = val; };
		
		static public function hide():void { flash.ui.Mouse.hide(); };
		static public function show():void { flash.ui.Mouse.show(); };
		
		static public function get data():Object { return mouse._globalData; };
			
		static public function get dx():Number { return mouse.dpos_.x; };	
		static public function get dy():Number { return mouse.dpos_.y; };
		static public function get delta():Point { return mouse.dpos_.clone(); };
		
		static public function get downX():Number { return mouse.cpos_.x };		
		static public function get downY():Number { return mouse.cpos_.y };
		static public function get mdown():Point { return mouse.cpos_.clone(); };

		static public function get X():Number { return mouse.opos_.x };
		static public function get Y():Number { return mouse.opos_.y };
		static public function get mpos():Point { return mouse.opos_.clone(); };		
		
		static public function get isDown():Boolean { return mouse.btn_; };
		
		static public function get selectionRect():Rectangle 
		{
			var r:Rectangle = new Rectangle();
			r.width = mouse.opos_.x - mouse.cpos_.x;
			r.height = mouse.opos_.y - mouse.cpos_.y;
			 if ( r.width<0 ) 
			 {
				 r.x = mouse.opos_.x;
				 r.width = -r.width;
			 } else r.x = mouse.cpos_.x;
			 if ( r.height<0 ) 
			 {
				 r.y = mouse.opos_.y;
				 r.height = -r.height;
			 } else r.y = mouse.cpos_.y;
			return r;
		}
		
		static public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true ):void
		{
			mouse.addEventListener( type, listener, false, 0, true);
		};
		
		static public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			mouse.removeEventListener( type, listener, false );
		};
		
		
		public function Mouse( stage:Stage ):void
		{ 
			op_ = new Point();
			_stage = stage;
			_globalListeners = { };
			var stage:Stage = _stage;
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,true ,int.MAX_VALUE); /* jest invoked przed wszystkimi innymi, ale nie jak jstage jest target (capture phase)*/
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,false,int.MAX_VALUE); /* jak stage jest target: (1target phase, bubbling phase)*/
			stage.addEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,true ,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,false,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,true ,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,false,int.MAX_VALUE);
			/* rejestrujac dwa nasluchy i wyrzucajac faze BUBBLING mam pewnosc ze zawsze mysz jest pierwsza */
			stage.addEventListener(Event.DEACTIVATE	 , DeactivateEvt);
			stage.addEventListener(Event.ACTIVATE	 	 , ActivateEvt);
			stage.addEventListener(Event.MOUSE_LEAVE	 ,MouseLeaveEvt);
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, MouseFocusChangeEvt );
			opos_ = new Point();
			dpos_ = new Point();
			cpos_ = new Point();
		};
		
		private function MouseFocusChangeEvt(e:Event):void
		{
			//trace("##MouseFocusChange player ...");
		};
		
		private function ActivateEvt(e:Event):void 
		{
			//trace("##Activate player ... ");		
		}
		
		protected function MouseDownEvt( evt:MouseEvent ):void
		{
			 if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
			opos_.x = evt.stageX; opos_.y = evt.stageY;
			cpos_.x = evt.stageX; cpos_.y = evt.stageY;
			btn_ = evt.buttonDown;
			
			 if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		};
				
		protected function MouseMoveEvt( evt:MouseEvent ):void
		{
			 if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
			 /* robie calk. zeby nie robic ulakowych wymiarow klatek 
			 	stageX,stageY - sa reczywiste jesli obiekt pod kursorem ma real(x) i/lub real(y)
			 */
			dpos_.x = Math.round(evt.stageX - opos_.x); 
			dpos_.y = Math.round(evt.stageY - opos_.y);
			opos_.x = evt.stageX; opos_.y = evt.stageY;
				 
			 if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		};
		
		protected function MouseUpEvt( evt:MouseEvent ):void 
		{ 
				if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
		  dpos_.x = dpos_.y = 0;
	  	  btn_ = evt.buttonDown;
				if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		};
		
		

		protected function DeactivateEvt( evt:Event ):void
		{
			trace("##Deactivate player ...");

			if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		};
		
		protected function MouseLeaveEvt( evt:Event ):void
		{			
			trace("##MouseLeave player ...");

			if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		};			
		
		//--------------------------------------------------------------------------
		//
		//  Global mouse down event listener
		//
		//--------------------------------------------------------------------------			
		public function addMouseGlobalListener( event:String, listener:Function, object:Object  ):void 
		{
			if ( event != MouseEvent.MOUSE_MOVE )
			{
					if ( !_globalListeners[event] ) _globalListeners[event] = new ListenersSet();
					 
					if ( ListenersSet(_globalListeners[event]).listeners[object] )
					{ 
						ListenersSet(_globalListeners[event]).listeners[object] = listener;
						return;  
					};
					
				var lset:ListenersSet = _globalListeners[event] as ListenersSet;
				lset.listeners[object] = listener;
				lset.count += 1;
				
				var stage:Stage = _stage;
				stage.addEventListener( event, mouseEventHandler, false, 0, true );
				stage.addEventListener( event, mouseEventHandler, true, 0, true );
			} else throw new IllegalOperationError("Cannot use 'addMouseMoveGlobalListener' to register global mouse move listener");
		};		
		
		public function removeMouseGlobalListener( event:String, object:Object  ):void 
		{
			if ( event != MouseEvent.MOUSE_MOVE )
			{				
				var lset:ListenersSet = _globalListeners[event] as ListenersSet;
				
					if ( lset )
					{				
						if ( object != null )
						{
							delete lset.listeners[ object ];
							lset.count -= 1;
						} else {
								for ( var obj:Object in lset.listeners )
									delete lset.listeners[ obj ];
							lset.count = 0;
						};
						
					
						if ( lset.count == 0 )
						{
							var stage:Stage = _stage;
							stage.removeEventListener( event, mouseEventHandler, false );
							stage.removeEventListener( event, mouseEventHandler, true );
						};
						
					};
			} else throw new IllegalOperationError("Cannot use 'removeMouseMoveGlobalListener' to unregister global mouse move listener");
		};
				
		private function mouseEventHandler(evt:MouseEvent):void 
		{
			if ( evt.eventPhase != EventPhase.BUBBLING_PHASE  )
			{
				var dict:Dictionary = ListenersSet(_globalListeners[ evt.type ]).listeners;
				var fnc:Function;
					if ( dict != null )
					{
							for ( var obj:Object in dict )
							{
								fnc = dict[obj];
								fnc( evt );
							};						
					} else {
						/* we should never get here ! */
						removeMouseGlobalListener( evt.type, null );
						throw new IllegalOperationError("Cannot use 'mouseEventHandler' on empty listeners set");
					};
			};
		}
		
		//--------------------------------------------------------------------------
		//
		//  Global mouse move event listener and move deactivation event handling.
		//
		//--------------------------------------------------------------------------			
		public function addMouseMoveGlobalListener( listener:Function, uplistener:Function=null, relatedData:Object=null  ):void 
		{
				if ( _globalListeners[MouseEvent.MOUSE_MOVE] ) removeMouseMoveGlobalListener();
						
			_globalListeners[MouseEvent.MOUSE_MOVE]  = listener;
			_globalListeners[Event.DEACTIVATE] = uplistener
			_globalData = relatedData;
			
			var stage:Stage = _stage;
			
			stage.addEventListener( MouseEvent.MOUSE_MOVE, listener, false, int.MAX_VALUE, false );			
			stage.addEventListener( MouseEvent.MOUSE_UP, mouseMoveDeactivate, false, int.MAX_VALUE, false );
			stage.addEventListener( Event.DEACTIVATE, mouseMoveDeactivate, false, int.MAX_VALUE, false );
			stage.addEventListener( Event.MOUSE_LEAVE, mouseMoveDeactivate, false, int.MAX_VALUE, false );					
	CONFIG::air {
			stage.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate, false, int.MAX_VALUE, false );
			stage.addEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate, true, int.MAX_VALUE, false );
			stage.addEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate, false, int.MAX_VALUE, false );
			stage.addEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate, true, int.MAX_VALUE, false );
	};
		};
		
		public function removeMouseMoveGlobalListener(cancel:Boolean=false):void 
		{
				if ( _globalListeners[MouseEvent.MOUSE_MOVE] == null ) return;
				
			var stage:Stage = _stage;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, _globalListeners[MouseEvent.MOUSE_MOVE] );			
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseMoveDeactivate );
			stage.removeEventListener( Event.DEACTIVATE, mouseMoveDeactivate );
			stage.removeEventListener( Event.MOUSE_LEAVE, mouseMoveDeactivate );			
	CONFIG::air {				
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate, true );
			stage.removeEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate, true );
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate );
			stage.removeEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate );
	};
				if ( cancel == false )
				{
					var fnc:Function = _globalListeners[Event.DEACTIVATE];
						if ( fnc!=null ) fnc( new Event( Event.DEACTIVATE )  );
				};
				
			_globalData = null;
			delete _globalListeners[MouseEvent.MOUSE_MOVE];
			delete _globalListeners[Event.DEACTIVATE]
		};
		
		private function mouseMoveDeactivate( evt : Event ):void
		{
			_stage.focus = null;
			removeMouseMoveGlobalListener();			
		};
		
	/* overrides */
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true ):void
		{
			super.addEventListener( type, listener, false, 0, true);
		};
		
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			super.removeEventListener( type, listener, false );
		};
		
	};	
};

import flash.utils.Dictionary;

internal final class ListenersSet {
	public var count : int;
	public var listeners : Dictionary;
	
	public function ListenersSet():void
	{
		count = 0;
		listeners = new Dictionary(true);	
	};
}