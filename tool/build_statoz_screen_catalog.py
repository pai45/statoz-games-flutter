"""Build the StatOz screenshot manifests, QA register, and searchable PDF."""

from __future__ import annotations

import csv
import json
import re
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image
from reportlab.lib.colors import HexColor, white
from reportlab.lib.pagesizes import A4
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen import canvas

ROOT = Path(__file__).resolve().parents[1]
SHOT_DIR = ROOT / "output" / "screenshots" / "statoz"
PDF_DIR = ROOT / "output" / "pdf"
PDF_PATH = PDF_DIR / "statoz-screen-state-catalog.pdf"
VIEWPORT = {"width": 393, "height": 852, "devicePixelRatio": 1}


def sentence(feature: str, surface: str, state: str) -> tuple[str, str, str, list[str]]:
    if feature == "onboarding":
        return "Fresh local player profile", "Launch StatOz", "The welcome reveal introduces first-launch setup", ["first-launch", "gratification", "keyframe-setup"]
    if feature == "sports":
        return "Deterministic fixture repository loaded", f"Open the {state.upper()} MATCH lane", "Fixtures, leagues, and match actions are visible", ["match", "seeded-data"]
    if feature == "picks":
        return "Deterministic markets loaded", "Open PICK", "Markets and current positions are visible", ["pick", "seeded-data"]
    if feature == "match-tabs":
        tab = state.upper()
        is_lower_stats_frame = state == "stats-lower"
        return (
            f"Seeded {surface.title()} fixture loaded",
            (
                "Open the fixture, select STATS, and scroll to the terminal "
                "screen position"
                if is_lower_stats_frame
                else f"Open the fixture and select {tab}"
            ),
            (
                f"The lower STATS content is visible for {surface.title()}"
                if is_lower_stats_frame
                else f"The {tab} match-detail tab is visible for {surface.title()}"
            ),
            [
                "match-detail",
                surface,
                state,
                "seeded-data",
                *( ["scroll-continuation"] if is_lower_stats_frame else [] ),
            ],
        )
    if feature == "games" and surface == "games-hub":
        return "All starter-pack gates satisfied", f"Open the {state.upper()} GAMES lane", "Shipped modes for the selected lane are visible", ["games", "seeded-data"]
    if feature == "games":
        sport = game_sport(surface)
        tags = ["game-entry", sport, "loaded"]
        if surface == "tennis-rally":
            tags = ["game-entry", sport, "loading", "qa-finding"]
        return f"{sport.title()} starter gate satisfied", f"Launch {surface.replace('-', ' ').title()}", "The production entry surface establishes objective and primary action", tags
    if feature == "shop":
        return "Seeded wallet and ownership", f"Open {state.upper()} shop category", "Price, ownership, and acquisition state are visible", ["shop", "economy"]
    if feature == "leaderboards":
        return "Seeded local rival roster", "Open TOP", "Podium, player rank, and rival actions are visible", ["leaderboard", "social"]
    if feature == "profile":
        return "Completed local profile", "Open PROFILE", "Identity, wallet, and progression are visible", ["profile", "progression"]
    if feature == "social":
        return "Completed local profile", f"Open {surface.replace('-', ' ')}", "Social and reward actions are visible", ["social", state]
    return "Any player", f"Open {surface.replace('-', ' ')}", "Help content and next action are visible", ["help", "support"]


def game_sport(game: str) -> str:
    if game in {"final-over", "cricket-quiz", "cricket-guess-player"}:
        return "cricket"
    if game in {"hoop-duel", "basketball-quiz", "basketball-guess-player"}:
        return "basketball"
    if game in {"grand-prix-dash", "motorsport-quiz", "guess-driver"}:
        return "motorsport"
    if game in {"tennis-rally", "tennis-quiz", "guess-winner"}:
        return "tennis"
    return "football"


def read_scenarios() -> list[dict]:
    scenarios = []
    seen = set()
    pattern = re.compile(r"^(\d{3})_([^_]+)__([^_]+)__([^.]*)\.png$")
    for path in sorted(SHOT_DIR.glob("*.png")):
        match = pattern.match(path.name)
        if not match:
            continue
        order, feature, surface, state = match.groups()
        scenario_id = f"{feature}.{surface}.{state}"
        if scenario_id in seen:
            raise ValueError(f"Duplicate scenario id: {scenario_id}")
        seen.add(scenario_id)
        with Image.open(path) as image:
            if image.size != (393, 852):
                raise ValueError(f"Unexpected dimensions for {path.name}: {image.size}")
            image.verify()
        preconditions, action, expected, tags = sentence(feature, surface, state)
        scenarios.append({
            "order": int(order), "id": scenario_id, "feature": feature,
            "surface": surface, "state": state, "preconditions": preconditions,
            "action": action, "expected": expected,
            "dataSource": "deterministic-seed / compiled-web-production-widget",
            "tags": tags, "animationKeyframe": "settled",
            "screenshotPath": path.relative_to(ROOT).as_posix(),
            "flowFrom": [] if not scenarios else [scenarios[-1]["id"]],
            "flowTo": [], "captureStatus": "captured",
        })
    for previous, current in zip(scenarios, scenarios[1:]):
        previous["flowTo"] = [current["id"]]
    return scenarios


