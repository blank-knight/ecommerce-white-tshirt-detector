#!/bin/bash
# 修复换行符问题 - 仅在WSL/Linux下运行

echo "正在修复换行符..."

# 使用sed删除所有\r字符
sed -i 's/\r$//' run_tshirt_detector.sh

echo "✅ 换行符已修复！"
echo ""
echo "现在可以运行："
echo "  ./run_tshirt_detector.sh"
