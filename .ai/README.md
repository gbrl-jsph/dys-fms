# AI Knowledge Base — DYS Financial Management System (DYS FMS)

Related:
- project-index.md
- project-memory.md
- AI_INSTRUCTIONS.md

## Purpose

This directory contains AI-friendly Markdown versions of every project document. It enables AI agents (Claude, OpenCode, Codex, Gemini, etc.) to read the full project context without parsing PDFs, DOCX, or other binary formats.

## Folder Layout

```
.ai/
├── README.md                  # This file
├── project-index.md           # Index of every document with summaries
├── project-memory.md          # AI context-optimized memory document
├── concept-paper.md           # Curated concept paper
├── client-interview.md        # Curated client interview
├── system-components.md       # Curated system components
├── blueprint/                 # Curated architectural documents
│   ├── system-architecture.md
│   ├── system-flowchart.md
│   ├── user-flow.md
│   ├── use-case.md
│   ├── wireframes.md
│   ├── er-diagram.md
│   ├── database-schema.md
│   └── consistency-review.md
├── extracted/                 # Raw MarkItDown conversions
│   ├── 1-system-architecture-*.md
│   ├── 2-system-flowchart-*.md
│   ├── ...
└── scripts/
    └── extract-docs.py        # Extraction script
```

## Extraction Process

Every supported document in the repository is converted to Markdown using [Microsoft MarkItDown](https://github.com/microsoft/markitdown).

Supported formats: PDF, DOCX, PPTX, XLSX, ODT, HTML, MD, TXT, Images

Curated documents (`concept-paper.md`, `client-interview.md`, etc.) are then generated from the extracted raw Markdown, extracting structured knowledge rather than copying verbatim.

## How to Refresh

```bash
python3 .ai/scripts/extract-docs.py
```

This will:
1. Scan the repository for all supported documents
2. Convert new/changed files using MarkItDown
3. Skip unchanged files using SHA-256 hashes
4. Regenerate all curated documents, project index, and project memory

## Source of Truth Hierarchy

1. Approved Concept Paper
2. System Architecture Documentation
3. User Flow Documentation
4. Use Case Documentation
5. ER Diagram / Database Design
6. Wireframes / HTML prototypes
7. System Flowchart
8. Client Interview
