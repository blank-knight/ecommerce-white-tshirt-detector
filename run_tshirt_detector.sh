#!/bin/bash
# T恤颜色识别器 - 一键运行脚本

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo -e "   T恤颜色识别器 🎨"
echo -e "========================================${NC}"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 检测操作系统并设置激活脚本路径
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
    # Windows (Git Bash/MSYS/Cygwin)
    ACTIVATE_SCRIPT="venv_tshirt/Scripts/activate"
else
    # Linux/Unix
    ACTIVATE_SCRIPT="venv_tshirt/bin/activate"
fi

# 检查虚拟环境
if [ ! -d "venv_tshirt" ]; then
    echo -e "${YELLOW}⚠️  虚拟环境不存在，正在创建...${NC}"
    python3 -m venv venv_tshirt
    source "$ACTIVATE_SCRIPT"
    pip install opencv-python numpy --quiet
    echo -e "${GREEN}✅ 虚拟环境创建完成${NC}"
else
    source "$ACTIVATE_SCRIPT"
    echo -e "${GREEN}✅ 虚拟环境已激活${NC}"
fi

echo ""

# 菜单
echo "请选择操作："
echo "1) 📸 快速识别（扫描目录，显示结果）"
echo "2) 💾 保存白色T恤（复制到输出目录）"
echo "3) 🗂️  自动分类（白色/非白色分开存放）"
echo "4) 🔍 调试模式（可视化白色区域）"
echo "5) 📝 查看文档"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        read -p "请输入图片目录路径: " input_dir
        if [ ! -d "$input_dir" ]; then
            echo -e "${RED}❌ 错误：目录不存在${NC}"
            exit 1
        fi
        echo ""
        echo -e "${BLUE}开始识别...${NC}"
        python3 tshirt_color_detector.py "$input_dir"
        ;;
    2)
        echo ""
        read -p "请输入图片目录路径: " input_dir
        if [ ! -d "$input_dir" ]; then
            echo -e "${RED}❌ 错误：目录不存在${NC}"
            exit 1
        fi
        read -p "请输入白色T恤输出目录: " output_dir
        echo ""
        echo -e "${BLUE}开始识别并保存...${NC}"
        python3 tshirt_color_detector.py "$input_dir" --output "$output_dir"
        ;;
    3)
        echo ""
        read -p "请输入图片目录路径: " input_dir
        if [ ! -d "$input_dir" ]; then
            echo -e "${RED}❌ 错误：目录不存在${NC}"
            exit 1
        fi
        read -p "请输入白色T恤输出目录: " output_dir
        echo ""
        echo -e "${BLUE}开始自动分类...${NC}"
        python3 tshirt_color_detector.py "$input_dir" --output "$output_dir" --move
        ;;
    4)
        echo ""
        read -p "请输入要调试的图片路径: " image_path
        if [ ! -f "$image_path" ]; then
            echo -e "${RED}❌ 错误：文件不存在${NC}"
            exit 1
        fi
        echo ""
        echo -e "${BLUE}生成可视化...${NC}"
        python3 tshirt_color_detector.py --visualize "$image_path"
        ;;
    5)
        echo ""
        cat tshirt_detector_README.md
        ;;
    *)
        echo -e "${RED}❌ 无效选项${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ 完成！${NC}"
