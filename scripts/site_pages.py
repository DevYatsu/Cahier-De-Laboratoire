#!/usr/bin/env python3
"""Render the multi-page site from the structured document.

Stdlib only. Every page shares site/layout.html: a global sidebar (all
séances and their entries), the page body, and a right rail ("Sur cette
page"). Pages produced:

    index.html          couverture, journal des séances, guide de lecture, contexte
    seance-NN.html      one page per séance, one <article> per entry
    suivi.html          grille de suivi: rubric status of every entry
    rapport.html        rapport d'activité (data loaded from rapport-data.json)
    usage-ia.html       déclaration d'usage de l'IA
    404.html            GitHub Pages fallback
    search-index.json   full-text index for the search dialog
"""

from __future__ import annotations

import html
import json
import os
import re
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

try:
    from scripts.site_model import (
        RUBRIQUES, Document, Entree, Seance, plain_text, split_on_level, HEADING_RE,
    )
except ImportError:  # executed as a script from scripts/
    from site_model import (  # type: ignore[no-redef]
        RUBRIQUES, Document, Entree, Seance, plain_text, split_on_level, HEADING_RE,
    )

ROOT = Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
REPO_URL = "https://github.com/DevYatsu/Cahier-De-Laboratoire"
PLACEHOLDER_RE = re.compile(r"\{\{(\w+)\}\}")

STATUT_LIBELLE = {"ok": "Rédigé", "todo": "À compléter", "absent": "Absent"}
STATUT_SYMBOLE = {"ok": "✓", "todo": "…", "absent": "—"}
MOIS_COURTS = ("janv.", "févr.", "mars", "avr.", "mai", "juin", "juil.",
               "août", "sept.", "oct.", "nov.", "déc.")


def esc(value: object) -> str:
    return html.escape(str(value), quote=True)


# ---------------------------------------------------------------- metadata

@dataclass
class Meta:
    author: str
    title: str
    subtitle: str
    marque: str
    semestre: str
    module: str
    objet: str
    commit: str
    commit_url: str
    build_iso: str
    build_date: str


def read_config() -> dict[str, str]:
    """Pull the cover metadata out of config.typ: one source for PDF and site."""
    text = (ROOT / "config.typ").read_text(encoding="utf-8")
    return dict(re.findall(r'^\s*([\w-]+):\s*"([^"]*)"', text, re.MULTILINE))


def build_meta() -> Meta:
    cfg = read_config()
    sha = os.environ.get("GITHUB_SHA")
    if not sha:
        try:
            sha = subprocess.run(
                ["git", "rev-parse", "HEAD"], cwd=ROOT, capture_output=True,
                text=True, timeout=10,
            ).stdout.strip()
        except (OSError, subprocess.SubprocessError):
            sha = ""
    now = datetime.now(ZoneInfo("Europe/Zurich"))
    return Meta(
        author=cfg.get("author", ""),
        title=cfg.get("titre", "Cahier de laboratoire"),
        subtitle=cfg.get("sous-titre", ""),
        marque=cfg.get("marque", ""),
        semestre=cfg.get("semestre", ""),
        module=cfg.get("module", ""),
        objet=cfg.get("objet", ""),
        commit=sha[:7] or "locale",
        commit_url=f"{REPO_URL}/commit/{sha}" if sha else REPO_URL,
        build_iso=now.isoformat(timespec="minutes"),
        build_date=f"{now.day} {MOIS_COURTS[now.month - 1]} {now.year} à {now:%H:%M}",
    )


def date_courte(iso: str | None) -> str:
    """2026-09-25 -> 25 sept. 2026."""
    if not iso:
        return ""
    year, month, day = (int(part) for part in iso.split("-"))
    return f"{day} {MOIS_COURTS[month - 1]} {year}"


# ---------------------------------------------------------------- fragments

def capitaliser(text: str | None) -> str:
    return text[:1].upper() + text[1:] if text else ""


def folio(num: str) -> str:
    """'2.10.' -> '2.10' : the PDF numbering without its trailing dot."""
    return num.rstrip(".")


def entry_href(seance: Seance, entree: Entree) -> str:
    return f"{seance.slug}#{entree.heading.id}"


def type_badge(entree: Entree) -> str:
    label = entree.kind + (f" {entree.ref}" if entree.ref else "")
    kind = re.sub(r"[^a-z]+", "-", entree.kind.lower()
                  .replace("é", "e").replace("è", "e")).strip("-")
    return f'<span class="type type-{esc(kind)}">{esc(label)}</span>'


