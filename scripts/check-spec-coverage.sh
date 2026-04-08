#!/usr/bin/env bash
set -euo pipefail

SPEC_DIR="openspec/specs"
TEST_DIR="Tests"
EXEMPT_SPECS="overview architecture"

slugify() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 -]//g' | sed 's/  */ /g' | sed 's/ /-/g'
}

expected=()
for spec_file in "$SPEC_DIR"/*/spec.md; do
    spec_name=$(basename "$(dirname "$spec_file")")

    skip=false
    for exempt in $EXEMPT_SPECS; do
        if [ "$spec_name" = "$exempt" ]; then
            skip=true
            break
        fi
    done
    $skip && continue

    current_req=""
    while IFS= read -r line; do
        if [[ "$line" == '### Requirement:'* ]]; then
            req_title="${line#*### Requirement: }"
            current_req="$(slugify "$req_title")"
            continue
        fi
        [[ "$line" == *'<!-- @nocover'* ]] && continue
        title="${line#*#### Scenario: }"
        if [ -n "$current_req" ]; then
            slug="$spec_name/$current_req/$(slugify "$title")"
        else
            slug="$spec_name/$(slugify "$title")"
        fi
        expected+=("$slug")
    done < <(grep -E '^(### Requirement:|#### Scenario:)' "$spec_file")
done

covered=()
while IFS= read -r line; do
    slug="${line#*@spec }"
    covered+=("$slug")
done < <(grep -rh '/// @spec ' "$TEST_DIR" 2>/dev/null || true)

declare -A covered_set
for slug in "${covered[@]}"; do
    covered_set["$slug"]=1
done

declare -A expected_set
for slug in "${expected[@]}"; do
    expected_set["$slug"]=1
done

uncovered=()
for slug in "${expected[@]}"; do
    if [[ -z "${covered_set[$slug]:-}" ]]; then
        uncovered+=("$slug")
    fi
done

orphaned=()
for slug in "${covered[@]}"; do
    if [[ -z "${expected_set[$slug]:-}" ]]; then
        orphaned+=("$slug")
    fi
done

total=${#expected[@]}
covered_count=$(( total - ${#uncovered[@]} ))

echo "Spec coverage: $covered_count/$total scenarios covered"
echo ""

if [ ${#uncovered[@]} -gt 0 ]; then
    echo "UNCOVERED (${#uncovered[@]}):"
    for slug in "${uncovered[@]}"; do
        echo "  - $slug"
    done
    echo ""
fi

if [ ${#orphaned[@]} -gt 0 ]; then
    echo "ORPHANED (${#orphaned[@]}):"
    for slug in "${orphaned[@]}"; do
        echo "  - $slug"
    done
    echo ""
fi

if [ ${#uncovered[@]} -eq 0 ] && [ ${#orphaned[@]} -eq 0 ]; then
    echo "All scenarios covered. No orphaned annotations."
    exit 0
else
    exit 1
fi
