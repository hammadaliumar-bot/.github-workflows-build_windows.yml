@echo off
echo === UMAR Town Planner: Windows build ===
call flutter create --platforms=windows,android --org com.umar .
call flutter pub get
call dart run flutter_launcher_icons
powershell -NoProfile -Command "(Get-Content windows\runner\main.cpp) -replace 'civil_calc','UMAR Town Planner' | Set-Content windows\runner\main.cpp"
call flutter build windows --release
echo.
echo App tayyar: build\windows\x64\runner\Release\civil_calc.exe
echo Installer banane ke liye Inno Setup mein installer.iss kholein aur Compile (F9) dabayein.
pause
