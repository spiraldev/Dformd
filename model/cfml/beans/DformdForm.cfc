/* 
filename:		/com/dformd/model/cfml/beans/DformdForm.cfc
date created:	06/06/2013
author:			Matt Graf and Matt Quackenbush (http://www.quackfuzed.com/) 
purpose:		This file represents a single Dformd form object.
				
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
	/*
	* formElements can be just about anything that can legally reside
	* inside a form: fieldset, field, div, etc
	*/
	property name="elements" type="array";

	// used in the form's id attribute
	property name="id" type="string";

	// used in the form's name attribute; defaults to id
	property name="name" type="string";
	
	// used in the form's action attribute;
	property name="action" type="string";
	
	// used in the form's enctype attribute; defaults to 'application/x-www-form-urlencoded'
	// options: application/x-www-form-urlencoded, multipart/form-data, text/plain
	property name="enctype" type="string" default="application/x-www-form-urlencoded";
	 	
	// used in the form's method attribute; defaults to 'post'
	// options: get, post
	property name="method" type="string" default="post"; 	

	// used in the form's class attribute;
	property name="classname" type="string";

	/* This will auto wrap elements with the an element with the same name as the element 
		with _wrapper at the end of the name $${name}_wrapper or if wrapperElementType is 
		populated it will wrap the element with that wrapper  */
	property name="autoWrapper" type="boolean" default="false";

	property name="wrapperElementType" type="string";

	/*
	* resources are CSS and/or JavaScript files that are loaded
	* to effect behavior on the form
	*/
	property name="resources" type="array";

	// this is a struct of all the values that will be used in the skin template
	property name="resourceContext" type="struct";

	// the renderer, duh!
	property name="renderer" type="any";


	public any function init()
	{
		setId( 'Dformd-' & generateID() );
		setEncType( 'application/x-www-form-urlencoded' );
		setMethod( 'post' );
		setAutoWrapper( false );
		setResourceContext( {} );
		variables.elements = [];
		variables.resources = [];
		return this;
	}

	public string function getFlattenAttributes() {
		var rtn_ats = "";
		if( len( getMethod() ) ) rtn_ats &= ' method="' & getMethod() & '"';
		if( len( getEncType() ) ) rtn_ats &= ' enctype="' & getEncType() & '"';
		if( len( getId() ) ) rtn_ats &= ' id="' & getId() & '"';
		if( len( getName() ) ) rtn_ats &= ' name="' & getName() & '"';
		if( len( getAction() ) ) rtn_ats &= ' action="' & getAction() & '"';
		if( len( getClassName() ) ) rtn_ats &= ' class="' & getClassName() & '"';
		return rtn_ats;
	}	

	//Add an element to the form
	public any function addElement( required any element )
	{
		arrayAppend( elements, element );
		return this;
	}

	//Add an array of elements to the form
	public any function addElements( required array arElements )
	{
		for( element in arguments.arElements ){
			arrayAppend( elements, element );
		}
		return this;
	}

	//Add a resource to the form
	public void function addResource( required string name)
	{
		arrayAppend( variables.resources, name );
	}

	//Render the form
	public string function render( boolean elements_only=false )
	{
		return renderer.renderForm( this, elements_only );
	}
	
	//Render the form resources
	public any function renderResources() {
		
		return renderer.renderResources( this );
	}	
}