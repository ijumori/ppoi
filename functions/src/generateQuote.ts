import Anthropic from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";

type QuoteTone = "humorous" | "serious";
type QuoteCategory = "life" | "work" | "philosophy" | "humor" | "love" | "growth";

interface GeneratedQuote {
  date: string;
  text: string;
  tone: QuoteTone;
  interpretation: string;
  category: QuoteCategory;
  question: string;
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

  return `あなたは「っぽい格言」生成AIです。以下のJSON形式で出力してください。

## ルール
- text: 日本語で1文のみ（20〜40文字程度）。${toneGuide}
- interpretation: その格言の3〜4文の深読み・解説（100〜150文字）
- category: 以下の6つから最も適切なものを選択
  - "life"（人生・日常）
  - "work"（仕事・努力）
  - "philosophy"（哲学・真理）
  - "humor"（ユーモア・笑い）
  - "love"（愛・人間関係）
  - "growth"（成長・挑戦）
- question: その格言を読んだ人への振り返り質問（30〜50文字、「〜ましたか？」「〜ですか？」形式）

## 出力形式（JSONのみ、説明文不要）
{
  "text": "格言本文",
  "interpretation": "解説テキスト",
  "category": "カテゴリID",
  "question": "振り返り質問"
}`;
}

export async function callClaude(
  client: Anthropic,
  tone: QuoteTone
): Promise<{ text: string; interpretation: string; category: QuoteCategory; question: string }> {
  const response = await client.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 600,
    messages: [{ role: "user", content: buildPrompt(tone) }],
  });

  const block = response.content[0];
  if (block.type !== "text") {
    throw new Error("Unexpected Claude response type");
  }

  const raw = block.text.trim();
  // JSON部分だけ抽出（```json ... ``` ブロックに包まれている場合も対応）
  const jsonMatch = raw.match(/\{[\s\S]*\}/);
  if (!jsonMatch) throw new Error("No JSON found in Claude response");

  const parsed = JSON.parse(jsonMatch[0]) as {
    text: string;
    interpretation: string;
    category: QuoteCategory;
    question: string;
  };

  // sanitize text
  parsed.text = parsed.text.replace(/^["「]|["」]$/g, "").trim();

  const validCategories: QuoteCategory[] = ["life", "work", "philosophy", "humor", "love", "growth"];
  if (!validCategories.includes(parsed.category)) {
    parsed.category = tone === "humorous" ? "humor" : "life";
  }

  return parsed;
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
    return {
      date,
      text: data.text,
      tone: data.tone,
      interpretation: data.interpretation ?? "",
      category: data.category ?? "life",
      question: data.question ?? "",
    };
  }

  const tone = await pickTone(db);
  const { text, interpretation, category, question } = await callClaude(client, tone);

  await docRef.set({
    text,
    tone,
    interpretation,
    category,
    question,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { date, text, tone, interpretation, category, question };
}
