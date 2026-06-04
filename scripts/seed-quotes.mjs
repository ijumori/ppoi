#!/usr/bin/env node
// Firestore に格言データを投入するスクリプト
// Usage: node scripts/seed-quotes.mjs

import { initializeApp, cert, applicationDefault } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

// Firebase Admin を Application Default Credentials で初期化
initializeApp({
  projectId: "ppoi-a714a",
});

const db = getFirestore();

// 今日から7日分の「っぽい格言」
const quotes = [
  { date: "2026-06-04", text: "遠回りした者だけが、近道の意味を知る", tone: "serious" },
  { date: "2026-06-05", text: "三日坊主も三回やれば九日続いたことになる", tone: "humorous" },
  { date: "2026-06-06", text: "沈黙は金、だが沈黙を破る勇気は白金である", tone: "serious" },
  { date: "2026-06-07", text: "早起きは三文の徳、二度寝は無限の幸福", tone: "humorous" },
  { date: "2026-06-08", text: "他人の靴で歩けば、靴擦れと共に理解が生まれる", tone: "serious" },
  { date: "2026-06-09", text: "石橋を叩きすぎて橋が壊れた者を、愚者と呼ぶか賢者と呼ぶか", tone: "humorous" },
  { date: "2026-06-10", text: "風は見えぬが、木々を揺らすことで己を語る", tone: "serious" },
  { date: "2026-06-11", text: "明日やろうは馬鹿野郎、だが今日やり過ぎるのは疲労野郎", tone: "humorous" },
  { date: "2026-06-12", text: "深い井戸から汲む水ほど、甘い", tone: "serious" },
  { date: "2026-06-13", text: "猫に小判と言うが、猫は小判より箱を選ぶ", tone: "humorous" },
  { date: "2026-06-14", text: "雨を恨む者は、虹を見ることができない", tone: "serious" },
];

async function seed() {
  const batch = db.batch();

  for (const q of quotes) {
    const ref = db.collection("quotes").doc(q.date);
    batch.set(ref, { text: q.text, tone: q.tone });
    console.log(`  ${q.date}: ${q.text} (${q.tone})`);
  }

  await batch.commit();
  console.log(`\n${quotes.length} 件の格言を投入しました`);
}

seed().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
