#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="$repo_root/ianzo-cn.conf"
mode="${1:-local}"
remote_temp_dir=''

fail() {
  printf 'ERROR: %s\n' "$1" >&2
  exit 1
}

cleanup_remote_temp() {
  if [[ "$remote_temp_dir" == /tmp/shadowrocket-rule.* && -d "$remote_temp_dir" ]]; then
    rm -rf -- "$remote_temp_dir"
  fi
}

trap cleanup_remote_temp EXIT

trim() {
  sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

group_exists() {
  local candidate="$1"
  case "$candidate" in
    DIRECT|PROXY|REJECT|REJECT-DROP) return 0 ;;
  esac
  printf '%s\n' "${groups[@]}" | grep -Fqx -- "$candidate"
}

group_regex() {
  local group="$1"
  local line
  line="$(grep -F "${group} = " "$config")"
  [[ "$line" == *"policy-regex-filter="* ]] || fail "地区组缺少正则: $group"
  printf '%s\n' "${line##*policy-regex-filter=}"
}

assert_matches() {
  local group="$1"
  local sample="$2"
  local regex
  regex="$(group_regex "$group")"
  printf '%s\n' "$sample" | grep -Pq -- "$regex" || fail "$group 未识别测试样本: $sample"
}

assert_not_matches() {
  local group="$1"
  local sample="$2"
  local regex
  regex="$(group_regex "$group")"
  if printf '%s\n' "$sample" | grep -Pq -- "$regex"; then
    fail "$group 错误识别测试样本: $sample"
  fi
}

