# T恤颜色识别器 🎨

自动识别图片中的T恤是否为白色，帮你筛选出白色T恤。

## 功能

✅ 批量处理图片目录
✅ 自动识别白色T恤
✅ 将白色T恤和非白色T恤分类存放
✅ 可视化白色区域（调试用）
✅ 可自定义颜色阈值参数

## 安装依赖

```bash
# 激活虚拟环境（已预装）
source venv_tshirt/bin/activate

# 如果需要重新安装
pip install opencv-python numpy
```

## 使用方法

### 1. 基本用法 - 筛选白色T恤

```bash
# 将你的T恤图片放到一个目录，比如 ~/tshirt_images
python3 tshirt_color_detector.py ~/tshirt_images
```

这会：
- 扫描目录中的所有图片
- 判断每张图片是否是白色T恤
- 显示每张图片的识别结果

### 2. 保存白色T恤到指定目录

```bash
python3 tshirt_color_detector.py ~/tshirt_images --output ~/white_tshirts
```

白色T恤会被复制到 `~/white_tshirts` 目录。

### 3. 自动分类（白色和非白色分开存放）

```bash
python3 tshirt_color_detector.py ~/tshirt_images --output ~/white_tshirts --move
```

这会创建两个目录：
- `~/white_tshirts/` - 白色T恤
- `~/non_white_tshirts/` - 非白色T恤

### 4. 调试：可视化白色区域

```bash
python3 tshirt_color_detector.py --visualize /path/to/some/image.jpg
```

这会生成一张新图片，白色区域用绿色标记，方便你调试参数。

### 5. 自定义颜色阈值

如果识别不准确，可以调整参数：

```bash
python3 tshirt_color_detector.py ~/tshirt_images \
  --min-brightness 170 \    # 降低亮度阈值（更容易识别为白色）
  --max-saturation 40 \     # 提高饱和度阈值（允许更多"偏白"的颜色）
  --min-ratio 0.5           # 降低白色比例要求（更宽松）
```

## 参数说明

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--min-brightness` | 180 | 最小亮度（0-255），白色应该很亮 |
| `--max-saturation` | 30 | 最大饱和度（0-255），白色饱和度很低 |
| `--min-ratio` | 0.6 | 白色像素最小比例（0-1），白色部分占图片的比例 |

## 工作原理

1. **HSV色彩空间**：将图片转换到HSV（色相、饱和度、亮度）空间
2. **白色检测**：
   - 色相（H）：任意（0-180）
   - 饱和度（S）：很低（<30）- 白色几乎无色彩
   - 亮度（V）：很高（>180）- 白色很亮
3. **比例判断**：如果白色像素占主体像素的比例超过60%，认为是白色T恤

## 注意事项

- 📸 图片最好是**正面的T恤照片**，不要有过多背景干扰
- 🌈 如果T恤有**彩色图案**，只要底色是白色也能识别
- 📏 建议图片**主体突出**，T恤占主要面积
- 🎨 如果识别不准，可以调整`--min-brightness`和`--max-saturation`参数

## 示例

```bash
# 快速测试
source venv_tshirt/bin/activate

# 把Temu下载的图片放到 ~/tshirt_images
mkdir -p ~/tshirt_images

# 运行识别
python3 tshirt_color_detector.py ~/tshirt_images --output ~/white_tshirts --move

# 查看结果
ls ~/white_tshirts/          # 白色T恤
ls ~/non_white_tshirts/      # 非白色T恤
```

## 问题？

如果识别效果不好，可以：

1. 先用 `--visualize` 调试单张图片
2. 调整 `--min-brightness`、`--max-saturation`、`--min-ratio` 参数
3. 确保图片主体是T恤正面

---

需要帮助？随时叫我！ ✨
