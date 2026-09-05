---
name: pdf-scraping
description: Cost-efficient protocol for extracting data from PDFs — the extraction tier hierarchy (cheap text tools first, vision models last), fingerprinting and clustering format variants before writing a parser, library selection, and cost control. Load before scraping, parsing, or extracting structured data from PDF documents, especially a batch with unknown or mixed layouts.
---

# Cost-Efficient PDF Scraping Protocol

## Extraction Tier Hierarchy

Always start at the cheapest tier and escalate only when the current tier fails:

1. **Tier 0: Programmatic parsing** — pdfplumber or pymupdf. If the PDF has selectable text and consistent structure, extract directly. Zero AI cost.
2. **Tier 1: Template-based extraction** — When structure varies across pages, use structural fingerprinting to cluster pages into format variants, build a parser per variant, and route pages by fingerprint.
3. **Tier 2: Targeted OCR/Vision** — Only for pages where Tier 0-1 fail (scanned images, garbled encodings, complex tables). Send just those pages to Claude Vision. Budget-cap this tier.
4. **Tier 3: LLM validation, not generation** — Use the programmatic parser to extract first, then validate a sample of outputs with an LLM. Much cheaper than full LLM extraction.

## Format Variant Discovery

PDFs often contain inconsistent layouts that aren't apparent from the first few pages. Use diversity sampling to discover all format variants efficiently:

### Step 1: Structural Fingerprinting (free)
Extract layout-level features per page using pdfplumber/pymupdf:
- Text block bounding boxes and positions
- Font size distribution
- Table presence/absence and column count
- Header/footer patterns
- Image regions vs text regions
- Page dimensions and margins

### Step 2: Cluster by Similarity
Run clustering (DBSCAN or agglomerative) on the fingerprint vectors. Each cluster represents a candidate format variant. Use a distance threshold that groups visually similar layouts together.

### Step 3: Sample Representatives
Inspect 1-2 pages per cluster to understand the variant and build/validate a parser for it. This is where you optionally spend on Vision — but only on ~5-10 exemplar pages, not the full corpus.

### Step 4: Parse and Discover Failures
Run parsers across all pages. Flag low-confidence outputs:
- Parse errors or exceptions
- Unexpected empty fields
- Structural mismatch with expected schema
- Outlier field lengths

These failures are your exploration frontier — they reveal undiscovered format variants.

### Step 5: Iterate
Cluster the failures, sample new representatives, build new parsers. Repeat until the failure rate drops below your threshold.

This is **active learning**: parse failures guide where to spend your expensive inspection budget. You get logarithmic discovery of variants instead of linear page-by-page debugging.

## Library Selection

| Library | Strengths | Use when |
|---------|-----------|----------|
| **pdfplumber** | Table extraction, precise bounding boxes, visual debugging | PDFs with tables, structured layouts |
| **pymupdf (fitz)** | Fast, low-level access, image extraction, text blocks with metadata | Large PDFs, need speed, image-heavy docs |
| **pdfminer.six** | Detailed text layout analysis, character-level positioning | Complex text layouts, multi-column |
| **tabula-py** | Java-based table extraction (wraps Tabula) | Table-heavy PDFs when pdfplumber struggles |
| **camelot** | Lattice and stream table detection | PDFs with visible or invisible table lines |

For fingerprinting, prefer **pymupdf** (fastest for bulk metadata extraction). For actual text extraction, prefer **pdfplumber** (best balance of accuracy and usability).

## Anti-Patterns

- **Sending all pages to Vision/LLM** — Linear cost scaling. Always try programmatic extraction first.
- **Building a parser from page 1 alone** — Format variants hide deeper in the document. Fingerprint and cluster first.
- **Retrying full pipeline on errors** — Isolate failures, understand which format variant caused them, fix the specific parser.
- **OCR on selectable-text PDFs** — Check `page.extract_text()` first. If it returns content, OCR is wasted money.
- **Ignoring confidence signals** — Empty fields, garbled text, and parse exceptions are data. Use them to find format variants you missed.
- **Uniform sampling** — Don't randomly sample pages to validate. Sample from each structural cluster to maximize coverage.

## Practical Workflow

```
1. Load PDF with pymupdf
2. For each page: extract fingerprint (bbox layout, fonts, tables)
3. Cluster fingerprints → identify N format variants
4. For each variant: inspect 1-2 sample pages
5. Build parser per variant (pdfplumber for tables, pymupdf for text)
6. Route each page to its cluster's parser
7. Collect outputs, flag low-confidence results
8. Cluster failures → new variants → repeat from step 4
9. Final validation: LLM-check a random sample of outputs (Tier 3)
```

## Cost Control

- Set a **budget cap** for Tier 2 (Vision) calls per document — e.g., max 10 pages.
- Track cost per page across tiers. If Tier 0 handles 90% of pages, your effective cost per page is near zero.
- For recurring document types, invest in a robust Tier 1 parser upfront — it amortizes to zero over time.
- Cache fingerprint → variant mappings so re-processing the same document type skips discovery.
