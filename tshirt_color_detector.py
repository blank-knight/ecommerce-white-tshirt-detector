#!/usr/bin/env python3
"""
T恤颜色识别器
自动识别图片中的T恤是否为白色
"""

import os
import sys
import cv2
import numpy as np
from pathlib import Path
from typing import Tuple, List
import argparse

# 白色识别参数（可调整）
WHITE_MIN_BRIGHTNESS = 180  # 最小亮度 (0-255)
WHITE_MAX_SATURATION = 30   # 最大饱和度 (0-255)，白色饱和度应该很低
WHITE_MIN_RATIO = 0.6       # 白色像素占主体像素的最小比例

# 聚焦中心区域参数
FOCUS_CROP_RATIO = 0.5     # 裁剪中心区域的比例（0.5表示只取中间50%的区域）
# 这样可以排除边缘的背景干扰，只聚焦T恤主体

# 颜色范围（HSV）
WHITE_LOWER = np.array([0, 0, WHITE_MIN_BRIGHTNESS])
WHITE_UPPER = np.array([180, WHITE_MAX_SATURATION, 255])


def load_image(image_path: str) -> np.ndarray:
    """加载图片"""
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"无法加载图片: {image_path}")
    return img


def crop_center(img: np.ndarray, crop_ratio: float = FOCUS_CROP_RATIO) -> np.ndarray:
    """
    裁剪图片的中心区域

    参数:
        img: 输入图片
        crop_ratio: 裁剪比例，0.5表示取中间50%的区域

    返回: 裁剪后的中心区域图片
    """
    h, w = img.shape[:2]

    # 计算裁剪区域
    new_h = int(h * crop_ratio)
    new_w = int(w * crop_ratio)

    # 计算起始点（使裁剪区域居中）
    start_y = (h - new_h) // 2
    start_x = (w - new_w) // 2

    # 裁剪中心区域
    cropped = img[start_y:start_y + new_h, start_x:start_x + new_w]

    return cropped


