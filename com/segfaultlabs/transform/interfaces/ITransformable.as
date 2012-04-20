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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	
	/****
	 * ITransformable interface is used to create objects that can be transformed by 
	 * used transformation manager. Implementators are not transformed directly by 
	 * transform manager itself, rather than by 'transformers' (that is implemetators
	 * of ITransformer interface, eq. SingleTransformer or MultipleTransformer)
	 * 
	 * This interface can be used to override default way of updating transformation matrix,
	 * with Your own fancy way of handling transformation
	 * 
	 * @author Mateusz Malczak (http://malczak.info)
	 *  
	 */	
	public interface ITransformable
	{
		
		/****
		* Returns initial operation matrix
		*  - transform.matrix if single object
		*  - identity if selection
		**/
		function initTransformation():Matrix;
		
		/****
		* Called when interactive transformation begins. This function is called just after 
		* user pressed mouse button, but before any transformations are done.
		**/
		function beginTransformation():void;
		
		/****
		* Appends new transformation to object. This function is called when transformation 
		* should be performed on object.
		**/
		function appendTransformation( mtx:Matrix ):void;
		
		/****
		* This function is called when interactive transformation finishes. That is, when
		* mouse button is released. This function should return current transformation matrix.
		* In simplest case this just returns transformation matrix for transformed DisplayObject.
		**/
		function commitTransformation():Matrix;		
		
	}
}