"""Build the simplified StatOz Instagram carousel from exact app screenshots."""

from __future__ import annotations

import zipfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SHOT_DIR = ROOT / "output" / "screenshots" / "statoz"
OUT_DIR = ROOT / "output" / "marketing" / "instagram"
W, H = 1080, 1350

DISPLAY = ROOT / "assets" / "fonts" / "Orbitron-VariableFont_wght.ttf"
BODY = ROOT / "assets" / "fonts" / "Onest-VariableFont_wght.ttf"
LOGO = ROOT / "assets" / "icons" / "app_logo.png"

BG = (5, 13, 26, 255)
CYAN = (73, 217, 255, 255)
MAGENTA = (255, 73, 197, 255)
GOLD = (244, 201, 93, 255)
GREEN = (71, 225, 151, 255)
MUTED = (148, 165, 190, 255)
WHITE = (242, 247, 255, 255)


def font(path: Path, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(path), size=size)


def display_font(size: int, weight: int = 400) -> ImageFont.FreeTypeFont:
    face = font(DISPLAY, size)
    face.set_variation_by_axes([weight])
    return face


def text_width(draw: ImageDraw.ImageDraw, value: str, face: ImageFont.FreeTypeFont) -> int:
    return draw.textbbox((0, 0), value, font=face)[2]


def wrap(draw: ImageDraw.ImageDraw, value: str, face: ImageFont.FreeTypeFont, width: int) -> list[str]:
    words, lines, current = value.split(), [], ""
    for word in words:
        candidate = f"{current} {word}".strip()
        if current and text_width(draw, candidate, face) > width:
            lines.append(current)
            current = word
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def rounded_mask(size: tuple[int, int], radius: int) -> Image.Image:
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255)
    return mask


def background(accent: tuple[int, int, int, int], glow_x: int) -> Image.Image:
    canvas = Image.new("RGBA", (W, H), BG)
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow, "RGBA")
    draw.ellipse((glow_x - 380, 270, glow_x + 380, 1030), fill=(*accent[:3], 46))
    canvas.alpha_composite(glow.filter(ImageFilter.GaussianBlur(105)))
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.line((64, 92, W - 64, 92), fill=(*accent[:3], 80), width=2)
    draw.line((64, H - 64, W - 64, H - 64), fill=(255, 255, 255, 28), width=1)
    return canvas


def header(canvas: Image.Image, index: int, accent: tuple[int, int, int, int]) -> None:
    draw = ImageDraw.Draw(canvas, "RGBA")
    logo = Image.open(LOGO).convert("RGBA")
    logo.thumbnail((42, 42), Image.Resampling.LANCZOS)
    canvas.alpha_composite(logo, (64, 33))
    draw.text((118, 42), "StatOz", fill=WHITE, font=font(DISPLAY, 24))
    draw.text((W - 64, 45), f"0{index} / 05", fill=(*accent[:3], 230), font=font(DISPLAY, 15), anchor="ra")


