import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const preferredAbbreviations = ["NVI", "NTLH", "NAA", "ARC", "ACF"];
const contentQuery =
  "content-type=html&include-notes=false&include-titles=true" +
  "&include-verse-numbers=true&include-verse-spans=true";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return json("ok");
  }

  const apiKey = Deno.env.get("BIBLE_API_KEY") ?? "";
  if (!apiKey) {
    return json({ error: "BIBLE_API_KEY missing" }, 503);
  }

  const base = (Deno.env.get("BIBLE_API_BASE") ?? "https://rest.api.bible")
    .replace(/\/$/, "");

  const body = await req.json().catch(() => ({}));
  const passages = Array.isArray(body.passages)
    ? body.passages.map((item: unknown) => String(item).trim()).filter(Boolean)
    : [];

  if (passages.length === 0) {
    return json({ error: "passages required" }, 400);
  }
  if (passages.length > 10) {
    return json({ error: "too many passages" }, 400);
  }

  const bibleId = await resolveBibleId(base, apiKey);
  if (!bibleId) {
    return json({ error: "no licensed bible available" }, 502);
  }

  const metaResponse = await apiBible(base, apiKey, `/v1/bibles/${bibleId}`);
  if (metaResponse.status === 401) {
    return json({ error: "invalid API.Bible key" }, 401);
  }
  if (!metaResponse.ok) {
    return json({ error: `bible ${metaResponse.status}` }, 502);
  }
  const meta = (await metaResponse.json()).data ?? {};

  const chapters = [];
  let copyright = String(meta.copyright ?? meta.info ?? "");
  for (const passageId of passages) {
    const path = contentPath(bibleId, passageId);
    const response = await apiBible(base, apiKey, path);
    if (!response.ok) {
      return json({ error: `${passageId} ${response.status}` }, 502);
    }
    const passage = (await response.json()).data ?? {};
    const html = String(passage.content ?? "");
    const verses = parseVerses(html);
    copyright = String(passage.copyright ?? copyright);
    chapters.push({
      id: passage.id ?? passageId,
      reference: passage.reference ?? passageId,
      content: verses.map((verse) =>
        verse.number ? `${verse.number} ${verse.text}` : verse.text
      ).join("\n"),
      verses,
    });
  }

  return json({
    bible_id: bibleId,
    abbreviation: meta.abbreviation ?? meta.abbreviationLocal ?? "",
    title: meta.nameLocal ?? meta.name ?? "",
    copyright,
    chapters,
  });
});

function contentPath(bibleId: string, id: string): string {
  const encoded = encodeURIComponent(id);
  // Passage IDs are two verse IDs joined by `-` (e.g. JHN.3.1-JHN.3.16).
  // Chapter IDs are BOOK.N (JHN.8). Verse IDs are BOOK.N.N (JHN.3.16).
  if (id.includes("-")) {
    return `/v1/bibles/${bibleId}/passages/${encoded}?${contentQuery}`;
  }
  const parts = id.split(".");
  if (parts.length >= 3) {
    return `/v1/bibles/${bibleId}/verses/${encoded}?${contentQuery}`;
  }
  return `/v1/bibles/${bibleId}/chapters/${encoded}?${contentQuery}`;
}

async function resolveBibleId(base: string, apiKey: string): Promise<string | null> {
  const configured = (Deno.env.get("BIBLE_ID") ?? "").trim();
  if (configured) return configured;

  const nvi = await apiBible(
    base,
    apiKey,
    "/v1/bibles?language=por&abbreviation=NVI&include-full-details=true",
  );
  const nviId = firstBibleId(await nvi.json().catch(() => ({})));
  if (nvi.ok && nviId) return nviId;

  const portuguese = await apiBible(
    base,
    apiKey,
    "/v1/bibles?language=por&include-full-details=true",
  );
  if (portuguese.ok) {
    const payload = await portuguese.json();
    const list = Array.isArray(payload.data) ? payload.data : [];
    list.sort((a, b) =>
      rankAbbreviation(a?.abbreviation) - rankAbbreviation(b?.abbreviation)
    );
    const id = list[0]?.id;
    if (typeof id === "string" && id.length > 0) return id;
  }

  const all = await apiBible(base, apiKey, "/v1/bibles?include-full-details=true");
  if (!all.ok) return null;
  return firstBibleId(await all.json());
}

function firstBibleId(payload: { data?: unknown }): string | null {
  const list = Array.isArray(payload.data) ? payload.data : [];
  const id = list[0]?.id;
  return typeof id === "string" && id.length > 0 ? id : null;
}

function rankAbbreviation(value: unknown): number {
  const abbr = String(value ?? "").toUpperCase();
  const index = preferredAbbreviations.indexOf(abbr);
  return index === -1 ? 50 : index;
}

function parseVerses(html: string): Array<{ number: string; text: string }> {
  const numbered =
    /<span[^>]*(?:class="[^"]*\bv\b[^"]*"|data-number="\d+")[^>]*>\s*(\d+)\s*<\/span>\s*/gi;
  const matches = [...html.matchAll(numbered)];
  if (matches.length === 0) {
    const text = stripHtml(html);
    return text ? [{ number: "", text }] : [];
  }
  const verses = [];
  for (let i = 0; i < matches.length; i++) {
    const match = matches[i];
    const start = (match.index ?? 0) + match[0].length;
    const end = i + 1 < matches.length
      ? (matches[i + 1].index ?? html.length)
      : html.length;
    const text = stripHtml(html.slice(start, end));
    if (!text) continue;
    verses.push({ number: match[1] ?? "", text });
  }
  return verses;
}

function stripHtml(html: string): string {
  return html
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/\s+/g, " ")
    .trim();
}

function apiBible(base: string, apiKey: string, path: string): Promise<Response> {
  return fetch(`${base}${path}`, {
    headers: { "api-key": apiKey },
  });
}

function json(body: unknown, status = 200): Response {
  const payload = typeof body === "string" ? body : JSON.stringify(body);
  return new Response(payload, {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
