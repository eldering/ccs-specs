#!/bin/sh -e

TMPDIR=$(mktemp -d -t 'gen-gh-pages-XXXXXX')

REPO_DIR="$TMPDIR/ccs-specs"
MY_DIR=$(realpath $(dirname $0))

mkdir -p "$REPO_DIR"
rsync -a "$MY_DIR/" "$REPO_DIR/"

rm -rf docs

bundle exec jekyll build -d docs/

for version in $(cat versions.json | jq -r -c '.[]'); do
    ( cd "$REPO_DIR" && git checkout "${version}" )
	ln -sf "$MY_DIR/_layouts" "$REPO_DIR"
	echo "version: ${version}" > "$TMPDIR/version.yml"
    bundle exec jekyll build --config _config.yml,"$TMPDIR/version.yml" \
        -b "/${version}" -s "$REPO_DIR" -d "docs/${version}/"
done

rm -rf "$TMPDIR"