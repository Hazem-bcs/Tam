#!/usr/bin/env python3
"""Emit measured CI metrics, truthful unmeasured fields, and baseline diffs."""
import argparse
import json
import os
import re
from pathlib import Path

CATEGORIES = [
 ("fps_frame_ms","UI 60 FPS / frame p95","lower","ms"),
 ("startup_ms","Android launch (emulator proxy)","lower","ms"),
 ("cache_checks","Cache policy checks","higher","tests"),
 ("map_rebuilds","Full map rebuilds / GPS update","lower","count"),
 ("pss_kb","Android memory PSS (emulator)","lower","KiB"),
 ("offline_checks","Offline/idempotency checks","higher","tests"),
 ("apk_bytes","Release APK file size","lower","bytes"),
]
def read(p):
 p=Path(p)
 return p.read_text(errors="replace") if p.is_file() else ""
def parse(pattern, s):
 m=re.search(pattern,s,re.M|re.I)
 return int(m.group(1)) if m else None
def collect(a):
 out=Path(a.output);out.parent.mkdir(parents=True,exist_ok=True)
 d=out.parent
 tests=read(d/"flutter-tests.log")
 start=read(d/"android-start.txt")
 mem=read(d/"android-memory.txt").replace(",","")
 size=read(d/"apk_bytes.txt").strip()
 total=parse(r"\+(\d+): All tests passed!",tests)
 if total is None: total=parse(r"\+(\d+):[^\n]*$",tests)
 pss=parse(r"TOTAL PSS:\s*(\d+)",mem)
 if pss is None: pss=parse(r"^\s*TOTAL\s+(\d+)\s+",mem)
 sources=list((Path(a.repo)/"apps/customer/lib").rglob("*.dart"))
 data={
 "sha":os.getenv("GITHUB_SHA","local"),
 "environment":"GitHub Actions Android emulator API 35; no physical low-end device",
 "metrics":{
  "fps_frame_ms":None,
  "startup_ms":parse(r"^TotalTime:\s*(\d+)",start),
  "cache_checks":1 if read(d/"cache_checks.txt").strip()=="1" else None,
  "map_rebuilds":None,
  "pss_kb":pss,
  "offline_checks":1 if read(d/"offline_checks.txt").strip()=="1" else None,
  "apk_bytes":int(size) if size.isdigit() else None
 },
 "tests_pass":("All tests passed!" in tests),
 "test_total":total,
 "dart_source_files":len(sources),
 "dart_source_bytes":sum(f.stat().st_size for f in sources),
 "notes":{
  "fps_frame_ms":"Not measurable yet: no production map/animation scenario. Physical device profile test needed.",
  "startup_ms":"am start -W TotalTime on emulator, not exact first Flutter frame.",
  "cache_checks":"Cache TTL unit test only; real SQLite/cache flow tests pending.",
  "map_rebuilds":"Map widget not built yet; cannot claim zero rebuilds.",
  "pss_kb":"dumpsys PSS on CI emulator; not representative of low-end device.",
  "offline_checks":"Local request coalescing only; real reconnect and Laravel server idempotency not yet measured.",
  "apk_bytes":"Release APK file size, not Google Play download size."
 }}
 out.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n")
def render(a):
 cur=json.loads(read(a.current)); b=read(a.baseline)
 old=json.loads(b) if b else None
 lines=["# Mashwar — performance regression report","",
  f"Current: `{cur['sha'][:12]}` · Baseline: "+(f"`{old['sha'][:12]}`" if old else "none (first run)"),"",
  "| Goal | Current | Previous | Change | Result |","|---|---:|---:|---:|---|"]
 def display(k,x):
  if x is None:return "N/A"
  if k=="apk_bytes":return f"{x/1048576:.2f} MiB"
  if k=="pss_kb":return f"{x/1024:.1f} MiB"
  return str(x)
 for k,label,direction,unit in CATEGORIES:
  x=cur["metrics"].get(k); y=old["metrics"].get(k) if old else None
  if x is None: delta="—";result="⚪ Not measured"
  elif y is None: delta="—";result="🔵 Baseline"
  else:
   change=x-y;delta=f"{change:+,} {unit}"
   result=("🟢 Improved" if (change<0 if direction=="lower" else change>0) else "🟡 Regression") if change else "⚪ No change"
  lines.append(f"| {label} | {display(k,x)} | {display(k,y)} | {delta} | {result} |")
 lines+=["","**Flutter tests:** "+("PASS" if cur["tests_pass"] else "NOT VERIFIED")+"; successful test count: "+str(cur["test_total"]),
  "**Important:** Emulator startup and RAM are diagnostic proxies, not proof of low-end phone performance.",
  "**Important:** FPS, map redraw and end-to-end reconnect are explicitly not measured until their real features exist.","",
  "## Coverage and interpretation"]
 for k,note in cur["notes"].items():lines.append(f"- **{k}** — {note}")
 lines+=["","## Next physical-device benchmark","Profile the real map and booking flow on low-end Android: UI/raster p95 frame times, jank, usable-screen latency, peak PSS, reconnect duplicate suppression, and GPS marker-only rebuild counts."]
 Path(a.markdown).write_text("\n".join(lines)+"\n")
def main():
 p=argparse.ArgumentParser(); sub=p.add_subparsers(dest="cmd",required=True)
 c=sub.add_parser("collect");c.add_argument("--repo",required=True);c.add_argument("--output",required=True)
 r=sub.add_parser("report");r.add_argument("--current",required=True);r.add_argument("--baseline",required=True);r.add_argument("--markdown",required=True)
 a=p.parse_args()
 (collect if a.cmd=="collect" else render)(a)
if __name__=="__main__":main()
