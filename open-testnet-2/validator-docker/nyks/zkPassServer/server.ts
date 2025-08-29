// server.ts
import express from "express";
import cors from "cors";
import { ZKPassport } from "@zkpassport/sdk";
import dotenv from "dotenv";
import {saveVerification} from "./database";

// Load environment variables
dotenv.config();

const app = express();

/** 1) CORS FIRST */
app.use(
  cors({
    origin: ["http://localhost:4173", "http://localhost:5173"],
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
    maxAge: 86400,
  })
);

/** 2) ONE set of parsers, with BIG limits (remove body-parser entirely) */
app.use(express.json({ limit: "50mb", type: "application/json" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));
// Optional: if clients might send a non-JSON content-type, accept raw and parse manually
// app.use("/verify", express.raw({ type: "*/*", limit: "50mb" }));

/** 3) Size logger (helps confirm it’s not a proxy/body limit) */
app.use((req, _res, next) => {
  const len = req.headers["content-length"];
  console.log(
    `Incoming ${req.method} ${req.url} ` +
      (len ? `content-length=${len}` : "(chunked/unknown)")
  );
  next();
});

app.options("/verify", (_req, res) => res.sendStatus(204));

app.get("/verify", (_req, res) => {
  res.send("hello from ZKPassport server!");
});

/** 4) Verify route */
app.post("/verify", async (req, res) => {
  try {
    // If you enabled express.raw above, uncomment this to parse Buffer:
    // const body = Buffer.isBuffer(req.body) ? JSON.parse(req.body.toString("utf8")) : req.body;
    const body = req.body ?? {};

    // Accept either "queryResult" (preferred) or "result" (what your FE sends now)
    const {
      proofs,
      queryResult,
      result,
      scope,
      uniqueIdentifier: clientUID,
      address, // Extract address from request body
    } = body;
    const qr = queryResult ?? result;

    if (!proofs || !qr || !scope) {
      return res
        .status(400)
        .json({ error: "missing fields", have: Object.keys(body) });
    }

    console.log("UID from client:", clientUID);

    // Backend origin: pass your frontend host to be safe (matches your dev preview at 4173)
    const zk = new ZKPassport();

    const { verified, uniqueIdentifier: serverUID, queryResultErrors } =
      await zk.verify({
        proofs,
        queryResult: qr,
        scope,
        devMode: true, // match your FE
      });

    // Save verification data to database
    try {
      await saveVerification(clientUID, address);
      console.log("Verification data saved to database");
    } catch (dbError) {
      console.error("Failed to save to database:", dbError);
      // Continue with response even if database save fails
    }

    return res.json({
      verified,
      clientUID,
      serverUID,
      match: clientUID === serverUID,
      queryResultErrors,
      address, // Include address in response
    });
  } catch (e: any) {
    console.error("Verify error:", e?.message || e);
    return res.status(500).json({ error: "verification_failed" });
  }
});

app.listen(3000, async () => {
  console.log("Verifier listening on :3000");
});