def statut_global(entree: Entree) -> str:
    if entree.complete:
        return '<span class="statut statut-ok">Complète</span>'
    return ""


def rubriques_chips(entree: Entree, seance: Seance | None = None) -> str:
    items = []
    for key, label, required in RUBRIQUES:
        status = entree.rubriques.get(key, "absent")
        if status == "absent" and not required:
            continue
        inner = (f'<span class="puce" aria-hidden="true">{STATUT_SYMBOLE[status]}</span>'
                 f'{esc(label)}<span class="sr"> : {STATUT_LIBELLE[status]}</span>')
        target = entree.rubrique_ids.get(key)
        if key == "objectifs" and status != "absent":
            target = entree.heading.id
        if target:
            href = f"{seance.slug}#{target}" if seance else f"#{target}"
            inner = f'<a href="{esc(href)}">{inner}</a>'
        items.append(f'<li class="rubrique rubrique-{status}">{inner}</li>')
    return f'<ul class="rubriques" aria-label="Rubriques">{"".join(items)}</ul>'


def progression(entrees: list[Entree]) -> str:
    return ""


def strip_h1(fragment: str) -> str:
    """Drop the leading h1 of a fragment (the page header renders the title)."""
    match = HEADING_RE.search(fragment)
    if match and match.group(1) == "1":
        return fragment[:match.start()] + fragment[match.end():]
    return fragment


# ---------------------------------------------------------------- chrome

def sidebar(doc: Document, current: str, seance_courante: Seance | None = None) -> str:
    def lien(href: str, label: str, key: str, icon: str) -> str:
        cur = ' aria-current="page"' if key == current else ""
        return f'<li><a href="{href}"{cur}>{icon}<span>{label}</span></a></li>'

    icon = '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="{}"/></svg>'.format
    out = ['<nav class="nav" aria-label="Pages du cahier">',
           '<p class="nav-titre">Cahier</p><ul class="nav-pages">',
           lien("index.html", "Accueil", "index", icon("M3 11 12 4l9 7v9H5v-9")),
           lien("suivi.html", "Grille de suivi", "suivi",
                icon("M4 4h16v16H4zM4 10h16M4 15h16M10 4v16")),
           lien("rapport.html", "Rapport d'activité", "rapport",
                icon("M5 21V9M12 21V3M19 21v-7")),
           lien("usage-ia.html", "Usage de l’IA", "usage-ia",
                icon("M12 3v3M12 18v3M3 12h3M18 12h3M8 8h8v8H8z")),
           '<li><a href="cahier.pdf" target="_blank" rel="noopener">'
           + icon("M14 3H6v18h12V7zM14 3v4h4")
           + '<span>Version PDF</span><span class="externe" aria-label="(nouvel onglet)">↗</span></a></li>',
           "</ul>",
           '<p class="nav-titre">Séances</p><ol class="nav-seances">']
    for seance in doc.seances:
        is_current = seance_courante is not None and seance.key == seance_courante.key
        cur = ' aria-current="page"' if is_current else ""
        out.append(
            f'<li class="nav-seance{" ouverte" if is_current else ""}">'
            f'<a href="{seance.slug}"{cur}><span class="nav-num">{seance.number:02d}</span>'
            f'<span class="nav-seance-texte"><b>{esc(date_courte(seance.date_iso) or seance.label)}</b>'
            f'{f"<small>{esc(capitaliser(seance.theme))}</small>" if seance.theme else ""}</span></a>'
        )
        if is_current and seance.entrees:
            out.append('<ol class="nav-entrees">')
            for entree in seance.entrees:
                out.append(
                    f'<li><a href="#{esc(entree.heading.id)}" data-spy="{esc(entree.heading.id)}">'
                    f'<span class="nav-folio">{esc(folio(entree.heading.num))}</span>'
                    f'<span>{esc(entree.heading.title)}</span></a></li>'
                )
            out.append("</ol>")
        out.append("</li>")
    out.append("</ol></nav>")
    return "\n".join(out)


