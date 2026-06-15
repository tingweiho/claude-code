"""
Brand-styled matplotlib/seaborn defaults for notebooks.

Usage:
    import sys
    sys.path.insert(0, '/Users/tingwei/.claude/skills/data-viz/assets')
    from viz_defaults import apply_aircall_style, BRAND_GREEN, INK, INK_MUTED, CATEGORICAL

    apply_aircall_style()

    # Your plots now inherit [Company] styling.
    import matplotlib.pyplot as plt
    plt.plot(x, y)

Colors match the `slides` brand palette so notebook visuals stay
visually consistent with eventual Reveal.js decks.
"""

BRAND_GREEN = "#008F6D"
BRAND_GREEN_LIGHT = "#A8E5D7"
BRAND_GREEN_DARK = "#06503E"

INK = "#002620"
INK_MUTED = "#749E98"

PAGE_BG = "#FAFBFD"
BORDER = "#E5EAE9"

CATEGORICAL = [
    "#008F6D",  # Brand Green 500
    "#237C90",  # Teal 500
    "#6A28B5",  # Purple 500
    "#941454",  # Pink 500
    "#091460",  # Periwinkle 900
    "#749E98",  # Neutral 500
    "#06503E",  # Brand Green 700
]

SEQUENTIAL_GREEN = [
    "#EEF6F4", "#D4ECE6", "#A8E5D7", "#4CE5C1",
    "#008F6D", "#056A52", "#06503E", "#06372B", "#041F18",
]

DIVERGING = [
    "#941454", "#E0A1C1", "#F3F5F5", "#A8E5D7", "#008F6D",
]


def apply_aircall_style():
    """Apply [Company] palette + typography to matplotlib rcParams.

    Call at the top of a notebook. Affects every plt/sns plot below it.
    Fonts fall back cleanly on systems without Instrument Serif / Poppins.
    """
    import matplotlib as mpl
    from cycler import cycler

    mpl.rcParams.update({
        # Colors
        "figure.facecolor": PAGE_BG,
        "axes.facecolor": PAGE_BG,
        "axes.edgecolor": BORDER,
        "axes.labelcolor": INK,
        "axes.titlecolor": INK,
        "xtick.color": INK_MUTED,
        "ytick.color": INK_MUTED,
        "text.color": INK,
        "axes.prop_cycle": cycler(color=CATEGORICAL),

        # Spines — keep only left/bottom
        "axes.spines.top": False,
        "axes.spines.right": False,
        "axes.spines.left": True,
        "axes.spines.bottom": True,
        "axes.linewidth": 0.8,

        # Grid — OFF by default. Ting-Wei prefers clean plots without gridlines.
        # Re-enable per-plot with ax.grid(True, axis='y') only if the chart genuinely needs it.
        "axes.grid": False,
        "axes.grid.axis": "y",
        "grid.color": BORDER,
        "grid.linewidth": 0.5,
        "grid.alpha": 0.7,

        # Typography — fallbacks chain
        "font.family": "sans-serif",
        "font.sans-serif": ["Poppins", "Helvetica Neue", "DejaVu Sans", "sans-serif"],
        "font.serif": ["Instrument Serif", "DejaVu Serif", "serif"],
        "font.monospace": ["JetBrains Mono", "Menlo", "DejaVu Sans Mono", "monospace"],
        "font.size": 11,
        "axes.titlesize": 13,
        "axes.titleweight": "normal",
        "axes.titlelocation": "center",  # Ting-Wei prefers centered chart titles.
        "figure.titlesize": 14,
        "figure.titleweight": "normal",
        "axes.labelsize": 10,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "legend.fontsize": 9,
        "legend.frameon": False,

        # Figure
        "figure.figsize": (8, 4.5),    # 16:9-ish, notebook-friendly
        "figure.dpi": 110,
        "savefig.dpi": 150,
        "savefig.bbox": "tight",
    })

    # Seaborn: set palette to match if it's imported
    try:
        import seaborn as sns
        sns.set_palette(CATEGORICAL)
    except ImportError:
        pass


def highlight_palette(highlighted_index=0, n_categories=5):
    """Return a palette where one series is Brand Green and the rest are INK_MUTED.

    Use when you want the reader's eye drawn to one segment among many:

        palette = highlight_palette(highlighted_index=segments.index("EMEA"), n_categories=len(segments))
        for color, segment in zip(palette, segments):
            plt.plot(x, y[segment], color=color, label=segment)

    Returns a list of hex color strings with `highlighted_index` as BRAND_GREEN
    and all others as INK_MUTED.
    """
    return [BRAND_GREEN if i == highlighted_index else INK_MUTED
            for i in range(n_categories)]
