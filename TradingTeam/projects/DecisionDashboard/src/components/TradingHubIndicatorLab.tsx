import { useState } from "react";
import type { Market } from "../domain/markets";
import pineSource from "../indicators/tradingHubSwing.pine?raw";

type TradingHubIndicatorLabProps = {
  market: Market;
};

export function TradingHubIndicatorLab({ market }: TradingHubIndicatorLabProps) {
  const [copyState, setCopyState] = useState<"idle" | "copied" | "failed">("idle");

  async function copyPine() {
    try {
      await navigator.clipboard.writeText(pineSource);
      setCopyState("copied");
      window.setTimeout(() => setCopyState("idle"), 1800);
    } catch {
      setCopyState("failed");
    }
  }

  return (
    <article className="indicator-lab" aria-labelledby="trading-hub-indicator-title">
      <div className="indicator-lab__intro">
        <div>
          <p className="eyebrow">Pine Script v6 · research profile TH-SWING-R0.1</p>
          <h4 id="trading-hub-indicator-title">Trading Hub · đỉnh/đáy theo IDM</h4>
          <p>
            Không đánh dấu mọi fractal. Một cực trị chỉ thành H/L cấu trúc sau khi giá break hoặc sweep
            internal pullback đối diện; HH/LH và HL/LL chỉ được phân loại sau xác nhận.
          </p>
        </div>
        <div className="indicator-lab__actions">
          <button type="button" onClick={copyPine}>
            {copyState === "copied" ? "Đã sao chép Pine" : copyState === "failed" ? "Không thể sao chép" : "Sao chép Pine Script"}
          </button>
          <a href={`https://www.tradingview.com/chart/?symbol=${encodeURIComponent(market.tradingViewSymbol)}`} target="_blank" rel="noreferrer">
            Mở Pine Editor ↗
          </a>
        </div>
      </div>

      <div className="indicator-lab__rules">
        <div><span>01</span><strong>Candidate</strong><p>H? hoặc L? còn có thể dịch chuyển, mặc định được ẩn.</p></div>
        <div><span>02</span><strong>IDM gate</strong><p>Wick/sweep là mặc định; có thể đổi sang close/break.</p></div>
        <div><span>03</span><strong>Confirmed</strong><p>H/L nằm tại cực trị, dấu ✓ nằm tại bar thực sự xác nhận.</p></div>
        <div><span>04</span><strong>Closed bar</strong><p>Chỉ commit sự kiện khi nến đóng; không dùng lookahead.</p></div>
      </div>

      <div className="indicator-lab__boundary">
        <strong>Ranh giới fidelity</strong>
        <p>
          “Internal pivot bars” là implementation seam có thể chỉnh và phải đối chiếu golden chart. Nó giúp tìm
          pullback ứng viên, không tuyên bố mọi pivot đó đều là IDM canonical của Mr Khan.
        </p>
      </div>
    </article>
  );
}

