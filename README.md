# T恤颜色识别器 🎨

自动识别图片中的T恤是否为白色，帮你快速筛选出白色T恤。

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-green.svg)
![OpenCV](https://img.shields.io/badge/opencv-4.x-orange.svg)

## ✨ 功能特性

- ✅ **批量处理** - 一键扫描整个目录的图片
- ✅ **智能识别** - 基于HSV色彩空间的高精度白色检测
- ✅ **聚焦主体** - 自动聚焦图片中心区域，排除背景干扰
- ✅ **自动分类** - 将白色T恤和非白色T恤分别保存
- ✅ **可调参数** - 自定义颜色阈值，适应不同场景
- ✅ **可视化调试** - 可视化白色区域，方便调整参数

## 📸 效果演示

### 问题背景
从电商网站（Temu、淘宝等）批量下载T恤图片后，需要筛选出白色T恤。手动筛选耗时耗力，自动识别可以大大提高效率。

### 识别原理

**核心算法：**
1. 裁剪图片中心区域（默认50%），聚焦T恤主体，排除背景干扰
2. 转换到HSV色彩空间（色相、饱和度、亮度）
3. 检测白色像素：
   - 色相（H）：任意（0-180）
   - 饱和度（S）：很低（<30）- 白色几乎无色彩
   - 亮度（V）：很高（>180）- 白色很亮
4. 如果白色像素占比超过阈值（默认60%），判定为白色T恤

**优化点：**
- 🎯 聚焦中心区域 - 排除模特皮肤、摄影棚背景等边缘干扰
- 🌈 HSV色彩空间 - 比RGB更符合人类感知
- ⚙️ 可调阈值 - 适应不同光照和摄影风格

## 🚀 快速开始

### 安装依赖

```bash
# 克隆仓库
git clone https://github.com/blank-knight/tshirt-color-detector.git
cd tshirt-color-detector

# 激活虚拟环境
source venv_tshirt/bin/activate  # Linux/Mac
# 或
venv_tshirt\Scripts\activate  # Windows

# 安装依赖（如果虚拟环境不存在）
pip install -r requirements.txt
```

**依赖包：**
- opencv-python >= 4.5.0
- numpy >= 1.19.0

### 基本使用

```bash
# 激活虚拟环境
source venv_tshirt/bin/activate

# 运行识别（只显示结果，不移动文件）
python3 tshirt_color_detector.py /path/to/your/images
```

**示例输出：**
```
处理图片目录: /path/to/your/images
白色阈值参数:
  - 最小亮度: 180
  - 最大饱和度: 30
  - 最小白色比例: 0.6
  - 中心区域裁剪比例: 50%

✅ 白色: img_001.jpg (白色比例: 79.04%)
❌ 非白色: img_002.jpg (白色比例: 1.41%)
✅ 白色: img_003.jpg (白色比例: 89.67%)

==================================================
处理完成！
==================================================
总图片数: 17
白色T恤: 12
非白色T恤: 5
==================================================
```

## 📂 进阶使用

### 1. 保存白色T恤到指定目录

```bash
python3 tshirt_color_detector.py /path/to/images \
  --output /path/to/white_tshirts
```

白色T恤会被复制到指定目录。

### 2. 自动分类（白色和非白色分开存放）

```bash
python3 tshirt_color_detector.py /path/to/images \
  --output /path/to/white_tshirts \
  --move
```

这会创建两个目录：
- `white_tshirts/` - 白色T恤
- `non_white_tshirts/` - 非白色T恤

### 3. 自定义颜色阈值

如果识别不准确，可以调整参数：

```bash
python3 tshirt_color_detector.py /path/to/images \
  --min-brightness 170 \    # 降低亮度阈值（更容易识别为白色）
  --max-saturation 40 \     # 提高饱和度阈值（允许更多"偏白"的颜色）
  --min-ratio 0.5           # 降低白色比例要求（更宽松）
```

### 4. 调整聚焦区域大小

```bash
# 更小的中心区域（40%），更严格排除背景
python3 tshirt_color_detector.py /path/to/images \
  --focus-ratio 0.4

# 更大的中心区域（60%），更宽松
python3 tshirt_color_detector.py /path/to/images \
  --focus-ratio 0.6
```

### 5. 调试：可视化白色区域

```bash
python3 tshirt_color_detector.py \
  --visualize /path/to/some/image.jpg
```

这会生成一张新图片，白色区域用绿色标记，方便你调试参数。

## ⚙️ 参数说明

| 参数 | 默认值 | 说明 | 适用场景 |
|------|--------|------|---------|
| `--min-brightness` | 180 | 最小亮度（0-255），白色应该很亮 | 光线较暗时降低此值 |
| `--max-saturation` | 30 | 最大饱和度（0-255），白色饱和度很低 | 允许米白色/浅灰色时提高此值 |
| `--min-ratio` | 0.6 | 白色像素最小比例（0-1），白色部分占图片的比例 | T恤占比小时降低此值 |
| `--focus-ratio` | 0.5 | 中心区域裁剪比例（0-1），T恤主体区域占比 | 背景干扰大时降低此值 |

## 💡 使用技巧

### 1. 提高识别准确度

- 📸 **正面照片** - 确保T恤正面朝向镜头
- 🌞 **光线充足** - 避免阴影影响颜色判断
- 🎯 **主体突出** - T恤占图片主要面积
- 🖼️ **背景简洁** - 避免复杂背景干扰

### 2. 参数调整建议

**场景1：识别太严格（漏掉白色T恤）**
```bash
--min-ratio 0.5 --max-saturation 40 --min-brightness 170
```

**场景2：识别太宽松（误判非白色）**
```bash
--min-ratio 0.7 --max-saturation 20 --min-brightness 190
```

**场景3：背景干扰严重**
```bash
--focus-ratio 0.4  # 只取中心40%区域
```

**场景4：T恤在图片中占比小**
```bash
--focus-ratio 0.7  # 扩大到中心70%区域
--min-ratio 0.5    # 降低白色比例要求
```

### 3. 批量处理流程

```bash
# 1. 从电商网站下载图片到 ~/temu_images/
# 2. 运行识别并分类
python3 tshirt_color_detector.py ~/temu_images \
  --output ~/white_tshirts \
  --move \
  --focus-ratio 0.5

# 3. 查看结果
ls ~/white_tshirts/          # 筛选出的白色T恤
ls ~/non_white_tshirts/      # 其他颜色的T恤

# 4. 人工复核（可选）
# 打开两个文件夹对比查看，确认无误
```

## 🧪 实战案例

### Temu白色T恤筛选

**背景：** 从Temu下载了17张"白色印花短袖圆领T恤"的商品图片

**初次识别（全图计算）：**
```
白色T恤：3张
非白色T恤：14张
问题：背景干扰导致识别不准确
```

**优化识别（聚焦中心50%区域）：**
```bash
python3 tshirt_color_detector.py /path/to/temu_images \
  --output /path/to/white_tshirts \
  --move \
  --focus-ratio 0.5
```

**结果：**
```
白色T恤：12张
非白色T恤：5张
准确度大幅提升！
```

## 📝 快速参考

### 常用命令

```bash
# 基本识别
python3 tshirt_color_detector.py /path/to/images

# 分类保存
python3 tshirt_color_detector.py /path/to/images --output /path/output --move

# 调试模式
python3 tshirt_color_detector.py --visualize /path/to/image.jpg

# 自定义参数
python3 tshirt_color_detector.py /path/to/images \
  --min-brightness 170 \
  --max-saturation 40 \
  --min-ratio 0.5 \
  --focus-ratio 0.4
```

### Windows用户

```batch
# 激活虚拟环境
venv_tshirt\Scripts\activate

# 运行识别（注意路径格式）
python tshirt_color_detector.py C:\Users\YourName\Downloads\images

# 使用WSL访问Windows路径（推荐）
python3 tshirt_color_detector.py /mnt/c/Users/YourName/Downloads/images
```

## 🔧 开发说明

### 项目结构

```
tshirt-color-detector/
├── tshirt_color_detector.py   # 主程序
├── requirements.txt            # 依赖列表
├── README.md                   # 本文档
├── venv_tshirt/               # Python虚拟环境（git忽略）
└── demo/                       # 示例图片（可选）
```

### 核心算法

```python
# 1. 裁剪中心区域
cropped = crop_center(img, focus_ratio)

# 2. 转换到HSV色彩空间
hsv = cv2.cvtColor(cropped, cv2.COLOR_BGR2HSV)

# 3. 检测白色像素
white_mask = cv2.inRange(hsv, WHITE_LOWER, WHITE_UPPER)

# 4. 计算白色比例
white_ratio = np.count_nonzero(white_mask) / total_pixels

# 5. 判断是否白色T恤
is_white = white_ratio >= min_ratio
```

## 🤝 贡献

欢迎提交Issue和Pull Request！

### 开发环境搭建

```bash
git clone https://github.com/blank-knight/tshirt-color-detector.git
cd tshirt-color-detector
python3 -m venv venv_tshirt
source venv_tshirt/bin/activate
pip install -r requirements.txt
```

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🙏 致谢

- [OpenCV](https://opencv.org/) - 计算机视觉库
- [NumPy](https://numpy.org/) - 科学计算库

## 📧 联系方式

- 作者：blank-knight
- GitHub：https://github.com/blank-knight
- 邮箱：846735605@qq.com

---

**觉得有用？给个Star吧！⭐**
