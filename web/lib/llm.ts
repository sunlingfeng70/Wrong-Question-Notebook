// Shared LLM client — OpenAI-compatible chat completions (Volcengine Ark / Doubao).
// Replaces the previous Google Gemini integration. Zero dependencies: uses global fetch.

const DEFAULT_BASE_URL = 'https://ark.cn-beijing.volces.com/api/plan/v3';
const DEFAULT_MODEL = 'doubao-seed-2.0-pro';

export function llmApiKey(): string {
  return process.env.VOLC_ARK_API_KEY ?? '';
}

export function isLLMConfigured(): boolean {
  return llmApiKey().length > 0;
}

export interface LLMOptions {
  system: string;
  user: string;
  /** Raw base64 image data (no data: prefix). Adds a vision part when provided. */
  image?: { mimeType: string; base64: string };
  /** Request JSON output (response_format json_object + explicit instruction). */
  json?: boolean;
  maxTokens?: number;
}

export async function completeLLM(opts: LLMOptions): Promise<string> {
  const apiKey = llmApiKey();
  if (!apiKey) {
    throw new Error('LLM service not configured (set ARK_API_KEY)');
  }

  const content: Array<Record<string, unknown>> = [];
  if (opts.image) {
    content.push({
      type: 'image_url',
      image_url: {
        url: `data:${opts.image.mimeType};base64,${opts.image.base64}`,
      },
    });
  }
  content.push({
    type: 'text',
    text: opts.json
      ? `${opts.user}\n\nRespond with valid JSON only. No markdown, no code fences.`
      : opts.user,
  });

  const body: Record<string, unknown> = {
    model: process.env.LLM_MODEL ?? DEFAULT_MODEL,
    messages: [
      { role: 'system', content: opts.system },
      { role: 'user', content },
    ],
    max_tokens: opts.maxTokens ?? 4096,
  };
  if (opts.json) {
    body.response_format = { type: 'json_object' };
  }

  const res = await fetch(
    `${process.env.VOLC_ARK_BASE_URL ?? DEFAULT_BASE_URL}/chat/completions`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify(body),
    }
  );

  if (!res.ok) {
    const errText = await res.text().catch(() => '');
    throw new Error(
      `LLM request failed (${res.status}): ${errText.slice(0, 300)}`
    );
  }

  const data = (await res.json()) as {
    choices?: Array<{ message?: { content?: string } }>;
  };
  const text = data?.choices?.[0]?.message?.content;
  if (typeof text !== 'string' || text.trim() === '') {
    throw new Error('LLM returned empty response');
  }
  return text;
}
