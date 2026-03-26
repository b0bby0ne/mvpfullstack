from __future__ import annotations

import json
import sys
from pathlib import Path


RUN_NAME = "vn_tender_companies_batch_1_2026_03_25"
RUN_DIR = Path(r"d:\Researcher\SaleTeam\Output") / RUN_NAME
CONTACT_JSON_PATH = RUN_DIR / "_tmp_contact_data.json"
CONTACT_OUTPUT_PATH = RUN_DIR / "02_Company_Contact_Information.md"
MASTER_INDEX_PATH = RUN_DIR / "Master_Index.md"


def u(text: str) -> str:
    return text


def write_utf8_bom(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8-sig")


def norm(value: object | None) -> str:
    if value is None:
        return ""
    return str(value).strip()


def display(
    value: object | None,
    fallback: str = "",
) -> str:
    cleaned = norm(value)
    if cleaned:
        return cleaned
    if fallback:
        return fallback
    return u("Ch\u01b0a th\u1ea5y c\u00f4ng khai t\u1eeb ngu\u1ed3n ch\u00ednh th\u1ee9c")


def completeness(record: dict[str, object]) -> str:
    score = 0
    if norm(record.get("office_web")):
        score += 1
    if norm(record.get("office_phone")):
        score += 1
    if norm(record.get("rep_name")):
        score += 1
    if norm(record.get("office_add")):
        score += 1

    if score >= 4:
        return u("Cao")
    if score >= 2:
        return u("Trung b\u00ecnh")
    return u("Th\u1ea5p")


def build_output(records: list[dict[str, object]]) -> str:
    website_count = sum(1 for record in records if norm(record.get("office_web")))
    phone_count = sum(1 for record in records if norm(record.get("office_phone")))
    rep_count = sum(1 for record in records if norm(record.get("rep_name")))
    address_count = sum(1 for record in records if norm(record.get("office_add")))

    lines: list[str] = []
    lines.append(f"# 02_Company_Contact_Information - {RUN_NAME}")
    lines.append("")
    lines.append(u("## B\u1ed1i c\u1ea3nh"))
    lines.append(
        u(
            "- Ngu\u1ed3n lead g\u1ed1c: H\u1ec7 th\u1ed1ng m\u1ea1ng "
            "\u0111\u1ea5u th\u1ea7u qu\u1ed1c gia - danh s\u00e1ch nh\u00e0 "
            "th\u1ea7u \u0111\u01b0\u1ee3c ph\u00ea duy\u1ec7t."
        )
    )
    lines.append(
        u(
            "- M\u1ee5c ti\u00eau: thu th\u1eadp th\u00f4ng tin li\u00ean l\u1ea1c "
            "c\u00f4ng khai c\u1ea5p doanh nghi\u1ec7p cho 100 lead trong run n\u00e0y."
        )
    )
    lines.append(
        u(
            "- Ph\u1ea1m vi li\u00ean l\u1ea1c \u01b0u ti\u00ean: website c\u00f4ng khai, "
            "\u0111i\u1ec7n tho\u1ea1i tr\u1ee5 s\u1edf, \u0111\u1ecba ch\u1ec9, "
            "ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n ph\u00e1p lu\u1eadt, "
            "ch\u1ee9c v\u1ee5 ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n."
        )
    )
    lines.append(
        u(
            "- Gi\u1edbi h\u1ea1n ngu\u1ed3n: payload c\u00f4ng khai \u0111\u00e3 truy c\u1eadp "
            "kh\u00f4ng hi\u1ec3n th\u1ecb email c\u00f4ng ty; tr\u01b0\u1eddng "
            "\u0111i\u1ec7n tho\u1ea1i t\u1ed3n t\u1ea1i nh\u01b0ng ph\u1ea7n l\u1edbn "
            "\u0111ang \u0111\u1ec3 tr\u1ed1ng."
        )
    )
    lines.append("")
    lines.append(u("## T\u1ed5ng h\u1ee3p nhanh"))
    lines.append(f"- {u('T\u1ed5ng s\u1ed1 doanh nghi\u1ec7p')}: {len(records)}")
    lines.append(
        f"- {u('S\u1ed1 doanh nghi\u1ec7p c\u00f3 website c\u00f4ng khai t\u1eeb ngu\u1ed3n ch\u00ednh th\u1ee9c')}: {website_count}"
    )
    lines.append(
        f"- {u('S\u1ed1 doanh nghi\u1ec7p c\u00f3 \u0111i\u1ec7n tho\u1ea1i c\u00f4ng khai t\u1eeb ngu\u1ed3n ch\u00ednh th\u1ee9c')}: {phone_count}"
    )
    lines.append(
        f"- {u('S\u1ed1 doanh nghi\u1ec7p c\u00f3 ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n ph\u00e1p lu\u1eadt c\u00f4ng khai')}: {rep_count}"
    )
    lines.append(
        f"- {u('S\u1ed1 doanh nghi\u1ec7p c\u00f3 \u0111\u1ecba ch\u1ec9 tr\u1ee5 s\u1edf c\u00f4ng khai')}: {address_count}"
    )
    lines.append("")

    for index, record in enumerate(records, start=1):
        lines.append(f"## Lead {index:02d}")
        lines.append(
            f"- {u('M\u00e3 b\u1ea3n ghi')}: "
            f"{display(record.get('record_id'), u('Ch\u01b0a c\u00f3'))}"
        )
        lines.append(f"- {u('T\u00ean c\u00f4ng ty')}: {display(record.get('company_name'))}")
        lines.append(f"- {u('M\u00e3 s\u1ed1 thu\u1ebf')}: {display(record.get('tax_code'))}")
        lines.append(f"- {u('Website c\u00f4ng khai')}: {display(record.get('office_web'))}")
        lines.append(
            f"- {u('\u0110i\u1ec7n tho\u1ea1i c\u00f4ng khai')}: "
            f"{display(record.get('office_phone'))}"
        )
        lines.append(
            f"- {u('Email c\u00f4ng khai')}: "
            f"{u('Ch\u01b0a th\u1ea5y c\u00f4ng khai t\u1eeb ngu\u1ed3n ch\u00ednh th\u1ee9c')}"
        )
        lines.append(
            f"- {u('Ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n ph\u00e1p lu\u1eadt')}: "
            f"{display(record.get('rep_name'))}"
        )
        lines.append(
            f"- {u('Ch\u1ee9c v\u1ee5 ng\u01b0\u1eddi \u0111\u1ea1i di\u1ec7n')}: "
            f"{display(record.get('rep_position'))}"
        )
        lines.append(f"- {u('\u0110\u1ecba ch\u1ec9 tr\u1ee5 s\u1edf')}: {display(record.get('office_add'))}")
        lines.append(f"- {u('T\u1ec9nh / th\u00e0nh ph\u1ed1')}: {display(record.get('province'))}")
        lines.append(
            f"- {u('Qu\u1eadn / huy\u1ec7n / khu v\u1ef1c')}: {display(record.get('district'))}"
        )
        lines.append(
            f"- {u('Ph\u01b0\u1eddng / x\u00e3 / th\u1ecb tr\u1ea5n')}: {display(record.get('ward'))}"
        )
        lines.append(
            f"- {u('S\u1ed1 \u0111\u0103ng k\u00fd kinh doanh')}: {display(record.get('dec_no'))}"
        )
        lines.append(
            f"- {u('M\u1ee9c \u0111\u1ed9 \u0111\u1ea7y \u0111\u1ee7 li\u00ean l\u1ea1c')}: {completeness(record)}"
        )
        lines.append(f"- {u('Ngu\u1ed3n tham chi\u1ebfu')}:")
        lines.append(
            f"  - {u('H\u1ed3 s\u01a1 ngu\u1ed3n')}: "
            f"{display(record.get('profile_url'), u('Ch\u01b0a c\u00f3'))}"
        )
        lines.append(
            "  - API chi tiet: "
            "https://muasamcong.mpi.gov.vn/o/egp-portal-contractors-approved/"
            "services/get-detail-approve-bidder"
        )
        lines.append("")

    return "\n".join(lines).rstrip() + "\n"


def update_master_index() -> None:
    text = MASTER_INDEX_PATH.read_text(encoding="utf-8-sig")
    file_line = "3. [02_Company_Contact_Information.md](./02_Company_Contact_Information.md)"
    if file_line not in text:
        text = text.replace(
            "2. [01_Lead_List.md](./01_Lead_List.md)\n",
            "2. [01_Lead_List.md](./01_Lead_List.md)\n"
            "3. [02_Company_Contact_Information.md](./02_Company_Contact_Information.md)\n",
        )

    old_note = (
        "- V\u00ec ch\u01b0a c\u00f3 website v\u00e0 ng\u01b0\u1eddi li\u00ean h\u1ec7, "
        "tr\u1ea1ng th\u00e1i l\u00e0m gi\u00e0u c\u1ee7a to\u00e0n b\u1ed9 lead hi\u1ec7n "
        "l\u00e0 `Ch\u01b0a l\u00e0m gi\u00e0u`."
    )
    new_note = (
        "- Run \u0111\u00e3 c\u00f3 file th\u00f4ng tin li\u00ean l\u1ea1c c\u00f4ng khai "
        "c\u1ea5p doanh nghi\u1ec7p t\u1eeb ngu\u1ed3n ch\u00ednh th\u1ee9c.\n"
        "- Email c\u00f4ng ty ch\u01b0a th\u1ea5y xu\u1ea5t hi\u1ec7n trong payload "
        "c\u00f4ng khai \u0111\u00e3 truy c\u1eadp."
    )
    if old_note in text:
        text = text.replace(old_note, new_note)

    write_utf8_bom(MASTER_INDEX_PATH, text)


def main() -> int:
    if not CONTACT_JSON_PATH.exists():
        print(f"Missing contact JSON: {CONTACT_JSON_PATH}", file=sys.stderr)
        return 1

    records = json.loads(CONTACT_JSON_PATH.read_text(encoding="utf-8-sig"))
    if not isinstance(records, list) or not records:
        print("Contact JSON is empty or invalid.", file=sys.stderr)
        return 1

    output = build_output(records)
    write_utf8_bom(CONTACT_OUTPUT_PATH, output)
    update_master_index()

    print(f"RUN_DIR={RUN_DIR}")
    print(f"CONTACT_FILE={CONTACT_OUTPUT_PATH}")
    print(f"COUNT={len(records)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
