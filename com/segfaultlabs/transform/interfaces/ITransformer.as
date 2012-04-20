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
package com.segfaultlabs.transform.interfaces
{
	import flash.geom.Point;

	/****
	 * ITransformer implemetators are transformed by transformation manager. It is resposible for
	 * updating related DisplayObject. This interface is used to create transformations
	 * for single and multiple objects. It can be implemented by developer to handle
	 * transformation in custom way.
	 * 
	 * Two main implementators are SingleTransformer and MultipleTransformer. Both classes
	 * are using simple transformation matrix updatating method to append transformations.
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 * 	 
	 */	
	public interface ITransformer extends ITransformable
	{
		
		/****
		 * This method calculated bounding box corner points in global space. Points 
		 * passed as parameters are used to return calculated values. Parameters must 
		 * always be set to non null values.
		 *
		 * <pre>
		 *  bbp0 ------- bbp1
		 *   |            |
		 *   |            |
		 *   |            |
		 *  bbp3 ------- bbp2
		 * </pre>	
		 **/
		function getCorners( bbp0:Point, bbp1:Point, bbp2:Point, bbp3:Point ):void;
		
		/**
		 * Object transformed by this transformer. Single DisplayObject in case of
		 * single object transformer or an Array in case of a selection transformer.
		 */
		function set data( obj:Object ):void		
		function get data():Object;
		
	}
}