; Inno Setup script - https://jrsoftware.org/isdl.php
[Setup]
AppName=UMAR Town Planner
AppVersion=1.0.0
AppPublisher=Umar
DefaultDirName={autopf}\UMAR Town Planner
DefaultGroupName=UMAR Town Planner
OutputBaseFilename=UMAR_Town_Planner_Setup
OutputDir=installer_output
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\civil_calc.exe
Compression=lzma2
SolidCompression=yes
[Tasks]
Name: "desktopicon"; Description: "Desktop par icon banayein"; Flags: checkedonce
[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs
[Icons]
Name: "{group}\UMAR Town Planner"; Filename: "{app}\civil_calc.exe"
Name: "{autodesktop}\UMAR Town Planner"; Filename: "{app}\civil_calc.exe"; Tasks: desktopicon
[Run]
Filename: "{app}\civil_calc.exe"; Description: "UMAR Town Planner chalayein"; Flags: nowait postinstall skipifsilent
