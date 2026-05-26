---
layout: default
title: Series Hub
nav_order: 1
---

# 연재 시리즈 목록
{: .no_toc }

이 페이지는 본 블로그에서 연재 중인 전체 시리즈 목록입니다. 관심 있는 주제를 선택하여 순서대로 정주행해보세요.

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 연재물 리스트

{% assign grouped_series = site.pages | where_exp: "item", "item.series != nil" | group_by: "series" %}

{% if grouped_series.size == 0 %}
현재 연재 중인 시리즈가 없습니다. 새로운 연재 시리즈가 등록될 예정입니다.
{% else %}
<div class="series-hub-grid">
  {% for series in grouped_series %}
    <div class="series-hub-card">
      <details class="series-hub-details">
        <summary class="series-hub-card-header">
          <div class="series-hub-header-content">
            <div class="series-hub-header-info">
              <span class="series-hub-badge">시리즈</span>
              <h3 class="series-hub-title">{{ series.name }}</h3>
              <span class="series-hub-count">총 {{ series.size }}편의 글</span>
            </div>
            <span class="series-hub-toggle-icon">▼</span>
          </div>
        </summary>
        <div class="series-hub-card-body">
          <ul class="series-hub-list">
            {% assign sorted_items = series.items | sort: "series_order" %}
            {% for item in sorted_items %}
              <li class="series-hub-item">
                <span class="series-hub-num">제 {{ item.series_order | default: forloop.index }}편.</span>
                <a href="{{ item.url | relative_url }}" class="series-hub-item-link">{{ item.title }}</a>
              </li>
            {% endfor %}
          </ul>
        </div>
      </details>
    </div>
  {% endfor %}
</div>
{% endif %}