NON_CAPTURABLE = [
    {"id": "global.offline.live-service", "status": "BUILT", "reason": "Requires a controllable service outage; retained as a manual QA scenario."},
    {"id": "global.level-up.celebration", "status": "BUILT", "reason": "Timing-dependent global overlay; existing component golden is authoritative."},
    {"id": "global.pack-and-settlement.keyframes", "status": "BUILT", "reason": "Existing focused goldens cover these frames; not duplicated in this baseline pass."},
    {"id": "shop.purchase.platform-payment", "status": "PROTOTYPE", "reason": "No production payment provider is connected."},
    {"id": "product.planned-and-deprecated", "status": "PLANNED/DEPRECATED", "reason": "Indexed from product docs and intentionally not visually invented."},
]


def write_manifests(scenarios: list[dict]) -> None:
    manifest = {
        "catalog": "StatOz Complete Screen and State Catalog",
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "viewport": VIEWPORT,
        "scenarioCount": len(scenarios),
        "findingCount": 1,
        "scenarios": scenarios,
        "nonCapturable": NON_CAPTURABLE,
    }
    (SHOT_DIR / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    fields = ["order", "id", "feature", "surface", "state", "preconditions", "action", "expected", "dataSource", "tags", "animationKeyframe", "screenshotPath", "flowFrom", "flowTo", "captureStatus"]
    with (SHOT_DIR / "manifest.csv").open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for row in scenarios:
            out = dict(row)
            out["tags"] = "|".join(out["tags"])
            out["flowFrom"] = "|".join(out["flowFrom"])
            out["flowTo"] = "|".join(out["flowTo"])
            writer.writerow(out)
    with (SHOT_DIR / "qa_findings.csv").open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.writer(handle)
        writer.writerow(["id", "severity", "scenario_id", "summary", "status"])
        writer.writerow(["QA-001", "medium", "games.tennis-rally.entry", "Tennis Rally remained on its loading indicator after the deterministic capture budget.", "open"])
    with (SHOT_DIR / "coverage_audit.csv").open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.writer(handle)
        writer.writerow(["source_file", "feature_area", "coverage_status", "representative_scenario", "note"])
        for source in sorted((ROOT / "lib" / "screens").rglob("*.dart")):
            area = source.relative_to(ROOT / "lib" / "screens").parts[0]
            candidates = [item for item in scenarios if area in item["surface"] or area in item["feature"]]
            representative = candidates[0]["id"] if candidates else ""
            status = "captured-representative" if representative else "indexed-no-dedicated-frame"
            note = "Dedicated or feature-entry frame exists." if representative else "Reachable sub-screen/state remains listed for follow-up expansion; no fabricated image."
            writer.writerow([source.relative_to(ROOT).as_posix(), area, status, representative, note])


def wrap(text: str, font: str, size: float, width: float) -> list[str]:
    lines, current = [], ""
    for word in text.split():
        candidate = f"{current} {word}".strip()
        if current and stringWidth(candidate, font, size) > width:
            lines.append(current)
            current = word
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def text_block(pdf: canvas.Canvas, label: str, value: str, x: float, y: float, width: float) -> float:
    pdf.setFont("Helvetica-Bold", 8)
    pdf.setFillColor(HexColor("#49D9FF"))
    pdf.drawString(x, y, label.upper())
    y -= 13
    pdf.setFont("Helvetica", 9)
    pdf.setFillColor(HexColor("#DCE7F4"))
    for line in wrap(value, "Helvetica", 9, width):
        pdf.drawString(x, y, line)
        y -= 12
    return y - 9


def background(pdf: canvas.Canvas, title: str, page_number: int) -> None:
    width, height = A4
    pdf.setFillColor(HexColor("#07111F"))
    pdf.rect(0, 0, width, height, stroke=0, fill=1)
    pdf.setStrokeColor(HexColor("#16324A"))
    pdf.line(28, height - 48, width - 28, height - 48)
    pdf.setFillColor(HexColor("#49D9FF"))
    pdf.setFont("Helvetica-Bold", 9)
    pdf.drawString(28, height - 35, title)
    pdf.setFillColor(HexColor("#7890A8"))
    pdf.drawRightString(width - 28, 22, f"STATOZ // {page_number:03d}")


def build_pdf(scenarios: list[dict]) -> None:
    PDF_DIR.mkdir(parents=True, exist_ok=True)
    pdf = canvas.Canvas(str(PDF_PATH), pagesize=A4, pageCompression=1)
    pdf.setTitle("StatOz Complete Screen and State Catalog")
    width, height = A4
    background(pdf, "STATOZ // PRODUCT + QA CATALOG", 1)
    pdf.setFillColor(white)
    pdf.setFont("Helvetica-Bold", 29)
    pdf.drawString(42, height - 180, "COMPLETE SCREEN")
    pdf.drawString(42, height - 217, "& STATE CATALOG")
    pdf.setFillColor(HexColor("#49D9FF"))
    pdf.setFont("Helvetica-Bold", 15)
    pdf.drawString(42, height - 254, "393 x 852 // DPR 1 // DETERMINISTIC BASELINE")
    pdf.setFillColor(HexColor("#B6C8D9"))
    pdf.setFont("Helvetica", 11)
    pdf.drawString(42, height - 310, f"{len(scenarios)} production-widget captures | 18 game entries | 5 sport families")
    pdf.drawString(42, height - 330, "Pitch Duel is cataloged as a Football game mode within StatOz.")
    pdf.showPage()

    background(pdf, "CONTENTS + LEGEND", 2)
    counts = Counter(item["feature"] for item in scenarios)
    y = height - 82
    pdf.setFont("Helvetica-Bold", 17)
    pdf.setFillColor(white)
    pdf.drawString(36, y, "CAPTURE COVERAGE")
    y -= 30
    for feature, count in counts.items():
        pdf.setFont("Helvetica-Bold", 10)
        pdf.setFillColor(HexColor("#49D9FF"))
        pdf.drawString(40, y, feature.upper())
        pdf.setFillColor(HexColor("#DCE7F4"))
        pdf.drawRightString(250, y, str(count))
        y -= 18
    y -= 16
    for color, line in [("#49D9FF", "Primary flow / active selection"), ("#FF49C5", "Alternate branch"), ("#F4C95D", "Reward / gratification"), ("#FF5964", "Failure / QA finding"), ("#8A98A8", "Back / return")]:
        pdf.setFillColor(HexColor(color))
        pdf.rect(40, y - 3, 18, 6, stroke=0, fill=1)
        pdf.setFillColor(HexColor("#DCE7F4"))
        pdf.drawString(68, y - 3, line)
        y -= 19
    pdf.showPage()

    for page_number, item in enumerate(scenarios, start=3):
        background(pdf, item["id"], page_number)
        shot = ROOT / item["screenshotPath"]
        image = ImageReader(str(shot))
        with Image.open(shot) as shot_image:
            image_width, image_height = shot_image.size
        phone_h = 700
        phone_w = phone_h * image_width / image_height
        pdf.drawImage(image, 30, 58, width=phone_w, height=phone_h, preserveAspectRatio=True, mask="auto")
        x, y = 30 + phone_w + 28, height - 86
        pdf.setFont("Helvetica-Bold", 13)
        pdf.setFillColor(white)
        title_lines = [f"{part}." if index < len(item["id"].split('.')) - 1 else part for index, part in enumerate(item["id"].split('.'))]
        for line in title_lines:
            pdf.drawString(x, y, line)
            y -= 16
        y -= 5
        for label, value in [
            ("Feature / surface", f"{item['feature']} / {item['surface']}"),
            ("State", item["state"]),
            ("Preconditions", item["preconditions"]),
            ("Player action", item["action"]),
            ("Expected result", item["expected"]),
            ("Data source", item["dataSource"]),
            ("Tags", ", ".join(item["tags"])),
            ("Flow from", ", ".join(item["flowFrom"]) or "START"),
            ("Flow to", ", ".join(item["flowTo"]) or "END"),
        ]:
            y = text_block(pdf, label, value, x, y, width - x - 28)
        pdf.showPage()

    page_number = len(scenarios) + 3
    background(pdf, "QA + NON-CAPTURABLE APPENDIX", page_number)
    y = height - 82
    pdf.setFillColor(HexColor("#FF5964"))
    pdf.setFont("Helvetica-Bold", 14)
    pdf.drawString(36, y, "QA-001 // TENNIS RALLY LOADING")
    y -= 24
    pdf.setFillColor(HexColor("#DCE7F4"))
    pdf.setFont("Helvetica", 10)
    for line in wrap("The Tennis Rally entry remained on its loading indicator after the deterministic capture budget. It is retained as evidence and not silently replaced.", "Helvetica", 10, width - 72):
        pdf.drawString(36, y, line)
        y -= 14
    y -= 18
    pdf.setFillColor(white)
    pdf.setFont("Helvetica-Bold", 14)
    pdf.drawString(36, y, "EXPLICITLY NON-CAPTURABLE")
    y -= 24
    for entry in NON_CAPTURABLE:
        y = text_block(pdf, f"{entry['status']} // {entry['id']}", entry["reason"], 36, y, width - 72)
    pdf.save()


if __name__ == "__main__":
    items = read_scenarios()
    if len(items) != 70:
        raise SystemExit(f"Expected 70 screenshots, found {len(items)}")
    write_manifests(items)
    build_pdf(items)
    print(f"Wrote {len(items)} scenarios and {PDF_PATH.relative_to(ROOT)}")
