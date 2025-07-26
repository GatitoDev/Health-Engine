@echo off
if not exist ".haxelib" (mkdir ".haxelib") else echo .haxelib exists.
title FNF Setup - Installing libs
haxelib install lime 
haxelib install hxcpp
haxelib install openfl
haxelib install flixel
haxelib install flixel-ui
haxelib install linc_luajit
haxelib install flixel-addons
echo Done. Press any key to exit.
pause >nul