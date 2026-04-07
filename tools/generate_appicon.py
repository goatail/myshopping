import json
import os
from PIL import Image


def px(size: float, scale: int) -> int:
    return int(round(float(size) * float(scale)))


def main() -> None:
    # Android 自适应图标：前景是透明 PNG/WebP + 背景色。
    # iOS AppIcon 需要不透明，这里用“前景图层 + 纯白底”来去除 Android 的绿色背景。
    foreground = r"f:\testflow-release\myshopping\myshoppingios\MyShoppingAndroid\app\src\main\res\mipmap-xxxhdpi\ic_launcher_foreground.webp"
    dst_dir = r"f:\testflow-release\myshopping\myshoppingios\myshopping\Assets.xcassets\AppIcon.appiconset"
    os.makedirs(dst_dir, exist_ok=True)

    fg = Image.open(foreground).convert("RGBA")

    # 先合成 1024 的母图（白底 + 前景居中铺满）
    base = Image.new("RGBA", (1024, 1024), (255, 255, 255, 255))
    fg_1024 = fg.resize((1024, 1024), Image.Resampling.LANCZOS)
    base.alpha_composite(fg_1024)
    im = base

    # iOS AppIcon set (common Xcode template)
    specs: list[tuple[str, float, int]] = [
        # iPhone
        ("iphone", 20, 2),
        ("iphone", 20, 3),
        ("iphone", 29, 2),
        ("iphone", 29, 3),
        ("iphone", 40, 2),
        ("iphone", 40, 3),
        ("iphone", 60, 2),
        ("iphone", 60, 3),
        # iPad
        ("ipad", 20, 1),
        ("ipad", 20, 2),
        ("ipad", 29, 1),
        ("ipad", 29, 2),
        ("ipad", 40, 1),
        ("ipad", 40, 2),
        ("ipad", 76, 1),
        ("ipad", 76, 2),
        ("ipad", 83.5, 2),
        # App Store
        ("ios-marketing", 1024, 1),
    ]

    images: list[dict[str, str]] = []
    for idiom, size, scale in specs:
        pixels = px(size, scale)
        size_str = f"{size}x{size}"
        filename = f"AppIcon-{idiom}-{size_str}@{scale}x.png"
        out_path = os.path.join(dst_dir, filename)

        out = im.resize((pixels, pixels), Image.Resampling.LANCZOS)
        out.save(out_path, format="PNG", optimize=True)

        images.append(
            {
                "idiom": idiom,
                "size": size_str,
                "scale": f"{scale}x",
                "filename": filename,
            }
        )

    contents = {"images": images, "info": {"author": "xcode", "version": 1}}
    with open(os.path.join(dst_dir, "Contents.json"), "w", encoding="utf-8") as f:
        json.dump(contents, f, ensure_ascii=False, indent=2)

    print(f"generated {len(images)} icons into {dst_dir}")


if __name__ == "__main__":
    main()