def detect_white_pixels(img: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    检测图片中的白色像素

    返回: (白色掩码, 白色像素比例)
    """
    # 裁剪中心区域（排除背景干扰）
    cropped = crop_center(img, FOCUS_CROP_RATIO)

    # 转换到HSV色彩空间
    hsv = cv2.cvtColor(cropped, cv2.COLOR_BGR2HSV)

    # 创建白色掩码
    white_mask = cv2.inRange(hsv, WHITE_LOWER, WHITE_UPPER)

    # 计算白色像素比例
    white_pixels = np.count_nonzero(white_mask)
    total_pixels = white_mask.shape[0] * white_mask.shape[1]
    white_ratio = white_pixels / total_pixels

    return white_mask, white_ratio


def is_white_tshirt(img: np.ndarray, min_ratio: float = WHITE_MIN_RATIO) -> Tuple[bool, float]:
    """
    判断是否为白色T恤

    返回: (是否白色, 白色像素比例)
    """
    white_mask, white_ratio = detect_white_pixels(img)

    # 简单判断：如果白色像素比例超过阈值，认为是白色
    is_white = white_ratio >= min_ratio

    return is_white, white_ratio


def process_images(
    input_dir: str,
    output_dir: str = None,
    move_non_white: bool = True,
    verbose: bool = True
) -> dict:
    """
    批量处理图片

    参数:
        input_dir: 输入图片目录
        output_dir: 白色T恤输出目录（可选，不指定则不移动）
        move_non_white: 是否将非白色T恤移动到其他目录
        verbose: 是否打印详细信息

    返回: 统计信息
    """
    input_path = Path(input_dir)
    if not input_path.exists():
        raise ValueError(f"输入目录不存在: {input_dir}")

    # 支持的图片格式
    image_extensions = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}

    # 获取所有图片文件
    image_files = [f for f in input_path.iterdir()
                   if f.suffix.lower() in image_extensions and f.is_file()]

    if not image_files:
        print(f"在 {input_dir} 中没有找到图片文件")
        return {"total": 0, "white": 0, "non_white": 0}

    # 创建输出目录
    white_dir = None
    non_white_dir = None

    if output_dir:
        white_dir = Path(output_dir)
        white_dir.mkdir(exist_ok=True)
        non_white_dir = white_dir.parent / "non_white_tshirts"
        non_white_dir.mkdir(exist_ok=True)

    # 统计信息
    stats = {
        "total": len(image_files),
        "white": 0,
        "non_white": 0,
        "white_files": [],
        "non_white_files": []
    }

    # 处理每张图片
    for img_file in image_files:
        try:
            img = load_image(str(img_file))
            is_white, white_ratio = is_white_tshirt(img)

            if is_white:
                stats["white"] += 1
                stats["white_files"].append(str(img_file))

                if white_dir and move_non_white:
                    # 保持白色T恤在原目录或移动到white_dir
                    new_path = white_dir / img_file.name
                    cv2.imwrite(str(new_path), img)

                if verbose:
                    print(f"✅ 白色: {img_file.name} (白色比例: {white_ratio:.2%})")

            else:
                stats["non_white"] += 1
                stats["non_white_files"].append(str(img_file))

                if non_white_dir and move_non_white:
                    # 移动非白色T恤
                    new_path = non_white_dir / img_file.name
                    cv2.imwrite(str(new_path), img)
                    # 删除原文件（可选）
                    # img_file.unlink()

                if verbose:
                    print(f"❌ 非白色: {img_file.name} (白色比例: {white_ratio:.2%})")

        except Exception as e:
            print(f"⚠️  处理失败 {img_file.name}: {e}")
            continue

    return stats


def visualize_white_pixels(image_path: str, output_path: str = None):
    """
    可视化白色区域（用于调试）

    将白色区域标记为绿色，显示在裁剪后的中心区域
    """
    img = load_image(image_path)

    # 裁剪中心区域
    cropped = crop_center(img, FOCUS_CROP_RATIO)

    # 检测白色
    hsv = cv2.cvtColor(cropped, cv2.COLOR_BGR2HSV)
    white_mask = cv2.inRange(hsv, WHITE_LOWER, WHITE_UPPER)

    # 计算白色像素比例
    white_pixels = np.count_nonzero(white_mask)
    total_pixels = white_mask.shape[0] * white_mask.shape[1]
    white_ratio = white_pixels / total_pixels

    # 创建可视化图片
    result = cropped.copy()
    result[white_mask > 0] = [0, 255, 0]  # 绿色标记白色区域

    # 保存结果
    if output_path is None:
        output_path = image_path.replace('.', '_white_mask.')

    cv2.imwrite(output_path, result)
    print(f"白色区域可视化已保存到: {output_path}")
    print(f"裁剪区域大小: {cropped.shape}")
    print(f"白色像素比例: {white_ratio:.2%}")


def main():
    global WHITE_MIN_BRIGHTNESS, WHITE_MAX_SATURATION, WHITE_MIN_RATIO
    global WHITE_LOWER, WHITE_UPPER, FOCUS_CROP_RATIO

    parser = argparse.ArgumentParser(description='T恤颜色识别器')
    parser.add_argument('input_dir', help='输入图片目录')
    parser.add_argument('--output', '-o', help='白色T恤输出目录')
    parser.add_argument('--move', action='store_true', help='将非白色T恤移动到non_white_tshirts目录')
    parser.add_argument('--visualize', '-v', help='可视化白色区域（指定单张图片路径）')
    parser.add_argument('--min-brightness', type=int, default=WHITE_MIN_BRIGHTNESS,
                        help=f'最小亮度阈值 (0-255, 默认: {WHITE_MIN_BRIGHTNESS})')
    parser.add_argument('--max-saturation', type=int, default=WHITE_MAX_SATURATION,
                        help=f'最大饱和度阈值 (0-255, 默认: {WHITE_MAX_SATURATION})')
    parser.add_argument('--min-ratio', type=float, default=WHITE_MIN_RATIO,
                        help=f'白色像素最小比例 (0-1, 默认: {WHITE_MIN_RATIO})')
    parser.add_argument('--focus-ratio', type=float, default=FOCUS_CROP_RATIO,
                        help=f'中心区域裁剪比例 (0.1-1.0, 默认: {FOCUS_CROP_RATIO}, 值越大包含越多背景)')

    args = parser.parse_args()

    # 更新全局参数
    WHITE_MIN_BRIGHTNESS = args.min_brightness
    WHITE_MAX_SATURATION = args.max_saturation
    WHITE_MIN_RATIO = args.min_ratio
    FOCUS_CROP_RATIO = args.focus_ratio

    # 更新HSV范围
    WHITE_LOWER = np.array([0, 0, WHITE_MIN_BRIGHTNESS])
    WHITE_UPPER = np.array([180, WHITE_MAX_SATURATION, 255])

    # 可视化模式
    if args.visualize:
        visualize_white_pixels(args.visualize)
        return

    # 批量处理模式
    print(f"处理图片目录: {args.input_dir}")
    print(f"白色阈值参数:")
    print(f"  - 最小亮度: {WHITE_MIN_BRIGHTNESS}")
    print(f"  - 最大饱和度: {WHITE_MAX_SATURATION}")
    print(f"  - 最小白色比例: {WHITE_MIN_RATIO}")
    print(f"  - 中心区域裁剪比例: {FOCUS_CROP_RATIO:.0%}")
    print()

    stats = process_images(
        input_dir=args.input_dir,
        output_dir=args.output,
        move_non_white=args.move,
        verbose=True
    )

    print()
    print("=" * 50)
    print("处理完成！")
    print("=" * 50)
    print(f"总图片数: {stats['total']}")
    print(f"白色T恤: {stats['white']}")
    print(f"非白色T恤: {stats['non_white']}")
    print("=" * 50)

    if args.output:
        print(f"\n白色T恤保存在: {args.output}")
        if args.move:
            print(f"非白色T恤保存在: {args.output}/../non_white_tshirts")


if __name__ == "__main__":
    main()
