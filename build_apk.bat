@echo off
echo ===================================================
echo     CAlcool - Generazione APK in corso...
echo ===================================================
echo.

:: Avvia la compilazione dell'APK in modalità release
call flutter build apk --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERRORE] La compilazione dell'APK e' fallita!
    echo Controlla i messaggi di errore qui sopra.
    echo.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo ===================================================
echo     COMPILAZIONE COMPLETATA CON SUCCESSO!
echo ===================================================
echo.
echo L'APK pronto si trova qui:
echo %~dp0build\app\outputs\flutter-apk\app-release.apk
echo.
echo Sto aprendo la cartella in Esplora File...
echo.

:: Apre la cartella di output selezionando l'APK appena generato
explorer.exe /select,"%~dp0build\app\outputs\flutter-apk\app-release.apk"

pause
