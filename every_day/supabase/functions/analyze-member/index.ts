import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const systemPrompt = `Você é um assistente do pastor. NÃO fala com o membro.
Escreva um briefing pastoral curto, em português, com o que o pastor precisa saber agora.
Não dê diagnóstico clínico. Não prometa cura. Não escreva como se a mensagem fosse para a ovelha.

Responda SOMENTE um JSON válido:
{
  "summary": "3 a 6 frases: panorama desta ovelha (leitura, humor, oração, engajamento)",
  "prayer_attention": "o que fazer com pedidos de oração e sinais de peso; se não houver pedido, diga isso com clareza",
  "reading_pulse": "como ela tem lido: tempo, constância, quizzes, comentários",
  "next_step": "uma ação concreta e pastoral para os próximos dias",
  "urgency": "low" | "medium" | "high" | "critical"
}`;

type MemberBriefing = {
  summary: string;
  prayer_attention: string;
  reading_pulse: string;
  next_step: string;
  urgency: "low" | "medium" | "high" | "critical";
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
    const memberId = body.user_id as string | undefined;
    if (!memberId) return json({ error: "user_id required" }, 400);

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: pastor } = await admin
      .from("profiles")
      .select("id, church_id, role, display_name")
      .eq("id", user.id)
      .single();
    if (!pastor || pastor.role !== "pastor" || !pastor.church_id) {
      return json({ error: "not allowed" }, 403);
    }

    const { data: member } = await admin
      .from("profiles")
      .select("id, display_name, church_id")
      .eq("id", memberId)
      .single();
    if (!member || member.church_id !== pastor.church_id) {
      return json({ error: "not allowed" }, 403);
    }

    const dossier = await loadDossier(admin, memberId, member.display_name as string);
    const fallback = fallbackBriefing(dossier);
    let report = fallback;
    let usedAi = false;

    try {
      const generated = await generateBriefing(dossier);
      if (generated) {
        report = generated;
        usedAi = true;
      }
    } catch {
      report = fallback;
    }

    return json({ ok: true, used_ai: usedAi, ...report });
  } catch (error) {
    return json({ error: String(error) }, 500);
  }
});

type Dossier = {
  name: string;
  minutesTotal: number;
  minutesWeek: number;
  readingCount: number;
  readingCountWeek: number;
  commentCount: number;
  lastPassage: string;
  checkins: Array<{ day: string; score: number; crisis: boolean; body: string }>;
  quizzes: Array<{
    title: string;
    understanding: number;
    reception: string;
    minutes: number;
    takeaway: string;
    comment: string;
  }>;
  comments: string[];
};

async function loadDossier(
  admin: ReturnType<typeof createClient>,
  memberId: string,
  name: string,
): Promise<Dossier> {
  const weekStart = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const [{ data: logs }, { data: checkins }, { data: careQuiz }, { data: groupQuiz }, { data: groupComments }, { data: feedComments }] =
    await Promise.all([
      admin.from("reading_logs").select("minutes, passage_label, occurred_at").eq("user_id", memberId),
      admin
        .from("mood_checkins")
        .select("day, score, crisis, body")
        .eq("user_id", memberId)
        .order("day", { ascending: false })
        .limit(12),
      admin
        .from("care_plan_reflections")
        .select("takeaway, comment_text, understanding, reception, minutes, created_at, care_plans(title)")
        .eq("user_id", memberId)
        .order("created_at", { ascending: false })
        .limit(8),
      admin
        .from("group_plan_completions")
        .select("takeaway, comment_text, understanding, reception, minutes, created_at, reading_plans(title)")
        .eq("user_id", memberId)
        .order("created_at", { ascending: false })
        .limit(8),
      admin
        .from("group_passage_comments")
        .select("body, created_at")
        .eq("user_id", memberId)
        .order("created_at", { ascending: false })
        .limit(8),
      admin
        .from("comments")
        .select("body, created_at")
        .eq("user_id", memberId)
        .order("created_at", { ascending: false })
        .limit(8),
    ]);

  let minutesTotal = 0;
  let minutesWeek = 0;
  let readingCountWeek = 0;
  let lastPassage = "";
  let lastAt = 0;
  for (const log of logs ?? []) {
    const minutes = Number(log.minutes ?? 0);
    minutesTotal += minutes;
    const when = Date.parse(String(log.occurred_at ?? ""));
    if (Number.isFinite(when) && new Date(when).toISOString() >= weekStart) {
      minutesWeek += minutes;
      readingCountWeek += 1;
    }
    if (Number.isFinite(when) && when >= lastAt) {
      lastAt = when;
      lastPassage = String(log.passage_label ?? "");
    }
  }

  const quizzes = [
    ...(careQuiz ?? []).map((row) => ({
      title: String((row.care_plans as { title?: string } | null)?.title ?? "Leitura de cuidado"),
      understanding: Number(row.understanding ?? 3),
      reception: String(row.reception ?? "paz"),
      minutes: Number(row.minutes ?? 1),
      takeaway: String(row.takeaway ?? ""),
      comment: String(row.comment_text ?? ""),
    })),
    ...(groupQuiz ?? []).map((row) => ({
      title: String((row.reading_plans as { title?: string } | null)?.title ?? "Leitura do grupo"),
      understanding: Number(row.understanding ?? 3),
      reception: String(row.reception ?? "paz"),
      minutes: Number(row.minutes ?? 1),
      takeaway: String(row.takeaway ?? ""),
      comment: String(row.comment_text ?? ""),
    })),
  ];

  const comments = [
    ...(groupComments ?? []).map((row) => String(row.body ?? "")),
    ...(feedComments ?? []).map((row) => String(row.body ?? "")),
  ].filter((item) => item.trim().length > 0);

  return {
    name,
    minutesTotal,
    minutesWeek,
    readingCount: (logs ?? []).length,
    readingCountWeek,
    commentCount: comments.length,
    lastPassage,
    checkins: (checkins ?? []).map((row) => ({
      day: String(row.day ?? ""),
      score: Number(row.score ?? 3),
      crisis: Boolean(row.crisis),
      body: String(row.body ?? ""),
    })),
    quizzes,
    comments: comments.slice(0, 8),
  };
}

