<p align="center">
  <img src="https://raw.githubusercontent.com/A7medMajed16/LogoMotion/main/assets/logo.png" width="220" alt="Logo Motion Logo" />
</p>

# Logo Motion 🚀

A highly customizable and premium SVG logo loading animation widget for Flutter. Provide any SVG logo path data and watch it animate with a beautiful stroke-trace followed by a smooth solid fill-reveal.

---

## Features ✨

- **SVG Support**: Easily load your logo from a raw SVG string or an asset path.
- **2 Animation Styles**:
  1. **Infinite Loop (`repeat: true`)**: Cycles through progressive path stroke drawing, full-color fill reveal, and a graceful fade out before repeating.
  2. **Single Play (`repeat: false`)**: Plays the path stroke drawing, reveals the full fill, and stops—keeping your logo completely filled and visible.
- **Customizable**: Tweak the colors, stroke width, canvas size, animation duration, and repeating behavior to perfectly match your brand's aesthetics.

---

## Installation 📦

Add the dependency to your project's `pubspec.yaml` file:

```yaml
dependencies:
  logo_motion: ^0.0.1
```

---

## Usage 🛠️

Import the library in your Dart code:

```dart
import 'package:logo_motion/logo_motion.dart';
```

### 1. From an SVG String

```dart
LogoMotion.string(
  '''<svg viewBox="0 0 100 100"><path d="..."/></svg>''',
  size: 80.0,
  color: Colors.deepPurple,
  duration: const Duration(seconds: 3),
  strokeWidth: 2.0,
  repeat: false, // Plays once and stays filled!
)
```

### 2. From a Flutter Asset

> **Note**: Don't forget to declare your SVG asset in your `pubspec.yaml`.

```dart
LogoMotion.asset(
  'assets/logo.svg',
  size: 100.0,
  color: Colors.blueAccent,
  duration: const Duration(seconds: 2),
  repeat: true, // Cycles infinitely
)
```

---

## Parameters ⚙️

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `size` | `double` | `50.0` | The width and height of the canvas. |
| `color` | `Color?` | `Color(0xFF0071AA)` | The color used for both the stroke outline and the solid fill. |
| `duration` | `Duration` | `3 seconds` | The duration of one complete animation cycle. |
| `strokeWidth` | `double` | `1.8` | The width of the line during the path-drawing phase. |
| `repeat` | `bool` | `true` | When `true`, loops infinitely with a fade-out. When `false`, animates once and stops at full fill. |

---

## Author ✍️

Developed with ❤️ by **A.Majed**.
# LogoMotion
