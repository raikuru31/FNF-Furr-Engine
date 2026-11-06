"""Генерирует списки файлов ассетов для Android (там нет листинга каталогов)."""
import json, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
data_dir = root / "assets" / "data"
weeks_dir = root / "assets" / "weeks"

if data_dir.is_dir():
    dirs = sorted(d.name for d in data_dir.iterdir() if d.is_dir())
    (data_dir / "songlist.json").write_text(json.dumps(dirs, ensure_ascii=False, indent=2), encoding="utf-8")
    print("songlist.json:", len(dirs))

if weeks_dir.is_dir():
    weeks = sorted(f.name for f in weeks_dir.glob("*.json") if f.name != "filelist.json")
    (weeks_dir / "filelist.json").write_text(json.dumps(weeks, ensure_ascii=False, indent=2), encoding="utf-8")
    print("filelist.json:", len(weeks))
