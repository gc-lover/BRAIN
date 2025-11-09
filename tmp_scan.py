from pathlib import Path

def extract_paths(source):
    paths = []
    for line in source.read_text("utf-8", errors="ignore").splitlines():
        line = line.strip()
        if line.startswith("- path:"):
            value = line.split(":", 1)[1].strip()
            if value.startswith('"') and value.endswith('"'):
                value = value[1:-1]
            paths.append(value)
    return paths

allfiles = extract_paths(Path("ALLFILES.yaml"))
tracker_paths = set(extract_paths(Path("06-tasks/config/readiness-tracker.yaml")))

for path in allfiles:
    if path not in tracker_paths:
        print(path)
        break
else:
    print("ALL_REGISTERED")

