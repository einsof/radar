package com.abrahamyan.util 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.ui.Mouse;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Armen Abrahamyan
	 */
	public class CursorManager 
	{
		private static var _cursor:DisplayObject;
		private static var _xOffset:Number;
		private static var _yOffset:Number;
		private static var _root:Stage
		
		public function CursorManager():void
		{
			throw new Error("no need to call constructor, use static methods CursorManager.init(), CursorManager.setCursor(),CursorManager.removeCursor(),CursorManager.destroy() " );
		}
		/**
		 * sets stage path
		 * @param	pRoot
		 */
		public static function init(pRoot:Stage):void
		{
			_root = pRoot;
		}
		/**
		 *  sets display object as cursor ( removes prev cursor automatically)
		 * @param	pCursor  new cursor
		 * @param	pXoffset x offset from mouse position
		 * @param	pYoffset y offset from mouse position
		 */
		public static function setCursor(pCursor:DisplayObject, pXoffset:Number = 0, pYoffset:Number = 0, rot:Number = 0):void
		{
			if (!_root)
			{
				throw new Error("set root using init(pRoot)");
			}
			if (_cursor)
			{
				removeCursor();
			}
			Mouse.hide();
			_cursor = pCursor;
			if (_cursor is InteractiveObject)
			{
				InteractiveObject(_cursor).mouseEnabled = false;
				if (_cursor is DisplayObjectContainer)
				{
					DisplayObjectContainer(_cursor).mouseChildren = false;
				}
			}
			
			_xOffset = pXoffset;
			_yOffset = pYoffset;
			_cursor.x = _root.mouseX + _xOffset;
			_cursor.y = _root.mouseY + _yOffset;
			_cursor.rotation = rot;
			_root.addChild(_cursor);
			_root.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			
		}
		/**
		 * update cursor position
		 * @param	e
		 */
		private static function onMouseMove(e:MouseEvent):void
		{
			_cursor.x = _root.mouseX + _xOffset;
			_cursor.y = _root.mouseY + _yOffset;
			e.updateAfterEvent();
		}
		/**
		 * brings cursor on top of display list in case u add another displayobjext on stage
		 */
		public static function bringToFront():void
		{
			if (_cursor)
			{
				_root.addChild(_cursor);
			}
		}
		/**
		 * removes cursor created by last setCursor() method, resotres original system cursor
		 */
		public static function removeCursor():void
		{
			
			if (!_cursor)
			{
				return;
			}
			_root.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_root.removeChild(_cursor);
			_cursor = null;
			Mouse.show();
			
		}
		/**
		 * works exactly same way as removeCursor()
		 */
		public static function destroy():void
		{
			if (_cursor)
			{
				removeCursor();
			}
		}
		
	}
	
}