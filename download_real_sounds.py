import urllib.request
import os

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'

# Known good public domain sounds from Wikimedia Commons
sound_sources = {
    'click.mp3': 'https://upload.wikimedia.org/wikipedia/commons/3/34/Sound_Effect_-_Click.mp3',
    'lexi_success.mp3': 'https://upload.wikimedia.org/wikipedia/commons/3/33/Success_Chime.mp3',
    'lexi_error.mp3': 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Windows_User_Account_Control_Error.mp3',
    'lexi_select.mp3': 'https://upload.wikimedia.org/wikipedia/commons/b/b3/Pops_1.mp3'
}

# Standard fallbacks for missing ones
fallbacks = [
    'lexi_ambient_calm.mp3', 'lexi_ambient_intense.mp3', 'ambient.mp3', 
    'error.mp3', 'select.mp3', 'success.mp3', 'lexi_reward.mp3', 
    'lexi_victory.mp3', 'lexi_fever.mp3'
]

if not os.path.exists(sounds_dir):
    os.makedirs(sounds_dir)

def download_file(url, filename):
    try:
        print(f"Downloading {filename} from {url}...")
        headers = {'User-Agent': 'Mozilla/5.0'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            data = response.read()
            with open(os.path.join(sounds_dir, filename), 'wb') as f:
                f.write(data)
        print(f"✓ Saved {filename}")
        return data
    except Exception as e:
        print(f"✗ Failed to download {filename}: {e}")
        return None

# Download primary sounds
click_data = download_file(sound_sources['click.mp3'], 'click.mp3')
success_data = download_file(sound_sources['lexi_success.mp3'], 'lexi_success.mp3')
error_data = download_file(sound_sources['lexi_error.mp3'], 'lexi_error.mp3')
select_data = download_file(sound_sources['lexi_select.mp3'], 'lexi_select.mp3')

# Fill fallbacks with the best substitute available
for f in fallbacks:
    target_path = os.path.join(sounds_dir, f)
    source_data = None
    if 'ambient' in f:
        # Use success music for ambient if it's long enough, or just a beep
        source_data = success_data if success_data else click_data
    elif 'success' in f or 'victory' in f or 'reward' in f or 'fever' in f:
        source_data = success_data if success_data else click_data
    elif 'error' in f:
        source_data = error_data if error_data else click_data
    else:
        source_data = select_data if select_data else click_data
    
    if source_data:
        with open(target_path, 'wb') as target_file:
            target_file.write(source_data)
        print(f"✓ Created fallback for {f}")

print("All audio assets processed.")
