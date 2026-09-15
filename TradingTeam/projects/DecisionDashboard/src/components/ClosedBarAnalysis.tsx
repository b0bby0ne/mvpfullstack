import { useEffect, useState } from "react";
import type { Market } from "../domain/markets";
import { useTechnicalAnalysis, type AnalysisMethodId, type DirectionalBias } from "../hooks/useTechnicalAnalysis";

const METHODS: Array<{ id: AnalysisMethodId; code: string; title: string; role: string; rule: string }> = [
  { id: "smc", code: "01", title: "SMC", role: "Structure · liquidity · POI", rule: "Chỉ xác nhận khi có location → liquidity event → displacement → accepted break." },
  { id: "wyckoff", code: "02", title: "Wyckoff", role: "Effort · result · range", rule: "Event và phase luôn provisional cho tới khi có response, test và dominance evidence." },
  { id: "elliott", code: "03", title: "Elliott", role: "Wave path · hard rules", rule: "Dùng price extremes; giữ alternate và loại count vi phạm hard rule, không cứu bằng close-only." },
];

const BIAS_LABEL: Record<DirectionalBias, string> = {
  bullish: "Tăng",
  bearish: "Giảm",
  neutral: "Trung tính",
};

function formatTime(value: string | null) {
  if (!value) return "Chưa có";
  return new Intl.DateTimeFormat("vi-VN", {
    timeZone: "Asia/Ho_Chi_Minh",
    day: "2-digit",
    month: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(new Date(value));
}

function formatPrice(value: number) {
  return new Intl.NumberFormat("en-US", { maximumFractionDigits: value >= 1000 ? 2 : 5 }).format(value);
}

function countdown(target: string, now: number) {
  const remaining = Math.max(0, new Date(target).getTime() - now);
  const minutes = Math.floor(remaining / 60_000);
  const seconds = Math.floor((remaining % 60_000) / 1_000);
  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
}

export function ClosedBarAnalysis({ market }: { market: Market }) {
  const analysis = useTechnicalAnalysis(market.id);
  const [activeMethod, setActiveMethod] = useState<AnalysisMethodId>("smc");
  const [now, setNow] = useState(Date.now());
  const method = METHODS.find((item) => item.id === activeMethod) ?? METHODS[0];

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 1_000);
    return () => window.clearInterval(timer);
  }, []);

  return (
    <section className="closed-bar-engine" aria-labelledby="closed-bar-title">
      <header className="closed-bar-engine__header">
        <div>
          <p className="eyebrow">Deterministic closed-bar engine</p>
          <h4 id="closed-bar-title">Phân tích 1D → 4H → 1H → M15</h4>
          <p>Chỉ sử dụng nến đã đóng từ venue khớp với chart. M15 điều phối lần phân tích kế tiếp.</p>
        </div>
        <button type="button" onClick={analysis.refresh} disabled={analysis.phase === "loading"}>Kiểm tra lại</button>
      </header>

      {analysis.phase === "loading" && <div className="engine-message" role="status"><span className="loader" /><p>{analysis.message}</p></div>}
      {analysis.phase === "error" && <div className="engine-message engine-message--error" role="alert"><strong>Không thể đọc datafeed</strong><p>{analysis.message}</p></div>}

      {analysis.phase === "ready" && (
        <>
          <div className="engine-runbar">
            <div><span className={`engine-status engine-status--${analysis.snapshot.status}`} /> <strong>{analysis.snapshot.status}</strong></div>
            <p>Nến M15 đóng: <strong>{formatTime(analysis.snapshot.closedBarAt)}</strong></p>
            <p>Lần chạy kế tiếp: <strong>{countdown(analysis.snapshot.nextAnalysisAt, now)}</strong></p>
            <p>{analysis.snapshot.source.provider} · {analysis.snapshot.source.instrument}</p>
          </div>

          {analysis.snapshot.status === "blocked" ? (
            <div className="engine-message engine-message--blocked" role="status">
              <strong>XAU analyzer đang chờ datafeed</strong>
              <p>{analysis.snapshot.error}</p>
              <small>TradingView widget vẫn hiển thị độc lập; hệ thống không tạo kết luận tự động khi thiếu raw closed bars.</small>
            </div>
          ) : (
            <>
              <div className={`mtf-synthesis mtf-synthesis--${analysis.snapshot.synthesis?.state ?? "mixed"}`}>
                <span>MTF synthesis</span>
                <strong>{analysis.snapshot.synthesis?.summary}</strong>
                <small>Generated at {formatTime(analysis.snapshot.checkedAt)} · trigger: {analysis.snapshot.trigger}</small>
              </div>

              <div className="method-lab method-lab--live">
                <div className="method-tabs" role="tablist" aria-label="Chọn phương pháp phân tích hành vi giá">
                  {METHODS.map((item) => (
                    <button
                      key={item.id}
                      type="button"
                      role="tab"
                      aria-selected={activeMethod === item.id}
                      className={activeMethod === item.id ? "is-active" : ""}
                      onClick={() => setActiveMethod(item.id)}
                    >
                      <span>{item.code}</span>
                      <div><strong>{item.title}</strong><small>{item.role}</small></div>
                    </button>
                  ))}
                  <div className="method-rule"><span>Rule</span><p>{method.rule}</p></div>
                </div>

                <div className="timeframe-analysis" role="tabpanel" aria-label={`Phân tích ${method.title} đa khung`}>
                  {analysis.snapshot.timeframes.map((frame) => {
                    const result = frame.methods[activeMethod];
                    return (
                      <article className="timeframe-analysis__card" key={frame.timeframe}>
                        <header>
                          <div><span>{frame.timeframe}</span><div><strong>{frame.role}</strong><small>Đóng {formatTime(frame.closedAt)} · {frame.barCount} bars</small></div></div>
                          <em className={`bias-pill bias-pill--${result.bias}`}>{BIAS_LABEL[result.bias]}</em>
                        </header>
                        <div className="timeframe-price-row">
                          <p><span>Close</span><strong>{formatPrice(frame.lastBar.close)}</strong></p>
                          <p><span>Candle</span><strong>{frame.candle.label}</strong></p>
                          <p><span>Structure</span><strong>{frame.structure.label}</strong></p>
                        </div>
                        <div className="behavior-summary"><span>{result.state}</span><p>{result.summary}</p></div>
                        <div className="behavior-evidence">
                          <p className="eyebrow">Hành vi giá &amp; evidence</p>
                          <ul>{result.behaviors.map((behavior) => <li key={behavior}>{behavior}</li>)}</ul>
                        </div>
                        <div className="behavior-levels">
                          {result.levels.length
                            ? result.levels.map((level) => <span key={`${level.label}-${level.price}`}><small>{level.label}</small><strong>{formatPrice(level.price)}</strong></span>)
                            : <span><small>Level</small><strong>Chưa đủ evidence</strong></span>}
                        </div>
                      </article>
                    );
                  })}
                </div>
              </div>
            </>
          )}
        </>
      )}
    </section>
  );
}
