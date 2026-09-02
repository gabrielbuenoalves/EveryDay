import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { createRemoteJWKSet, jwtVerify } from "npm:jose@5";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const issuer = "https://api.youversion.com";
const jwks = createRemoteJWKSet(
  new URL("https://api.youversion.com/.well-known/jwks.json"),
);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return json("ok");
  }

  const appKey = Deno.env.get("YVP_APP_KEY") ?? "";
  if (!appKey) {
    return json({ error: "YVP_APP_KEY missing" }, 503);
  }

  try {
    const body = await req.json().catch(() => ({}));
    const idToken = String(body.id_token ?? "");
    const expectedNonce = String(body.nonce ?? "");
    if (!idToken) {
      return json({ error: "id_token required" }, 400);
    }

    const { payload } = await jwtVerify(idToken, jwks, {
      issuer,
      audience: appKey,
      algorithms: ["RS256"],
    });

    if (expectedNonce && payload.nonce !== expectedNonce) {
      return json({ error: "nonce mismatch" }, 401);
    }

    const yvpId = String(payload.yvp_id ?? payload.sub ?? "");
    const email = String(payload.email ?? "").trim().toLowerCase();
    const name = String(payload.name ?? "").trim();
    if (!yvpId || !email) {
      return json({ error: "token missing yvp_id or email" }, 400);
    }

    const admin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
    );

    const created = await admin.auth.admin.createUser({
      email,
      email_confirm: true,
      user_metadata: {
        display_name: name || email.split("@")[0],
        yvp_id: yvpId,
        avatar_url: payload.profile_picture ?? "",
      },
    });
    if (created.error && !isAlreadyRegistered(created.error.message)) {
      return json({ error: created.error.message }, 502);
    }

    const link = await admin.auth.admin.generateLink({
      type: "magiclink",
      email,
    });
    if (link.error || !link.data.properties?.hashed_token) {
      return json({ error: link.error?.message ?? "generateLink failed" }, 502);
    }

    const userId = link.data.user?.id ?? created.data.user?.id;
    if (userId) {
      await admin.auth.admin.updateUserById(userId, {
        user_metadata: {
          display_name: name || email.split("@")[0],
          yvp_id: yvpId,
          avatar_url: payload.profile_picture ?? "",
        },
      });
      await admin.from("profiles").update({ yvp_id: yvpId }).eq("id", userId);
    }

    return json({ token_hash: link.data.properties.hashed_token });
  } catch (error) {
    return json({ error: String(error) }, 401);
  }
});

function isAlreadyRegistered(message: string): boolean {
  const lower = message.toLowerCase();
  return lower.includes("already") || lower.includes("registered") ||
    lower.includes("exists");
}

function json(body: unknown, status = 200): Response {
  const payload = typeof body === "string" ? body : JSON.stringify(body);
  return new Response(payload, {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
