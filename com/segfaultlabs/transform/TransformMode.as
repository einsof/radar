/**
 * Transform Manager, part of segfaultlabs AS3 library
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
package com.segfaultlabs.transform
{
	/**
	 * Available transformation modes.
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 * 
	 */	
	public class TransformMode
	{		
		static public const MODE_IDLE 		 : uint = 0x01;
		static public const MODE_SCALEX 	 : uint = 0x12;
		static public const MODE_SCALEY 	 : uint = 0x22;
		static public const MODE_SCALE 	 	 : uint = 0x32;
		static public const MODE_SKEWX 		 : uint = 0x14;
		static public const MODE_SKEWY 		 : uint = 0x24;
		static public const MODE_ROTATE 	 : uint = 0x08;
		static public const MODE_REVPOINT 	 : uint = 0x10;

        static public const MODE_ALLOW_SCALE : uint = 0x100000;
        static public const MODE_ALLOW_ROTATE: uint = 0x200000;
        static public const MODE_ALLOW_SKEW  : uint = 0x400000;
        static public const MODE_ALLOW_ALL   : uint = 0x700000;
				
	}
}