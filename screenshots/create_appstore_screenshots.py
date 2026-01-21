"""
App Store Screenshot Generator for NutriLens Pro
Creates professional screenshots with captions for iPhone and iPad
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Screenshot configuration
SCREENSHOTS = [
    {
        "file": "01_scan_screen.png",
        "caption": "Scan Any Barcode",
        "subtitle": "Instantly identify products"
    },
    {
        "file": "02_search_screen.png",
        "caption": "Search Products",
        "subtitle": "Find millions of food items"
    },
    {
        "file": "03_tracker_screen.png",
        "caption": "Track Your Nutrition",
        "subtitle": "Monitor calories & macros"
    },
    {
        "file": "04_profile_screen.png",
        "caption": "View History",
        "subtitle": "All your scanned products"
    },
    {
        "file": "05_product_detail.png",
        "caption": "Detailed Nutrition Info",
        "subtitle": "Know what you eat"
    },
]

# Device configurations
# Apple App Store accepted dimensions:
# - iPhone 6.7": 1284 x 2778px (portrait) or 2778 x 1284px (landscape)
# - iPhone 6.5": 1242 x 2688px (portrait) or 2688 x 1242px (landscape)
# - iPad 12.9": 2048 x 2732px (portrait) or 2732 x 2048px (landscape)
DEVICES = {
    "iphone_67": {
        "output_width": 1284,
        "output_height": 2778,
        "status_bar_crop": 90,  # Android status bar height to crop (increased)
        "corner_radius_ratio": 0.08,
        "phone_height_ratio": 0.80,
        "folder": "iphone"
    },
    "ipad_129": {
        "output_width": 2048,
        "output_height": 2732,
        "status_bar_crop": 50,  # Tablet status bar height (increased)
        "corner_radius_ratio": 0.04,
        "phone_height_ratio": 0.70,
        "folder": "ipad"
    }
}

# Colors
BG_COLOR_START = (19, 163, 100)  # #13A364 - App primary color
BG_COLOR_END = (13, 128, 80)     # #0D8050 - Darker green
TEXT_COLOR = (255, 255, 255)

def create_gradient_background(width, height, color1, color2):
    """Create a vertical gradient background"""
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)

    for y in range(height):
        ratio = y / height
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))

    return img

def add_rounded_corners(img, radius):
    """Add rounded corners to an image"""
    mask = Image.new('L', img.size, 0)
    draw = ImageDraw.Draw(mask)
    draw.rounded_rectangle([(0, 0), (img.size[0]-1, img.size[1]-1)], radius=radius, fill=255)

    output = Image.new('RGBA', img.size, (0, 0, 0, 0))
    output.paste(img, mask=mask)
    return output

def add_shadow(img, offset=(15, 15), blur=40):
    """Add drop shadow to an image"""
    shadow = Image.new('RGBA', (img.width + blur*2 + abs(offset[0]),
                                 img.height + blur*2 + abs(offset[1])), (0, 0, 0, 0))

    shadow_shape = Image.new('RGBA', img.size, (0, 0, 0, 60))
    shadow.paste(shadow_shape, (blur + max(0, offset[0]), blur + max(0, offset[1])))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur//2))

    result = Image.new('RGBA', shadow.size, (0, 0, 0, 0))
    result.paste(shadow, (0, 0))
    result.paste(img, (blur + max(0, -offset[0]), blur + max(0, -offset[1])), img if img.mode == 'RGBA' else None)

    return result

def crop_status_bar(img, crop_height):
    """Crop out the status bar from the top of the screenshot"""
    return img.crop((0, crop_height, img.width, img.height))

def create_screenshot(screenshot_path, output_path, caption, subtitle, device_config):
    """Create an App Store ready screenshot with device frame and caption"""

    output_width = device_config["output_width"]
    output_height = device_config["output_height"]
    status_bar_crop = device_config["status_bar_crop"]
    corner_radius_ratio = device_config["corner_radius_ratio"]
    phone_height_ratio = device_config["phone_height_ratio"]

    # Create gradient background
    background = create_gradient_background(output_width, output_height, BG_COLOR_START, BG_COLOR_END)

    # Load screenshot and crop status bar completely
    screenshot = Image.open(screenshot_path)
    screenshot = crop_status_bar(screenshot, status_bar_crop)

    # Calculate device frame dimensions
    phone_height = int(output_height * phone_height_ratio)
    phone_width = int(phone_height * (screenshot.width / screenshot.height))

    # Resize screenshot
    screenshot = screenshot.resize((phone_width, phone_height), Image.Resampling.LANCZOS)

    # Add rounded corners (iPhone/iPad style)
    corner_radius = int(phone_width * corner_radius_ratio)
    screenshot_rgba = screenshot.convert('RGBA')
    screenshot_rounded = add_rounded_corners(screenshot_rgba, corner_radius)

    # Add shadow
    screenshot_with_shadow = add_shadow(screenshot_rounded, offset=(12, 12), blur=45)

    # Position device in center-bottom area
    phone_x = (output_width - screenshot_with_shadow.width) // 2
    phone_y = output_height - screenshot_with_shadow.height - 80

    # Paste screenshot onto background
    background = background.convert('RGBA')
    background.paste(screenshot_with_shadow, (phone_x, phone_y), screenshot_with_shadow)

    # Add text
    draw = ImageDraw.Draw(background)

    # Calculate font sizes based on output width
    title_size = int(output_width * 0.07)
    subtitle_size = int(output_width * 0.038)

    # Try to load fonts
    try:
        title_font = ImageFont.truetype("C:/Windows/Fonts/segoeuib.ttf", title_size)
        subtitle_font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", subtitle_size)
    except:
        try:
            title_font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", title_size)
            subtitle_font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", subtitle_size)
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()

    # Draw caption (centered at top)
    caption_bbox = draw.textbbox((0, 0), caption, font=title_font)
    caption_width = caption_bbox[2] - caption_bbox[0]
    caption_x = (output_width - caption_width) // 2
    caption_y = int(output_height * 0.06)

    draw.text((caption_x, caption_y), caption, font=title_font, fill=TEXT_COLOR)

    # Draw subtitle
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (output_width - subtitle_width) // 2
    subtitle_y = caption_y + int(title_size * 1.3)

    draw.text((subtitle_x, subtitle_y), subtitle, font=subtitle_font, fill=(255, 255, 255, 220))

    # Convert back to RGB and save
    background = background.convert('RGB')
    background.save(output_path, 'PNG', quality=95)
    print(f"Created: {output_path}")

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))

    # Process each device type
    for device_name, device_config in DEVICES.items():
        output_dir = os.path.join(script_dir, "appstore_ready", device_config["folder"])
        os.makedirs(output_dir, exist_ok=True)

        print(f"\nCreating {device_name} screenshots...")
        print(f"Output size: {device_config['output_width']}x{device_config['output_height']}")
        print("-" * 50)

        for i, config in enumerate(SCREENSHOTS, 1):
            # Try device-specific screenshot first, then fallback to generic
            device_input = os.path.join(script_dir, device_config["folder"], config["file"])
            generic_input = os.path.join(script_dir, config["file"])

            if os.path.exists(device_input):
                input_path = device_input
            elif os.path.exists(generic_input):
                input_path = generic_input
            else:
                print(f"Warning: {config['file']} not found, skipping...")
                continue

            output_path = os.path.join(output_dir, f"{i:02d}_{config['file']}")

            create_screenshot(
                input_path,
                output_path,
                config["caption"],
                config["subtitle"],
                device_config
            )

    print("-" * 50)
    print(f"Done! Screenshots saved to: {os.path.join(script_dir, 'appstore_ready')}")

if __name__ == "__main__":
    main()
