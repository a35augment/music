import { Innertube, Log } from "youtubei.js";

Log.setLevel(Log.Level.NONE);

function playlistIdFromInput(input: string): string {
  try {
    const url = new URL(input);
    const id = url.searchParams.get("list");

    if (!id) {
      throw new Error("URL does not contain a playlist 'list=' parameter.");
    }

    return id;
  } catch {
    // Allow passing a bare playlist ID too.
    if (/^[A-Za-z0-9_-]+$/.test(input)) {
      return input;
    }

    throw new Error("Expected a YouTube/YouTube Music playlist URL or playlist ID.");
  }
}

if (Deno.args.length < 1) {
  console.error(
    "usage: deno run --allow-net scripts/backends/youtube_music_probe.ts <playlist-url-or-id>",
  );
  Deno.exit(2);
}

const source = Deno.args[0];
const playlistId = playlistIdFromInput(source);

const youtube = await Innertube.create({
  generate_session_locally: true,
});

let page = await youtube.music.getPlaylist(playlistId);

const records: Array<Record<string, unknown>> = [];
let playlistIndex = 1;
let pageNumber = 1;

while (true) {
  let pageCount = 0;

  for (const rawItem of page.items) {
    const item = rawItem as any;

    // The continuation token itself is exposed as an item.
    if (item?.constructor?.name === "ContinuationItem") {
      continue;
    }

    const artists =
      item?.artists?.map((artist: any) => artist?.name).filter(Boolean) ?? [];

    const authors =
      item?.authors?.map((author: any) => author?.name).filter(Boolean) ?? [];

    records.push({
      playlist_index: playlistIndex,
      video_id: item?.id ?? "",
      item_type: item?.item_type ?? "",
      title: item?.title ?? "",
      artists,
      authors,
      album: item?.album?.name ?? "",
      duration: item?.duration?.seconds ?? null,
    });

    playlistIndex += 1;
    pageCount += 1;
  }

  console.error(
    `playlist page ${pageNumber}: ${pageCount} records (total ${records.length})`,
  );

  if (!page.has_continuation) {
    break;
  }

  page = await page.getContinuation();
  pageNumber += 1;
}

console.error(`records collected: ${records.length}`);

// Keep stdout machine-readable. Progress goes to stderr.
console.log(JSON.stringify(records));
