import base64
import os

# Verified Base64 for a short MP3 beep
beep_base64 = "/+MYxAAEaAIEeUAQAgBgNgP/////KQQ/////Lvrg+lcWYHgtjadzsbTq+yREu495tq9c6v/7vt/of7mna9v6/btUnU17Jun9/+MYxCkT26KW+YGBAj9v6vUh/zab//v/96C3/pu6H+pv//r/ycIIP4pcWWTRBBBAMXgNdbRaABQAAABRWKwgjQVX0ECmrb///+MYxBQSM0sWWYI4A++Z/////////////0rOZ3MP//7H44QEgxgdvRVMXHZseL//540B4JAvXPEgaA4/0nHjxLhRgAoAYAgA/+MYxAYIAAJfGYEQAMAJAIAQMAwX936/q/tWtv/2f/+v//6v/+7qTEFNRTMuOTkuNVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV"

mp3_data = base64.b64decode(beep_base64)

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
    print(f"Generated {filename} ({len(mp3_data)} bytes)")

print("Success: All files replaced with a valid playable beep.")
