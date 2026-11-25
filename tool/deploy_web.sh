#!/usr/bin/env bash
# 构建 Flutter Web 并发布到 gh-pages 分支（GitHub Pages 由此发布）
#
# 用法：bash tool/deploy_web.sh
#
# 仓库 Settings → Pages 的 Source 需指向 gh-pages / (root)。
# 采用「克隆 gh-pages → 覆盖产物 → 提交 → 普通 push」，不使用强制推送，历史可追溯。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

BRANCH="gh-pages"
REPO_NAME="$(basename "$REPO_ROOT")"
BASE_HREF="/$REPO_NAME/"
ORIGIN="$(git remote get-url origin)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> 构建 Web（base-href $BASE_HREF）"
flutter build web --release --base-href "$BASE_HREF" --no-web-resources-cdn

BUILD_ID="$(git rev-parse --short=12 HEAD 2>/dev/null || date -u +%Y%m%d%H%M%S)"

echo "==> 整理产物"
STAGE="$WORK/site"
mkdir -p "$STAGE"
cp -r build/web/. "$STAGE/"
rm -f "$STAGE"/canvaskit/*.js.symbols
# Flutter 自带的 SW 已弃用且会自我注销，会顶掉 web/sw.js
rm -f "$STAGE/flutter_service_worker.js"
touch "$STAGE/.nojekyll"
if grep -q "__BUILD_ID__" "$STAGE/sw.js" 2>/dev/null; then
  sed -i "s/__BUILD_ID__/$BUILD_ID/" "$STAGE/sw.js"
fi

echo "==> 取 gh-pages 分支"
if git ls-remote --exit-code --heads "$ORIGIN" "$BRANCH" >/dev/null 2>&1; then
  git clone --quiet --depth 1 --branch "$BRANCH" "$ORIGIN" "$WORK/pages"
  cd "$WORK/pages"
else
  mkdir -p "$WORK/pages" && cd "$WORK/pages"
  git init --quiet --initial-branch "$BRANCH"
  git remote add origin "$ORIGIN"
fi

echo "==> 覆盖产物（删除已不存在的旧文件）"
find . -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -r "$STAGE"/. .

git add -A
if git diff --cached --quiet; then
  echo "==> 产物无变化，跳过提交"
else
  git -c user.name="${GIT_AUTHOR_NAME:-chayu-deploy}" \
      -c user.email="${GIT_AUTHOR_EMAIL:-chayu-deploy@users.noreply.github.com}" \
      commit --quiet -m "deploy: $BUILD_ID"
  echo "==> 推送 $BRANCH"
  git push --quiet origin "$BRANCH"
fi

echo "==> 完成：https://<用户名>.github.io/$REPO_NAME/"
