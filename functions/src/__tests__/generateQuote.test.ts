import { describe, it, expect, vi } from "vitest";
import { todayJST, callClaude } from "../generateQuote.js";
import type Anthropic from "@anthropic-ai/sdk";

// ---------------------------------------------------------------------------
// todayJST
// ---------------------------------------------------------------------------

describe("todayJST", () => {
  it("returns a string in YYYY-MM-DD format", () => {
    const result = todayJST();
    expect(result).toMatch(/^\d{4}-\d{2}-\d{2}$/);
  });

  it("returns the same value when called twice in the same millisecond", () => {
    const a = todayJST();
    const b = todayJST();
    expect(a).toBe(b);
  });
});

// ---------------------------------------------------------------------------
// callClaude — response parsing
// ---------------------------------------------------------------------------

function makeMockClient(responseText: string): Anthropic {
  return {
    messages: {
      create: vi.fn().mockResolvedValue({
        content: [{ type: "text", text: responseText }],
      }),
    },
  } as unknown as Anthropic;
}

describe("callClaude — JSON extraction", () => {
  it("parses a clean JSON response", async () => {
    const json = JSON.stringify({
      text: "テスト格言",
      interpretation: "テスト解説",
      category: "life",
      question: "どう思いますか？",
    });
    const result = await callClaude(makeMockClient(json), "serious");
    expect(result.text).toBe("テスト格言");
    expect(result.category).toBe("life");
  });

  it("extracts JSON wrapped in ```json ... ``` code fence", async () => {
    const json = JSON.stringify({
      text: "コードフェンス格言",
      interpretation: "解説",
      category: "work",
      question: "質問？",
    });
    const fenced = `\`\`\`json\n${json}\n\`\`\``;
    const result = await callClaude(makeMockClient(fenced), "serious");
    expect(result.text).toBe("コードフェンス格言");
  });

  it("strips surrounding quotes from text", async () => {
    const json = JSON.stringify({
      text: "「引用符付き格言」",
      interpretation: "解説",
      category: "philosophy",
      question: "質問？",
    });
    const result = await callClaude(makeMockClient(json), "serious");
    expect(result.text).toBe("引用符付き格言");
  });

  it("strips double-quote wrapping from text", async () => {
    const json = JSON.stringify({
      text: '"ダブルクォート格言"',
      interpretation: "解説",
      category: "humor",
      question: "質問？",
    });
    const result = await callClaude(makeMockClient(json), "humorous");
    expect(result.text).toBe("ダブルクォート格言");
  });
});

// ---------------------------------------------------------------------------
// callClaude — category validation
// ---------------------------------------------------------------------------

describe("callClaude — category validation", () => {
  it("accepts all valid categories", async () => {
    const validCategories = ["life", "work", "philosophy", "humor", "love", "growth"] as const;
    for (const cat of validCategories) {
      const json = JSON.stringify({
        text: "格言",
        interpretation: "解説",
        category: cat,
        question: "質問？",
      });
      const result = await callClaude(makeMockClient(json), "serious");
      expect(result.category).toBe(cat);
    }
  });

  it("remaps invalid category to 'humor' for humorous tone", async () => {
    const json = JSON.stringify({
      text: "格言",
      interpretation: "解説",
      category: "invalid_cat",
      question: "質問？",
    });
    const result = await callClaude(makeMockClient(json), "humorous");
    expect(result.category).toBe("humor");
  });

  it("remaps invalid category to 'life' for serious tone", async () => {
    const json = JSON.stringify({
      text: "格言",
      interpretation: "解説",
      category: "unknown",
      question: "質問？",
    });
    const result = await callClaude(makeMockClient(json), "serious");
    expect(result.category).toBe("life");
  });
});

// ---------------------------------------------------------------------------
// callClaude — error cases
// ---------------------------------------------------------------------------

describe("callClaude — error handling", () => {
  it("throws if response contains no JSON", async () => {
    const client = makeMockClient("申し訳ありませんが、JSONがありません");
    await expect(callClaude(client, "serious")).rejects.toThrow("No JSON found");
  });

  it("throws if content block is not text type", async () => {
    const client = {
      messages: {
        create: vi.fn().mockResolvedValue({
          content: [{ type: "image", source: {} }],
        }),
      },
    } as unknown as Anthropic;
    await expect(callClaude(client, "serious")).rejects.toThrow("Unexpected Claude response type");
  });
});