def rail_for_seance(seance: Seance) -> str:
    if not seance.entrees:
        return ""
    out = ['<p class="rail-titre">Sur cette page</p><nav aria-label="Sections de la séance"><ol>']
    for entree in seance.entrees:
        out.append(
            f'<li><a href="#{esc(entree.heading.id)}" data-spy="{esc(entree.heading.id)}">'
            f'{esc(entree.name)}</a>'
        )
        if entree.sous_titres:
            out.append("<ol>")
            for sub in entree.sous_titres:
                out.append(f'<li><a href="#{esc(sub.id)}" data-spy="{esc(sub.id)}">'
                           f'{esc(sub.title)}</a></li>')
            out.append("</ol>")
        out.append("</li>")
    out.append('</ol></nav><a class="rail-haut" href="#contenu">↑ Haut de page</a>')
    return "\n".join(out)


def rail_simple(items: list[tuple[str, str]]) -> str:
    links = "".join(f'<li><a href="#{esc(i)}" data-spy="{esc(i)}">{esc(t)}</a></li>'
                    for i, t in items)
    return (f'<p class="rail-titre">Sur cette page</p>'
            f'<nav aria-label="Sections de la page"><ol>{links}</ol></nav>')


def fil(*crumbs: tuple[str | None, str]) -> str:
    parts = []
    for href, label in crumbs:
        if href:
            parts.append(f'<li><a href="{esc(href)}">{esc(label)}</a></li>')
        else:
            parts.append(f'<li><span aria-current="page">{esc(label)}</span></li>')
    return f'<nav class="fil" aria-label="Fil d’Ariane"><ol>{"".join(parts)}</ol></nav>'


def render_layout(meta: Meta, *, title: str, description: str, page_class: str,
                  sidebar_html: str, main: str, rail: str = "", scripts: str = "") -> str:
    layout = (SITE / "layout.html").read_text(encoding="utf-8")
    values = {
        "title": esc(title), "description": esc(description), "page_class": esc(page_class),
        "author": esc(meta.author), "module": esc(meta.module),
        "sidebar": sidebar_html, "main": main, "rail": rail, "scripts": scripts,
        "build_iso": esc(meta.build_iso), "build_date": esc(meta.build_date),
        "commit": esc(meta.commit), "commit_url": esc(meta.commit_url),
    }

    def substitute(match: re.Match[str]) -> str:
        key = match.group(1)
        if key not in values:
            raise KeyError(f"layout.html: unknown placeholder {{{{{key}}}}}")
        return values[key]

    # One pass: a placeholder-like string inside generated content is left alone.
    return PLACEHOLDER_RE.sub(substitute, layout)


# ---------------------------------------------------------------- pages

