#!/usr/bin/env python3
"""Generates the game's placeholder sound effects and music as WAV files.

Run from the project root:  python3 tools/generate_audio.py
Output goes to assets/audio/. Swap in real recordings any time; keep the file names.
"""
import math
import os
import random
import struct
import wave

SR = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
random.seed(7)


def write(name, samples, peak=0.9):
    m = max(abs(s) for s in samples) or 1.0
    scale = peak / m
    os.makedirs(OUT, exist_ok=True)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))


def noise():
    return random.uniform(-1, 1)


def hit():
    # Cartoon "bonk": quick downward pitch bend with a click at the start.
    d, out, phase = 0.16, [], 0.0
    for i in range(int(SR * d)):
        t = i / SR
        f = 520 * math.exp(-t * 14) + 170
        phase += 2 * math.pi * f / SR
        s = math.sin(phase) + 0.3 * math.sin(phase * 2)
        s *= math.exp(-t * 22)
        if t < 0.006:
            s += noise() * 0.6
        out.append(s)
    write("hit", out)


def throw():
    # Short airy whoosh.
    d, out, y = 0.22, [], 0.0
    for i in range(int(SR * d)):
        p = i / (SR * d)
        a = 0.04 + 0.25 * math.sin(math.pi * p)
        y += a * (noise() - y)
        out.append(y * math.sin(math.pi * p) ** 2)
    write("throw", out, 0.7)


def fireball_cast():
    # Big "fwoosh" with a low rumble and crackles.
    d, out, y = 0.55, [], 0.0
    for i in range(int(SR * d)):
        t = i / SR
        p = t / d
        env = min(1.0, t / 0.04) * (1 - p) ** 1.5
        y += (0.06 + 0.2 * (1 - p)) * (noise() - y)
        s = y * 2.0 * env
        s += math.sin(2 * math.pi * 90 * t) * 0.4 * env
        if random.random() < 0.004:
            s += noise() * env
        out.append(s)
    write("fireball_cast", out)


def monster_die():
    # Silly "wah-wah-wah-waaah" sad trombone.
    notes = [(466, 0.15), (440, 0.15), (415, 0.15), (392, 0.5)]
    out, phase, y = [], 0.0, 0.0
    for idx, (f0, d) in enumerate(notes):
        n = int(SR * d)
        for i in range(n):
            t = i / SR
            f = f0
            if idx == len(notes) - 1:
                f *= 1 + 0.03 * math.sin(2 * math.pi * 6 * t)
            phase = (phase + f / SR) % 1.0
            saw = 2 * phase - 1
            y += 0.12 * (saw - y)  # soften the buzz
            env = min(1.0, t / 0.02) * min(1.0, (d - t) / 0.04)
            out.append(y * env)
    write("monster_die", out)


def explosion():
    # Deep boom: darkening noise, sub thump, and crackles.
    d, out, y = 1.5, [], 0.0
    for i in range(int(SR * d)):
        t = i / SR
        a = 0.03 + 0.5 * math.exp(-t * 5)
        y += a * (noise() - y)
        s = y * 2.5 * math.exp(-t * 2.8)
        f = 80 * math.exp(-t * 4) + 35
        s += math.sin(2 * math.pi * f * t) * 1.2 * math.exp(-t * 5)
        if random.random() < 0.002 * math.exp(-t * 2):
            s += noise() * 0.8
        out.append(s)
    write("explosion", out, 0.95)


def music():
    # Cheerful 8-bar loop, 120 BPM: C G Am F twice.
    bpm, eighth = 120, 0.25
    bars = 8
    total = int(SR * bars * 4 * 60 / bpm)
    buf = [0.0] * total

    def midi(n):
        return 440 * 2 ** ((n - 69) / 12)

    def add_note(start, dur, freq, vol, wave_fn):
        s0 = int(start * SR)
        for i in range(int(dur * SR)):
            if s0 + i >= total:
                break
            t = i / SR
            env = min(1.0, t / 0.01) * math.exp(-t * 3.5) * min(1.0, (dur - t) / 0.03)
            buf[s0 + i] += wave_fn(freq * t) * vol * env

    square = lambda x: 1.0 if (x % 1.0) < 0.25 else -1.0
    triangle = lambda x: 4 * abs((x % 1.0) - 0.5) - 1

    R = None
    melody = [
        72, 76, 79, 76, 72, 76, 79, R,
        71, 74, 79, 74, 71, 74, 79, R,
        72, 76, 81, 79, 76, 72, 76, R,
        77, 76, 74, 72, 74, R, R, R,
        79, 79, 76, 76, 72, 72, 76, R,
        74, 74, 79, 79, 74, 71, 74, R,
        76, 79, 81, 81, 79, 76, 72, R,
        77, 77, 76, 74, 72, R, R, R,
    ]
    for i, n in enumerate(melody):
        if n is not None:
            add_note(i * eighth, eighth * 0.9, midi(n), 0.22, square)

    roots = [48, 43, 45, 41] * 2
    for bar, root in enumerate(roots):
        for beat in range(4):
            n = root if beat % 2 == 0 else root + 7
            add_note((bar * 4 + beat) * 0.5, 0.45, midi(n), 0.45, triangle)

    # Soft kick on beats 1 and 3, tiny hi-hat on off-beats.
    for beat in range(bars * 4):
        s0 = int(beat * 0.5 * SR)
        if beat % 2 == 0:
            for i in range(int(0.12 * SR)):
                t = i / SR
                buf[s0 + i] += math.sin(2 * math.pi * (60 + 90 * math.exp(-t * 30)) * t) * 0.5 * math.exp(-t * 25)
        h0 = s0 + int(0.25 * SR)
        for i in range(int(0.03 * SR)):
            if h0 + i < total:
                buf[h0 + i] += noise() * 0.06 * math.exp(-i / SR * 120)
    write("music", buf, 0.7)


if __name__ == "__main__":
    hit()
    throw()
    fireball_cast()
    monster_die()
    explosion()
    music()
    print("wrote audio to", os.path.abspath(OUT))
