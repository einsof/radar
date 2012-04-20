/**
 * segfaultlabs AS3 library
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
package com.segfaultlabs.events
{
	import flash.events.Event;

	public class TransformEvent extends Event
	{
		static public const TRANSFORM_INIT   : String = "transformInit";  
		static public const TRANSFORM_BEGIN  : String = "transformBegin";
		static public const TRANSFORM_APPEND : String = "transformAppend";
		static public const TRANSFORM_COMMIT : String = "transformCommit";
		static public const TRANSFORM_CURSOR : String = "transformCursor";
	
		private var _mode : int;
		
		private var _angle : Number;
		
		public function TransformEvent(type:String, mode:int = 0, angle:Number = NaN )
		{
			super(type, false, false);
			_mode = mode;
			_angle = angle;
		}
		
		public function get mode():int 
		{
			return _mode;
		};
		
		public function get angle():Number
		{
			return _angle;
		};
		
		override public function clone():Event
		{
			return new TransformEvent( type, _mode, _angle );
		}
		
	}
}