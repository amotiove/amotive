#!/bin/bash
# DEPRECATED — use daily-backup.sh instead (rsync mirror to ~/Desktop/openclaw-backup/)
# This script synced to ~/Documents/openclaw-knowledge/ which has been removed.
# Kept for reference only. Do not run.

BACKUP_DIR="/home/aiden/Documents/openclaw-knowledge"
WORKSPACE="/home/aiden/.openclaw/workspace"

mkdir -p "$BACKUP_DIR"/{projects,skills,guides,scripts,memory,obsidian-export}

# Core MDs
for f in MEMORY.md AGENTS.md SOUL.md USER.md TOOLS.md IDENTITY.md HEARTBEAT.md MOTIVATION.md PROJECT_TODOS.md PERSONALITY.md; do
  [ -f "$WORKSPACE/$f" ] && cp "$WORKSPACE/$f" "$BACKUP_DIR/"
done

# Memory
cp "$WORKSPACE/memory/"*.md "$BACKUP_DIR/memory/" 2>/dev/null
cp "$WORKSPACE/memory/"*.json "$BACKUP_DIR/memory/" 2>/dev/null

# Guides + Scripts + Obsidian
cp "$WORKSPACE/guides/"* "$BACKUP_DIR/guides/" 2>/dev/null
cp "$WORKSPACE/scripts/"* "$BACKUP_DIR/scripts/" 2>/dev/null
cp "$WORKSPACE/obsidian-export/"* "$BACKUP_DIR/obsidian-export/" 2>/dev/null

# Projects (exclude venv/node_modules)
cd "$WORKSPACE/projects"
find . \( -path "*/venv/*" -o -path "*/node_modules/*" -o -path "*/__pycache__/*" -o -path "*/.git/*" -o -path "*/site-packages/*" \) -prune -o \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.py" -o -name "*.sh" -o -name "*.html" -o -name "*.css" -o -name "*.js" -o -name "*.txt" -o -name "*.png" -o -name "*.jpg" \) -print | while read f; do
  dir="$BACKUP_DIR/projects/$(dirname "$f")"
  mkdir -p "$dir"
  cp "$f" "$dir/"
done

# Skills (SKILL.md + scripts only)
cd "$WORKSPACE/skills"
find . \( -path "*/venv/*" -o -path "*/node_modules/*" -o -path "*/__pycache__/*" \) -prune -o \( -name "SKILL.md" -o -name "*.py" -o -name "*.sh" -o -name "*.yaml" \) -print | while read f; do
  dir="$BACKUP_DIR/skills/$(dirname "$f")"
  mkdir -p "$dir"
  cp "$f" "$dir/"
done

echo "✅ Backup synced: $(find "$BACKUP_DIR" -type f | wc -l) files, $(du -sh "$BACKUP_DIR" | cut -f1)"
