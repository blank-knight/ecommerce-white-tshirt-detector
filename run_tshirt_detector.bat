@echo off
REM T恤颜色识别器 - Windows一键运行脚本

echo ========================================
echo    T恤颜色识别器 🎨
echo ========================================
echo.

REM 检查虚拟环境
if not exist "venv_tshirt" (
    echo [警告] 虚拟环境不存在，正在创建...
    python -m venv venv_tshirt
    call venv_tshirt\Scripts\activate
    pip install opencv-python numpy
    echo [完成] 虚拟环境创建完成
) else (
    call venv_tshirt\Scripts\activate
    echo [完成] 虚拟环境已激活
)

echo.
echo 请选择操作：
echo 1) 快速识别（扫描目录，显示结果）
echo 2) 保存白色T恤（复制到输出目录）
echo 3) 自动分类（白色/非白色分开存放）
echo 4) 调试模式（可视化白色区域）
echo 5) 查看文档
echo.
set /p choice=请输入选项 (1-5): 

if "%choice%"=="1" goto quick_detect
if "%choice%"=="2" goto save_white
if "%choice%"=="3" goto auto_classify
if "%choice%"=="4" goto debug_mode
if "%choice%"=="5" goto show_doc
echo [错误] 无效选项
goto end

:quick_detect
set /p input_dir=请输入图片目录路径: 
python tshirt_color_detector.py "%input_dir%"
goto end

:save_white
set /p input_dir=请输入图片目录路径: 
set /p output_dir=请输入白色T恤输出目录: 
python tshirt_color_detector.py "%input_dir%" --output "%output_dir%"
goto end

:auto_classify
set /p input_dir=请输入图片目录路径: 
set /p output_dir=请输入白色T恤输出目录: 
python tshirt_color_detector.py "%input_dir%" --output "%output_dir%" --move
goto end

:debug_mode
set /p image_path=请输入要调试的图片路径: 
python tshirt_color_detector.py --visualize "%image_path%"
goto end

:show_doc
type tshirt_detector_README.md
goto end

:end
echo.
echo [完成] 
pause
