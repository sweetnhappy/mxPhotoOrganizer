package hmw {
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	import flash.net.*;
	
	import mx.controls.*;
	import mx.core.*;
	import mx.events.*;
	
	public class AppTasks {
		private var appMXML:mxPhotoOrganizer;
		private var xmlFile:File;
		private var importFileOrDir:File;
		private var importArray:Array;
		private var importXML:XML;
		
		public function AppTasks(appRef:mxPhotoOrganizer) {
			appMXML = appRef;
		}
		
		public function refreshTreeArray(xmlData:XML, theTree:Tree):Array {
			var treeItems:Array = new Array();
			for (var i:int = 0; i < xmlData..node.length(); i++) {
				theTree.selectedIndex = i;
				treeItems.push(theTree.selectedItem);
			}
			return treeItems;
		}
		
		public function loadExternalLib():void {
			Alert.buttonWidth = 100;
			Alert.show("Please note that your current library will be overwritten.\n\nAre you sure you want to load an external library?",
				"Overwrite Library Caution", (Alert.YES | Alert.NO | Alert.NONMODAL), appMXML, confirmLoad);
		}
		
		public function saveExternalLib():void {
			xmlFile = new File();
			try {
				xmlFile.browseForSave("Export Library (use .xml after the name to ensure it can be imported correctly)");
				xmlFile.addEventListener(Event.SELECT, saveLocationSelected);
			}
			catch (error:Error) {
				Alert.show("Could not save the library\nto the location you specified.", "Library Export Error", Alert.NONMODAL);
			}
		}
		
		public function requestImportSelection():void {
			importFileOrDir = File.documentsDirectory;
			Alert.yesLabel = "Folder";
			Alert.okLabel = "Files";
			Alert.buttonWidth = 100;
			Alert.show("Would you like to open a folder or select individual file(s)?", "Import Choice",
				(Alert.YES | Alert.OK | Alert.CANCEL), appMXML, requestImportSpecified, null, (Alert.YES));
		}
		
		private function requestImportSpecified(event:CloseEvent):void {
			Alert.yesLabel = "Yes";
			Alert.okLabel = "OK";
			Alert.buttonWidth = 50;
			if (event.detail == Alert.OK) {
				var photoFilter:FileFilter = new FileFilter("Photos", "*.jpg;*.gif;*.png");
				
				try {
					importFileOrDir.browseForOpenMultiple("Select Image Files", [photoFilter]);
					importFileOrDir.addEventListener(FileListEvent.SELECT_MULTIPLE, importFilesSelectionMade);
					importFileOrDir.addEventListener(Event.CANCEL, cancelTheImport);
				}
				catch (error:Error) {
					Alert.show("Could not import the photos you selected.", "Import Photos Error", Alert.NONMODAL);
				}
			}
			else if (event.detail == Alert.YES) {
				try {
					importFileOrDir.browseForDirectory("Select Image Folder");
					importFileOrDir.addEventListener(Event.SELECT, importDirSelectionMade);
					importFileOrDir.addEventListener(Event.CANCEL, cancelTheImport);
				}
				catch (error:Error) {
					Alert.show("Could not import the folder you selected.", "Import Folder Error", Alert.NONMODAL);
				}
			}
			else {
				cancelTheImport(null);
			}
		}
		
		private function cancelTheImport(event:Event):void {
			appMXML.dismissImport();
			appMXML.status = "Photo Import Cancelled";
		}
		
		private function importFilesSelectionMade(event:FileListEvent):void {
			importArray = event.files;
			readFilePropertiesToXML();
		}
		
		private function importDirSelectionMade(event:Event):void {
			importFileOrDir = event.target as File;
			importArray = new Array();
			var tempArray:Array = importFileOrDir.getDirectoryListing();
			
			for each (var f:File in tempArray) {
				if ((f.extension == "jpg") || (f.extension == "gif") || (f.extension == "png")) {
					importArray.push(f);
				}
			}
			
			if (importArray.length == 0) {
				Alert.show("The folder you selected does not \ncontain any valid image files.\n\nWould you like to try again?",
					"No Images Found", (Alert.YES | Alert.NO), appMXML, retryImport, null, Alert.NO);
			}
			else {
				readFilePropertiesToXML();
			}
		}
		
		private function retryImport(event:CloseEvent):void {
			if (event.detail == Alert.YES) {
				requestImportSelection();
			}
			else {
				cancelTheImport(null);
			}
		}
		
		private function convertMonth(monthAsNum:Number):String {
			if (monthAsNum == 0) { return "  (Jan) "; }
			else if (monthAsNum == 1) { return "  (Feb) "; }
			else if (monthAsNum == 2) { return "  (Mar)"; }
			else if (monthAsNum == 3) { return "  (Apr) "; }
			else if (monthAsNum == 4) { return "  (May)"; }
			else if (monthAsNum == 5) { return "  (Jun) "; }
			else if (monthAsNum == 6) { return "  (Jul)  "; }
			else if (monthAsNum == 7) { return "  (Aug) "; }
			else if (monthAsNum == 8) { return "  (Sep) "; }
			else if (monthAsNum == 9) { return "(Oct) "; }
			else if (monthAsNum == 10) { return "(Nov) "; }
			else if (monthAsNum == 11) { return "(Dec) "; }
			else { return ""; }
		}
		
		private function addLeadingZero(rawDate:Number):String {
			if (rawDate < 10) {
				return (0 + rawDate.toString());
			}
			else {
				return rawDate.toString();
			}
		}
		
		private function readFilePropertiesToXML():void {
			importXML = <importNodes>
			</importNodes>;
			var counter:int = appMXML.getLibUIDCounter();
			
			for each (var f:File in importArray) {
				var name:String;
				var date:String;
				var size:String;
				var path:String;
				
				name = f.name.replace("." + f.extension, "");
				date = f.creationDate.getFullYear() + " - " + (f.creationDate.getMonth() + 1) + " " +
					convertMonth(f.creationDate.getMonth()) + " " + addLeadingZero(f.creationDate.getDate());
				size = (f.size / 1024).toFixed(1) + " KB";
				path = f.url;
				
				var xmlNodeString:String = "<node uID=\"" + counter + "\" name=\"" + name + "\" date=\"" + date +
					"\" size=\"" + size + "\" source=\"" + path + "\" keywords=\"\" />";
					
				importXML.appendChild(new XML(xmlNodeString));
				
				counter++;
			}
			
			appMXML.setImportXML(importXML);
			appMXML.updateImportItems();
			appMXML.updateLibUIDCounter(counter);
			appMXML.importAll.enabled = true;
		}
		
		private function confirmLoad(event:CloseEvent):void {
			Alert.buttonWidth = 50;
			if (event.detail == Alert.YES) {
				var xmlFilter:FileFilter = new FileFilter("XML", "*.xml");
				
				xmlFile = new File();
				try {
					xmlFile.browseForOpen("Import Library", [xmlFilter]);
					xmlFile.addEventListener(Event.SELECT, librarySelected);
				}
				catch (error:Error) {
					Alert.show("Could not load the library.\nPlease try again.\nIf it still does not load\nit may be corrupt.",
						"Library Import Error", Alert.NONMODAL);
				}
			}
		}
		
		private function librarySelected(event:Event):void {
			appMXML.status = "Importing Library...";
			var fs:FileStream = new FileStream();
			
			fs.open(xmlFile, FileMode.READ);
			
			try {
				var xmlData:XML = new XML(fs.readUTF());
				fs.close();
				
				appMXML.setLibraryXML(xmlData);
			}
			catch (error:Error) {
				fs.close();
				
				Alert.show("Could not load the library.\nPlease try again.\nIf it still does not load\nit may be corrupt.",
					"Library Import Error", Alert.NONMODAL);
				appMXML.status = "Library Import Failed.";
			}
		}
		
		private function saveLocationSelected(event:Event):void {
			var fs:FileStream = new FileStream();
			var theXMLData:String = appMXML.getLibXMLData();
			fs.open(xmlFile, FileMode.WRITE);
			fs.writeUTF(theXMLData);
			fs.close();
			
			appMXML.status = appMXML.status + " Completed Successfully";
		}
	}
}