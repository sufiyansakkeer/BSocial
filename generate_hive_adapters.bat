@echo off
echo Generating Hive adapters...
flutter pub run build_runner build --delete-conflicting-outputs
echo Done!
pause
