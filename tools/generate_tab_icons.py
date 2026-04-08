import json
import os
from PIL import Image, ImageDraw


ROOT = r"f:\testflow-release\myshopping\myshoppingios\myshopping\Assets.xcassets"


def write_imageset(name: str, img: Image.Image) -> None:
    folder = os.path.join(ROOT, f"{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    png = f"{name}.png"
    img.save(os.path.join(folder, png), format="PNG", optimize=True)
    contents = {
        "images": [
            {"filename": png, "idiom": "universal", "scale": "1x"},
            {"idiom": "universal", "scale": "2x"},
            {"idiom": "universal", "scale": "3x"},
        ],
        "info": {"author": "xcode", "version": 1},
    }
    with open(os.path.join(folder, "Contents.json"), "w", encoding="utf-8") as f:
        json.dump(contents, f, ensure_ascii=False, indent=2)


def canvas(size: int = 96) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    return im, ImageDraw.Draw(im)


def stroke(draw: ImageDraw.ImageDraw, width: int) -> int:
    # Pillow stroke width for lines/rounded rectangles
    return width


def icon_home(size: int = 96) -> Image.Image:
    im, d = canvas(size)
    w = max(4, size // 12)
    pad = size // 6
    roof = [
        (size // 2, pad),
        (pad, size // 2),
        (pad + w, size // 2),
        (size // 2, pad + w),
        (size - pad - w, size // 2),
        (size - pad, size // 2),
    ]
    d.line(roof + [roof[0]], fill=(0, 0, 0, 255), width=w, joint="curve")
    # house body
    body = [pad + w, size // 2, size - pad - w, size - pad]
    d.rectangle(body, outline=(0, 0, 0, 255), width=w)
    # door
    door_w = size // 6
    door = [size // 2 - door_w // 2, size - pad - size // 3, size // 2 + door_w // 2, size - pad]
    d.rectangle(door, outline=(0, 0, 0, 255), width=w)
    return im


def icon_heart(size: int = 96) -> Image.Image:
    im, d = canvas(size)
    w = max(4, size // 12)
    # simple heart using two circles + triangle-ish bottom
    r = size // 5
    cx1, cy = size // 2 - r, size // 2 - r // 2
    cx2 = size // 2 + r
    d.ellipse([cx1 - r, cy - r, cx1 + r, cy + r], outline=(0, 0, 0, 255), width=w)
    d.ellipse([cx2 - r, cy - r, cx2 + r, cy + r], outline=(0, 0, 0, 255), width=w)
    bottom = [(size // 2 - 2 * r, cy), (size // 2, size - size // 5), (size // 2 + 2 * r, cy)]
    d.line(bottom + [bottom[0]], fill=(0, 0, 0, 255), width=w, joint="curve")
    return im


def icon_cart(size: int = 96) -> Image.Image:
    im, d = canvas(size)
    w = max(4, size // 12)
    pad = size // 6
    # basket
    top = pad + size // 5
    d.rectangle([pad + size // 6, top, size - pad, size - pad - size // 5], outline=(0, 0, 0, 255), width=w)
    # handle
    d.line([(pad, top), (pad + size // 5, top)], fill=(0, 0, 0, 255), width=w)
    d.line([(pad + size // 5, top), (pad + size // 4, pad)], fill=(0, 0, 0, 255), width=w)
    # wheels
    r = size // 12
    y = size - pad - r
    d.ellipse([pad + size // 3 - r, y - r, pad + size // 3 + r, y + r], outline=(0, 0, 0, 255), width=w)
    d.ellipse([size - pad - size // 6 - r, y - r, size - pad - size // 6 + r, y + r], outline=(0, 0, 0, 255), width=w)
    return im


def icon_person(size: int = 96) -> Image.Image:
    im, d = canvas(size)
    w = max(4, size // 12)
    # head
    r = size // 6
    cx, cy = size // 2, size // 2 - r
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=(0, 0, 0, 255), width=w)
    # body
    body_w = size // 2
    body_h = size // 3
    x1 = cx - body_w // 2
    y1 = cy + r + size // 16
    x2 = cx + body_w // 2
    y2 = y1 + body_h
    d.rounded_rectangle([x1, y1, x2, y2], radius=size // 10, outline=(0, 0, 0, 255), width=w)
    return im


def main() -> None:
    os.makedirs(ROOT, exist_ok=True)
    write_imageset("tab_home", icon_home())
    write_imageset("tab_favorite", icon_heart())
    write_imageset("tab_cart", icon_cart())
    write_imageset("tab_profile", icon_person())
    print("generated tab icons")


if __name__ == "__main__":
    main()

