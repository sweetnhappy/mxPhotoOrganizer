package hmw {
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	import mx.controls.*;
	import mx.core.*;
	
	public class AppCleanup {
		private var appMXML:mxPhotoOrganizer;
		public var stdXMLHeader:String;
		
		public function AppCleanup(appRef:mxPhotoOrganizer) {
			appMXML = appRef;
			stdXMLHeader = new String("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		}
		
		public function cleanUp(masterXML:XML):void {
			saveLibrary(masterXML);
		}
		
		public function saveLibrary(masterXML:XML):void {
			var fs:FileStream = new FileStream();
			var xmlFile:File = new File(File.applicationStorageDirectory.nativePath + File.separator + "appData.xml");
			
			fs.open(xmlFile, FileMode.WRITE);
			fs.writeUTF(stdXMLHeader + masterXML.toXMLString());
			fs.close();
		}
	}
}