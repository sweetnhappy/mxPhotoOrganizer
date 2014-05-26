package hmw {
	import flash.display.*;
	import flash.events.*;
	import flash.filesystem.*;
	
	import mx.controls.*;
	import mx.core.*;
	
	public class AppInit {
		private var appMXML:mxPhotoOrganizer;
		public var stdXMLHeader:String;
		
		public function AppInit(appRef:mxPhotoOrganizer) {
			appMXML = appRef;
			stdXMLHeader = new String("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
		}
		
		public function updateFileMenuMac(fileMenu:NativeMenu):NativeMenu {
			var closeCommand:NativeMenuItem = fileMenu.getItemAt(0);
			
			fileMenu.removeItemAt(0);
			fileMenu.removeItemAt(0);
			fileMenu = updateFileMenu(fileMenu);
			fileMenu.addItem(new NativeMenuItem("", true));
			fileMenu.addItem(closeCommand);
			
			return fileMenu;
		}
		
		public function createFileMenuWin():NativeMenu {
			var fileMenu:NativeMenu = new NativeMenu();
			
			fileMenu = updateFileMenu(fileMenu);
			
			fileMenu.addItem(new NativeMenuItem("", true));
			var exitCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Exit"));
			exitCommand.addEventListener(Event.SELECT, selectCommand);
			
			return fileMenu;
		}
		
		public function loadLibrary():XML {
			var fs:FileStream = new FileStream();
			var xmlFile:File = new File(File.applicationStorageDirectory.nativePath + File.separator + "appData.xml");
			if (! xmlFile.exists) {
				return createLibrary();
			}
			else {
				fs.open(xmlFile, FileMode.READ);
				
				try {
					var xmlData:XML = new XML(fs.readUTF());
					fs.close();
					
					xmlFile = new File(File.applicationStorageDirectory.nativePath + File.separator + "appData.bak.xml");
					fs.open(xmlFile, FileMode.WRITE);
					fs.writeUTF(stdXMLHeader + xmlData.toXMLString());
					fs.close();
					
					return xmlData;
				}
				catch (error:Error) {
					fs.close();
					
					xmlFile = new File(File.applicationStorageDirectory.nativePath + File.separator + "appData.bak.xml");
					fs.open(xmlFile, FileMode.READ);
					
					try {
						xmlData = new XML(fs.readUTF());
						fs.close();
						
						return xmlData;
					}
					catch (error:Error) {
						fs.close();
						
						Alert.show("Could not load the library nor its backup.\nYour library is likely corrupt so a new library will be created.",
							"Library Load Error", Alert.NONMODAL);
						
						return createLibrary();
					}
				}
				
				return createLibrary();
			}
		}
		
		public function createLibrary():XML {
			return <appLib>
				<treeNodes>
					<node label="Library" uID="-1" />
					<node label="Albums" clickable="false" uID="0">
					</node>
					<node label="Search" uID="10000" />
				</treeNodes>
				<libNodes>
				</libNodes>
				<groupNodes>
				</groupNodes>
				<prefs>
					<prefSet lib="1" album="1" search="10001" firstRun="true" />
				</prefs>
			</appLib>;
		}
		
		private function updateFileMenu(fileMenu:NativeMenu):NativeMenu {
			var importPhotosCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Import Photos..."));
			importPhotosCommand.keyEquivalent = "o";
			importPhotosCommand.addEventListener(Event.SELECT, selectCommand);
			fileMenu.addItem(new NativeMenuItem("", true));
			var saveLibCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Save Library"));
			saveLibCommand.keyEquivalent = "s";
			saveLibCommand.addEventListener(Event.SELECT, selectCommand);
			fileMenu.addItem(new NativeMenuItem("", true));
			var importLibCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Import Library..."));
			importLibCommand.keyEquivalent = "i";
			importLibCommand.addEventListener(Event.SELECT, selectCommand);
			var exportLibCommand:NativeMenuItem = fileMenu.addItem(new NativeMenuItem("Export Library..."));
			exportLibCommand.keyEquivalent = "e";
			exportLibCommand.addEventListener(Event.SELECT, selectCommand);
			
			return fileMenu;
		}
		
		private function selectCommand(event:Event):void {
			if (event.target.label == "Import Photos...") {
				appMXML.setupForImport();
			}
			else if (event.target.label == "Save Library") {
				appMXML.saveLibraryNow();
			}
			else if (event.target.label == "Import Library...") {
				appMXML.loadExternalLib();
			}
			else if (event.target.label == "Export Library...") {
				appMXML.saveExternalLib();
			}
			else if (event.target.label == "Exit") {
				appMXML.nativeWindow.close();
			}
		}
	}
}