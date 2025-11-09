from pathlib import Path
path = Path('ALLFILES.yaml')
remove_paths = {
    '.BRAIN/.cursor/rules/brain-readiness-checker-rules.mdc',
    '.BRAIN/.cursor/rules/brain-rules.mdc',
    '.BRAIN/.gitignore',
    '.BRAIN/01-concepts/README.md',
    '.BRAIN/01-concepts/simulation-reality-truth.md',
    '.BRAIN/01-concepts/vision-unique-features.md',
    '.BRAIN/01-concepts/vision.md',
}
lines = path.read_text(encoding='utf-8-sig').splitlines(keepends=True)
result = []
removed = set()
for line in lines:
    stripped = line.strip()
    if stripped.startswith('- path:'):
        value = stripped.split(':', 1)[1].strip()
        if value.startswith(' ) and value.endswith( '):
            value = value[1:-1]
        if value in remove_paths and value not in removed:
            removed.add(value)
            continue
    result.append(line)
path.write_text(''.join(result), encoding='utf-8-sig')
print(f'Removed {len(removed)} entries')
