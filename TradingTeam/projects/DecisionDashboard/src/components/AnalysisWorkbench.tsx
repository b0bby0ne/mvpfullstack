import type { Market, Timeframe } from "../domain/markets";
import { ClosedBarAnalysis } from "./ClosedBarAnalysis";
import { TradingHubIndicatorLab } from "./TradingHubIndicatorLab";
import { TradingViewTechnicalAnalysis } from "./TradingViewTechnicalAnalysis";

type AnalysisWorkbenchProps = {
  market: Market;
  timeframe: Timeframe;
};

function timeframeLabel(timeframe: Timeframe) {
  if (timeframe === "D") return "1D";
  if (timeframe === "240") return "4H";
  if (timeframe === "60") return "1H";
  return "15m";
}

export function AnalysisWorkbench({ market, timeframe }: AnalysisWorkbenchProps) {
  return (
    <section id="analysis-workbench" className="analysis-workbench" aria-labelledby="analysis-workbench-title">
      <header className="analysis-workbench__header">
        <div>
          <p className="eyebrow">Analysis engine · below chart</p>
          <h3 id="analysis-workbench-title">Bộ phân tích kỹ thuật</h3>
          <p>TradingView cung cấp technical snapshot; DecisionDashboard tổ chức evidence trước khi chuyên gia kết luận.</p>
        </div>
        <div className="analysis-source-pills" aria-label="Nguồn phân tích">
          <span>TradingView widget</span>
          <strong>{market.tradingViewSymbol}</strong>
          <strong>{timeframeLabel(timeframe)}</strong>
        </div>
      </header>

      <TradingHubIndicatorLab market={market} />

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

      <ClosedBarAnalysis market={market} />
    </section>
  );
}
