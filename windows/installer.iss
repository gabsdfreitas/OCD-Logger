[Setup]
AppName=OCD Logger
AppVersion=1.0.0
DefaultDirName={pf}\OCD Logger
DefaultGroupName=OCD Logger
DisableProgramGroupPage=no
UninstallDisplayIcon={app}\ocd_logger.exe
OutputBaseFilename=ocd_logger_installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "c:\Users\Alteralph\Documents\Projects\ocd_logger\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\OCD Logger"; Filename: "{app}\ocd_logger.exe"; WorkingDir: "{app}"; IconFilename: "{app}\app_icon.ico"; IconIndex: 0
Name: "{userdesktop}\OCD Logger"; Filename: "{app}\ocd_logger.exe"; WorkingDir: "{app}"; IconFilename: "{app}\app_icon.ico"; IconIndex: 0

[Run]
Filename: "{app}\ocd_logger.exe"; Description: "Launch OCD Logger"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
