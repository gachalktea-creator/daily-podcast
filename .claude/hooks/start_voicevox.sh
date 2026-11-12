#!/bin/bash
# SessionStart フック(async): VOICEVOX エンジンを用意して起動する。進捗は /tmp/voicevox_status.txt に書く。
# 状態: DOWNLOADING / EXTRACTING / STARTING / READY / FAILED:<原因>
ST=/tmp/voicevox_status.txt
exec >>/tmp/voicevox_hook.log 2>&1
echo "$(date -u +%FT%TZ) hook start (pid $$)"
BASE=/opt/voicevox
RUN=$BASE/extracted/linux-cpu-x64/run
URL="https://github.com/VOICEVOX/voicevox_engine/releases/download/0.25.2/voicevox_engine-linux-cpu-x64-0.25.2.7z.001"

if curl -s -m 2 http://127.0.0.1:50021/version >/dev/null; then echo READY > $ST; exit 0; fi
exec 9>/tmp/voicevox.lock
flock -n 9 || { echo "another hook holds the lock"; exit 0; }

if [ ! -x "$RUN" ]; then
  echo DOWNLOADING > $ST
  command -v 7z >/dev/null 2>&1 || { apt-get update -qq && apt-get install -y -qq p7zip-full; } || { echo "FAILED:apt-7z" > $ST; exit 0; }
  T=$(mktemp -d /tmp/vv.XXXXXX); cd "$T" || exit 0
  curl -fL --retry 5 --retry-all-errors --connect-timeout 20 -o engine.7z.001 "$URL" || { echo "FAILED:download" > $ST; exit 0; }
  echo EXTRACTING > $ST
  7z x -y -o"$T/ex" engine.7z.001 >/dev/null || { echo "FAILED:extract" > $ST; exit 0; }
  [ -d "$T/ex/linux-cpu-x64" ] || { echo "FAILED:layout" > $ST; exit 0; }
  mkdir -p "$BASE/extracted" && rm -rf "$BASE/extracted/linux-cpu-x64" && mv "$T/ex/linux-cpu-x64" "$BASE/extracted/" || { echo "FAILED:install" > $ST; exit 0; }
  chmod +x "$RUN"; rm -rf "$T"
fi

echo STARTING > $ST
setsid nohup "$RUN" --host 127.0.0.1 --port 50021 </dev/null >/tmp/voicevox_run.log 2>&1 &
for i in $(seq 1 180); do
  if curl -s -m 2 http://127.0.0.1:50021/version >/dev/null; then echo READY > $ST; echo "ready after ${i}s"; exit 0; fi
  sleep 1
done
echo "FAILED:no-response" > $ST
tail -n 20 /tmp/voicevox_run.log
exit 0
