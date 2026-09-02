import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const crisisKeywords = [
  "suicídio",
  "suicidio",
  "me matar",
  "quero morrer",
  "tirar minha vida",
  "automutilação",
  "automutilacao",
  "me cortar",
  "me ferir",
  "não aguento mais viver",
  "nao aguento mais viver",
  "ideação suicida",
  "ideacao suicida",
  "estupro",
  "me bateram",
  "violência doméstica",
  "violencia domestica",
];

const systemPrompt = `Você é um assistente do pastor. NÃO fala com o membro.
O pastor vai LER o seu relatório e AUDITAR as leituras antes de qualquer coisa chegar à ovelha.
Não dê diagnóstico clínico. Não prometa cura. Não envie consolo direto à pessoa.

Responda SOMENTE um JSON válido:
{
  "summary": "relatório pastoral em 3-5 frases: o que essa ovelha está vivendo e o que o pastor precisa saber",
  "urgency": "low" | "medium" | "high" | "critical",
  "theme": "tema curto do cuidado, ex.: solidão, luto, cansaço",
  "duration_days": 3 a 7,
  "passages": ["Salmos 23", "João 14:1-6", "Isaías 41:10"],
  "approach_notes": ["por que esta leitura 1", "por que esta leitura 2", "como o pastor pode apresentar isso"]
}

Regras para passages:
- Uma referência clara por item, em português, que o pastor possa aprovar e enviar.
- Prefira capítulo inteiro ou trecho curto (ex.: "Salmos 34", "Mateus 11:28-30").
- Escolha textos que falem ao sentimento e ao pedido de oração DESTA pessoa.
- approach_notes explica ao pastor o PORQUÊ de cada leitura, não é texto para o membro.`;

