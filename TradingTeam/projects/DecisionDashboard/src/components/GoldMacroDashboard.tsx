import {
  getSource,
  GOLD_EVENTS,
  GOLD_MACRO_SNAPSHOT_AT,
  GOLD_SOURCES,
} from "../domain/goldMacro";
import type { DailyMacroState } from "../hooks/useDailyGoldMacro";

function SourceLink({ sourceId, compact = false }: { sourceId: string; compact?: boolean }) {
  const source = getSource(sourceId);
  return (
    <a className={`source-link ${compact ? "source-link--compact" : ""}`} href={source.url} target="_blank" rel="noreferrer">
      <span>{compact ? "Nguồn" : source.name}</span>
      <span aria-hidden="true">↗</span>
    </a>
  );
}

function MetricCard({
  kicker,
  value,
  unit,
  change,
  tone,
  sourceId,
  children,
}: {
  kicker: string;
  value: string;
  unit: string;
  change: string;
  tone: "positive" | "mixed";
  sourceId: string;
  children: React.ReactNode;
}) {
  return (
    <article className="macro-metric-card">
      <div className="metric-topline">
        <span>{kicker}</span>
        <span className={`signal-tag signal-tag--${tone}`}>{change}</span>
      </div>
      <div className="metric-value"><strong>{value}</strong><span>{unit}</span></div>
      <div className="metric-body">{children}</div>
      <SourceLink sourceId={sourceId} compact />
    </article>
  );
}

function DailyOperationsStatus({ operations }: { operations: DailyMacroState }) {
  if (operations.phase === "checking") {
    return <div className="daily-ops daily-ops--checking" role="status"><span className="status-pulse" /><div><strong>Đang kiểm tra nguồn hôm nay</strong><small>App sẽ tự bù nếu cronjob chưa chạy.</small></div></div>;
  }

  if (operations.phase === "error") {
    return <div className="daily-ops daily-ops--failed" role="status"><span>!</span><div><strong>Kiểm tra nguồn thất bại</strong><small>{operations.message}</small></div></div>;
  }

  const { snapshot } = operations;
  const checkedAt = new Intl.DateTimeFormat("vi-VN", {
    dateStyle: "short",
    timeStyle: "short",
    timeZone: "Asia/Ho_Chi_Minh",
  }).format(new Date(snapshot.checkedAt));
  const statusLabel = snapshot.status === "current" ? "Nguồn đầy đủ" : snapshot.status === "partial" ? "Nguồn một phần" : "Nguồn lỗi";

  return (
    <div className={`daily-ops daily-ops--${snapshot.status}`} role="status">
      <span className={snapshot.status === "current" ? "status-pulse" : "daily-ops-mark"}>{snapshot.status === "current" ? "" : "!"}</span>
      <div>
        <strong>{statusLabel} · {snapshot.summary.ok}/{snapshot.summary.total}</strong>
        <small>Đã kiểm tra {checkedAt} · {snapshot.trigger === "cache" ? "cron/cache hôm nay" : "bù khi mở app"}</small>
      </div>
    </div>
  );
}

