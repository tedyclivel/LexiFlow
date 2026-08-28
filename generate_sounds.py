import os

# A tiny valid MP3 header + some silent frame data
# This is a minimal 1-frame MP3 file
mp3_data = bytes([
    0xFF, 0xFB, 0x90, 0x44, 0x00, 0x00, 0x00, 0x03, 0x48, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
])

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'
files_to_replace = [
    'click.mp3', 'lexi_success.mp3', 'lexi_error.mp3', 'lexi_ambient_calm.mp3',
    'lexi_ambient_intense.mp3', 'lexi_select.mp3', 'ambient.mp3', 'error.mp3',
    'select.mp3', 'success.mp3', 'lexi_reward.mp3', 'lexi_victory.mp3', 'lexi_fever.mp3'
]

if not os.path.exists(sounds_dir):
    os.makedirs(sounds_dir)

for filename in files_to_replace:
    filepath = os.path.join(sounds_dir, filename)
    with open(filepath, 'wb') as f:
        f.write(mp3_data)
    print(f"Generated {filename}")

print("Success: All files generated offline.")
