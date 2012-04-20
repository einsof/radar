/**
 * segfaultlabs AS3 library, mouse extensions class
 * Copyright (C) 2010, Mateusz Malczak (http://malczak.info)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */
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
	

	/**
	 * Mouse class defines additional functionality to handle mouse
	 * in flash applications. 
	 * 
	 * This class allows you to define 
	 * global mouse listeners, eq. global mouse move listener. This
	 * listener is active no matter where mouse move event is fired,  
	 * even if mouse is outside of application window. 
	 * 
	 * You can also access mouse position, point where last mouse down
	 * event was dispatched.  
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 */
	public class Mouse extends EventDispatcher 
	{
		private static var mouse : Mouse = null;
		
		private var _op   	  		 : Point;		
		private var _btn  	  		 : Boolean;
		private var _cpos 	  		 : Point;
		private var _opos 	  		 : Point;
		private var _dpos 	  		 : Point;		
		private var _fpactive 		 : Boolean;		
		private var _stage    		 : Stage;
		private var _globalListeners : Object;		
		private var _globalData 	 : Object;
		
		public static function get instance():Mouse
		{
				if ( mouse==null ) initialize(null);
			return mouse;
		}
		
		/**
		 * Initialize mouse instance
		 *  
		 * @param stage
		 * 
		 */		
		public static function initialize( stage:Stage ):Mouse
		{			
			mouse = new Mouse( stage );
			return mouse;
		}
		
		/**
		 * @see flash.ui.Mouse#cursor
		 */		
		static public function set cursor( val:String ):void { flash.ui.Mouse.cursor = val; }
		
		/**
		 * @see flash.ui.Mouse#hide()
		 */		
		static public function hide():void { flash.ui.Mouse.hide() }

		/**
		 * @see flash.ui.Mouse#show()
		 */				
		static public function show():void { flash.ui.Mouse.show() }
		
		/**
		 * Get data object currently associated with Mouse instance
		 * 
		 * @return data object 
		 */
		static public function get data():Object { return mouse._globalData; }
			
		/**
		 * @return mouse position change 
		 */		
		static public function get delta():Point { return mouse._dpos.clone(); }

		/**
		 * @return mouse horizontal position change 
		 */		
		static public function get dx():Number { return mouse._dpos.x; }

		/**
		 * @return mouse vertical position change 
		 */		
		static public function get dy():Number { return mouse._dpos.y; }
		
		/**
		 * @return point where the last mouse down event was dispatched (stage coordinates) 
		 */		
		static public function get mdown():Point { return mouse._cpos.clone(); }
		
		/**
		 * @return X coordinate, where the last mouse down event was dispatched (stage coordinates) 
		 */		
		static public function get downX():Number { return mouse._cpos.x }
		
		/**
		 * @return Y coordinate, where the last mouse down event was dispatched (stage coordinates) 
		 */		
		static public function get downY():Number { return mouse._cpos.y }

		
		/**
		 * @return current mouse position (stage coordinate space) 
		 */
		static public function get mpos():Point { return mouse._opos.clone(); }
		
		/**
		 * @return current mouse X coordinate (stage coordinate space) 
		 */
		static public function get X():Number { return mouse._opos.x }

		/**
		 * @return current mouse Y coordinate (stage coordinate space) 
		 */
		static public function get Y():Number { return mouse._opos.y }
		
		/**
		 * @return returns true if mouse left button is down 
		 */		
		static public function get isDown():Boolean { return mouse._btn; }
		
		/**
		 * @return rectangle, defined by point where mouse 
		 * button has been pressed and current mouse position 
		 */
		static public function get selectionRect():Rectangle 
		{
			var r:Rectangle = new Rectangle();
			r.width = mouse._opos.x - mouse._cpos.x;
			r.height = mouse._opos.y - mouse._cpos.y;
			 if ( r.width<0 ) 
			 {
				 r.x = mouse._opos.x;
				 r.width = -r.width;
			 } else r.x = mouse._cpos.x;
			 if ( r.height<0 ) 
			 {
				 r.y = mouse._opos.y;
				 r.height = -r.height;
			 } else r.y = mouse._cpos.y;
			return r;
		}
		
		/**
		 * @see flash.events.IEventDispatcher#addEventListener() 
		 */			
		static public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true ):void
		{
			mouse.addEventListener( type, listener, false, 0, true);
		}
		
		/**
		 * @see flash.events.IEventDispatcher#removeEventListener() 
		 */			
		static public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			mouse.removeEventListener( type, listener, false );
		}
		
		
		public function Mouse( stage:Stage ):void
		{ 
			super();
			init(stage);
		}
			
		protected function init(stage:Stage):void
		{
			_op = new Point();
			_stage = stage;
			_globalListeners = { }
			
			var stage:Stage = _stage;
			addListeners();
			
			/* make sure Mouse is always first */
			stage.addEventListener(Event.DEACTIVATE	     		, DeactivateEvt, false, int.MAX_VALUE );
			stage.addEventListener(Event.ACTIVATE	 	 		, ActivateEvt, false, int.MAX_VALUE );
			stage.addEventListener(Event.MOUSE_LEAVE	 	    , MouseLeaveEvt, false, int.MAX_VALUE );
			stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, MouseFocusChangeEvt, false, int.MAX_VALUE );
			
			_opos = new Point();
			_dpos = new Point();
			_cpos = new Point();
			
			_fpactive = true;
		}
		
		/**
		 * remove all listeners  
		 * 
		 */		
		private function removeListeners():void
		{
			var stage:Stage = _stage;
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,true );
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,false);
			stage.removeEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,true );
			stage.removeEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,false);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,true );
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,false);
		}
		
		/**
		 * setup add listeners 
		 * 
		 */		
		private function addListeners():void
		{
			var stage:Stage = _stage;
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,true ,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,MouseDownEvt,false,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,true ,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_UP  ,MouseUpEvt  ,false,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,true ,int.MAX_VALUE);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,MouseMoveEvt,false,int.MAX_VALUE);			
		}
		
		private function MouseFocusChangeEvt(e:Event):void
		{
			// trace("##MouseFocusChange player ..." + e.target);			
		}
		
		
		private function ActivateEvt(e:Event):void 
		{
			addListeners()
		}
		
		protected function DeactivateEvt( evt:Event ):void
		{
			removeListeners();
			if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		}
		
		protected function MouseLeaveEvt( evt:Event ):void
		{			
			if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		}		
		
		protected function MouseDownEvt( evt:MouseEvent ):void
		{
			 if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
			
			_opos.x = evt.stageX; _opos.y = evt.stageY;
			_cpos.x = evt.stageX; _cpos.y = evt.stageY;
			_btn = evt.buttonDown;
			
			 if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		}
				
		protected function MouseMoveEvt( evt:MouseEvent ):void
		{
			 if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
			 
			_dpos.x = Math.round(evt.stageX - _opos.x); 
			_dpos.y = Math.round(evt.stageY - _opos.y);
			_opos.x = evt.stageX; _opos.y = evt.stageY;
				 
			 if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		}
		
		protected function MouseUpEvt( evt:MouseEvent ):void 
		{ 
				if ( evt.eventPhase==EventPhase.BUBBLING_PHASE ) return;
		  _dpos.x = _dpos.y = 0;
	  	  _btn = evt.buttonDown;
				if( hasEventListener( evt.type ) )	dispatchEvent( evt );
		}
		
		/**
		 * @see flash.events.IEventDispatcher#addEventListener() 
		 */			
		override public function addEventListener( type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=true ):void
		{
			super.addEventListener( type, listener, false, 0, true);
		}
		
		/**
		 * @see flash.events.IEventDispatcher#addEventListener() 
		 */			
		override public function removeEventListener( type:String, listener:Function, useCapture:Boolean=false ):void
		{
			super.removeEventListener( type, listener, false );
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Global mouse down event listener
		//
		//--------------------------------------------------------------------------
		/**
		 * Global mouse event listener. Method 'listener' is called when event occures
		 * no matter where it was dispatched 
		 *  
		 * @param event event to listen to
		 * @param listener function to be called on event
		 * @param object object listening to the event
		 * 
		 */		
		public function addMouseGlobalListener( event:String, listener:Function, object:Object  ):void 
		{
			//if ( event != MouseEvent.MOUSE_MOVE )
			//{
					if ( !_globalListeners[event] ) _globalListeners[event] = new ListenersSet();
					 
					if ( ListenersSet(_globalListeners[event]).listeners[object] )
					{ 
						ListenersSet(_globalListeners[event]).listeners[object] = listener;
						return;  
					}
					
				var lset:ListenersSet = _globalListeners[event] as ListenersSet;
				lset.listeners[object] = listener;
				lset.count += 1;
				
				var stage:Stage = _stage;
				stage.addEventListener( event, mouseEventHandler, false, 0, true );
				stage.addEventListener( event, mouseEventHandler, true, 0, true );
			//} else 
			//	throw new IllegalOperationError("Cannot use 'addMouseMoveGlobalListener' to register global mouse move listener");
		}		
		
		/**
		 * Method removes global listener. 
		 *  
		 * @param event type of event
		 * @param object object intenersted in that event
		 * 
		 */		
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
						}
						
					
						if ( lset.count == 0 )
						{
							var stage:Stage = _stage;
							stage.removeEventListener( event, mouseEventHandler, false );
							stage.removeEventListener( event, mouseEventHandler, true );
						}
						
					}
			} else throw new IllegalOperationError("Cannot use 'removeMouseMoveGlobalListener' to unregister global mouse move listener");
		}
				
		/**
		 * Internal handler for mouse events. This method manages
		 * all global listeners. 
		 */		
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
							}						
					} else {
						/* we should never get here ! */
						removeMouseGlobalListener( evt.type, null );
						throw new IllegalOperationError("Cannot use 'mouseEventHandler' on empty listeners set");
					}
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Global mouse move event listener and move deactivation event handling.
		//
		//--------------------------------------------------------------------------
		/**
		 * Method defines global mouse move listeners. That is a special type
		 * of global mouse event listeners. Function 'listener' is called
		 * whenever mouse is moved (event if it is moved outside of application
		 * window).
		 * This is mainy used as a reaction to mouse down event. User defines global
		 * mouse move handler to react to mouse movement. 
		 * 
		 * @param listener function to be called when mouse moves
		 * @param uplistener function to be called when mouse button is released
		 * @param relatedData data to be stored by mouse manager
		 * 
		 */		
		public function addMouseMoveGlobalListener( listener:Function, uplistener:Function=null, relatedData:Object=null  ):void 
		{
				if ( _globalListeners[GLOBAL_MOUSE_MOVE] ) removeMouseMoveGlobalListener();
						
			_globalListeners[GLOBAL_MOUSE_MOVE]  = listener;
			_globalListeners[GLOBAL_MOUSE_MOVE_END] = uplistener
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
	}
		}
		
		/**
		 * Method removes a global mouse move listener
		 * 
		 * @param cancel if true 'uplistener' function is not called
		 * 
		 */		
		public function removeMouseMoveGlobalListener(cancel:Boolean=false):void 
		{
				if ( _globalListeners[GLOBAL_MOUSE_MOVE] == null ) return;
				
			var stage:Stage = _stage;
			
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, _globalListeners[GLOBAL_MOUSE_MOVE] );			
			stage.removeEventListener( MouseEvent.MOUSE_UP, mouseMoveDeactivate );
			stage.removeEventListener( Event.DEACTIVATE, mouseMoveDeactivate );
			stage.removeEventListener( Event.MOUSE_LEAVE, mouseMoveDeactivate );			
	CONFIG::air {				
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate, true );
			stage.removeEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate, true );
			stage.removeEventListener( MouseEvent.MIDDLE_MOUSE_DOWN, mouseMoveDeactivate );
			stage.removeEventListener( MouseEvent.RIGHT_MOUSE_DOWN, mouseMoveDeactivate );
	}
				if ( cancel == false )
				{
					var fnc:Function = _globalListeners[GLOBAL_MOUSE_MOVE_END];
						if ( fnc!=null ) fnc( new Event( Event.DEACTIVATE )  );
				}
				
			_globalData = null;
			delete _globalListeners[GLOBAL_MOUSE_MOVE];
			delete _globalListeners[GLOBAL_MOUSE_MOVE_END]
		}
		
		private function mouseMoveDeactivate( evt : Event ):void
		{
			_stage.focus = null;
			removeMouseMoveGlobalListener();			
		}
		
		private const GLOBAL_MOUSE_MOVE:String = "global_mouse_move";
		private const GLOBAL_MOUSE_MOVE_END:String = "global_mouse_move_end";
		
	}	
}

import flash.utils.Dictionary;
internal final class ListenersSet {
	public var count : int;
	public var listeners : Dictionary;
	
	public function ListenersSet():void
	{
		count = 0;
		listeners = new Dictionary(true);	
	}
}