#!/usr/bin/env python3
"""Generate GitHub Pages HTML from workshop markdown."""

from __future__ import annotations

import html
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKSHOP = ROOT / "workshop"
DOCS = ROOT / "docs"
GUIA = DOCS / "guia"
REPO = "https://github.com/pkstaz/semantic-routing-workshop"

PAGES = [
    {
        "src": "00-introduccion.md",
        "slug": "00-introduccion",
        "title": "Introducción",
        "time": "5 min",
        "num": "00",
    },
    {
        "src": "01-python.md",
        "slug": "01-python",
        "title": "Requisitos de Python",
        "time": "10 min",
        "num": "01",
    },
    {
        "src": "02-docker.md",
        "slug": "02-docker",
        "title": "Docker y Docker Compose",
        "time": "10 min",
        "num": "02",
    },
    {
        "src": "03-vllm-sr.md",
        "slug": "03-vllm-sr",
        "title": "Instalar vllm-sr CLI",
        "time": "5 min",
        "num": "03",
    },
    {
        "src": "04-arquitectura-y-flujo.md",
        "slug": "04-arquitectura-y-flujo",
        "title": "Arquitectura y flujo",
        "time": "10 min",
        "num": "04",
    },
    {
        "src": "05-configuracion.md",
        "slug": "05-configuracion",
        "title": "Configuración",
        "time": "20 min",
        "num": "05",
    },
    {
        "src": "06-levantar-servicios.md",
        "slug": "06-levantar-servicios",
        "title": "Levantar los servicios",
        "time": "10 min",
        "num": "06",
    },
    {
        "src": "07-ejercicios.md",
        "slug": "07-ejercicios",
        "title": "Ejercicios prácticos",
        "time": "30 min",
        "num": "07",
    },
    {
        "src": "08-comandos-cli.md",
        "slug": "08-comandos-cli",
        "title": "Comandos CLI útiles",
        "time": "10 min",
        "num": "08",
    },
    {
        "src": "09-troubleshooting.md",
        "slug": "09-troubleshooting",
        "title": "Troubleshooting",
        "time": "referencia",
        "num": "09",
    },
    {
        "src": "10-limpieza.md",
        "slug": "10-limpieza",
        "title": "Limpieza",
        "time": "5 min",
        "num": "10",
    },
    {
        "src": "instructor.md",
        "slug": "instructor",
        "title": "Guía del instructor",
        "time": "staff",
        "num": "I",
    },
]


HEADER = """<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{title} · Semantic Router Workshop</title>
  <meta name="description" content="{description}" />
  <link rel="stylesheet" href="{prefix}assets/css/style.css" />
</head>
<body class="bg-space">
  <div class="star-field" aria-hidden="true"></div>
  <div class="wrap">
    <header class="site-header">
      <div class="container header-inner">
        <a class="brand" href="{home}">
          <span class="brand-mark">🚀</span>
          <span class="brand-text">
            <span class="brand-kicker">DevOpsDays Santiago</span>
            <span class="brand-name">Semantic Router Workshop</span>
          </span>
        </a>
        <button class="menu-toggle" type="button" data-menu-toggle aria-expanded="false">Menú</button>
        <nav class="nav" data-nav>
          <a href="{home}" class="{home_active}">Inicio</a>
          <a href="{guides}" class="{guide_active}">Guía</a>
          <a href="{home}#arquitectura">Arquitectura</a>
          <a href="{instructor}" class="{instructor_active}">Instructor</a>
          <a href="{repo}" target="_blank" rel="noopener">Repo</a>
          <a class="btn btn-primary btn-sm" href="{first}">Empezar</a>
        </nav>
      </div>
    </header>
"""

FOOTER = """    <footer class="site-footer">
      <div class="container footer-inner">
        <p>Semantic Router Workshop · DevOpsDays Santiago 2026 — Misión Espacial DevOps</p>
        <p>
          <a href="https://santiago.devopsdayschile.cl/" target="_blank" rel="noopener">DevOpsDays Chile</a>
          ·
          <a href="{repo}" target="_blank" rel="noopener">GitHub</a>
        </p>
      </div>
    </footer>
  </div>
  <script src="{prefix}assets/js/main.js"></script>
</body>
</html>
"""


def rewrite_links(md: str) -> str:
    md = re.sub(r"\]\(\./([^)]+)\.md\)", r"](\1.html)", md)
    md = re.sub(r"\]\((?!https?:)([^)/][^)]*)\.md\)", r"](\1.html)", md)
    md = md.replace(
        "](../config/config.example.yaml)",
        f"]({REPO}/blob/devopsdays/config/config.example.yaml)",
    )
    return md


def inline_format(text: str) -> str:
    text = re.sub(r"`([^`]+)`", lambda m: f"<code>{html.escape(m.group(1))}</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    text = re.sub(
        r"\[([^\]]+)\]\(([^)]+)\)",
        lambda m: f'<a href="{html.escape(m.group(2), quote=True)}">{m.group(1)}</a>',
        text,
    )
    return text


def is_table_separator(line: str) -> bool:
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    return bool(cells) and all(re.fullmatch(r":?-{3,}:?", c) for c in cells)


def convert_table(block: str) -> str | None:
    rows = [line.strip() for line in block.strip().splitlines() if line.strip()]
    if len(rows) < 2 or not is_table_separator(rows[1]):
        return None
    def cells(line: str) -> list[str]:
        line = line.strip().strip("|")
        return [c.strip() for c in line.split("|")]

    header = cells(rows[0])
    body = [cells(r) for r in rows[2:]]
    out = ["<table>", "<thead><tr>"]
    out.extend(f"<th>{inline_format(c)}</th>" for c in header)
    out.append("</tr></thead><tbody>")
    for row in body:
        out.append("<tr>")
        out.extend(f"<td>{inline_format(c)}</td>" for c in row)
        out.append("</tr>")
    out.append("</tbody></table>")
    return "".join(out)


