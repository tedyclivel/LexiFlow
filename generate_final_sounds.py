import wave
import struct
import math
import os
import shutil

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'

def generate_wav(filename, freq_list, duration_ms, volume=0.5):
    sample_rate = 44100
    filepath = os.path.join(sounds_dir, filename)
    
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Split duration among frequencies in freq_list
        num_freqs = len(freq_list)
        samples_per_freq = int(sample_rate * (duration_ms / 1000.0) / num_freqs)
        
        for freq in freq_list:
            for i in range(samples_per_freq):
                # Sine wave with simple envelope to avoid clicking
                envelope = 1.0
                if i < 100: envelope = i / 100.0
                if i > samples_per_freq - 100: envelope = (samples_per_freq - i) / 100.0
                
                value = int(volume * 32767.0 * math.sin(2.0 * math.pi * freq * i / sample_rate) * envelope)
                data = struct.pack('<h', value)
                wav_file.writeframesraw(data)
    print(f"Generated {filename}")

if not os.path.exists(sounds_dir):
    os.makedirs(sounds_dir)

# Clean up old mp3 files to avoid confusion
for f in os.listdir(sounds_dir):
    if f.endswith('.mp3'):
        os.remove(os.path.join(sounds_dir, f))

# 1. Click (Short crisp beep)
generate_wav('click.wav', [1200], 40, volume=0.4)

# 2. Success (Happy ascending)
generate_wav('success.wav', [440, 554.37, 659.25, 880], 400, volume=0.5)

# 3. Error (Low buzz descending)
generate_wav('error.wav', [200, 150, 100], 300, volume=0.6)

# 4. Ambient (Very long soft hum)
generate_wav('ambient.wav', [220, 221], 5000, volume=0.2) 

print("Success: Generated distinct WAV files.")