def page_seance(doc: Document, meta: Meta, index: int) -> str:
    seance = doc.seances[index]
    prev = doc.seances[index - 1] if index > 0 else None
    nxt = doc.seances[index + 1] if index + 1 < len(doc.seances) else None
    titre = capitaliser(seance.theme) or seance.heading.title
    meta_bits = [f'<span class="tampon">{esc(seance.label)}</span>']
    if seance.date_iso:
        meta_bits.append(f'<time datetime="{seance.date_iso}">{esc(seance.date_label)}</time>')
    meta_bits.append(f"{len(seance.entrees)} entrée{'s' if len(seance.entrees) != 1 else ''}")
    if seance.modified:
        meta_bits.append(f'modifiée le <time datetime="{seance.modified}">'
                         f'{esc(date_courte(seance.modified))}</time>')

    out = [fil(("index.html", "Accueil"), (None, f"{seance.label}")),
           f'<header class="seance-tete" id="{esc(seance.heading.id)}">',
           f'<p class="surtitre">{" · ".join(meta_bits)}</p>',
           f'<h1><span class="num">{esc(folio(seance.heading.num))}</span> {esc(titre)}</h1>',
           f'<div class="seance-intro">{seance.intro_html}</div>' if seance.intro_html else "",
           "</header>"]

    if seance.entrees:
        out.append('<section class="programme" aria-labelledby="programme-titre">'
                   '<div class="programme-tete"><h2 id="programme-titre" class="petit-titre">Au programme</h2>'
                   '</div><ol class="programme-liste">')
        for entree in seance.entrees:
            out.append(
                f'<li><a href="#{esc(entree.heading.id)}">'
                f'<span class="folio">{esc(folio(entree.heading.num))}</span>'
                f'{type_badge(entree)}<span class="programme-nom">{esc(entree.name)}</span>'
                f'{statut_global(entree)}</a></li>'
            )
        out.append("</ol></section>")
    else:
        out.append('<div class="vide"><p class="vide-titre">Séance en cours de rédaction</p>'
                   '<p>Les entrées de cette séance seront publiées ici dès qu’elles '
                   'seront ajoutées aux sources du cahier.</p></div>')

    out.append(f'<div class="bloc-seance" data-seance="{esc(seance.key)}">')
    for entree in seance.entrees:
        match = HEADING_RE.match(entree.html)
        body = entree.html[match.end():] if match else entree.html
        h = entree.heading
        modified = (f'<time datetime="{entree.modified}" title="Dernière modification">'
                    f'modifiée le {esc(date_courte(entree.modified))}</time>'
                    if entree.modified else "")
        out.append(
            f'<article class="entree" aria-labelledby="{esc(h.id)}">'
            f'<header class="entree-tete">'
            f'<div class="entree-meta"><span class="folio">{esc(folio(h.num))}</span>'
            f'{type_badge(entree)}{statut_global(entree)}{modified}</div>'
            f'<h2 id="{esc(h.id)}" data-seance="{esc(seance.key)}">{esc(entree.name)} '
            f'<a class="ancre" href="#{esc(h.id)}" aria-label="Copier le lien vers cette entrée">#</a></h2>'
            f'{rubriques_chips(entree)}'
            f'</header>'
            f'<div class="entree-corps">{body}</div>'
            f'</article>'
        )
    out.append("</div>")

    pager = ['<nav class="pager" aria-label="Séances précédente et suivante">']
    if prev:
        pager.append(f'<a class="pager-prec" href="{prev.slug}"><small>← Séance précédente</small>'
                     f'<b>{esc(prev.label)} · {esc(date_courte(prev.date_iso))}</b></a>')
    else:
        pager.append('<a class="pager-prec" href="index.html"><small>← Retour</small><b>Accueil</b></a>')
    if nxt:
        pager.append(f'<a class="pager-suiv" href="{nxt.slug}"><small>Séance suivante →</small>'
                     f'<b>{esc(nxt.label)} · {esc(date_courte(nxt.date_iso))}</b></a>')
    else:
        pager.append('<a class="pager-suiv" href="suivi.html"><small>Bilan →</small>'
                     '<b>Grille de suivi</b></a>')
    pager.append("</nav>")
    out.extend(pager)

    return render_layout(
        meta,
        title=f"{seance.label} — {titre} · Cahier de laboratoire",
        description=f"{seance.label} du {seance.date_label or ''} : {seance.objectifs or titre}"[:300],
        page_class="page-seance",
        sidebar_html=sidebar(doc, seance.key, seance),
        main="\n".join(out),
        rail=rail_for_seance(seance),
    )


GUIDE_RUBRIQUES = (
    ("Objectifs", "Encadré placé sous le titre : ce que l’entrée doit permettre d’acquérir."),
    ("Métiers pertinents", "Les métiers de la sécurité que l’activité concerne."),
    ("Déroulement", "Facultatif : journal, résultats intermédiaires, sources consultées."),
    ("Résultats", "Ce qui a été produit : tableaux, schémas, réponses argumentées."),
    ("Interprétation", "Pertinence pour les métiers, normes et certifications, "
                       "amélioration continue, apprentissage effectué."),
)


