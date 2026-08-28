"""
LexiFlow - Complete Audio Generation Script
Generates 14 WAV files for all screens and actions.
Uses phase accumulation for perfect seamless looping.
"""
import math
import struct
import wave
import os
import random

sounds_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'assets', 'sounds')
os.makedirs(sounds_dir, exist_ok=True)

SAMPLE_RATE = 44100

def generate_seamless_loop(filename, freq_func, duration_s, volume=0.4, harmonics=None):
    """Generate a seamless looping ambient track using phase accumulation."""
    num_samples = int(SAMPLE_RATE * duration_s)
    filepath = os.path.join(sounds_dir, filename)
    fade_samples = min(int(SAMPLE_RATE * 0.5), num_samples // 4)
    
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        
        phase = 0.0
        harmonic_phases = [0.0] * (len(harmonics) if harmonics else 0)
        
        for i in range(num_samples):
            t = i / SAMPLE_RATE
            freq = freq_func(t, duration_s)
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            
            val = math.sin(phase)
            
            if harmonics:
                for hi, (hfreq_mult, hvol) in enumerate(harmonics):
                    harmonic_phases[hi] += 2.0 * math.pi * (freq * hfreq_mult) / SAMPLE_RATE
                    val += hvol * math.sin(harmonic_phases[hi])
            
            # Perfect crossfade envelope for looping
            env = 1.0
            if i < fade_samples:
                env = i / fade_samples
            elif i > num_samples - fade_samples:
                env = (num_samples - i) / fade_samples
            
            sample = int(max(-32767, min(32767, volume * 32767 * val * env)))
            wf.writeframesraw(struct.pack('<h', sample))
    print(f"  [OK] {filename}")


def generate_sfx(filename, samples_func, duration_ms, volume=0.6):
    """Generate a one-shot sound effect."""
    num_samples = int(SAMPLE_RATE * duration_ms / 1000.0)
    filepath = os.path.join(sounds_dir, filename)
    fade = min(500, num_samples // 4)
    
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        
        phase = 0.0
        for i in range(num_samples):
            t = i / SAMPLE_RATE
            freq, amp = samples_func(t, duration_ms / 1000.0)
            phase += 2.0 * math.pi * freq / SAMPLE_RATE
            
            env = 1.0
            if i < fade: env = i / fade
            elif i > num_samples - fade: env = (num_samples - i) / fade
            
            sample = int(max(-32767, min(32767, volume * 32767 * math.sin(phase) * amp * env)))
            wf.writeframesraw(struct.pack('<h', sample))
    print(f"  [OK] {filename}")


print("=== LexiFlow Audio Generation ===")
print()

# ── AMBIENT TRACKS ─────────────────────────────────────────────────────────────
print("── Ambient Tracks ──")

# hub_ambient: Peaceful, zen, slow sine sweep (used in Auth, Main Menu, Hub screens)
def hub_freq(t, d): return 220 + 8 * math.sin(2 * math.pi * 0.05 * t)
generate_seamless_loop('hub_ambient.wav', hub_freq, 30, volume=0.18,
    harmonics=[(2, 0.3), (3, 0.1)])  # Rich harmonics

# grid_ambient: Focused, steady low drone (Solo / Multiplayer grids)
def grid_freq(t, d): return 110 + 3 * math.sin(2 * math.pi * 0.08 * t)
generate_seamless_loop('grid_ambient.wav', grid_freq, 30, volume=0.2,
    harmonics=[(2, 0.4), (1.5, 0.2)])

# blitz_ambient: Urgent, rising tension (Blitz mode)
# Uses a smooth sine-based pulse to avoid frequency jumps
def blitz_freq(t, d):
    pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 1.5 * t)  # 1.5Hz smooth pulse
    return 180 + 40 * pulse
generate_seamless_loop('blitz_ambient.wav', blitz_freq, 30, volume=0.22,
    harmonics=[(2, 0.25)])

# chaos_ambient: Unsettling, shifting, swirling (Chaos mode)
def chaos_freq(t, d):
    return 130 + 60 * math.sin(2 * math.pi * 0.3 * t) + 20 * math.sin(2 * math.pi * 0.7 * t)
generate_seamless_loop('chaos_ambient.wav', chaos_freq, 30, volume=0.2,
    harmonics=[(1.5, 0.3), (2.5, 0.15)])

# ── SOUND EFFECTS ──────────────────────────────────────────────────────────────
print()
print("── Sound Effects ──")

# click: Short, snappy UI feedback
def click_fn(t, d):
    freq = 800 * math.exp(-15 * t)
    amp = math.exp(-20 * t)
    return max(1, freq), amp
generate_sfx('click.wav', click_fn, 80, volume=0.5)

# navigation: Soft whoosh-like tone for screen transitions
def nav_fn(t, d):
    freq = 400 + 200 * (t / d)
    amp = math.exp(-5 * t) * (0.5 + 0.5 * (t / d))
    return freq, amp
generate_sfx('navigation.wav', nav_fn, 200, volume=0.4)

# word_found: Bright, satisfying ping when a word is discovered
def word_found_fn(t, d):
    freq = 523 + 261 * math.exp(-8 * t)  # C5 → lower harmonically
    amp = math.exp(-6 * t)
    return freq, amp
generate_sfx('word_found.wav', word_found_fn, 350, volume=0.6)

# error: Low, short buzz for wrong selections
def error_fn(t, d):
    freq = 120 + 30 * math.sin(2 * math.pi * 20 * t)
    amp = math.exp(-10 * t)
    return freq, amp
generate_sfx('error.wav', error_fn, 250, volume=0.5)

# success (level win): Ascending, triumphant fanfare
def success_fn(t, d):
    # Glide up from 261 to 523 Hz (C4 to C5)
    freq = 261 + (523 - 261) * min(1.0, t / 0.4)
    amp = math.exp(-3 * (t - 0.3)**2) if t > 0.1 else t / 0.1
    return freq, amp
generate_sfx('success.wav', success_fn, 800, volume=0.65)

# coin_collect: Metallic high-pitched "ding"
def coin_fn(t, d):
    freq = 2093 * math.exp(-5 * t) + 880  # High-pitched decay
    amp = math.exp(-12 * t)
    return max(100, freq), amp
generate_sfx('coin_collect.wav', coin_fn, 200, volume=0.55)

# letter_select: Tiny tick for selecting a letter
def letter_fn(t, d):
    freq = 1200 * math.exp(-30 * t)
    amp = math.exp(-30 * t)
    return max(100, freq), amp
generate_sfx('letter_select.wav', letter_fn, 50, volume=0.4)

# back: Low click for going back
def back_fn(t, d):
    freq = 350 * math.exp(-10 * t)
    amp = math.exp(-15 * t)
    return max(50, freq), amp
generate_sfx('back.wav', back_fn, 120, volume=0.4)

# hint_used: Soft chime for using a hint
def hint_fn(t, d):
    freq = 659 + 100 * math.sin(2 * math.pi * 5 * t)  # E5 with slight vibrato
    amp = math.exp(-8 * t)
    return freq, amp
generate_sfx('hint.wav', hint_fn, 300, volume=0.45)

# timer_tick: Quiet metronome tick for countdown (Blitz)
def tick_fn(t, d):
    freq = 1000 * math.exp(-40 * t)
    amp = math.exp(-40 * t)
    return max(50, freq), amp
generate_sfx('timer_tick.wav', tick_fn, 40, volume=0.3)

print()
print(f"=== Generated {len(os.listdir(sounds_dir))} audio files in assets/sounds/ ===")
