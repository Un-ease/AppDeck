.pragma library

const COLOR_LINE = /^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*"(#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)"/;

function parse(text) {
    const palette = {};
    const lines = String(text || "").split("\n");

    for (let i = 0; i < lines.length; i++) {
        const match = lines[i].match(COLOR_LINE);
        if (match) palette[match[1].toLowerCase()] = match[2];
    }

    return palette;
}

function validColor(value) {
    return typeof value === "string"
        && /^#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?$/.test(value);
}

function opaqueHex(value) {
    return validColor(value) ? value.slice(0, 7) : "";
}

function rgb(value) {
    const hex = opaqueHex(value);
    if (!hex) return null;

    return {
        r: parseInt(hex.slice(1, 3), 16),
        g: parseInt(hex.slice(3, 5), 16),
        b: parseInt(hex.slice(5, 7), 16)
    };
}

function channelLuminance(channel) {
    const value = channel / 255;
    return value <= 0.04045
        ? value / 12.92
        : Math.pow((value + 0.055) / 1.055, 2.4);
}

function luminance(value) {
    const valueRgb = rgb(value);
    if (!valueRgb) return 0;

    return 0.2126 * channelLuminance(valueRgb.r)
        + 0.7152 * channelLuminance(valueRgb.g)
        + 0.0722 * channelLuminance(valueRgb.b);
}

function contrast(first, second) {
    if (!validColor(first) || !validColor(second)) return 1;

    const firstLuminance = luminance(first);
    const secondLuminance = luminance(second);
    const lighter = Math.max(firstLuminance, secondLuminance);
    const darker = Math.min(firstLuminance, secondLuminance);
    return (lighter + 0.05) / (darker + 0.05);
}

function byteHex(value) {
    const clamped = Math.max(0, Math.min(255, Math.round(value)));
    return clamped.toString(16).padStart(2, "0");
}

function blend(first, second, amount) {
    const firstRgb = rgb(first);
    const secondRgb = rgb(second);
    if (!firstRgb) return opaqueHex(second);
    if (!secondRgb) return opaqueHex(first);

    const mix = Math.max(0, Math.min(1, amount));
    return "#" + byteHex(firstRgb.r + (secondRgb.r - firstRgb.r) * mix)
        + byteHex(firstRgb.g + (secondRgb.g - firstRgb.g) * mix)
        + byteHex(firstRgb.b + (secondRgb.b - firstRgb.b) * mix);
}

function firstValid(candidates, fallback) {
    for (let i = 0; i < candidates.length; i++) {
        if (validColor(candidates[i])) return opaqueHex(candidates[i]);
    }
    return opaqueHex(fallback);
}

function strongestContrast(candidates, against, fallback) {
    let best = firstValid([fallback], "");
    let bestRatio = validColor(best) ? contrast(best, against) : 0;

    for (let i = 0; i < candidates.length; i++) {
        const candidate = opaqueHex(candidates[i]);
        if (!candidate) continue;

        const ratio = contrast(candidate, against);
        if (ratio > bestRatio) {
            best = candidate;
            bestRatio = ratio;
        }
    }

    return best;
}

function ensureContrast(preferred, against, anchor, minimum) {
    const start = firstValid([preferred, anchor], "");
    const target = firstValid([anchor, preferred], "");
    if (!start || !target || !validColor(against)) return start;
    if (contrast(start, against) >= minimum) return start;

    for (let step = 1; step <= 40; step++) {
        const candidate = blend(start, target, step / 40);
        if (contrast(candidate, against) >= minimum) return candidate;
    }

    return contrast(target, against) > contrast(start, against) ? target : start;
}

function selectionPair(palette, surface, background, foreground, accent) {
    const backgroundCandidates = [
        palette.selection_background,
        accent,
        palette.color4,
        palette.color1,
        palette.color2,
        palette.color3,
        foreground
    ];
    const foregroundCandidates = [
        palette.selection_foreground,
        background,
        foreground,
        palette.color0,
        palette.color7,
        palette.color15
    ];

    for (let i = 0; i < backgroundCandidates.length; i++) {
        const selectedBackground = opaqueHex(backgroundCandidates[i]);
        if (!selectedBackground || contrast(selectedBackground, surface) < 3.0) continue;

        const selectedForeground = strongestContrast(
            foregroundCandidates,
            selectedBackground,
            background
        );
        if (contrast(selectedForeground, selectedBackground) >= 4.5) {
            return { background: selectedBackground, foreground: selectedForeground };
        }
    }

    const preferredBackground = firstValid(backgroundCandidates, accent);
    const backgroundAnchor = strongestContrast([foreground, accent], surface, foreground);
    const selectedBackground = ensureContrast(
        preferredBackground,
        surface,
        backgroundAnchor,
        4.5
    );
    const textAnchor = strongestContrast(
        foregroundCandidates,
        selectedBackground,
        background
    );
    const selectedForeground = ensureContrast(
        firstValid([palette.selection_foreground, textAnchor], textAnchor),
        selectedBackground,
        textAnchor,
        4.5
    );

    return { background: selectedBackground, foreground: selectedForeground };
}

function shadowBase(palette, background, foreground) {
    const candidates = [background, palette.color0, palette.color8, foreground];
    let darkest = firstValid(candidates, background);

    for (let i = 0; i < candidates.length; i++) {
        const candidate = opaqueHex(candidates[i]);
        if (candidate && luminance(candidate) < luminance(darkest)) darkest = candidate;
    }

    return darkest;
}

function derive(palette) {
    if (!palette || !validColor(palette.background) || !validColor(palette.foreground)) {
        return null;
    }

    const background = opaqueHex(palette.background);
    const foreground = opaqueHex(palette.foreground);
    const accent = firstValid([palette.accent, palette.color4], foreground);
    const backgroundAlt = blend(background, foreground, 0.06);
    const surface = blend(background, foreground, 0.10);
    const textAnchor = strongestContrast([foreground, palette.color7], surface, foreground);
    const foregroundMuted = ensureContrast(
        firstValid([palette.color8, palette.color7], foreground),
        surface,
        textAnchor,
        4.5
    );
    const border = ensureContrast(
        firstValid([palette.color8, palette.color7, accent], foreground),
        surface,
        textAnchor,
        3.0
    );
    const borderMuted = ensureContrast(
        blend(surface, textAnchor, 0.14),
        surface,
        textAnchor,
        1.5
    );
    const selected = selectionPair(palette, surface, background, foreground, accent);

    return {
        background: background,
        backgroundAlt: backgroundAlt,
        surface: surface,
        foreground: foreground,
        foregroundMuted: foregroundMuted,
        border: border,
        borderMuted: borderMuted,
        selectedBackground: selected.background,
        selectedForeground: selected.foreground,
        accent: accent,
        danger: firstValid([palette.color1, accent], foreground),
        warning: firstValid([palette.color3, accent], foreground),
        success: firstValid([palette.color2, accent], foreground),
        shadow: shadowBase(palette, background, foreground)
    };
}
