/* 
filename:		/com/dformd/model/cfml/services/DformdService.cfc
date created:	06/06/2013
author:			Matt Graf and Matt Quackenbush (http://www.quackfuzed.com/) 
purpose:		This is the main Dformd service object. Its purpose is to allow easy interaction with the Dformd library from your application controllers and/or services.
				
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




component accessors="true"
{
	property name="defaultRenderer";

	public any function init( required any defaultRenderer )
	{
		variables.defaultRenderer = arguments.defaultRenderer;	
		
		return this;
	}


	public any function getDform( any renderer=defaultRenderer )
	{
		var Dform = createObject( 'Dformd.model.cfml.beans.DformdForm' ).init();

		Dform.setRenderer( renderer );
		
		return Dform;
	}

	public any function getElement( required string type, struct context={}, any renderer=defaultRenderer ) {
		
		var DformElement = createObject( 'Dformd.model.cfml.beans.DformdElement' ).init();
		DformElement.setRenderer( renderer );
		DformElement.setType( arguments.type );
		DformElement.setContext( arguments.context );
		
		return DformElement;
	}
	
}