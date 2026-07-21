#!/usr/bin/env python3
"""
lofi-wire — 마스킹 스크립트.
입력: 원본 HTML 파일 경로 (+ 선택: 추가 마스킹 패턴 JSON)
출력: {filename}.masked.html (같은 디렉토리)

사용 예:
  python3 mask.py ~/Downloads/glinda-onboarding-light-structure.html
  python3 mask.py ~/Downloads/foo.html --extra '{"patterns":[{"pattern":"비밀","replace":"[REDACTED]"}]}'

원칙:
- 자동 룰이 1차. PD가 미리보기로 직접 확인하는 게 결정타.
- preserve 리스트의 단어는 패턴 매칭에서도 가능한 한 유지.
- footnote가 있으면 그 안에 *공유용 마스킹 안내* 한 줄 추가.
"""

import json
import re
import sys
from pathlib import Path

PATTERNS_PATH = Path(__file__).resolve().parent.parent / "assets" / "masking-patterns.json"


def load_patterns():
    with PATTERNS_PATH.open("r", encoding="utf-8") as f:
        return json.load(f)


def apply_rules(text: str, rules: list) -> str:
    for rule in rules:
        try:
            text = re.sub(rule["pattern"], rule["replace"], text)
        except re.error as e:
            print(f"[mask] 정규식 오류 — pattern={rule['pattern']!r}: {e}", file=sys.stderr)
    return text


def mask_html(html: str, patterns_cfg: dict, extra_patterns: list = None) -> str:
    """모든 카테고리의 패턴을 순차 적용."""
    for category in patterns_cfg.get("patterns", []):
        html = apply_rules(html, category.get("rules", []))
    if extra_patterns:
        html = apply_rules(html, extra_patterns)
    return html


def inject_footnote_notice(html: str, footnote_append: str) -> str:
    """기존 .footnote 박스 안에 공유 안내 한 줄 추가. 없으면 body 끝에 신규 박스."""
    notice = (
        f'<div style="margin-top:10px;padding:8px 12px;background:#fff8e1;'
        f'border:1px solid #f0d469;border-radius:6px;font-size:11.5px;color:#7a5a08;">'
        f'⚠️ {footnote_append}</div>'
    )
    if 'class="footnote"' in html or "class='footnote'" in html:
        # 기존 footnote 끝에 끼워넣기
        html = re.sub(
            r'(<div[^>]*class=["\']footnote["\'][^>]*>)(.*?)(</div>)',
            r'\1\2' + notice + r'\3',
            html,
            count=1,
            flags=re.DOTALL,
        )
    else:
        # body 끝에 추가
        html = html.replace("</body>", f"{notice}\n</body>")
    return html


def main():
    if len(sys.argv) < 2:
        print("Usage: mask.py <html_file> [--extra <json_string>]", file=sys.stderr)
        sys.exit(1)

    src = Path(sys.argv[1]).expanduser().resolve()
    if not src.exists():
        print(f"[mask] 파일 없음: {src}", file=sys.stderr)
        sys.exit(1)

    extra_patterns = None
    if "--extra" in sys.argv:
        idx = sys.argv.index("--extra")
        if idx + 1 < len(sys.argv):
            try:
                extra_cfg = json.loads(sys.argv[idx + 1])
                extra_patterns = extra_cfg.get("patterns", [])
            except json.JSONDecodeError as e:
                print(f"[mask] --extra JSON 파싱 실패: {e}", file=sys.stderr)
                sys.exit(1)

    patterns_cfg = load_patterns()
    html = src.read_text(encoding="utf-8")
    masked = mask_html(html, patterns_cfg, extra_patterns)
    masked = inject_footnote_notice(masked, patterns_cfg.get("footnote_append", ""))

    dst = src.with_suffix(".masked.html")
    dst.write_text(masked, encoding="utf-8")

    print(f"[mask] 완료 → {dst}")
    print(f"[mask] PD가 미리 열어서 확인한 후 'OK 푸시'라고 말해야 push.sh 진행.")


if __name__ == "__main__":
    main()
