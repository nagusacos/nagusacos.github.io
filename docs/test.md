---
layout: default
title: KaTeX 렌더링 테스트
nav_order: 1
---

# KaTeX 수학 수식 테스트

<div>
KaTeX HTML 테스트: $$ x^2 + y^2 = z^2 $$
</div>

{% raw %}
KaTeX Liquid 우회 테스트: $$ \int_a^b f(x) dx $$
{% endraw %}

## 인라인 수식 (Inline Math)
문장 중간에 들어가는 수식입니다. 강화학습의 상태가치함수 $V(s)$와 행동가치함수 $Q(s, a)$가 잘 렌더링되는지 확인합니다.

## 블록 수식 (Display Math)
독립된 줄에 중앙 정렬되어 나타나는 수식입니다.

$$
Q(s, a) = \E \left[ R_{t+1} + \gamma \max_{a'} Q(S_{t+1}, a') \mid S_t = s, A_t = a \right]
$$

## 행렬 (Matrix)
$$
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
$$