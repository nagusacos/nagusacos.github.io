# frozen_string_literal: true

# =============================================================================
# 파일 경로: _plugins/right_section.rb
#
# Jekyll 커스텀 Liquid 블록 태그: {% right_section %}
#
# [사용법]
#   {% right_section src="assets/images/graph.png" alt="그래프 설명" %}
#   여기에 **마크다운** 본문을 자유롭게 작성합니다.
#   - 리스트, [링크](url), `코드`, $수식$ 모두 정상 렌더링됩니다.
#   {% endright_section %}
#
# [출력 HTML 구조]
#   <div class="content-row" id="section-N">
#     <div class="text-content">
#       [Kramdown으로 변환된 HTML]
#     </div>
#     <aside class="right-reference-sidebar">
#       <div class="sticky-wrapper">
#         <img src="/baseurl/assets/images/graph.png" alt="그래프 설명">
#       </div>
#     </aside>
#   </div>
#
# [설계 주의사항 - 계획서 반영]
#   1. Markdown 변환 누락 방지:
#      블록 내부 텍스트는 raw string으로 넘어옵니다.
#      반드시 Jekyll Kramdown 컨버터를 명시적으로 호출해야 합니다.
#
#   2. 이미지 경로 처리:
#      src 속성값을 그대로 쓰면 서브패스 배포 시 경로가 깨집니다.
#      site.baseurl을 앞에 붙여 절대 경로를 만들어 안전하게 처리합니다.
#      (예: baseurl="/blog" + src="assets/img/a.png" → "/blog/assets/img/a.png")
#
#   3. 섹션 카운터:
#      Liquid context의 registers를 이용하여 페이지 빌드 사이클 내에서
#      section_counter를 누적합니다. 각 section에 고유한 id="section-N"을 부여합니다.
#
#   4. GitHub Actions 배포:
#      이 파일은 .github/workflows/deploy.yml의 bundle exec jekyll build 단계에서
#      자동 로드됩니다. 기본 GitHub Pages 빌더(safe mode)에서는 실행되지 않습니다.
# =============================================================================

module Jekyll
  class RightSectionTag < Liquid::Block

    # -------------------------------------------------------------------------
    # 태그 초기화: 매개변수 없이 사용하도록 슬림화
    # -------------------------------------------------------------------------
    def initialize(tag_name, markup, tokens)
      super
    end

    # -------------------------------------------------------------------------
    # 렌더링: 블록 내부 텍스트를 파싱하고 변환하여 HTML을 조합함
    # -------------------------------------------------------------------------
    def render(context)
      # --- 1. 섹션 카운터 누적 ---
      context.registers[:right_section_counter] ||= 0
      context.registers[:right_section_counter] += 1
      section_id = context.registers[:right_section_counter]

      # --- 2. 블록 내부 텍스트 렌더링 (Liquid 변수 먼저 처리) ---
      raw_content = super

      # 들여쓰기 공백 제거
      raw_content = raw_content.gsub(/^[ \t]{4}/, '')

      # --- 3. 본문(좌)과 사이드바(우) 콘텐츠 분배 ---
      # '+++' 구분자를 기준으로 나눕니다.
      left_markdown, right_markdown = raw_content.split('+++', 2)
      right_markdown ||= ""

      # --- 4. Markdown → HTML 변환 (Kramdown 명시 호출) ---
      site = context.registers[:site]
      converter = site.find_converter_instance(Jekyll::Converters::Markdown)
      
      left_html = converter.convert(left_markdown.strip)
      right_html = right_markdown.strip.empty? ? "" : converter.convert(right_markdown.strip)

      # --- 5. 상대 경로 이미지 src 자동 보정 (Jekyll baseurl 지원) ---
      if !right_html.empty?
        baseurl = site.config["baseurl"].to_s.chomp("/")
        right_html = right_html.gsub(/src=(["'])(?!\/|https?:\/\/)([^"'\s]+)\1/) do
          "src=#{$1}#{baseurl}/#{$2}#{$1}"
        end
      end

      # --- 6. HTML 출력 ---
      # 우측 추가 마크다운(이미지, LaTeX 공식 등)이 존재할 때만 사이드바 렌더링
      sidebar_html = ""
      if !right_html.empty?
        sidebar_html = <<~HTML
          <aside class="right-reference-sidebar" aria-label="참조 콘텐츠 #{section_id}" data-section="#{section_id}">
            <div class="sticky-wrapper">
              <div class="sidebar-custom-content">
                #{right_html}
              </div>
            </div>
          </aside>
        HTML
      end

      <<~HTML
        <div class="content-row" id="section-#{section_id}">
          <div class="text-content">
            #{left_html}
          </div>
          #{sidebar_html}
        </div>
      HTML
    end

  end
end

# Jekyll 플러그인 시스템에 태그 등록
Liquid::Template.register_tag("right_section", Jekyll::RightSectionTag)

# site.imageurl 전역 변수 동적 설정 (baseurl 기반)
Jekyll::Hooks.register :site, :after_init do |site|
  baseurl = site.config["baseurl"].to_s.chomp("/")
  site.config["imageurl"] = "#{baseurl}/assets/images"
end
