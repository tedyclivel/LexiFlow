import wave
import struct
import math
import os

sounds_dir = r'c:\Users\eganh\Documents\LABHACKING\user\search_word\assets\sounds'

def generate_wav(filename, freq_func, duration_ms, volume=0.5):
    sample_rate = 44100
    num_samples = int(sample_rate * (duration_ms / 1000.0))
    filepath = os.path.join(sounds_dir, filename)
    
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        
        # Phase tracking to ensure continuity
        phase = 0.0
        for i in range(num_samples):
            t = i / sample_rate
            freq = freq_func(t, duration_ms/1000.0)
            
            # Update phase based on frequency
            phase += 2.0 * math.pi * freq / sample_rate
            
            # 500ms envelope for smooth looping
            envelope = 1.0
            fade_samples = int(sample_rate * 0.5) 
            if i < fade_samples: 
                envelope = i / fade_samples
            elif i > num_samples - fade_samples: 
                envelope = (num_samples - i) / fade_samples
            
            value = int(volume * 32767.0 * math.sin(phase) * envelope)
            data = struct.pack('<h', value)
            wav_file.writeframesraw(data)
    print(f"Generated {filename}")

if not os.path.exists(sounds_dir):
    os.makedirs(sounds_dir)

# 1. Hub Ambient: Soft, Zen, Harmonic
def hub_freq(t, d): return 220 + 2 * math.sin(2 * math.pi * 0.2 * t)
generate_wav('hub_ambient.wav', hub_freq, 30000, volume=0.2)

# 2. Grid/Solo/Multi Ambient: Constant, focused drone
def grid_freq(t, d): return 110 + math.sin(2 * math.pi * 0.1 * t)
generate_wav('grid_ambient.wav', grid_freq, 30000, volume=0.2)

# 3. Blitz Ambient: Fast, Tense rhythmic pulse (Cleaned up loop)
def blitz_freq(t, d): 
    # Use a smoother transition for the pulse
    pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 2.0 * t) # 2Hz pulse
    return 165 + 30 * pulse
generate_wav('blitz_ambient.wav', blitz_freq, 30000, volume=0.25)

# 4. Chaos Ambient: Irregular, shifting freq
def chaos_freq(t, d): return 100 + 100 * math.sin(t * t)
generate_wav('chaos_ambient.wav', chaos_freq, 30000, volume=0.2)

# 5. Coin Collect: Metallic high-pitched "ping"
def coin_freq(t, d): return 2000 * math.exp(-10 * t) + 880
generate_wav('coin_collect.wav', coin_freq, 200, volume=0.4)

# 6. Click: Short pop
def click_func(t, d): return 1000
generate_wav('click.wav', click_func, 40, volume=0.4)

# 7. Success: Melodic rise
def success_func(t, d):
    if t < 0.1: return 440
    if t < 0.2: return 554
    if t < 0.3: return 659
    return 880
generate_wav('success.wav', success_func, 400, volume=0.5)

# 8. Error: Harsh descent
def error_func(t, d): return 200 * (1 - t)
generate_wav('error.wav', error_func, 300, volume=0.6)

print("Success: All 8 specialized audio files generated.")
