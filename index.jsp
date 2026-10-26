<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.*, java.time.format.*, java.util.*" %>
<%!
    /* ===================== 데이터 영역 =====================
       실제 서비스라면 DB에서 가져오겠지만, 연습용으로 배열에 넣어 둡니다. */

    // 탭: {코드, 화면에 보일 이름}
    static final String[][] TABS = {
        {"med",      "의대유치"},
        {"notice",   "공지사항"},
        {"academic", "학사"},
        {"scholar",  "장학"}
    };

    // 게시글: {탭코드, 제목, 작성일}
    static final String[][] POSTS = {
        {"med", "의과대학 설립 추진 관련 법원 결정에 대한 대학 입장", "2026.10.06"},
        {"med", "의과대학 후보대학 선정 논란에 관한 대학 입장", "2026.09.17"},
        {"med", "의과대학 신설 후보대학 선정에 대한 대학 입장문", "2026.09.01"},
        {"med", "[보도자료] 의과대학 신설 추진계획서 재제출", "2026.08.20"},
        {"med", "[보도자료] 의과대학 및 교육(부속)병원 설립 추진 계획서 제출 완료", "2026.08.20"},
        {"med", "[설명자료] 의대 신설 관련 일부 보도는 사실과 다릅니다", "2026.08.16"},

        {"notice", "2026학년도 동계 계절학기 운영 안내", "2026.10.22"},
        {"notice", "중앙도서관 시험기간 연장 개방 안내", "2026.10.15"},
        {"notice", "교내 전산망 정기 점검에 따른 서비스 일시 중단 안내", "2026.10.10"},
        {"notice", "2026 대학 축제 개최 안내", "2026.09.30"},
        {"notice", "학생식당 운영 시간 변경 안내", "2026.09.21"},
        {"notice", "개인정보 처리방침 개정 안내", "2026.09.05"},

        {"academic", "2026학년도 2학기 중간고사 시행 안내", "2026.10.12"},
        {"academic", "2026학년도 2학기 수강신청 정정 결과 확인 안내", "2026.09.10"},
        {"academic", "복수전공·부전공 신청 안내", "2026.09.08"},
        {"academic", "2026학년도 후기 학위수여식 안내", "2026.08.18"},

        {"scholar", "2027학년도 1학기 국가장학금 1차 신청 안내", "2026.10.20"},
        {"scholar", "교외 장학생 추천 공고", "2026.10.02"},
        {"scholar", "근로장학생 2학기 추가 모집", "2026.09.14"}
    };

    // 학사일정: {시작일, 종료일, 일정명}
    static final String[][] SCHEDULES = {
        {"2026-09-01", "2026-09-01", "제2학기 개강"},
        {"2026-09-24", "2026-09-26", "추석 연휴"},
        {"2026-10-03", "2026-10-03", "개천절"},
        {"2026-10-09", "2026-10-09", "한글날"},
        {"2026-10-19", "2026-10-23", "제2학기 중간시험"},
        {"2026-10-28", "2026-10-28", "수업일수 2/4"},
        {"2026-11-23", "2026-11-23", "수업일수 3/4"},
        {"2026-12-14", "2026-12-18", "제2학기 기말시험"},
        {"2026-12-25", "2026-12-25", "성탄절"}
    };

    static final DateTimeFormatter OUT = DateTimeFormatter.ofPattern("yyyy.MM.dd.");

    // HTML 특수문자 처리 (사용자 입력을 화면에 출력할 때 필요)
    static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    /* ===================== 요청 처리 영역 ===================== */
    request.setCharacterEncoding("UTF-8");

    // 1) 어떤 탭을 보여줄지: ?tab=notice
    String tab = request.getParameter("tab");
    String tabName = null;
    for (String[] t : TABS) if (t[0].equals(tab)) tabName = t[1];
    if (tabName == null) { tab = TABS[0][0]; tabName = TABS[0][1]; }

    List<String[]> posts = new ArrayList<>();
    for (String[] p : POSTS) {
        if (p[0].equals(tab) && posts.size() < 6) posts.add(p);
    }

    // 2) 오늘 날짜와 보여줄 달: ?ym=2026-11
    LocalDate today = LocalDate.now(ZoneId.of("Asia/Seoul"));
    YearMonth ym;
    try {
        ym = YearMonth.parse(request.getParameter("ym"));
    } catch (Exception e) {
        ym = YearMonth.from(today);
    }
    LocalDate monthStart = ym.atDay(1);
    LocalDate monthEnd   = ym.atEndOfMonth();

    // 그 달에 걸쳐 있는 일정만 고르기
    List<String[]> events = new ArrayList<>();
    for (String[] s : SCHEDULES) {
        LocalDate st = LocalDate.parse(s[0]);
        LocalDate en = LocalDate.parse(s[1]);
        if (!en.isBefore(monthStart) && !st.isAfter(monthEnd)) events.add(s);
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>대학 메인 - 소식과 학사일정</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css">
  <link rel="stylesheet" href="css/style.css">
</head>
<body>

<!-- ===================== 헤더 ===================== -->
<header class="header">
  <a class="logo" href="index.jsp">
    <span class="logo-mark">U</span>
    <span class="logo-text">우리대학교</span>
  </a>

  <nav class="gnb">
    <a href="#">대학홍보</a>
    <a href="#">입학안내</a>
    <a href="#">스쿨(대학)/대학원</a>
    <a href="#">학사안내/취업</a>
    <a href="#">학생광장</a>
    <a href="#">대학소개</a>
  </nav>

  <div class="util">
    <button class="lang">Kor
      <svg width="12" height="12" viewBox="0 0 24 24"><path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="2"/></svg>
    </button>
    <a href="#" class="icon-btn" aria-label="로그인">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="8" r="4"/><path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6"/></svg>
    </a>
    <a href="#" class="icon-btn" aria-label="검색">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/></svg>
    </a>
    <button class="menu-btn" aria-label="전체메뉴">
      <span></span><span></span><span></span>
    </button>
  </div>
</header>

<!-- ===================== 본문 ===================== -->
<main class="main">

  <!-- THE LATEST -->
  <section class="latest">
    <div class="sec-head">
      <h2 class="sec-title"><span class="hash">#</span> THE LATEST</h2>
      <p class="sec-desc"><strong>NOTICE</strong> 우리대학교에서 전하는 주요 정보를 확인하세요.</p>
      <div class="sec-row">
        <ul class="tabs">
          <% for (String[] t : TABS) { %>
            <li><a href="?tab=<%= t[0] %>&ym=<%= ym %>"
                   class="<%= t[0].equals(tab) ? "active" : "" %>"><%= t[1] %></a></li>
          <% } %>
        </ul>
        <a href="#" class="more">더보기 <span class="plus">+</span></a>
      </div>
    </div>

    <div class="cards">
      <% if (posts.isEmpty()) { %>
        <p class="empty">등록된 게시글이 없습니다.</p>
      <% } %>
      <% for (String[] p : posts) { %>
        <a href="#" class="card">
          <span class="chip"><%= tabName %></span>
          <strong class="card-title"><%= esc(p[1]) %></strong>
          <span class="card-date"><%= p[2] %></span>
        </a>
      <% } %>
    </div>
  </section>

  <!-- SCHEDULES -->
  <section class="schedules">
    <div class="sec-head">
      <h2 class="sec-title"><span class="hash">#</span> SCHEDULES</h2>
      <p class="sec-desc"><strong>학사일정</strong> 이번 달 주요 학사일정을 확인하세요</p>
      <div class="sec-row">
        <span></span>
        <a href="#" class="more">더보기 <span class="plus">+</span></a>
      </div>
    </div>

    <div class="sch-panel">
      <div class="sch-top">
        <p class="today"><strong>Today</strong> <%= today.format(DateTimeFormatter.ofPattern("yyyy.MM.dd")) %></p>
        <div class="month-nav">
          <a href="?tab=<%= tab %>&ym=<%= ym.minusMonths(1) %>" aria-label="이전 달">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M11 6l-6 6 6 6"/></svg>
          </a>
          <span class="ym"><%= ym.getYear() %>.<%= String.format("%02d", ym.getMonthValue()) %></span>
          <a href="?tab=<%= tab %>&ym=<%= ym.plusMonths(1) %>" aria-label="다음 달">
            <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M13 6l6 6-6 6"/></svg>
          </a>
        </div>
      </div>

      <div class="sch-grid">
        <% if (events.isEmpty()) { %>
          <p class="sch-empty">이번 달 등록된 학사일정이 없습니다.</p>
        <% } %>
        <% for (String[] e : events) {
             String range = LocalDate.parse(e[0]).format(OUT) + "~" + LocalDate.parse(e[1]).format(OUT);
        %>
          <div class="sch-item">
            <span class="sch-date"><%= range %></span>
            <strong class="sch-name"><%= esc(e[2]) %></strong>
          </div>
        <% } %>
      </div>
    </div>
  </section>
</main>

<!-- ===================== 오른쪽 퀵메뉴 ===================== -->
<aside class="quick">
  <a href="#">
    <span class="q-icon">
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M6 16V11a6 6 0 0 1 12 0v5l2 2H4z"/><path d="M10 20a2 2 0 0 0 4 0"/></svg>
      <em class="badge">22</em>
    </span>
    <b>POPUP</b>
  </a>
  <a href="#">
    <span class="q-icon">
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M12 3l4 6H8z"/><circle cx="7" cy="17" r="3"/><rect x="14" y="14" width="6" height="6"/></svg>
    </span>
    사용자메뉴
  </a>
  <a href="#">
    <span class="q-icon">
      <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M4 21h16M6 21V5h8v16M14 10h4v11"/><path d="M9 9h2M9 13h2M9 17h2"/></svg>
    </span>
    관련기관
  </a>
</aside>

</body>
</html>
