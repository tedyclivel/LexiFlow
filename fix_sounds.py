import urllib.request
import os

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'
url = 'https://raw.githubusercontent.com/anars/blank-audio/master/0.5-seconds-of-silence.mp3'

files_to_replace = [
    'click.mp3',
    'lexi_success.mp3',
    'lexi_error.mp3',
    'lexi_ambient_calm.mp3',
    'lexi_ambient_intense.mp3',
    'lexi_select.mp3',
    'ambient.mp3',
    'error.mp3',
    'select.mp3',
    'success.mp3',
    'lexi_reward.mp3',
    'lexi_victory.mp3',
    'lexi_fever.mp3'
]

print(f"Downloading silent placeholder from {url}...")
try:
    with urllib.request.urlopen(url) as response:
        content = response.read()
    
    for filename in files_to_replace:
        filepath = os.path.join(sounds_dir, filename)
        with open(filepath, 'wb') as f:
            f.write(content)
        print(f"Replaced {filename}")
    print("Success: All files replaced with silent placeholder.")
except Exception as e:
    print(f"Error: {e}")
