import csv
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SPOTIFY_DIR = ROOT / "spotify"
OUTPUT_DIR = ROOT / "output" / "normalized"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


def normalize_text(text):
    """Normalize text for matching while preserving the original elsewhere."""
    if not text:
        return ""

    # Unicode normalization
    text = unicodedata.normalize("NFKC", text)

    # Case insensitive
    text = text.casefold()

    # Normalize common separators
    text = text.replace("&", " and ")

    # Remove punctuation, keeping letters/numbers/spaces
    text = re.sub(r"[^\w\s]", " ", text, flags=re.UNICODE)

    # Collapse whitespace
    text = re.sub(r"\s+", " ", text).strip()

    return text


def make_key(artist, title):
    return f"{normalize_text(artist)}|{normalize_text(title)}"


files = sorted(SPOTIFY_DIR.glob("*.csv"))

print(f"Found {len(files)} Spotify playlist files.")
print()

total_tracks = 0

for source_file in files:
    output_file = OUTPUT_DIR / source_file.name

    with source_file.open("r", encoding="utf-8-sig", newline="") as infile:
        reader = csv.DictReader(infile)

        rows = []

        for row in reader:
            artist = row.get("Artist Name(s)", "")
            title = row.get("Track Name", "")

            rows.append({
                "playlist": source_file.stem,
                "spotify_uri": row.get("Track URI", ""),
                "artist": artist,
                "title": title,
                "album": row.get("Album Name", ""),
                "release_date": row.get("Release Date", ""),
                "duration_ms": row.get("Duration (ms)", ""),
                "added_at": row.get("Added At", ""),
                "normalized_artist": normalize_text(artist),
                "normalized_title": normalize_text(title),
                "match_key": make_key(artist, title),
            })

        total_tracks += len(rows)

    with output_file.open("w", encoding="utf-8", newline="") as outfile:
        fieldnames = [
            "playlist",
            "spotify_uri",
            "artist",
            "title",
            "album",
            "release_date",
            "duration_ms",
            "added_at",
            "normalized_artist",
            "normalized_title",
            "match_key",
        ]

        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"{source_file.name}: {len(rows)} tracks")

print()
print(f"Total tracks across playlists: {total_tracks}")
print(f"Normalized files written to: {OUTPUT_DIR}")