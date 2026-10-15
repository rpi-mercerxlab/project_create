import express from "express";
import cors from "cors";

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

const apiKey = process.env.GEMINI_API_KEY;

app.post("/askAI", async (req, res) => {
  if (!apiKey) return res.status(503).json({ error: "GEMINI_API_KEY is not configured on the server." });
  const prompt = typeof req.body?.prompt === "string" ? req.body.prompt.trim() : "";
  if (!prompt) return res.status(400).json({ error: "A prompt is required." });

  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ text: `You are Luxi, a practical engineering project mentor.\n\n${prompt}` }] }],
          generationConfig: { maxOutputTokens: 20000 },
        }),
        signal: AbortSignal.timeout(180_000),
      },
    );
    const data = await response.json();
    if (!response.ok) {
      return res.status(response.status).json({ error: data?.error?.message ?? "The AI request failed." });
    }
    const text = data?.candidates?.[0]?.content?.parts
      ?.map((part) => (typeof part?.text === "string" ? part.text : ""))
      .join("")
      .trim();
    if (!text) return res.status(502).json({ error: "The AI returned an empty response." });
    return res.json({ text });
  } catch (error) {
    const message = error?.name === "TimeoutError" ? "The AI request timed out." : "Could not reach the AI service.";
    return res.status(502).json({ error: message });
  }
});

app.listen(process.env.PORT || 3000, () => console.log("Luxi backend ready"));
