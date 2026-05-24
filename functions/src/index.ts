import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { generateDailyQuote } from "./generateQuote";

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");
const manualQuoteSecret = defineSecret("MANUAL_QUOTE_SECRET");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function authorizeManualRequest(
  authorizationHeader: string | undefined,
  expectedSecret: string
): boolean {
  if (!authorizationHeader?.startsWith("Bearer ")) {
    return false;
  }
  const token = authorizationHeader.slice("Bearer ".length);
  return token.length > 0 && token === expectedSecret;
}

/** 毎日 0:00 JST（= 15:00 UTC）に格言を生成 */
export const generateDailyQuoteScheduled = onSchedule(
  {
    schedule: "0 15 * * *",
    timeZone: "UTC",
    secrets: [anthropicApiKey],
    region: "asia-northeast1",
  },
  async () => {
    const client = new Anthropic({ apiKey: anthropicApiKey.value() });
    await generateDailyQuote(db, client);
  }
);

/** 手動テスト用 — Bearer トークン必須（MANUAL_QUOTE_SECRET） */
export const generateDailyQuoteManual = onRequest(
  {
    secrets: [anthropicApiKey, manualQuoteSecret],
    region: "asia-northeast1",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ ok: false, error: "Method Not Allowed" });
      return;
    }

    if (!authorizeManualRequest(req.headers.authorization, manualQuoteSecret.value())) {
      res.status(401).json({ ok: false, error: "Unauthorized" });
      return;
    }

    try {
      const client = new Anthropic({ apiKey: anthropicApiKey.value() });
      const result = await generateDailyQuote(db, client);
      res.json({ ok: true, ...result });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Unknown error";
      res.status(500).json({ ok: false, error: message });
    }
  }
);