load_groups() {
  mapfile -t groups < <(
    awk '
      /^\[Proxy Group\]$/ { in_groups=1; next }
      /^\[/ { if (in_groups) exit }
      in_groups && $0 !~ /^[[:space:]]*#/ && index($0, "=") {
        name=$0
        sub(/[[:space:]]*=.*/, "", name)
        sub(/^[[:space:]]*/, "", name)
        sub(/[[:space:]]*$/, "", name)
        print name
      }
    ' "$config"
  )
  ((${#groups[@]} > 0)) || fail "未找到任何策略组"
}

check_structure() {
  [[ -s "$config" ]] || fail "ianzo-cn.conf 不存在或为空"
  [[ ! -e "$repo_root/ianzo-rule.conf" ]] || fail "发现已废弃的 ianzo-rule.conf"

  local section
  for section in General Proxy 'Proxy Group' Rule; do
    [[ "$(grep -Fxc "[$section]" "$config")" -eq 1 ]] || fail "区段 [$section] 缺失或重复"
  done
  [[ "$(grep -c '^FINAL,' "$config")" -eq 1 ]] || fail "FINAL 必须存在且只能有一条"
}

check_security_boundary() {
  if grep -Eiq '^\[(Script|MITM|URL Rewrite)\]$|script-(path|url)|http-(request|response)|(^|[[:space:],])(cron|event)[[:space:]]*=' "$config"; then
    fail "CN 配置出现 Script、MITM、URL Rewrite 或客户端脚本入口"
  fi

  if grep -Eiq '(^|[[:space:],])(password|secret|token|api[-_]?key|private[-_]?key|cookie|authorization)[[:space:]]*=' "$config"; then
    fail "CN 配置疑似包含敏感字段"
  fi

  if grep -Eiq 'https?://[^,[:space:]]+\.(js|mjs|py|sh|exe|dll|dylib|so|bin)([?,[:space:]]|$)' "$config"; then
    fail "CN 配置引用了疑似远程可执行资源"
  fi

  local expected_update='update-url = https://raw.githubusercontent.com/webhuage-debug/Shadowrocket-Rule/main/ianzo-cn.conf'
  [[ "$(grep -Fxc "$expected_update" "$config")" -eq 1 ]] || fail "稳定版 update-url 缺失或错误"
}

check_groups_and_rules() {
  local duplicates
  duplicates="$(printf '%s\n' "${groups[@]}" | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "策略组名称重复: $duplicates"

  while IFS= read -r line; do
    local name rhs type item
    name="$(printf '%s\n' "${line%%=*}" | trim)"
    rhs="$(printf '%s\n' "${line#*=}" | trim)"
    IFS=',' read -r -a fields <<< "$rhs"
    type="$(printf '%s\n' "${fields[0]}" | trim)"
    [[ "$type" == "select" ]] || continue
    for item in "${fields[@]:1}"; do
      item="$(printf '%s\n' "$item" | trim)"
      [[ -z "$item" || "$item" == *=* ]] && continue
      group_exists "$item" || fail "策略组 $name 引用了不存在的成员: $item"
    done
  done < <(
    awk '
      /^\[Proxy Group\]$/ { in_groups=1; next }
      /^\[/ { if (in_groups) exit }
      in_groups && $0 !~ /^[[:space:]]*#/ && index($0, "=") { print }
    ' "$config"
  )

  mapfile -t rules < <(
    awk '
      /^\[Rule\]$/ { in_rules=1; next }
      /^\[/ { if (in_rules) exit }
      in_rules && $0 !~ /^[[:space:]]*(#|$)/ { print }
    ' "$config"
  )
  ((${#rules[@]} > 0)) || fail "[Rule] 中没有规则"

  duplicates="$(printf '%s\n' "${rules[@]}" | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "存在重复规则: $duplicates"

  while IFS= read -r line; do
    IFS=',' read -r -a fields <<< "$line"
    local rule_type policy
    rule_type="$(printf '%s\n' "${fields[0]}" | trim)"
    if [[ "$rule_type" == "FINAL" ]]; then
      policy="$(printf '%s\n' "${fields[1]:-}" | trim)"
    else
      policy="$(printf '%s\n' "${fields[2]:-}" | trim)"
    fi
    [[ -n "$policy" ]] || fail "规则缺少策略: $line"
    group_exists "$policy" || fail "规则引用了不存在的策略组: $policy"
  done < <(printf '%s\n' "${rules[@]}")

  mapfile -t rule_urls < <(printf '%s\n' "${rules[@]}" | awk -F, '$1 == "RULE-SET" { print $2 }')
  [[ "${#rule_urls[@]}" -eq 15 ]] || fail "CN RULE-SET 数量应为 15，当前为 ${#rule_urls[@]}"
  duplicates="$(printf '%s\n' "${rule_urls[@]}" | sort | uniq -d)"
  [[ -z "$duplicates" ]] || fail "远程 RULE-SET 地址重复: $duplicates"

  local url
  for url in "${rule_urls[@]}"; do
    [[ "$url" =~ ^https://raw\.githubusercontent\.com/[^/]+/[^/]+/[^/]+/.+\.list$ ]] || fail "RULE-SET 不是允许的 GitHub Raw .list: $url"
  done
}

check_region_regex() {
  local sample
  for sample in '🇭🇰' '香港' 'Hong Kong' 'HongKong' 'HK-01' 'HK_01' 'HK 01' 'HKG-01' '香港01'; do
    assert_matches '🇭🇰 香港节点' "$sample"
  done
  for sample in '🇺🇸' '美国' 'United States 01' 'USA-01' 'US-01' 'America' 'Los Angeles 01' 'San Jose' 'Seattle 01' 'New York' 'Dallas' 'Chicago' 'Phoenix'; do
    assert_matches '🇺🇸 美国节点' "$sample"
  done
  for sample in 'RUS-01' 'RUS Moscow' 'Russia-01'; do
    assert_not_matches '🇺🇸 美国节点' "$sample"
    assert_matches '🌐 其他节点' "$sample"
  done
  for sample in '🇯🇵' '日本01' 'Japan' 'JP-01' 'JPN-01' 'Tokyo 01' 'Osaka' '东京' '大阪'; do
    assert_matches '🇯🇵 日本节点' "$sample"
  done
  for sample in '🇸🇬' '新加坡01' 'Singapore 01' 'SG-01' 'SGP-01' '狮城'; do
    assert_matches '🇸🇬 新加坡节点' "$sample"
  done
  for sample in '🇹🇼' '台湾01' '台灣' 'Taiwan' 'TW-01' 'TWN-01' 'TPE-01' 'Taipei 01' '台北' '台中'; do
    assert_matches '🇹🇼 台湾节点' "$sample"
  done
  for sample in 'HK-01' 'US-01' 'JP-01' 'SG-01' 'TW-01'; do
    assert_not_matches '🌐 其他节点' "$sample"
  done
}

check_remote_rules() {
  remote_temp_dir="$(mktemp -d /tmp/shadowrocket-rule.XXXXXX)"

  local index=0 url output first_rule
  for url in "${rule_urls[@]}"; do
    index=$((index + 1))
    output="$remote_temp_dir/rule-$index.list"
    curl --fail --silent --show-error --location --retry 2 --max-time 30 "$url" --output "$output"
    [[ -s "$output" ]] || fail "远程规则为空: $url"
    grep -Eiq '<!doctype[[:space:]]+html|<html' "$output" && fail "远程规则返回了 HTML: $url"
    first_rule="$(awk 'NF && $0 !~ /^[[:space:]]*#/ { print; exit }' "$output")"
    [[ "$first_rule" =~ ^(DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR|IP-CIDR6|GEOIP|IP-ASN|USER-AGENT|PROCESS-NAME|URL-REGEX), ]] || fail "远程文件首条有效内容不是允许的分流规则: $url"
  done
}

case "$mode" in
  local|--remote|--remote-only) ;;
  *) fail "未知参数: $mode" ;;
esac

load_groups
check_groups_and_rules

if [[ "$mode" != "--remote-only" ]]; then
  check_structure
  check_security_boundary
  check_region_regex
  printf 'CN local validation: PASS\n'
fi

if [[ "$mode" == "--remote" || "$mode" == "--remote-only" ]]; then
  check_remote_rules
  printf 'CN remote RULE-SET validation: PASS (%s files)\n' "${#rule_urls[@]}"
fi