function fallbackBriefing(dossier: Dossier): MemberBriefing {
  const prayers = dossier.checkins.filter((item) =>
    item.body.toLowerCase().includes("pedido de oração"),
  );
  const hard = dossier.checkins.some((item) => item.score <= 2 || item.crisis);
  return {
    summary:
      `${dossier.name} leu ${dossier.readingCount} vezes (${dossier.minutesTotal} min no total, ${dossier.minutesWeek} min nesta semana). ` +
      (dossier.quizzes.length > 0
        ? `Já concluiu ${dossier.quizzes.length} plano(s) com quiz. `
        : "Ainda não há quiz de plano concluído. ") +
      (prayers.length > 0
        ? `Há ${prayers.length} pedido(s) de oração registrados.`
        : "Não há pedido de oração recente."),
    prayer_attention: prayers.length > 0
      ? prayers.slice(0, 3).map((item) => item.body).join("\n")
      : "Nenhum pedido de oração recente. Continue acompanhando o humor diário.",
    reading_pulse:
      `Última passagem: ${dossier.lastPassage || "ainda sem registro"}. ` +
      `${dossier.readingCountWeek} leituras e ${dossier.commentCount} comentários recentes.`,
    next_step: hard
      ? "Priorize um contato pastoral breve e uma leitura curta de acolhimento."
      : "Afirme a constância e, se fizer sentido, avance com um texto um pouco mais profundo.",
    urgency: hard ? "high" : dossier.readingCountWeek === 0 ? "medium" : "low",
  };
}

async function generateBriefing(dossier: Dossier): Promise<MemberBriefing | null> {
  const provider = (Deno.env.get("AI_PROVIDER") ?? "gemini").toLowerCase();
  const apiKey = Deno.env.get("AI_API_KEY") ?? "";
  if (!apiKey || provider === "none") return null;

  const userPrompt =
    `Nome: ${dossier.name}\n` +
    `Tempo total: ${dossier.minutesTotal} min · nesta semana: ${dossier.minutesWeek} min\n` +
    `Leituras: ${dossier.readingCount} no total · ${dossier.readingCountWeek} nesta semana\n` +
    `Última passagem: ${dossier.lastPassage || "nenhuma"}\n` +
    `Comentários recentes: ${dossier.comments.join(" | ") || "nenhum"}\n` +
    `Quizzes:\n${
      dossier.quizzes.map((item) =>
        `- ${item.title}: compreensão ${item.understanding}/5, recepção ${item.reception}, ${item.minutes} min. Ficou: ${item.takeaway}. Comentário: ${item.comment}`
      ).join("\n") || "nenhum"
    }\n` +
    `Check-ins / pedidos de oração:\n${
      dossier.checkins.map((item) =>
        `- ${item.day} nota ${item.score}${item.crisis ? " (crise)" : ""}: ${item.body || "sem texto"}`
      ).join("\n") || "nenhum"
    }`;

  const raw = provider === "openai"
    ? await callOpenAi(apiKey, userPrompt)
    : await callGemini(apiKey, userPrompt);
  return parseBriefing(raw);
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
  if (!response.ok) throw new Error(`gemini ${response.status}`);
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
  if (!response.ok) throw new Error(`openai ${response.status}`);
  const data = await response.json();
  return data?.choices?.[0]?.message?.content ?? "";
}

function parseBriefing(raw: string): MemberBriefing | null {
  const cleaned = raw.trim().replace(/^```json\s*/i, "").replace(/```$/i, "").trim();
  if (!cleaned) return null;
  const parsed = JSON.parse(cleaned) as Record<string, unknown>;
  const urgencyRaw = String(parsed.urgency ?? "medium");
  const urgency = ["low", "medium", "high", "critical"].includes(urgencyRaw)
    ? urgencyRaw as MemberBriefing["urgency"]
    : "medium";
  const summary = String(parsed.summary ?? "").trim();
  if (!summary) return null;
  return {
    summary,
    prayer_attention: String(parsed.prayer_attention ?? "").trim() ||
      "Nenhum pedido de oração destacado.",
    reading_pulse: String(parsed.reading_pulse ?? "").trim() ||
      "Ainda há pouca leitura para um pulso claro.",
    next_step: String(parsed.next_step ?? "").trim() ||
      "Acompanhe esta ovelha na próxima leitura.",
    urgency,
  };
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
