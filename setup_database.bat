@echo off
echo Setting up STEG LOTO Database...

REM Stop the Spring Boot application if it's running
taskkill /F /IM java.exe /T

REM Wait for 2 seconds
timeout /t 2 /nobreak

REM Execute the setup script
psql -U postgres -f backend\src\main\resources\setup_database.sql

echo Database setup complete!
pause 