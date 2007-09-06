/**
* @author Ignacio Delgado
* 
* OSCMessage object
* 
* (c) 2007 http://www.h-umus.it
* 
*/
	 
package it.h_umus.osc
{
	public final class OSCMessage
	{
		public var _name			: String;
		public var _argumentsArray 	: Array;
		
		public function OSCMessage(name:String)
		{
			_name = name;
			_argumentsArray = new Array();
		}
		
		
		public function addArg(arg:OSCArgument):void
		{
			_argumentsArray.push(arg);
		}
		
		
		public function getArgumentValue(index:uint):Object{
			if(index>_argumentsArray.length)
				return null;
			return OSCArgument(_argumentsArray[index]).value;
		}
		
		
		public function getXML():XML{
			var messageNode:XML = 	<MESSAGE NAME="{name}"/>;
			for each(var arg:OSCArgument in _argumentsArray)
				messageNode.ARGUMENT+=arg.getXML();
				
			return messageNode;
		}	
	}
}