type PastoralJson = {
  summary: string;
  urgency: "low" | "medium" | "high" | "critical";
  theme: string | null;
  duration_days: number;
  passages: string[];
  approach_notes: string[];
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const authHeader = req.headers.get("Authorization") ?? "";

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const {
      data: { user },
      error: userError,
    } = await userClient.auth.getUser();
    if (userError || !user) {
      return json({ error: "not authenticated" }, 401);
    }

    const body = await req.json().catch(() => ({}));
    const checkinId = body.checkin_id as string | undefined;
    if (!checkinId) {
      return json({ error: "checkin_id required" }, 400);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: checkin, error: checkinError } = await admin
      .from("mood_checkins")
      .select("id, user_id, score, body, status")
      .eq("id", checkinId)
      .single();

    if (checkinError || !checkin) {
      return json({ error: "checkin not found" }, 404);
    }
    if (checkin.user_id !== user.id) {
      return json({ error: "not allowed" }, 403);
    }
    if ((checkin.score as number) > 2) {
      return json({ ok: true, skipped: true });
    }

    const crisis = containsCrisisLanguage(checkin.body as string | null);
    const fallback = fallbackReport(
      crisis,
      checkin.score as number,
      (checkin.body as string | null) ?? "",
    );
    let report = fallback;
    let rawModel: string | null = null;
    let usedAi = false;

    try {
      const generated = await generatePastoralReport({
        score: checkin.score as number,
        body: (checkin.body as string | null) ?? "",
        crisis,
      });
      if (generated) {
        report = generated;
        usedAi = true;
        rawModel = JSON.stringify(generated);
      }
    } catch {
      report = fallback;
    }

    if (crisis) {
      report = { ...report, urgency: "critical" };
    }

    const status = usedAi ? "analyzed" : "needs_care";

    await admin
      .from("mood_checkins")
      .update({ crisis, status })
      .eq("id", checkinId);

    const { data: existing } = await admin
      .from("pastoral_reports")
      .select("id")
      .eq("checkin_id", checkinId)
      .maybeSingle();

    const payload = {
      checkin_id: checkinId,
      summary: report.summary,
      urgency: report.urgency,
      theme: report.theme,
      duration_days: report.duration_days,
      passages: report.passages,
      approach_notes: report.approach_notes,
      raw_model: rawModel,
    };

    if (existing?.id) {
      await admin.from("pastoral_reports").update(payload).eq("id", existing.id);
    } else {
      await admin.from("pastoral_reports").insert(payload);
    }

    return json({ ok: true, crisis, status, used_ai: usedAi });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

function containsCrisisLanguage(text: string | null): boolean {
  if (!text || text.trim().length === 0) return false;
  const normalized = text.toLowerCase();
  return crisisKeywords.some((keyword) => normalized.includes(keyword));
}

function fallbackReport(crisis: boolean, score: number, body: string): PastoralJson {
  const feeling = body.trim() || "O membro pediu cuidado, sem texto extra.";
  return {
    summary:
      `Relato do membro:\n${feeling}\n\n` +
      (crisis
        ? "Há sinais de crise. Priorize contato humano ainda hoje."
        : "Prepare um contato pastoral breve, sem pressa de consolar ou corrigir."),
    urgency: crisis ? "critical" : score <= 1 ? "high" : "medium",
    theme: "Acolhimento",
    duration_days: 5,
    passages: ["Salmos 23", "Salmos 34", "Mateus 11:28-30"],
    approach_notes: [
      "Comece pelo que a pessoa escreveu; não mude o assunto.",
      "Confirme que o cuidado é confidencial e que ela não está sozinha.",
      "Se houver risco, priorize contato humano ainda hoje.",
    ],
  };
}

async function generatePastoralReport(input: {
  score: number;
  body: string;
  crisis: boolean;
}): Promise<PastoralJson | null> {
  const provider = (Deno.env.get("AI_PROVIDER") ?? "gemini").toLowerCase();
  const apiKey = Deno.env.get("AI_API_KEY") ?? "";
  if (!apiKey || provider === "none") return null;

  const userPrompt =
    `Nota de humor (1-5, sendo 1 o mais difícil): ${input.score}\n` +
    `Possível crise por palavras-chave: ${input.crisis ? "sim" : "não"}\n` +
    `O campo Relato inclui o sentimento escolhido (ex.: Triste, Angustiado) e, se houver, o pedido de oração e a permissão de WhatsApp.\n` +
    `Monte um relatório SÓ para o pastor e sugira leituras para ELE auditar e, se quiser, enviar a esta ovelha.\n` +
    `Não escreva como se a mensagem já fosse para o membro.\n` +
    `Relato:\n${input.body}`;

  const raw = provider === "openai"
    ? await callOpenAi(apiKey, userPrompt)
    : await callGemini(apiKey, userPrompt);

  return parsePastoralJson(raw);
}

async function callGemini(apiKey: string, userPrompt: string): Promise<string> {
  const model = Deno.env.get("AI_MODEL") ?? "gemini-3.5-flash";
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: systemPrompt }] },
      contents: [{ role: "user", parts: [{ text: userPrompt }] }],
      generationConfig: {
        temperature: 0.3,
        responseMimeType: "application/json",
      },
    }),
  });
  if (!response.ok) {
    throw new Error(`gemini ${response.status}`);
  }
  const data = await response.json();
  return data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
}

async function callOpenAi(apiKey: string, userPrompt: string): Promise<string> {
  const model = Deno.env.get("AI_MODEL") ?? "gpt-4o-mini";
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      temperature: 0.3,
      response_format: { type: "json_object" },
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
    }),
  });
  if (!response.ok) {
    throw new Error(`openai ${response.status}`);
  }
  const data = await response.json();
  return data?.choices?.[0]?.message?.content ?? "";
}

function parsePastoralJson(raw: string): PastoralJson | null {
  const cleaned = raw.trim().replace(/^```json\s*/i, "").replace(/```$/i, "").trim();
  if (!cleaned) return null;
  const parsed = JSON.parse(cleaned) as Record<string, unknown>;
  const urgencyRaw = String(parsed.urgency ?? "medium");
  const urgency = ["low", "medium", "high", "critical"].includes(urgencyRaw)
    ? urgencyRaw as PastoralJson["urgency"]
    : "medium";
  const passages = asStringList(parsed.passages);
  const notes = asStringList(parsed.approach_notes);
  const summary = String(parsed.summary ?? "").trim();
  if (!summary) return null;
  return {
    summary,
    urgency,
    theme: parsed.theme ? String(parsed.theme) : "Acolhimento",
    duration_days: clampDays(parsed.duration_days),
    passages: passages.length > 0 ? passages : ["Salmos 23"],
    approach_notes: notes.slice(0, 3),
  };
}

function asStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value.map((item) => String(item).trim()).filter((item) => item.length > 0);
}

function clampDays(value: unknown): number {
  const n = Number(value);
  if (!Number.isFinite(n)) return 5;
  return Math.min(14, Math.max(1, Math.round(n)));
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