def md_to_html(md: str) -> str:
    md = rewrite_links(md.replace("\r\n", "\n"))
    fences: list[tuple[str, str]] = []

    def save_fence(match: re.Match[str]) -> str:
        fences.append((match.group(1) or "", match.group(2).rstrip("\n")))
        return f"\n@@FENCE{len(fences) - 1}@@\n"

    md = re.sub(r"```(\w+)?\n(.*?)```", save_fence, md, flags=re.S)

    blocks = re.split(r"\n\s*\n", md.strip())
    html_blocks: list[str] = []

    for block in blocks:
        raw = block.strip()
        if not raw:
            continue
        fence = re.fullmatch(r"@@FENCE(\d+)@@", raw)
        if fence:
            lang, code = fences[int(fence.group(1))]
            cls = f' class="language-{html.escape(lang)}"' if lang else ""
            html_blocks.append(f"<pre><code{cls}>{html.escape(code)}</code></pre>")
            continue
        if raw.startswith("# "):
            html_blocks.append(f"<h1>{inline_format(raw[2:].strip())}</h1>")
            continue
        if raw.startswith("## "):
            html_blocks.append(f"<h2>{inline_format(raw[3:].strip())}</h2>")
            continue
        if raw.startswith("### "):
            html_blocks.append(f"<h3>{inline_format(raw[4:].strip())}</h3>")
            continue
        if raw.startswith("> "):
            quote = " ".join(line[2:] if line.startswith("> ") else line for line in raw.splitlines())
            html_blocks.append(f"<blockquote>{inline_format(quote)}</blockquote>")
            continue
        if "|" in raw and any(is_table_separator(line) for line in raw.splitlines()):
            table = convert_table(raw)
            if table:
                html_blocks.append(table)
                continue
        lines = raw.splitlines()
        if all(re.match(r"^[-*] ", line) or line.startswith("  ") for line in lines):
            items = []
            current = []
            for line in lines:
                if re.match(r"^[-*] ", line):
                    if current:
                        items.append(" ".join(current))
                    current = [line[2:].strip()]
                else:
                    current.append(line.strip())
            if current:
                items.append(" ".join(current))
            lis = "".join(f"<li>{inline_format(item)}</li>" for item in items)
            html_blocks.append(f"<ul>{lis}</ul>")
            continue
        if all(re.match(r"^\d+\. ", line) or line.startswith("  ") for line in lines):
            items = []
            current = []
            for line in lines:
                numbered = re.match(r"^\d+\. (.*)", line)
                if numbered:
                    if current:
                        items.append(" ".join(current))
                    current = [numbered.group(1).strip()]
                else:
                    current.append(line.strip())
            if current:
                items.append(" ".join(current))
            lis = "".join(f"<li>{inline_format(item)}</li>" for item in items)
            html_blocks.append(f"<ol>{lis}</ol>")
            continue
        html_blocks.append(f"<p>{inline_format(raw.replace(chr(10), ' '))}</p>")

    return "\n".join(html_blocks)


def toc_html(active: str, prefix: str) -> str:
    items = []
    for page in PAGES:
        cls = " is-active" if page["slug"] == active else ""
        items.append(
            f'<a class="{cls.strip()}" href="{prefix}guia/{page["slug"]}.html">'
            f'<span>{page["num"]}. {page["title"]}</span>'
            f'<div class="toc-time">{page["time"]}</div></a>'
        )
    return "\n".join(items)


def pager_html(index: int) -> str:
    prev_page = PAGES[index - 1] if index > 0 else None
    next_page = PAGES[index + 1] if index + 1 < len(PAGES) else None
    left = (
        f'<a href="{prev_page["slug"]}.html"><span class="dir">Anterior</span>{prev_page["title"]}</a>'
        if prev_page
        else "<span></span>"
    )
    right = (
        f'<a href="{next_page["slug"]}.html"><span class="dir">Siguiente</span>{next_page["title"]}</a>'
        if next_page
        else "<span></span>"
    )
    return f'<nav class="pager">{left}{right}</nav>'


def nav_flags(kind: str) -> dict[str, str]:
    return {
        "home_active": "is-active" if kind == "home" else "",
        "guide_active": "is-active" if kind == "guide" else "",
        "instructor_active": "is-active" if kind == "instructor" else "",
    }


def write_guide_pages() -> None:
    GUIA.mkdir(parents=True, exist_ok=True)
    for i, page in enumerate(PAGES):
        md = (WORKSHOP / page["src"]).read_text(encoding="utf-8")
        body = md_to_html(md)
        kind = "instructor" if page["slug"] == "instructor" else "guide"
        header = HEADER.format(
            title=page["title"],
            description=f"Guía del workshop Semantic Router: {page['title']}.",
            prefix="../",
            home="../index.html",
            guides="00-introduccion.html",
            instructor="instructor.html",
            repo=REPO,
            first="00-introduccion.html",
            **nav_flags(kind),
        )
        content = f"""{header}
    <main class="container guide-shell">
      <aside class="toc">
        <h2>Itinerario</h2>
        {toc_html(page["slug"], "../")}
      </aside>
      <article class="article prose">
        <div class="article-kicker">Misión {page["num"]} · {page["time"]}</div>
        {body}
        {pager_html(i)}
      </article>
    </main>
{FOOTER.format(prefix="../", repo=REPO)}
"""
        (GUIA / f"{page['slug']}.html").write_text(content, encoding="utf-8")


if __name__ == "__main__":
    write_guide_pages()
    print(f"Generated {len(PAGES)} guide pages in {GUIA}")
