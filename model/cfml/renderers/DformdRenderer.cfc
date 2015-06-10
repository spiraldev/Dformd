/* 
filename:		/com/dformd/model/cfml/renderers/DformdRenderer.cfc
date created:	06/06/2013
author:			Matt Graf and Matt Quackenbush (http://www.quackfuzed.com/) 
purpose:		This is the default Dformd renderer object.
				
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

	property name="resourcesDefinitions" type="struct";
	property name="elementDefinitions" type="struct";

	//captures nested structure references
	variables.ConditionRegEx = "\{\{(##|@|\%)\s*(\w+(?:(?:\.\w+){1,})?)\s*}}(.*?)\{\{/\s*\2\s*\}\}";
    
	// set to true to see exception; false to silently ignore missing keys
    throwOnMissingPlaceholderKey = false;
    elementDefinitions = {};

	public any function init( required string skinFilePath )
	{

		buildElementDefinitions( fileRead(skinFilePath) );
		return this;
	}

	/* Renders a given form */
	public string function renderForm( required any Dform, boolean elements_only=false )
	{
		var rtnFromHtml = "<form" & Dform.getFlattenAttributes() & ">";
		if( elements_only ){
			rtnFromHtml = "";
		}
		for( var element in Dform.getElements() )
		{
			if( Dform.getAutoWrapper() && !len( element.getWrapperType() ) )
			{
				if( len( Dform.getWrapperElementType() ) )
				{
					element.setWrapperType( Dform.getWrapperElementType() );
				}
				else
				{
					element.setWrapperType( element.getType() & '_wrapper' );
				}
			}
			rtnFromHtml &= renderElement( element );
		}
		if( !elements_only ){
			rtnFromHtml &= "</form>";
		}
		return rtnFromHtml;
	}

	/* Renders a given element */
	public string function renderElement( required any Element )
	{
		var rtn = "";
		
		if( structKeyExists( getelementDefinitions(), element.getType() ) )
		{
			var orig_context = element.getContext();
			if( element.hasChildren() )
			{
				var element_Dformd_children = '';
				var new_context = element.getContext();

				for( var childElement in element.getChildren() )
				{
					if( element.getAutoChildWrapper() && !len( childElement.getWrapperType() ) )
					{
						if( len( element.getChildWrapperType() ) )
						{
							childElement.setWrapperType( element.getChildWrapperType() );
						}else
						{
							childElement.setWrapperType( childElement.getType() & '_wrapper' );
						}
					}
					element_Dformd_children &= renderElement( childElement );					
				}
				new_context.element_Dformd_children = element_Dformd_children;
				element.setContext( new_context );
			}
			
			rtn = renderElementDefinition( element.getType(), element.getContext() );

			if( len( element.getWrapperType() ) && structKeyExists( getelementDefinitions(), element.getWrapperType() ) )
			{
				orig_context.element_Dformd_element = rtn;
				rtn = renderElementDefinition( element.getWrapperType() , orig_context );
			}

		}
		return rtn;
	}

	/* Renders the resources for a given form */
	public any function renderResources( required any Dform )
	{
		var rtn = "";
		for( var resource in Dform.getResources() )
		{
			var context 	= Dform.getResourceContext();
			context.formid 	= Dform.getid();
			rtn 			&= renderResourceDefinition( resource, context );	
		}
		
		return rtn;
	}
	
	/* Render a element definition */
	public any function renderElementDefinition( required string type, required struct context={} )
	{
		var rtn = "";
		if( structKeyExists( variables.elementDefinitions, arguments.type ) )
		{
			rtn = variables.elementDefinitions[ arguments.type  ];
			rtn = renderSections( rtn, arguments.context );
			rtn = renderPlaceholders( rtn, arguments.context );
		}
		return rtn;
	}

	/* Render a resource definition */
	public any function renderResourceDefinition( required string type, required struct context={} ) 
	{
		var rtn = "";
		if( structKeyExists( variables.resourcesDefinitions, arguments.type ) )
		{
			rtn = variables.resourcesDefinitions[ arguments.type  ];
			rtn = renderSections( rtn, arguments.context );
			rtn = renderPlaceholders( rtn, arguments.context );
		}
		
		return rtn;
	}
	
	/*
	* replaces $${foo} placeholders in the provided source string with corresponding values in
	* the provided values struct
	*/
	private string function renderPlaceholders( required string source, required struct values )
	{
	  var rtn = source;
	  var end = false;
	 
	  while ( NOT end )
	  {
	      var match = reFind( '\$\$\{[A-Za-z_-]+\}', rtn, 1, true);

	      if ( match.pos[1] GT 0 )
	      {
	          var orig = mid( rtn, match.pos[1], match.len[1] );
	          var key = reReplace( orig, '\$\$\{|\}', '', 'all' );
	          var pos = match.pos[1] + match.len[1];

	          if ( throwOnMissingPlaceholderKey )
	          {
	              rtn = replace( rtn, orig, trim( values[ key ] ) );
	          }
	          else
	          {
	              rtn = replace( rtn, orig, structKeyExists( values, key ) ? trim( values[ key ] ) : '' );
	          }
	      }
	      else
	      {
	          end = true;
	      }
	  }
	 
	  return rtn;
	}

	/* Replaces {{##condition|%array|@query}} {{/condition|array|query}} with the code provided in the skin file*/
	public any function renderSections( required string template, struct context ) 
	{
		var whiteSpaceRegex = "(^\r?\n?)?(\r?\n?)?";
		var rtn             = arguments.template;
		var matches         = [];
		var end             = false;

		while ( NOT end )
		{
			matches = ReFindNoCaseValues( rtn, variables.ConditionRegEx );

			if( isDefined("matches") && isArray( matches ) && arrayLen( matches ) == 4 )
			{
				var rendered = "";
				var test_var = matches[3];
				if( structKeyExists( arguments.context, test_var ) )
				{
				    if( matches[2] == '##' )
				    {
				    	if( isBoolean( arguments.context[ test_var ] ) && arguments.context[ test_var ] )
				    	{
					        rendered = matches[4];
					    }
				    }
				    else if( matches[2] == '%' )
		    		{
				    	if( isarray( arguments.context[ test_var ] ) && arrayLen(arguments.context[ test_var ]) )
				    	{
					    	for( var arElement in arguments.context[ test_var ] )
					    	{
					    		var arElementContext = structCopy(arguments.context);
					    		var sElem = "";
					    		structAppend( arElementContext, arElement, true);
					    		sElem = renderSections( matches[4], arElementContext );
					    		rendered &= renderPlaceholders( sElem, arElementContext );
					    	}
					    }
		    		}
		    		else if( matches[2] == '@' )
		    		{
		    			if(  isQuery( arguments.context[ test_var ] ) )
		    			{
			    			var qry = arguments.context[ test_var ];
			    			var cols = listToArray( qry.columnList ); 
			    			for( var row = 1; rows lte qry.recordCount; row = row + 1 )
					    	{
					    		var qryElementContext = structCopy(arguments.context);
					    		var sElem = "";
				    			for(var ii = 1; ii lte arraylen( cols ); ii = ii + 1)
				    			{
									qryElementContext[ cols[ ii ] ] = qry[ cols[ ii ] ][ row ];
								}
					    		sElem = renderSections( matches[4], qryElementContext );
					    		rendered &= renderPlaceholders( sElem, qryElementContext );
							}
			    		}
		    		}
				}

				rtn = Replace(rtn, matches[1], rendered, 'all');
				//Maybe this should be conditional not sure
				rtn = reReplace( rtn, whiteSpaceRegex, '', 'all' );
			}
			else
			{
				end = true;
			}

		}

		return rtn;
	}

	/* original function is in Mustache https://github.com/rip747/Mustache.cfc  */
	private array function ReFindNoCaseValues( required string textBlock, required string RegEx )
	{
	  var results   = [];
	  var matcher   = REFind( arguments.regEx, arguments.textBlock , 1, true  );
	  var idx       = 0;

	  if( isStruct(matcher) && structKeyExists( matcher, "len") 
	      && structKeyExists( matcher, "pos") )
	  {
	    if( isArray( matcher.pos ) && arrayLen( matcher.pos )  )
	    {
	      for( idx=1; idx LTE arrayLen( matcher.pos ); idx=idx+1 )
	      {
	        if( matcher.pos[idx] gt 0 && matcher.len[idx] gt 0)
	        {
	        arrayAppend( results, mid( arguments.textBlock, matcher.pos[idx], matcher.len[idx] ) );
	        }
	      }  
	    }
	  }
	  return results;
	}

	/* Build the element and resource definitions */
	public void function buildElementDefinitions( required string skinFile )
	{
		/*
		* skin convention is:
		*
		*    element.element_name=
		*        // stuff here
		*    # END element.element_name
		*
		* this convention must be followed or elements will be all jacked up
		*/
		var regex 	= "(element\.\w+)=(?:[^##]+|##(?! END \1))+(?=## END \1)";
		var regex2 	= "(resource\.\w+)=(?:[^##]+|##(?! END \1))+(?=## END \1)";

		var elements 	= REMatch( regex, skinFile );
		var resources	= REMatch( regex2, skinFile );

		for( var element in elements )
		{
			var name = listLast( listFirst( element, '=' ), '.' );
			var definition = listRest( element, '=' );
			if(  name != 'example_element_name' ){
				elementDefinitions[ name ] = trim( definition );
			}
		}

		for( var resource in resources )
		{
			var name = listLast( listFirst( resource, '=' ), '.' );
			var definition = listRest( resource, '=' );
			if(  name != 'example_resource_name' ){
				resourcesDefinitions[ name ] = trim( definition );
			}
		}

	}
}