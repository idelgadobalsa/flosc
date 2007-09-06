/**
 * @author Ignacio Delgado
 * 
 * OSCArgument object
 * 
 * (c) 2007 http://www.h-umus.it
 * 
 */

package it.h_umus.osc 
{ 
	 public final class OSCArgument
	 {	 
		 public static const i:String = "i";		// int32
		 public static const s:String = "s";		// float32
		 public static const f:String = "f";		// OSC-String
//		 public static var b:String = "b";		// OSC-blob

		 public static const h:String = "h";		// 64 bit big-endian two's complement integer
		 public static const t:String = "t";		// OSC-timetag
		 public static const d:String = "d";		// 64 bit ("double")
		 public static const S:String = "S";		// alternate type for OSC-String
		 public static const c:String = "c";		// ascii character, 32 bit
		 public static const r:String = "r";		// 32 bit RGBA color
		 public static const m:String = "m";		// 4 byte MIDI message
		 public static const T:String = "T";		// TRUE
		 public static const F:String = "F"; 		// FALSE
//		 public static var N:String = "N";
//		 public static var I:String = "I";
		 
		 public var type:String = OSCArgument.s;
		 public var value:Object;
		 
		 public function OSCArgument (...args)
		 {
			 switch (args.length) 
			 {
				//case 0: constructor1(); return;
				case 1: constructor2(args[0]); return;
				case 2: constructor3(args[0], args[1]); return;
			}
		 }
		 
		 
		 private function constructor3(type:String , value:Object):void
		 {
			 this.type=type;
			 this.value=value;
		 }
		 
		 
		 private function constructor2(array:Array):void
		 {
			 type = array[0];
			 value = array[1];
		 }
		 
		 
		 public function getXML():XML{
		 	var value:String = (type == "s") ? escape(String(value)) : value.toString();
		 	var node:XML = 	<ARGUMENT TYPE="{type}" VALUE="{value}" />;

			return node;
		 } 
	 }
 }