export function GoldMacroDashboard({ operations }: { operations: DailyMacroState }) {
  const snapshot = new Intl.DateTimeFormat("vi-VN", {
    dateStyle: "medium",
    timeStyle: "short",
    timeZone: "Asia/Ho_Chi_Minh",
  }).format(new Date(GOLD_MACRO_SNAPSHOT_AT));

  return (
    <div className="macro-page">
      <section className="macro-hero">
        <div>
          <p className="eyebrow">Gold macro intelligence</p>
          <h2>Dòng tiền &amp; sự kiện vĩ mô</h2>
          <p className="macro-intro">
            Quan sát nhu cầu cấu trúc, dòng vốn chiến thuật và catalyst có khả năng dịch chuyển real yield, USD và giá vàng.
          </p>
        </div>
        <div className="snapshot-stamp">
          <span className="status-pulse" />
          <div><strong>Verified snapshot</strong><small>{snapshot}</small></div>
        </div>
      </section>

      <DailyOperationsStatus operations={operations} />

      <section className="regime-banner">
        <div className="regime-score">
          <span>Macro pulse</span>
          <strong>Demand mạnh</strong>
          <em>Event risk cao</em>
        </div>
        <div className="regime-thesis">
          <p><span>Observation</span> ETF và central-bank demand cùng dương mạnh; futures positioning vẫn net long nhưng đã giảm trong tuần gần nhất.</p>
          <p><span>Inference</span> Nền cầu đang hỗ trợ vàng, trong khi CPI và FOMC có thể tạo biến động hai chiều qua USD và real yield.</p>
        </div>
        <div className="confidence-block">
          <small>Evidence coverage</small>
          <strong>{GOLD_SOURCES.length} nguồn</strong>
          <span>Không phải tín hiệu mua/bán</span>
        </div>
      </section>

      <section className="macro-section" id="capital-flows">
        <div className="macro-section-heading">
          <div><p className="eyebrow">Capital flows</p><h3>Nhu cầu và vị thế</h3></div>
          <span>Dữ liệu gần nhất theo từng nguồn</span>
        </div>

        <div className="macro-metrics-grid">
          <MetricCard kicker="Central banks · Q2" value="+289" unit="t net" change="5× Q1" tone="positive" sourceId="wgc-central-bank-q2">
            <p>Q2 lập kỷ lục cho một quý II; H1 đạt <strong>345t</strong>. Đây là lớp cầu cấu trúc, không phải timing intraday.</p>
            <div className="mini-flow"><span>Poland YTD</span><strong>+82t</strong></div>
            <div className="mini-flow"><span>China YTD</span><strong>+40t</strong></div>
            <div className="mini-flow mini-flow--negative"><span>Turkey YTD</span><strong>−83t</strong></div>
          </MetricCard>

          <MetricCard kicker="Gold ETFs · August" value="+$18" unit="bn" change="Record holdings" tone="positive" sourceId="wgc-etf-august">
            <p>Holdings tăng <strong>121t</strong> lên kỷ lục <strong>4,189t</strong>; AUM đạt US$615bn.</p>
            <div className="mini-flow"><span>North America</span><strong>+$7.7bn</strong></div>
            <div className="mini-flow"><span>Asia</span><strong>+$2.0bn</strong></div>
            <div className="mini-flow"><span>YTD holdings</span><strong>+160t</strong></div>
          </MetricCard>

          <MetricCard kicker="Gold market · August" value="$430" unit="bn/day" change="+21% MoM" tone="positive" sourceId="wgc-market-august">
            <p>Thanh khoản tăng trên các phân khúc; đây là activity proxy, không phải consolidated buy/sell spot tape.</p>
            <div className="mini-flow"><span>OTC volume</span><strong>$226bn/day · +10%</strong></div>
            <div className="mini-flow"><span>LBMA activity</span><strong>$199bn/day · +11%</strong></div>
            <div className="mini-flow"><span>ETF turnover</span><strong>$8.7bn/day · +83%</strong></div>
          </MetricCard>
        </div>

        <div className="positioning-strip">
          <div><p className="eyebrow">Positioning proxy</p><h4>COMEX non-commercial</h4></div>
          <div className="position-stat"><strong>228,124</strong><span>net long contracts</span></div>
          <div className="position-stat position-stat--cool"><strong>−15,210</strong><span>weekly net change</span></div>
          <p>Vị thế đầu cơ vẫn nghiêng long, nhưng mức giảm tuần cho thấy momentum đã nguội bớt tại ngày 01/09.</p>
          <SourceLink sourceId="cftc-cot" compact />
        </div>

        <div className="method-note">
          <span>!</span>
          <p><strong>Giới hạn spot flow:</strong> giao dịch vàng OTC phân mảnh và không có consolidated tape công khai. Dashboard dùng ETF flows, WGC/LBMA activity và COMEX positioning làm proxy; không suy diễn chúng thành lệnh mua/bán spot theo thời gian thực.</p>
        </div>
      </section>

      <section className="macro-section" id="event-risk">
        <div className="macro-section-heading">
          <div><p className="eyebrow">Three-star calendar</p><h3>Sự kiện tác động mạnh</h3></div>
          <span>Giờ Việt Nam · UTC+7</span>
        </div>

        <div className="events-table">
          <div className="event-table-head">
            <span>Thời gian</span><span>Sự kiện</span><span>Actual / trạng thái</span><span>Phân tích truyền dẫn tới vàng</span><span>Nguồn</span>
          </div>
          {GOLD_EVENTS.map((event) => (
            <article className={`event-row event-row--${event.status}`} key={event.id}>
              <div className="event-time"><strong>{event.date}</strong><span>{event.localTime}</span></div>
              <div className="event-name"><span className="stars" aria-label="Mức ảnh hưởng 3 sao">★★★</span><strong>{event.title}</strong><small>{event.category}</small></div>
              <div className="event-actual"><strong>{event.actual}</strong><small>Trước: {event.previous}</small></div>
              <p>{event.analysis}</p>
              <SourceLink sourceId={event.sourceId} compact />
            </article>
          ))}
        </div>
      </section>

      <section className="macro-section" id="catalysts">
        <div className="macro-section-heading">
          <div><p className="eyebrow">Broader watch</p><h3>Catalyst khác cần theo dõi</h3></div>
          <span>Không giới hạn ở lịch kinh tế</span>
        </div>
        <div className="catalyst-grid">
          <article><span>01</span><h4>USD &amp; real yields</h4><p>Kênh truyền dẫn nhanh nhất của CPI, PPI, jobs và Fed. Giá vàng thường nhạy hơn với real yield so với headline inflation đơn lẻ.</p><em>Daily / intraday</em></article>
          <article><span>02</span><h4>Fiscal &amp; Treasury stress</h4><p>Rủi ro bền vững tài khóa, term premium và can thiệp thị trường tiền tệ có thể tăng nhu cầu trú ẩn hoặc làm USD biến động.</p><em>Event-driven</em></article>
          <article><span>03</span><h4>Geopolitical risk</h4><p>Xung đột, sanctions và gián đoạn thanh khoản có thể tạo safe-haven bid; cần xác nhận bằng ETF/OTC activity thay vì headline đơn lẻ.</p><em>Real-time watch</em></article>
          <article><span>04</span><h4>Asia physical demand</h4><p>Premium, bar-and-coin demand, mùa vụ Trung Quốc/Ấn Độ và biến động FX địa phương tác động tới cầu vật chất.</p><em>Weekly / monthly</em></article>
          <article><span>05</span><h4>Reserve disclosures</h4><p>Mua/bán của NHTW, swap và các revision từ IMF/WGC có thể thay đổi đánh giá cầu cấu trúc.</p><em>Monthly / quarterly</em></article>
          <article><span>06</span><h4>Supply &amp; recycling</h4><p>Mine output và recycling phản ứng chậm hơn, nhưng ảnh hưởng cán cân trung hạn khi giá duy trì ở vùng cao.</p><em>Quarterly</em></article>
        </div>
      </section>

      <section className="sources-section">
        <div className="macro-section-heading">
          <div><p className="eyebrow">Provenance ledger</p><h3>Nguồn và độ mới</h3></div>
          <span>Click để kiểm chứng dữ liệu gốc</span>
        </div>
        <div className="source-ledger">
          {GOLD_SOURCES.map((source) => (
            <a href={source.url} target="_blank" rel="noreferrer" key={source.id}>
              <div><strong>{source.name}</strong><small>Published {source.publishedAt}</small></div>
              <div><span>Data through</span><strong>{source.dataThrough}</strong></div>
              <span aria-hidden="true">↗</span>
            </a>
          ))}
        </div>
      </section>
    </div>
  );
}
