# AppDeck 🎴

An immersive, tactile 3D playing-card fanned application launcher built on **Quickshell** (Wayland/Qt6). 

AppDeck renders your installed desktop applications as a hand of Bicycle-style playing cards fanned out at the bottom of the screen. It features rich physics-based mouse tracking, interactive 3D flips, and advanced performance optimizations.

<p align="center">
  <video src="Demo.mp4" width="100%" style="max-width: 800px;" controls autoplay loop muted></video>
</p>

## Features

- **Tactile Card Fan**: Polar-coordinate fanning math with a wide fanning radius that keeps cards upright while hiding cut-off card corners off-screen.
- **3D Card Flip Info Deck**: The central decorative deck remains fanned out. Selecting or hovering over an app card bottom-side triggers a 3D Y-axis flip of the top central card, revealing details (Initials, App Icon, Title) in real time.
- **3D Parallax Mouse Tracking**: Cards tilt in 3D space tracking mouse coordinate movement.
- **Interactive Coin Spin**: Hovering over the active center information card triggers a snappy `360-degree` spin animation with bouncy overshoot easing.
- **Instantaneous Load Times (<50ms)**: Built with viewport-based lazy loading and $O(1)$ asynchronous icon path caching to easily handle 100+ application lists without UI lag.
- **Translucent Backdrop**: A gorgeous blurred background (opacity `0.82`) letting window borders shine through, with snappy closing transitions (`150ms` opacity fade).
- **Search & Filter**: Type queries to instantly filter applications. Cards maintain full opacity while you search, and text-navigation key separation lets Left/Right arrow keys manage search cursor movements while Up/Down arrow keys navigate card selection.

## Installation

### Prerequisites
- [Quickshell](https://github.com/outfoxxed/quickshell) built against Qt6.
- A Wayland compositor (e.g. Hyprland).

### Install Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/Un-ease/AppDeck.git
   cd AppDeck
   ```
2. Run the installer:
   ```bash
   ./install.sh
   ```

## Keyboard Shortcuts & Compositor Bindings

### Hyprland Setup
Add the following bindings to your `~/.config/hypr/bindings.conf` or main configuration:
```ini
# Toggle the launcher modal overlay
bindd = SUPER, SPACE, Command surface, exec, omarchy-tui-shell toggle
```

## License
MIT License
