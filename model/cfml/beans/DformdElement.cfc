/* 
filename:		/com/dformd/model/cfml/beans/DformdElement.cfc
date created:	06/06/2013
author:			Matt Graf and Matt Quackenbush (http://www.quackfuzed.com/) 
purpose:		this is the generic form element class for Dformd specific element types that need additional behaviors/properties should extend this class
				
	// **************************************** LICENSE INFO **************************************** \\
	
	Copyright 2013 Matt Quackenbush, Matt Graf

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	   http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.


 */

component accessors="true" extends="dformd.model.cfml.beans.DformdAbstractBean"
{
	// this is the DformdForm/DformdElement that this element belongs to
	property name="parent" type="any";

	// this is a list of DformdElement children this element owns
	property name="children" type="array";

	// this is a struct of all the values that will be used in the skin template
	property name="context" type="struct";

	//this is the type element which needs to match a skin definition
	property name="type" 	type="string";

	//this is the type element which needs to match a skin definition
	property name="wrappertype" 	type="string";
	
	/* This will auto wrap child elements with the an element with the same name as the element 
		with _wrapper at the end of the name $${name}_wrapper or if childWrapperType is 
		populated it will wrap the element with that wrapper  */
	property name="autoChildWrapper" type="boolean" default="false";
	property name="childWrapperType" type="string";

	// the renderer, duh!
	property name="renderer" type="any";

	public any function init()
	{
		variables.children = [];
		setId( 'Dformd-' & generateId() );
		setAutoChildWrapper( false );
		return this;
	}

	//Checks to see if the element has any child elements
	public boolean function hasChildren() {
		
		return ( arrayLen( variables.children ) ? true : false );
	}
	
	//Add an elements to the element
	public any function addElement( required any element )
	{
		arrayAppend( variables.children, element );
		return this;
	}

	//Add an array of elements to the element
	public any function addElements( required array arElements )
	{
		for( element in arguments.arElements ){
			arrayAppend( variables.children, element );
		}
		return this;
	}
}