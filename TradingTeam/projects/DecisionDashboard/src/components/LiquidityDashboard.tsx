import type { MarketId } from "../domain/markets";
import { getMarket } from "../domain/markets";
import { useLiquidity, type OptionLevel } from "../hooks/useLiquidity";

const usd = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", notation: "compact", maximumFractionDigits: 1 });
const price = new Intl.NumberFormat("en-US", { maximumFractionDigits: 1 });
const number = new Intl.NumberFormat("en-US", { notation: "compact", maximumFractionDigits: 1 });

function signedUsd(value: number | null) {
  if (value === null) return "—";
  return `${value >= 0 ? "+" : "−"}${usd.format(Math.abs(value))}`;
}

function optionOi(level: OptionLevel, side: "call" | "put") {
  const btcValue = side === "call" ? level.callOiBtc : level.putOiBtc;
  const contracts = side === "call" ? level.callOiContracts : level.putOiContracts;
  if (btcValue !== undefined) return `${number.format(btcValue)} BTC`;
  return contracts !== undefined ? `${number.format(contracts)} contracts` : "—";
}

export function LiquidityDashboard({ marketId }: { marketId: MarketId }) {
  const market = getMarket(marketId);
  const state = useLiquidity(marketId);

  if (state.phase === "loading") {
    return <section className="liquidity-page liquidity-state" role="status"><span className="liquidity-loader" /><p className="eyebrow">Liquidity engine</p><h2>Đang xây bản đồ thanh khoản {market.shortName}/USD</h2><p>{state.message}</p></section>;
  }
  if (state.phase === "error") {
    return <section className="liquidity-page liquidity-state liquidity-state--error" role="alert"><span>!</span><p className="eyebrow">Liquidity engine</p><h2>Không thể tải dữ liệu thanh khoản</h2><p>{state.message}</p></section>;
  }

  const { snapshot } = state;
  const checkedAt = new Intl.DateTimeFormat("vi-VN", { dateStyle: "short", timeStyle: "medium", timeZone: "Asia/Ho_Chi_Minh" }).format(new Date(snapshot.checkedAt));
  const data = snapshot.data;
  const dataThrough = data ? new Intl.DateTimeFormat("vi-VN", { dateStyle: "short", timeZone: "Asia/Ho_Chi_Minh" }).format(new Date(data.observedAt)) : null;
  const maxWallAmount = Math.max(1, ...(data?.futures.walls.map((wall) => wall.amountUsd) ?? []));
  const statusLabel = snapshot.status === "current" ? "Current" : snapshot.status === "partial" ? "Partial" : snapshot.status === "stale" ? "Stale fallback" : "Source unavailable";
  const futuresOi = data?.futures.openInterestUsd !== null
    ? usd.format(data?.futures.openInterestUsd ?? 0)
    : data?.futures.openInterestContracts
      ? `${number.format(data.futures.openInterestContracts)} contracts`
      : "Licensed feed";
  const futuresVolume = data?.futures.volume24hUsd
    ? `${usd.format(data.futures.volume24hUsd)} volume 24h`
    : data?.futures.volumeContracts
      ? `${number.format(data.futures.volumeContracts)} contracts EOD`
      : "Không có trong public snapshot";
  const optionBlockTrades = data?.options.blockTrades ?? [];
  const optionPanelTitle = data?.options.levels.length ? "Open-interest walls" : optionBlockTrades.length ? "Block volume prints" : "Open-interest walls";

  return (
    <section className="liquidity-page" aria-label={`Liquidity ${market.shortName}/USD`}>
      <header className="liquidity-hero">
        <div><p className="eyebrow">Futures · Options · Order flow</p><h2>Bản đồ thanh khoản {market.shortName}/USD</h2><p>Xác định cụm lệnh chờ và open-interest wall lớn để đưa vào context trước khi phân tích chart.</p></div>
        <div className={`liquidity-status liquidity-status--${snapshot.status}`}><span /><div><strong>{statusLabel}</strong><small>Checked {checkedAt} · data through {dataThrough ?? "—"}</small></div></div>
      </header>

      {!data ? (
        <div className="liquidity-unavailable">
          <span className="lock-mark">!</span>
          <div><p className="eyebrow">Fail closed · không tạo vùng giả</p><h3>Chưa có order flow COMEX hợp lệ</h3><p>{snapshot.disclaimer}</p><small>{snapshot.error}</small></div>
        </div>
      ) : (
        <>
          <div className="liquidity-metrics">
            <article><span>Reference</span><strong>{data.referencePrice ? `$${price.format(data.referencePrice)}` : "EOD strikes"}</strong><small>{data.futures.instrument}{data.futures.settlementChange ? ` · +${price.format(data.futures.settlementChange)}` : ""}</small></article>
            <article><span>Futures OI</span><strong>{futuresOi}</strong><small>{futuresVolume}{data.futures.openInterestChangeContracts ? ` · OI +${number.format(data.futures.openInterestChangeContracts)}` : ""}</small></article>
            <article><span>Taker delta</span><strong className={(data.futures.deltaUsd ?? 0) >= 0 ? "positive" : "negative"}>{signedUsd(data.futures.deltaUsd)}</strong><small>{data.futures.sampledTrades ? `${data.futures.sampledTrades} trades gần nhất` : "Không có tick-level public data"}</small></article>
            <article><span>Option universe</span><strong>{data.options.instruments === null ? "COMEX EOD" : number.format(data.options.instruments)}</strong><small>{data.options.levels.length ? `${data.options.levels.length} OI walls được xếp hạng` : `${optionBlockTrades.length} block prints · chưa phải OI`}</small></article>
          </div>

          <div className="liquidity-grid">
            <article className="liquidity-panel">
              <div className="liquidity-panel-head"><div><p className="eyebrow">Futures depth</p><h3>Large resting walls</h3></div><span>{data.futures.walls.length ? "Top bid / ask" : "Licensed depth required"}</span></div>
              {data.futures.walls.length ? (
                <div className="depth-list">
                  {data.futures.walls.map((wall) => (
                    <div className={`depth-row depth-row--${wall.side}`} key={`${wall.side}-${wall.price}`}>
                      <span className="depth-side">{wall.side}</span><strong>${price.format(wall.price)}</strong>
                      <div className="depth-bar"><i style={{ width: `${Math.max(4, (wall.amountUsd / maxWallAmount) * 100)}%` }} /></div>
                      <span>{usd.format(wall.amountUsd)}</span><small>{wall.distancePct > 0 ? "+" : ""}{wall.distancePct}%</small>
                    </div>
                  ))}
                </div>
              ) : <div className="panel-empty">CME public bulletin không cung cấp order-by-order depth. Kết nối CME MDP/API đã license để bật bid/ask walls cho XAU.</div>}
            </article>

            <article className="liquidity-panel">
              <div className="liquidity-panel-head"><div><p className="eyebrow">Options positioning</p><h3>{optionPanelTitle}</h3></div><span>{data.options.levels.length ? "Không phải dealer gamma" : "Không phải OI wall"}</span></div>
              <div className="option-wall-list">
                {data.options.levels.map((level) => (
                  <div className={`option-wall option-wall--${level.bias}`} key={`${level.expiry ?? "all"}-${level.strike}`}>
                    <div><strong>${price.format(level.strike)}</strong><small>{level.expiry ?? `${level.distancePct && level.distancePct > 0 ? "+" : ""}${level.distancePct ?? 0}%`}</small></div>
                    <div className="option-bar"><i style={{ width: `${Math.max(5, level.strength * 100)}%` }} /></div>
                    <div><span>C {optionOi(level, "call")}</span><span>P {optionOi(level, "put")}</span></div>
                  </div>
                ))}
                {!data.options.levels.length && optionBlockTrades.map((trade) => (
                  <div className={`option-wall option-wall--${trade.side}-wall`} key={`block-${trade.expiry}-${trade.side}-${trade.strike}`}>
                    <div><strong>${price.format(trade.strike)}</strong><small>{trade.expiry} · {trade.side}</small></div>
                    <div className="option-bar"><i style={{ width: `${Math.max(5, trade.strength * 100)}%` }} /></div>
                    <div><span>BLOCK</span><span>{number.format(trade.volumeContracts)} contracts</span></div>
                  </div>
                ))}
                {!data.options.levels.length && !optionBlockTrades.length && <div className="panel-empty">Không có option OI level hợp lệ trong snapshot.</div>}
              </div>
            </article>
          </div>

          {data.futures.sampledTrades > 0 && (
            <div className="flow-balance">
              <div><p className="eyebrow">Recent taker flow</p><h3>{Math.round((data.futures.buyRatio ?? 0) * 100)}% buy · {Math.round((1 - (data.futures.buyRatio ?? 0)) * 100)}% sell</h3></div>
              <div className="flow-track"><i style={{ width: `${(data.futures.buyRatio ?? 0) * 100}%` }} /></div>
              <div><span>Liquidation prints</span><strong>{data.futures.liquidations} · {usd.format(data.futures.liquidationAmountUsd ?? 0)}</strong></div>
            </div>
          )}
        </>
      )}

      <div className="liquidity-method"><span>i</span><p><strong>Phương pháp:</strong> {snapshot.disclaimer} {data?.sourceMode === "verified-public-fallback" ? `Đang dùng CME bulletin đã xác minh cho trade date ${data.cmeTradeDate}; option panel là block volume, không phải OI wall.` : "Wall được xếp hạng theo quy mô quan sát tại thời điểm snapshot và có thể bị rút trước khi giá chạm."}</p></div>
      <div className="liquidity-sources">
        {snapshot.sources.map((source) => <a href={source.url} target="_blank" rel="noreferrer" key={source.id}><span>{source.publisher}</span><strong>{source.data}</strong><small>{source.latency} ↗</small></a>)}
      </div>
    </section>
  );
}
