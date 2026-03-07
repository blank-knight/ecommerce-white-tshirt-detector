@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

set MIN_BRIGHTNESS=180
set MAX_SATURATION=30
set MIN_RATIO=0.6
set FOCUS_RATIO=0.5

:menu
cls
echo ========================================
echo    T-Shirt Color Detector
echo ========================================
echo.

echo Please select an option:
echo 1) Quick scan (show results only)
echo 2) Save white t-shirts (copy to output folder)
echo 3) Auto classify (white/non-white separate)
echo 4) Debug mode (visualize white areas)
echo 5) Advanced settings (adjust threshold params)
echo 6) View documentation
echo 0) Exit
echo.
echo Current parameters:
echo   - MIN_BRIGHTNESS: %MIN_BRIGHTNESS% (0-255, lower = more lenient)
echo   - MAX_SATURATION: %MAX_SATURATION% (0-255, higher = more lenient)
echo   - MIN_RATIO: %MIN_RATIO% (0-1, lower = more lenient)
echo   - FOCUS_RATIO: %FOCUS_RATIO% (0.1-1.0, higher = more background)
echo.
set /p choice=Enter option (0-6): 

if "%choice%"=="0" goto exit
if "%choice%"=="1" goto quick_detect
if "%choice%"=="2" goto save_white
if "%choice%"=="3" goto auto_classify
if "%choice%"=="4" goto debug_mode
if "%choice%"=="5" goto advanced_settings
if "%choice%"=="6" goto show_doc
echo [Error] Invalid option
pause
goto menu

:quick_detect
set /p input_dir=Enter image folder path: 
python tshirt_color_detector.py "%input_dir%" --min-brightness %MIN_BRIGHTNESS% --max-saturation %MAX_SATURATION% --min-ratio %MIN_RATIO% --focus-ratio %FOCUS_RATIO%
echo.
pause
goto menu

:save_white
set /p input_dir=Enter image folder path: 
set /p output_dir=Enter output folder for white t-shirts: 
python tshirt_color_detector.py "%input_dir%" --output "%output_dir%" --min-brightness %MIN_BRIGHTNESS% --max-saturation %MAX_SATURATION% --min-ratio %MIN_RATIO% --focus-ratio %FOCUS_RATIO%
echo.
pause
goto menu

:auto_classify
set /p input_dir=Enter image folder path: 
set /p output_dir=Enter output folder for white t-shirts: 
python tshirt_color_detector.py "%input_dir%" --output "%output_dir%" --move --min-brightness %MIN_BRIGHTNESS% --max-saturation %MAX_SATURATION% --min-ratio %MIN_RATIO% --focus-ratio %FOCUS_RATIO%
echo.
pause
goto menu

:debug_mode
set /p image_path=Enter image path to debug: 
python tshirt_color_detector.py --visualize "%image_path%" --min-brightness %MIN_BRIGHTNESS% --max-saturation %MAX_SATURATION%
echo.
pause
goto menu

:advanced_settings
echo.
echo Advanced Settings - Adjust threshold parameters
echo.
echo Parameter tips:
echo   - Lower MIN_BRIGHTNESS or higher MAX_SATURATION: more lenient (easier to detect as white)
echo   - Higher MIN_BRIGHTNESS or lower MAX_SATURATION: stricter (only pure white)
echo   - Lower MIN_RATIO: allow less white area (more lenient)
echo   - Higher FOCUS_RATIO: include more background (may cause false positives)
echo.

set /p new_val=Current MIN_BRIGHTNESS = %MIN_BRIGHTNESS%, new value (0-255, press Enter to skip): 
if not "%new_val%"=="" set MIN_BRIGHTNESS=%new_val%
set new_val=

set /p new_val=Current MAX_SATURATION = %MAX_SATURATION%, new value (0-255, press Enter to skip): 
if not "%new_val%"=="" set MAX_SATURATION=%new_val%
set new_val=

set /p new_val=Current MIN_RATIO = %MIN_RATIO%, new value (0-1, press Enter to skip): 
if not "%new_val%"=="" set MIN_RATIO=%new_val%
set new_val=

set /p new_val=Current FOCUS_RATIO = %FOCUS_RATIO%, new value (0.1-1.0, press Enter to skip): 
if not "%new_val%"=="" set FOCUS_RATIO=%new_val%
set new_val=

echo.
echo [Done] Parameters updated!
echo.
pause
goto menu

:show_doc
type tshirt_detector_README.md
echo.
pause
goto menu

:exit
echo.
echo Goodbye!
