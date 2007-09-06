/**
* @author Ignacio Delgado
* 
* OSCConnectionEvent object
* 
* (c) 2007 http://www.h-umus.it
* 
*/
	 
package it.h_umus.osc 
{
	import flash.events.Event;
	 
	public final class OSCConnectionEvent extends Event 
	{	
		public static const ON_PACKET_IN:String 			= "onPacketIn";
		public static const ON_PACKET_OUT:String 			= "onPacketOut";
		
		public var data:OSCPacket;//Object;
		
		public function OSCConnectionEvent(inType:String,inData:OSCPacket=null) 
		{
			super(inType);
			data = inData; 
		}
		
		
		public override function clone():Event
		{
			return new OSCConnectionEvent(type,(OSCPacket)(data));
		}	
	}
}