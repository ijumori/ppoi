import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import { generateDailyQuote } from "./generateQuote";

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

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

/** 手動テスト用（開発時のみ使用推奨） */
export const generateDailyQuoteManual = onRequest(
  {
    secrets: [anthropicApiKey],
    region: "asia-northeast1",
  },
  async (_req, res) => {
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