def page_index(doc: Document, meta: Meta, total_heures: float | None,
               figure_count: int) -> str:
    entrees = doc.entrees
    first = doc.seances[0] if doc.seances else None
    dernier = max((s.modified for s in doc.seances if s.modified), default=None)

    out = ['<section class="couverture" aria-labelledby="titre-cahier">',
           f'<p class="surtitre">{esc(meta.marque)}</p>',
           f'<h1 id="titre-cahier">{esc(meta.title)}</h1>',
           f'<p class="couverture-sous-titre">{esc(meta.subtitle)}</p>',
           '<dl class="fiche">',
           f'<div><dt>Auteur</dt><dd>{esc(meta.author)}</dd></div>',
           f'<div><dt>Modules</dt><dd>{esc(meta.module)}</dd></div>',
           f'<div><dt>Semestre</dt><dd>{esc(meta.semestre)}</dd></div>',
           f'<div><dt>Mise à jour</dt><dd>{esc(date_courte(dernier) or "—")}</dd></div>',
           '</dl>',
           f'<p class="couverture-objet"><b>Objet :</b> {esc(meta.objet)}</p>',
           '<div class="couverture-actions">']
    if first:
        out.append(f'<a class="bouton" href="{first.slug}">Commencer la lecture →</a>')
    out.append('<a class="bouton-ligne" href="suivi.html">Grille de suivi</a>'
               '<a class="bouton-ligne" href="cahier.pdf" target="_blank" rel="noopener">'
               'Version PDF ↗</a></div></section>')

    chiffres = [
        (len(doc.seances), "séances"),
        (len(entrees), "entrées"),
        (figure_count, "figures"),
    ]
    if total_heures:
        chiffres.append((f"{total_heures:g} h", "d’activité déclarées"))
    out.append('<ul class="chiffres" aria-label="Le cahier en chiffres">'
               + "".join(f'<li><b>{esc(v)}</b><span>{esc(l)}</span></li>' for v, l in chiffres)
               + "</ul>")

    out.append('<section aria-labelledby="journal"><h2 id="journal" class="section-titre">'
               'Journal des séances</h2><ol class="journal">')
    for seance in doc.seances:
        day, month = "", ""
        if seance.date_iso:
            _, m, d = seance.date_iso.split("-")
            day, month = str(int(d)), MOIS_COURTS[int(m) - 1]
        chips = "".join(
            f'<li><a href="{esc(entry_href(seance, e))}">'
            f'<span class="folio">{esc(folio(e.heading.num))}</span>{esc(e.heading.title)}</a></li>'
            for e in seance.entrees
        )
        resume = seance.objectifs or (
            "Séance en cours de rédaction." if not seance.entrees else "")
        out.append(
            f'<li class="journal-item">'
            f'<time class="journal-date" datetime="{esc(seance.date_iso or "")}">'
            f'<b>{esc(day)}</b><span>{esc(month)}</span></time>'
            f'<div class="journal-carte">'
            f'<p class="surtitre"><span class="tampon">{esc(seance.label)}</span> '
            f'{len(seance.entrees)} entrée{"s" if len(seance.entrees) != 1 else ""}</p>'
            f'<h3><a href="{seance.slug}">{esc(capitaliser(seance.theme) or seance.heading.title)}</a></h3>'
            + (f'<p class="journal-resume">{esc(resume)}</p>' if resume else "")
            + (f'<ol class="journal-entrees">{chips}</ol>' if chips else "")
            + "</div></li>"
        )
    out.append("</ol></section>")

    guide = "".join(f"<li><b>{esc(t)}</b><span>{esc(d)}</span></li>" for t, d in GUIDE_RUBRIQUES)
    out.append(
        '<section aria-labelledby="guide"><h2 id="guide" class="section-titre">Guide de lecture</h2>'
        '<div class="guide">'
        '<div class="guide-bloc"><h3>Organisation</h3>'
        '<p>Une page par séance, dans l’ordre chronologique. Chaque séance s’ouvre sur ses '
        'objectifs et la liste de ses entrées (exercices, activités, travail personnel, synthèse).</p>'
        '<p>La numérotation (<span class="folio">2.3</span>, <span class="folio">2.3.1</span>…) '
        'est identique à celle de la <a href="cahier.pdf" target="_blank" rel="noopener">version PDF</a> : '
        'un renvoi fonctionne dans les deux supports.</p></div>'
        f'<div class="guide-bloc"><h3>Structure d’une entrée</h3><ol class="guide-rubriques">{guide}</ol></div>'
        '<div class="guide-bloc"><h3>Repères</h3><ul class="legende">'
        '<li><span class="rubrique rubrique-ok"><span class="puce">✓</span>Résultats</span> '
        'rubrique rédigée — cliquer pour y accéder.</li>'
        '<li><kbd>Ctrl</kbd> <kbd>K</kbd> ou <kbd>/</kbd> recherche plein texte dans tout le cahier.</li>'
        '</ul></div></div></section>'
    )

    contexte = strip_h1(doc.contexte_html)
    out.append(
        '<section aria-labelledby="contexte"><h2 id="contexte" class="section-titre">Contexte</h2>'
        f'<div class="prose">{contexte}'
        '<p>Le module fonctionne en classe inversée : les sujets sont étudiés en autonomie à partir '
        'des ressources proposées, puis discutés, exercés et expérimentés en séance. Ce cahier en '
        'consigne la trace — problématiques rencontrées, travaux effectués et résultats, recherches '
        'complémentaires — et sert d’outil d’auto-évaluation.</p>'
        f'<p class="mention">Sources : <a href="{REPO_URL}">dépôt GitHub</a> · chaque modification '
        'publiée reconstruit automatiquement ce site et le PDF.</p></div></section>'
    )

    return render_layout(
        meta,
        title=f"{meta.title} — {meta.author}",
        description=f"{meta.title} de {meta.author} ({meta.module}, semestre {meta.semestre.lower()}) : {meta.objet}"[:300],
        page_class="page-accueil",
        sidebar_html=sidebar(doc, "index"),
        main="\n".join(out),
        rail=rail_simple([("journal", "Journal des séances"), ("guide", "Guide de lecture"),
                          ("contexte", "Contexte")]),
        scripts=f'<script type="application/json" id="ancres">{legacy_anchor_map(doc)}</script>',
    )


