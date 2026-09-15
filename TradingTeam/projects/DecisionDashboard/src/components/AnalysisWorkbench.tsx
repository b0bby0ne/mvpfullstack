import { useState } from "react";
import type { Market, Timeframe } from "../domain/markets";
import { TradingViewTechnicalAnalysis } from "./TradingViewTechnicalAnalysis";

type AnalysisWorkbenchProps = {
  market: Market;
  timeframe: Timeframe;
};

type MethodId = "smc" | "wyckoff" | "elliott";

const METHOD_PLAYBOOKS: Array<{
  id: MethodId;
  code: string;
  title: string;
  role: string;
  outputs: string[];
  guardrail: string;
}> = [
  {
    id: "smc",
    code: "01",
    title: "SMC",
    role: "Location & liquidity",
    outputs: [
      "External structure và draw-on-liquidity",
      "Sweep/displacement cùng protected swing",
      "POI, confirmation và thesis invalidation",
    ],
    guardrail: "TradingView rating không thay thế sweep, BOS/CHoCH hay POI evidence.",
  },
  {
    id: "wyckoff",
    code: "02",
    title: "Wyckoff",
    role: "Regime & trading range",
    outputs: [
      "Trend đi vào và provisional range boundaries",
      "Candidate event → response → test → dominance",
      "Primary/alternate phase cùng volume venue",
    ],
    guardrail: "Moving-average summary không chứng minh accumulation hoặc distribution.",
  },
  {
    id: "elliott",
    code: "03",
    title: "Elliott",
    role: "Path & invalidation",
    outputs: [
      "Degree, scale và audited price extremes",
      "Primary/alternate count qua hard-rule filter",
      "Confirmation, invalidation và target tách biệt",
    ],
    guardrail: "Oscillator consensus không được dùng để cứu wave count vi phạm rule.",
  },
];

function timeframeLabel(timeframe: Timeframe) {
  if (timeframe === "D") return "1D";
  if (timeframe === "240") return "4H";
  if (timeframe === "60") return "1H";
  return "15m";
}

export function AnalysisWorkbench({ market, timeframe }: AnalysisWorkbenchProps) {
  const [activeMethod, setActiveMethod] = useState<MethodId>("smc");
  const method = METHOD_PLAYBOOKS.find((item) => item.id === activeMethod) ?? METHOD_PLAYBOOKS[0];

  return (
    <section id="analysis-workbench" className="analysis-workbench" aria-labelledby="analysis-workbench-title">
      <header className="analysis-workbench__header">
        <div>
          <p className="eyebrow">Analysis engine · below chart</p>
          <h3 id="analysis-workbench-title">Bộ phân tích kỹ thuật</h3>
          <p>TradingView cung cấp technical snapshot; DecisionDashboard tổ chức evidence trước khi chuyên gia kết luận.</p>
        </div>
        <div className="analysis-source-pills" aria-label="Nguồn phân tích">
          <span>TradingView data</span>
          <strong>{market.tradingViewSymbol}</strong>
          <strong>{timeframeLabel(timeframe)}</strong>
        </div>
      </header>

      <div className="analysis-workbench__grid">
        <article className="tv-analysis-card">
          <div className="analysis-card-heading">
            <div><span className="analysis-index">A</span><div><p>Automated snapshot</p><h4>Oscillators &amp; moving averages</h4></div></div>
            <span className="hosted-badge">Hosted widget</span>
          </div>
          <TradingViewTechnicalAnalysis market={market} timeframe={timeframe} />
        </article>

        <article className="analysis-contract-card">
          <div className="analysis-card-heading">
            <div><span className="analysis-index">B</span><div><p>Evidence contract</p><h4>Từ dữ liệu tới thesis</h4></div></div>
            <span className="review-badge">Expert review</span>
          </div>
          <ol className="analysis-pipeline">
            <li><span>01</span><div><strong>Technical rating</strong><p>Snapshot TradingView theo đúng symbol và timeframe đang chọn.</p></div></li>
            <li><span>02</span><div><strong>Structure reading</strong><p>Đọc chart/drawings bằng SMC, Wyckoff và Elliott contracts.</p></div></li>
            <li><span>03</span><div><strong>Conflict check</strong><p>Giữ alternate khi methods hoặc timeframes chưa đồng thuận.</p></div></li>
            <li><span>04</span><div><strong>Decision note</strong><p>Ghi confirmation, invalidation và target ở panel bên phải.</p></div></li>
          </ol>
          <div className="analysis-boundary">
            <span>i</span>
            <p>Hosted iframe không xuất raw OHLC, indicator values hoặc drawings cho app. Snapshot này là nguồn tham khảo tự động; method synthesis vẫn cần chuyên gia xác nhận.</p>
          </div>
        </article>
      </div>

      <div className="method-lab">
        <div className="method-tabs" role="tablist" aria-label="Chọn phương pháp phân tích">
          {METHOD_PLAYBOOKS.map((item) => (
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
        </div>

        <div className="method-output" role="tabpanel" aria-label={`Khung phân tích ${method.title}`}>
          <div><p className="eyebrow">Required evidence</p><h4>{method.title} · {method.role}</h4></div>
          <div className="method-output__items">
            {method.outputs.map((output, index) => (
              <p key={output}><span>{String(index + 1).padStart(2, "0")}</span>{output}</p>
            ))}
          </div>
          <div className="method-guardrail"><span>Guardrail</span><p>{method.guardrail}</p></div>
        </div>
      </div>
    </section>
  );
}
