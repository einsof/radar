package com.segfaultlabs.ui {
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.IUITextField;

	/**
	 * @author Mateusz Malczak
	 */
	dynamic public class Key extends EventDispatcher
	{
		private static var _shortcuts 		: Array = [];
		private static var _activeShortcuts : Boolean = true;
		private static var _instance 		: Key = null;
				
		public static function get instanceOf():Key
		{
			return _instance;					
		};
		
		public static function initialize( stage:Stage ):Key
		{
			_instance = new Key( new kKeyIsSingleton(), stage );
			return _instance;
		};
		
		public static function downEvent( key:uint ):String { return key + "_down"; };
		
		public static function upEvent( key:uint ):String { return key + "_up"; };
		
		public function Key(magic:kKeyIsSingleton, _stage:Stage )
		{
			super();
			/**
			 * seems like EventPhase.CAPTURING occures always in AIR (?? this is strange)
			 */
 			_stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyboardEvent, true, 0, true );
			_stage.addEventListener( KeyboardEvent.KEY_UP, handleKeyboardEvent, true, 0, true );
			
CONFIG::flex {
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, handleKeyboardEvent, false, 0, true );
			_stage.addEventListener( KeyboardEvent.KEY_UP, handleKeyboardEvent, false, 0, true  );
};
		
		};
		
		private function keyUpClosure( keyCode:uint, charCode:uint, keyLocation:uint, ctrlKey:Boolean, altKey:Boolean ):void
		{		
			if ( this[ keyCode ] == null )
				dispatchEvent( new KeyboardEvent( keyCode.toString() + "_up",
							   false, false, charCode, keyCode, keyLocation, ctrlKey, altKey ) );
		};
		
		/*
		 * Key accelerators
		 **/
		
		static public function defineShortcut( key:uint, fnc:Function, data:Object=null ):void
		{
			if ( _shortcuts[ key ] == null )
			{
				var short:Shortcut = new Shortcut();
				short.f = fnc;
				short.d = data;
				_shortcuts[ key ] = short;
			};
		}
		
		static public function set activateShortcuts( value : Boolean ):void { _activeShortcuts = value; }
		
		protected function handleKeyboardEvent(evt:KeyboardEvent):void
		{
			if ( evt.eventPhase!=EventPhase.BUBBLING_PHASE )
			{
				switch ( evt.type )
				{
					case KeyboardEvent.KEY_DOWN: 
							this[ evt.keyCode ] = getTimer();
														
								if ( _activeShortcuts && evt.ctrlKey )
								{
									var istf:Boolean = (evt.target is TextInput)||(evt.target is TextArea);
										if ( evt.target is TextField )
										{
											istf = istf || TextField( evt.target ).type == TextFieldType.INPUT;
										} else if ( evt.target is IUITextField ) {
											istf = istf || IUITextField( evt.target ).type == TextFieldType.INPUT;
										};
									if ( istf==false )
									{
										var short:Shortcut = _shortcuts[ evt.keyCode ];								
											if ( short ) {
												(short.f as Function).call( null, short.d );
												return;
											};
									}; 
								};
								
							if ( hasEventListener( evt.keyCode.toString() + "_down" ) )
								dispatchEvent( new KeyboardEvent( evt.keyCode.toString() + "_down", false, false, evt.charCode, evt.keyCode, evt.keyLocation, evt.ctrlKey, evt.altKey ) );
								
						break;
				 	case KeyboardEvent.KEY_UP: 
				 			var del:uint = getTimer() - this[evt.keyCode];
							delete this[ evt.keyCode ];
							
								if ( hasEventListener( evt.keyCode.toString() + "_up" ) )
									setInterval( keyUpClosure, del, evt.keyCode, evt.charCode, evt.keyLocation, evt.ctrlKey, evt.altKey );
							
							
						break;
				};
			};
		};

		static public function isDown( key:uint ):Boolean { return ( Key._instance[key] != null ) };
		
	};
	
}

internal class kKeyIsSingleton { };

internal final class Shortcut {
	public var d : Object;
	public var f : Function;
}