def legacy_anchor_map(doc: Document) -> str:
    """Heading id -> page, so links to the former single-page site still land."""
    mapping: dict[str, str] = {}
    for seance in doc.seances:
        mapping[seance.heading.id] = seance.slug
        for entree in seance.entrees:
            mapping[entree.heading.id] = seance.slug
            for sub in entree.sous_titres:
                mapping[sub.id] = seance.slug
    # "</" cannot appear in ids (slugify), so the JSON is safe inside <script>.
    return json.dumps(mapping, ensure_ascii=False, separators=(",", ":"))


def page_suivi(doc: Document, meta: Meta) -> str:
    entrees = doc.entrees
    head = "".join(f'<th scope="col" class="col-rubrique">{esc(label)}'
                   f'{"" if required else "<small>facultatif</small>"}</th>'
                   for _, label, required in RUBRIQUES)
    rows = []
    for seance in doc.seances:
        rows.append(
            f'<tbody data-seance="{esc(seance.key)}"><tr class="ligne-seance">'
            f'<th colspan="{3 + len(RUBRIQUES)}" scope="rowgroup">'
            f'<a href="{seance.slug}">{esc(seance.label)}</a> · {esc(seance.date_label or "")}'
            f'{(" — " + esc(seance.theme)) if seance.theme else ""}</th></tr>'
        )
        if not seance.entrees:
            rows.append(f'<tr><td colspan="{3 + len(RUBRIQUES)}" class="vide-ligne">'
                        'Aucune entrée pour le moment.</td></tr>')
        for entree in seance.entrees:
            cells = []
            for key, label, _ in RUBRIQUES:
                status = entree.rubriques.get(key, "absent")
                symbol = (f'<span aria-hidden="true">{STATUT_SYMBOLE[status]}</span>'
                          f'<span class="sr">{STATUT_LIBELLE[status]}</span>')
                target = entree.heading.id if key == "objectifs" else entree.rubrique_ids.get(key)
                if target and status != "absent":
                    symbol = f'<a href="{seance.slug}#{esc(target)}" title="{esc(label)} : {STATUT_LIBELLE[status]}">{symbol}</a>'
                cells.append(f'<td class="cellule cellule-{status}">{symbol}</td>')
            rows.append(
                f'<tr data-complete="{"oui" if entree.complete else "non"}">'
                f'<td class="folio-cellule"><span class="folio">{esc(folio(entree.heading.num))}</span></td>'
                f'<th scope="row"><a href="{esc(entry_href(seance, entree))}">{esc(entree.name)}</a>'
                f'{type_badge(entree)}</th>'
                + "".join(cells)
                + f'<td class="date-cellule">{esc(date_courte(entree.modified))}</td></tr>'
            )
        rows.append("</tbody>")

    main = "\n".join([
        fil(("index.html", "Accueil"), (None, "Grille de suivi")),
        '<header class="page-tete"><p class="surtitre"><span class="tampon">Bilan</span> '
        'calculé à chaque publication</p><h1>Grille de suivi</h1>'
        '<p class="chapeau">État de chaque entrée du cahier selon les rubriques attendues. '
        'La grille est recalculée depuis les sources à chaque publication : une rubrique '
        'marquée « À compléter » ou absente y apparaît immédiatement.</p></header>',
        '<ul class="chiffres" aria-label="Synthèse">'
        f'<li><b>{len(entrees)}</b><span>entrées</span></li></ul>',
        '<ul class="legende legende-ligne"><li><span class="cellule-ok legende-pastille">✓</span> rédigée</li>'
        '<li><span class="cellule-todo legende-pastille">…</span> à compléter</li>'
        '<li><span class="cellule-absent legende-pastille">—</span> absente</li></ul>',
        '<div class="table-scroll grille-scroll" tabindex="0" role="region" aria-label="Grille de suivi">'
        '<table class="grille"><thead><tr><th scope="col">N°</th><th scope="col">Entrée</th>'
        f'{head}<th scope="col">Modifiée</th></tr></thead>'
        + "".join(rows) + "</table></div>",
    ])
    return render_layout(
        meta,
        title="Grille de suivi · Cahier de laboratoire",
        description="État d’avancement de chaque entrée du cahier de laboratoire, rubrique par rubrique.",
        page_class="page-suivi",
        sidebar_html=sidebar(doc, "suivi"),
        main=main,
    )


