@echo off

elm make src/Main.elm --output=build/bundle.js --optimize
xcopy .\build\* ..\..\modules\lexicon\web\ /E /Y