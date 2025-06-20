@echo off
echo Resetting STEG LOTO Database...

REM Stop the Spring Boot application if it's running
taskkill /F /IM java.exe /T

REM Wait for 2 seconds
timeout /t 2 /nobreak

REM Execute the reset script
psql -U postgres -f backend\src\main\resources\reset_db.sql

REM Execute the schema script
psql -U postgres -d loto_db -f backend\src\main\resources\schema.sql

echo Database reset complete!
pause 