def copy_block(canvas: Image.Image, kicker: str, headline: str, support: str, accent: tuple[int, int, int, int]) -> None:
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.text((W // 2, 138), kicker, fill=accent, font=font(DISPLAY, 16), anchor="ma")
    title_face = display_font(48, 800)
    lines = wrap(draw, headline, title_face, 900)
    y = 180
    for line in lines:
        draw.text((W // 2, y), line, fill=WHITE, font=title_face, anchor="ma")
        y += 56
    draw.text((W // 2, y + 10), support, fill=MUTED, font=font(BODY, 22), anchor="ma")


def phone_mockup(canvas: Image.Image, screenshot: Path, accent: tuple[int, int, int, int], x: int = 350, y: int = 370, phone_width: int = 380) -> None:
    source = Image.open(screenshot).convert("RGBA")
    screen_width = phone_width - 28
    screen_height = round(source.height * screen_width / source.width)
    phone_height = screen_height + 28

    shadow = Image.new("RGBA", (phone_width + 90, phone_height + 90), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow, "RGBA")
    shadow_draw.rounded_rectangle((45, 45, phone_width + 44, phone_height + 44), radius=54, fill=(0, 0, 0, 220))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(25)), (x - 45, y - 22))

    device = Image.new("RGBA", (phone_width, phone_height), (0, 0, 0, 0))
    device_draw = ImageDraw.Draw(device, "RGBA")
    device_draw.rounded_rectangle((0, 0, phone_width - 1, phone_height - 1), radius=49, fill=(3, 8, 16, 255), outline=(*accent[:3], 180), width=3)
    device_draw.rounded_rectangle((8, 8, phone_width - 9, phone_height - 9), radius=42, outline=(255, 255, 255, 44), width=1)
    source = source.resize((screen_width, screen_height), Image.Resampling.LANCZOS)
    clipped = Image.new("RGBA", source.size, (0, 0, 0, 0))
    clipped.paste(source, (0, 0), rounded_mask(source.size, 35))
    device.alpha_composite(clipped, (14, 14))
    device_draw.rounded_rectangle((phone_width // 2 - 46, 20, phone_width // 2 + 46, 29), radius=5, fill=(1, 4, 9, 255))
    device_draw.rounded_rectangle((phone_width // 2 - 37, phone_height - 30, phone_width // 2 + 37, phone_height - 25), radius=4, fill=(255, 255, 255, 58))
    canvas.alpha_composite(device, (x, y))

    edge = Image.new("RGBA", (phone_width, phone_height), (0, 0, 0, 0))
    ImageDraw.Draw(edge, "RGBA").rounded_rectangle((3, 3, phone_width - 4, phone_height - 4), radius=47, outline=(*accent[:3], 150), width=3)
    canvas.alpha_composite(edge.filter(ImageFilter.GaussianBlur(10)), (x, y))


def footer(canvas: Image.Image, index: int, label: str, accent: tuple[int, int, int, int]) -> None:
    draw = ImageDraw.Draw(canvas, "RGBA")
    draw.text((64, H - 43), f"0{index}  //  {label}", fill=accent, font=font(DISPLAY, 14))
    draw.text((W - 64, H - 43), "STATOZ", fill=MUTED, font=font(DISPLAY, 14), anchor="ra")


SLIDES = [
    ("LIVE SPORTS, ONE ARENA", "SPORTS, PLAYED DIFFERENT.", "Follow the action. Make your move.", "002_sports__match-hub__trending.png", CYAN, "ENTER THE ARENA", 540),
    ("FIVE SPORTS. EIGHTEEN GAMES.", "YOUR SPORT. YOUR GAME.", "Choose a lane. Chase the next win.", "009_games__games-hub__trending.png", MAGENTA, "PICK YOUR SPORT", 650),
    ("SEE THE GAME CLEARLY", "MAKE THE CALL.", "See the story behind the score.", "049_match-tabs__football__stats.png", CYAN, "BACK YOUR INSTINCT", 410),
    ("QUICK PLAY. REAL CHALLENGE.", "PICK YOUR CHALLENGE.", "Arcade sport made for the replay.", "016_games__penalty-shootout__entry.png", GOLD, "PLAY YOUR WAY", 670),
    ("XP. RIVALS. RANK.", "CLIMB THE BOARD.", "Every session moves you forward.", "040_leaderboards__top__rankings.png", GREEN, "DISCOVER STATOZ", 540),
]


def build_slide(index: int, spec: tuple) -> Image.Image:
    kicker, headline, support, screen, accent, footer_text, glow_x = spec
    canvas = background(accent, glow_x)
    header(canvas, index, accent)
    copy_block(canvas, kicker, headline, support, accent)
    phone_mockup(canvas, SHOT_DIR / screen, accent)
    footer(canvas, index, footer_text, accent)
    return canvas


def write_copy() -> None:
    content = """# StatOz Instagram Carousel\n\n## Slide copy\n\n1. **SPORTS, PLAYED DIFFERENT.**\n   Follow the action. Make your move.\n\n2. **YOUR SPORT. YOUR GAME.**\n   Choose a lane. Chase the next win.\n\n3. **MAKE THE CALL.**\n   See the story behind the score.\n\n4. **PICK YOUR CHALLENGE.**\n   Arcade sport made for the replay.\n\n5. **CLIMB THE BOARD.**\n   Every session moves you forward.\n\n## Campaign caption\n\nSports are more fun when your decisions count. StatOz puts live match insight, quick-fire games, XP, and rivalries in one cyber arena. Choose your sport, make your move, and climb higher.\n\nDiscover StatOz.\n\n#StatOz #SportsGaming #FootballGaming #CricketGaming #BasketballGaming #TennisGaming #Motorsport #SportsFans #GameOn\n"""
    (OUT_DIR / "statoz-carousel-copy.md").write_text(content, encoding="utf-8")


def contact_sheet(paths: list[Path]) -> None:
    thumb_width, thumb_height = 250, 313
    sheet = Image.new("RGBA", (thumb_width * 5 + 64, thumb_height + 110), BG)
    draw = ImageDraw.Draw(sheet, "RGBA")
    draw.text((32, 30), "STATOZ // INSTAGRAM CAROUSEL", fill=CYAN, font=font(DISPLAY, 17))
    for index, path in enumerate(paths):
        with Image.open(path) as source:
            thumb = ImageOps.contain(source.convert("RGBA"), (thumb_width, thumb_height), Image.Resampling.LANCZOS)
        sheet.alpha_composite(thumb, (32 + index * thumb_width, 76))
    sheet.convert("RGB").save(OUT_DIR / "statoz-carousel-contact-sheet.png", optimize=True)


def package(paths: list[Path]) -> None:
    with zipfile.ZipFile(OUT_DIR / "statoz-instagram-carousel.zip", "w", compression=zipfile.ZIP_DEFLATED) as archive:
        for path in paths:
            archive.write(path, path.name)
        archive.write(OUT_DIR / "statoz-carousel-copy.md", "statoz-carousel-copy.md")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    paths = []
    for index, spec in enumerate(SLIDES, start=1):
        path = OUT_DIR / f"statoz-carousel-{index:02d}.png"
        build_slide(index, spec).convert("RGB").save(path, format="PNG", optimize=True)
        paths.append(path)
    write_copy()
    contact_sheet(paths)
    package(paths)
    print(f"Wrote {len(paths)} revised carousel frames to {OUT_DIR}")


if __name__ == "__main__":
    main()