def page_rapport(doc: Document, meta: Meta) -> str:
    body = (SITE / "rapport-body.html").read_text(encoding="utf-8")
    main = fil(("index.html", "Accueil"), (None, "Rapport d’activité")) + body
    return render_layout(
        meta,
        title="Rapport d’activité · Cahier de laboratoire",
        description=f"Rapport d’activité d’apprentissage — {meta.author}, module 3275.",
        page_class="page-rapport",
        sidebar_html=sidebar(doc, "rapport"),
        main=main,
        scripts='<script src="rapport.js" defer></script>',
    )


def page_usage_ia(doc: Document, meta: Meta) -> str:
    main = (
        fil(("index.html", "Accueil"), (None, "Usage de l’IA"))
        + '<header class="page-tete"><p class="surtitre"><span class="tampon">Déclaration</span></p>'
        '<h1>Usage de l’IA</h1></header>'
        '<div class="prose">'
        '<p>Ce site web a été entièrement créé à l’aide de l’intelligence artificielle.</p>'
        '<p>Pour le contenu du cahier, l’IA est utilisée exclusivement pour reformuler et mettre en '
        'forme les activités, ainsi que pour rédiger les messages de commit.</p></div>'
    )
    return render_layout(
        meta,
        title="Usage de l’IA · Cahier de laboratoire",
        description="Déclaration de l’usage de l’intelligence artificielle dans ce cahier de laboratoire.",
        page_class="page-usage-ia",
        sidebar_html=sidebar(doc, "usage-ia"),
        main=main,
    )


def page_404(doc: Document, meta: Meta) -> str:
    main = ('<div class="vide vide-404"><p class="surtitre"><span class="tampon">Erreur 404</span></p>'
            '<h1>Page introuvable</h1><p>Cette page n’existe pas ou a été déplacée. '
            'Le cahier est désormais découpé en une page par séance.</p>'
            '<p><a class="bouton" href="index.html">Retour à l’accueil</a> '
            '<button type="button" class="bouton-ligne" data-search-open>Rechercher</button></p></div>')
    return render_layout(meta, title="Page introuvable · Cahier de laboratoire",
                         description="Page introuvable.", page_class="page-404",
                         sidebar_html=sidebar(doc, ""), main=main)


# ---------------------------------------------------------------- search

def search_index(doc: Document) -> list[dict[str, str]]:
    """One record per entry and per sub-section: title, context, url, text."""
    records: list[dict[str, str]] = []

    def add(url: str, title: str, context: str, fragment: str) -> None:
        records.append({"u": url, "t": title, "c": context,
                        "x": plain_text(fragment)[:2000]})

    add("index.html#contexte", "Contexte", "Accueil", doc.contexte_html)
    for seance in doc.seances:
        ctx = f"{seance.label} · {date_courte(seance.date_iso)}"
        add(seance.slug, seance.theme or seance.heading.title, ctx, seance.intro_html)
        for entree in seance.entrees:
            preamble, sections = split_on_level(entree.html, 3)
            match = HEADING_RE.match(preamble)
            add(entry_href(seance, entree),
                f"{folio(entree.heading.num)} {entree.heading.title}", ctx,
                preamble[match.end():] if match else preamble)
            for heading, body in sections:
                match = HEADING_RE.match(body)
                add(f"{seance.slug}#{heading.id}",
                    f"{folio(heading.num)} {heading.title}",
                    f"{ctx} · {entree.heading.title}",
                    body[match.end():] if match else body)
    return records
