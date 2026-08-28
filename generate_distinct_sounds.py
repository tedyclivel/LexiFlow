import wave
import struct
import math
import os

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'

def generate_beep(filename, frequency, duration_ms, volume=0.5):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    
    filepath = os.path.join(sounds_dir, filename)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1) # Mono
        wav_file.setsampwidth(2) # 16-bit
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            # Sine wave
            value = int(volume * 32767.0 * math.sin(2.0 * math.pi * frequency * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename} ({frequency}Hz, {duration_ms}ms)")

def generate_success(filename, duration_ms=500):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(sounds_dir, filename)
    
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Two-tone rising chime
        for i in range(num_samples):
            freq = 440 if i < num_samples // 2 else 880
            value = int(0.5 * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename} (Success Chime)")

def generate_error(filename, duration_ms=400):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(sounds_dir, filename)
    
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Low buzz
        for i in range(num_samples):
            freq = 150
            value = int(0.6 * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate))
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename} (Error Buzz)")

if not os.path.exists(sounds_dir):
    os.makedirs(sounds_dir)

# Generate distinct WAV files (renamed to .mp3 to avoid changing SoundService paths, 
# but they are actually PCM WAV which audioplayers often handles if the platform player supports it, 
# or we can update SoundService to .wav)
generate_beep('click.mp3', 1000, 50)
generate_success('success.mp3', 400)
generate_error('error.mp3', 300)

# Fill others
primary_files = ['click.mp3', 'success.mp3', 'error.mp3']
all_files = [
    'lexi_success.mp3', 'lexi_error.mp3', 'lexi_ambient_calm.mp3',
    'lexi_ambient_intense.mp3', 'lexi_select.mp3', 'ambient.mp3',
    'select.mp3', 'lexi_reward.mp3', 'lexi_victory.mp3', 'lexi_fever.mp3'
]

import shutil
for f in all_files:
    src = 'click.mp3'
    if 'success' in f or 'victory' in f or 'reward' in f: src = 'success.mp3'
    if 'error' in f: src = 'error.mp3'
    shutil.copy(os.path.join(sounds_dir, src), os.path.join(sounds_dir, f))

print("Success: Generated distinct WAV-encoded MP3 files.")
