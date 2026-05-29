from PIL import Image
import os

src = r'C:\Users\Garet\nova_app\assets\images\dino_garden_bg.png'

# Reload from original each run - keep a backup first
bak = src + '.bak'
if not os.path.exists(bak):
    import shutil
    shutil.copy(src, bak)
    print('Backup created')

img = Image.open(bak)
print(f'Original size: {img.size}, mode: {img.mode}')

# Resize to 1080x1920 max (portrait mobile), keep aspect
img.thumbnail((1080, 1920), Image.LANCZOS)
print(f'Resized to: {img.size}')

img_rgb = img.convert('RGB')
img_rgb.save(src, optimize=True, quality=78)

new_mb = os.path.getsize(src) / 1024 / 1024
print(f'Final file: {new_mb:.2f} MB')
