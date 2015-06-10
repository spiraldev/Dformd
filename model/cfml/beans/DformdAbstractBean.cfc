/* 
filename:		/com/dformd/model/cfml/beans/DformdAbstractBean.cfc
date created:	06/06/2013
author:			Matt Graf and Matt Quackenbush (http://www.quackfuzed.com/) 
purpose:		this is the abstract bean for Dformd it currently serves no purpose beyond preparing for future expansion. 
				IMPORTANT: DO NOT USE ANY OF THE PROPERTIES DEFINED IN THIS CLASS. THEY WILL BE PUT TO GOOD USE AT SOME POINT 
				AND IF YOU'VE USED THEM YOUR CODE ==WILL== BREAK.
				
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
	property name="id" type="string";
	property name="name" type="string";
	property name="dateCreated" type="date";
	property name="dateLastModified" type="date";


	public any function init()
	{
		throw( type='DformdAbstractClass', message='This is an abstract class that must be extended.' );
	}


	private string function generateID()
	{
		return replace( createUUID(), '-', '', 'all' );
	}
}

