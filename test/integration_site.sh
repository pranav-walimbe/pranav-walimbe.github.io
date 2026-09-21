#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
tmp_site="${tmp_dir}/site"

cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

JEKYLL_ENV=production bundle exec jekyll build -d "${tmp_site}" >/dev/null

homepage="${tmp_site}/index.html"
sitemap="${tmp_site}/sitemap.xml"

test -f "${homepage}"
test -f "${sitemap}"

grep -q '<title>.*Pranav Walimbe.*</title>' "${homepage}"
grep -q 'Data and machine learning systems engineer' "${homepage}"
grep -q 'rel="canonical" href="https://pranav-walimbe.github.io/"' "${homepage}"
grep -q 'property="og:title"' "${homepage}"
grep -q 'application/ld+json' "${homepage}"
grep -q 'G-97N1NFBMLZ' "${homepage}"

if grep -Eq '/(blog|books|cv|news|people|plugins|projects|publications|repositories|teaching)/' "${sitemap}"; then
  echo "sitemap contains retired starter content" >&2
  exit 1
fi

url_count="$(ruby -e 'print File.read(ARGV[0]).scan(%r{<loc>}).length' "${sitemap}")"
if [ "${url_count}" -ne 1 ]; then
  echo "expected one indexable URL, found ${url_count}" >&2
  exit 1
fi

echo "site discoverability checks passed"
