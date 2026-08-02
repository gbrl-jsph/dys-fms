#!/usr/bin/env python3
"""Add cross-link metadata to all memory/ Markdown files."""

from pathlib import Path

AI_DIR = Path(__file__).resolve().parents[1]

RELATED_MAP = {
    "README.md": [
        "project-index.md",
        "project-memory.md",
        "AI_INSTRUCTIONS.md",
    ],
    "AI_INSTRUCTIONS.md": [
        "concept-paper.md",
        "project-memory.md",
        "client-interview.md",
        "project-index.md",
    ],
    "concept-paper.md": [
        "client-interview.md",
        "project-memory.md",
        "project-index.md",
        "blueprint/use-case.md",
        "AI_INSTRUCTIONS.md",
    ],
    "client-interview.md": [
        "concept-paper.md",
        "project-memory.md",
        "project-index.md",
        "blueprint/use-case.md",
    ],
    "project-memory.md": [
        "concept-paper.md",
        "client-interview.md",
        "project-index.md",
        "AI_INSTRUCTIONS.md",
        "blueprint/system-architecture.md",
        "blueprint/user-flow.md",
        "blueprint/consistency-review.md",
    ],
    "project-index.md": [
        "concept-paper.md",
        "project-memory.md",
        "client-interview.md",
        "system-components.md",
        "AI_INSTRUCTIONS.md",
    ],
    "system-components.md": [
        "concept-paper.md",
        "project-memory.md",
        "blueprint/system-architecture.md",
        "blueprint/user-flow.md",
        "blueprint/er-diagram.md",
    ],
    "blueprint/system-architecture.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "../system-components.md",
        "system-flowchart.md",
        "er-diagram.md",
    ],
    "blueprint/system-flowchart.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "system-architecture.md",
        "user-flow.md",
        "use-case.md",
    ],
    "blueprint/user-flow.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "system-flowchart.md",
        "use-case.md",
    ],
    "blueprint/use-case.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "user-flow.md",
        "wireframes.md",
    ],
    "blueprint/wireframes.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "use-case.md",
        "user-flow.md",
    ],
    "blueprint/er-diagram.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "../system-components.md",
        "database-schema.md",
        "system-architecture.md",
    ],
    "blueprint/database-schema.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "er-diagram.md",
        "system-architecture.md",
    ],
    "blueprint/consistency-review.md": [
        "../concept-paper.md",
        "../project-memory.md",
        "../project-index.md",
        "system-architecture.md",
        "user-flow.md",
        "use-case.md",
        "er-diagram.md",
        "wireframes.md",
    ],
}


def add_related_block(content: str, rel_path: str, related: list[str]) -> str:
    lines = content.split("\n")
    first_heading = None
    for i, line in enumerate(lines):
        if line.startswith("# ") and first_heading is None:
            first_heading = i
            break

    if first_heading is None:
        return content

    existing_related = False
    for j in range(first_heading + 1, min(first_heading + 5, len(lines))):
        if lines[j].strip().startswith("Related:") or lines[j].strip().startswith("> **Related"):
            existing_related = True
            break

    if existing_related:
        return content

    related_block = "\nRelated:"
    for r in related:
        related_block += f"\n- {r}"
    related_block += "\n"

    insert_at = first_heading + 1
    while insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1

    new_lines = lines[:insert_at]
    new_lines.append("")
    new_lines.append("Related:")
    for r in related:
        new_lines.append(f"- {r}")
    new_lines.append("")
    new_lines.extend(lines[insert_at:])

    return "\n".join(new_lines)


def process_extracted(filepath: Path):
    stem = filepath.stem
    content = filepath.read_text()
    lines = content.split("\n")

    first_heading = None
    for i, line in enumerate(lines):
        if line.startswith("# ") and first_heading is None:
            first_heading = i
            break
    if first_heading is None:
        return

    for j in range(first_heading + 1, min(first_heading + 5, len(lines))):
        if "Related:" in lines[j]:
            return

    related = []
    if any(kw in stem for kw in ["concept-paper", "research"]):
        related = ["../concept-paper.md", "../client-interview.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["interview"]):
        related = ["../client-interview.md", "../concept-paper.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["system-architecture", "architecture"]):
        related = ["../blueprint/system-architecture.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["system-flowchart", "flowchart"]):
        related = ["../blueprint/system-flowchart.md", "../blueprint/user-flow.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["user-flow", "userflow"]):
        related = ["../blueprint/user-flow.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["use-case", "usecase"]):
        related = ["../blueprint/use-case.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["er-diagram", "er diagram"]) or "er" in stem:
        related = ["../blueprint/er-diagram.md", "../blueprint/database-schema.md", "../project-memory.md"]
    elif any(kw in stem for kw in ["wireframes"]):
        related = ["../blueprint/wireframes.md", "../project-memory.md"]
    elif stem == "final":
        related = ["../blueprint/system-architecture.md", "../project-memory.md"]
    else:
        related = ["../project-memory.md"]

    insert_at = first_heading + 1
    while insert_at < len(lines) and lines[insert_at].strip() == "":
        insert_at += 1

    block = "\nRelated:\n" + "\n".join(f"- {r}" for r in related) + "\n"

    new_lines = lines[:insert_at] + ["", "Related:"] + [f"- {r}" for r in related] + [""] + lines[insert_at:]
    filepath.write_text("\n".join(new_lines))


def main():
    print("Adding cross-links to curated documents...")
    for rel_path, related in RELATED_MAP.items():
        filepath = AI_DIR / rel_path
        if not filepath.exists():
            print(f"  ⚠  Not found: {rel_path}")
            continue
        content = filepath.read_text()
        new_content = add_related_block(content, rel_path, related)
        if new_content != content:
            filepath.write_text(new_content)
            print(f"  ✅ {rel_path}")
        else:
            print(f"  ⏭  {rel_path} (already has links)")

    print("\nAdding cross-links to extracted documents...")
    extracted_dir = AI_DIR / "extracted"
    if extracted_dir.exists():
        for fpath in sorted(extracted_dir.iterdir()):
            if fpath.suffix == ".md":
                process_extracted(fpath)
                print(f"  ✅ extracted/{fpath.name}")

    print("\nDone.")


if __name__ == "__main__":
    main()
