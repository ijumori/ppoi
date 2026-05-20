import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";

type QuoteTone = "humorous" | "serious";

interface GeneratedQuote {
  date: string;
  text: string;
  tone: QuoteTone;
}

/** JST の今日の日付 yyyy-MM-dd */
export function todayJST(): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
}

/** 直近7日の tone 比率を見て、偏り防止 */
export async function pickTone(db: admin.firestore.Firestore): Promise<QuoteTone> {
  const snapshot = await db
    .collection("quotes")
    .orderBy("createdAt", "desc")
    .limit(7)
    .get();

  let humorous = 0;
  let serious = 0;

  snapshot.forEach((doc) => {
    const tone = doc.data().tone as QuoteTone;
    if (tone === "humorous") humorous++;
    else if (tone === "serious") serious++;
  });

  if (humorous > serious) return "serious";
  if (serious > humorous) return "humorous";
  return Math.random() < 0.5 ? "humorous" : "serious";
}

function buildPrompt(tone: QuoteTone): string {
  const toneGuide =
    tone === "humorous"
      ? "ユーモア全振り。笑える・ネタ系。大喜利のネタになるような「っぽい格言」。"
      : "シリアスっぽい。本物の格言に紛れ込むような、深みのある「っぽい格言」。";

  return `あなたは「っぽい格言」生成AIです。

## ルール
- 日本語で1文のみ（20〜40文字程度）
- ${toneGuide}
- 既存の有名格言の言い回しを混ぜてもよい
- 正解がない、解釈が分かれる余白を残す
- 出力は格言本文のみ（説明・引用符・番号不要）`;
}

export async function callClaude(
  client: Anthropic,
  tone: QuoteTone
): Promise<string> {
  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 200,
    messages: [{ role: "user", content: buildPrompt(tone) }],
  });

  const block = response.content[0];
  if (block.type !== "text") {
    throw new Error("Unexpected Claude response type");
  }

  return block.text.trim().replace(/^["「]|["」]$/g, "");
}

export async function generateDailyQuote(
  db: admin.firestore.Firestore,
  client: Anthropic
): Promise<GeneratedQuote> {
  const date = todayJST();
  const docRef = db.collection("quotes").doc(date);
  const existing = await docRef.get();

  if (existing.exists) {
    const data = existing.data()!;
    return { date, text: data.text, tone: data.tone };
  }

  const tone = await pickTone(db);
  const text = await callClaude(client, tone);

  await docRef.set({
    text,
    tone,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { date, text, tone };
}
