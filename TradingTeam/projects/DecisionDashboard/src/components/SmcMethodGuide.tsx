import type { MarketId } from "../domain/markets";
import {
  getSmcMarketPolicy,
  SMC_METHOD_BASELINE,
  SMC_MODEL_SUMMARIES,
  type SmcModelId,
} from "../domain/smcMethod";

const MODEL_IDS: SmcModelId[] = ["SMC_RR_01", "SMC_TC_01"];

export function SmcMethodGuide({ marketId }: { marketId: MarketId }) {
  const policy = getSmcMarketPolicy(marketId);

  return (
    <details className="smc-method-card" open>
      <summary>
        <span><strong>SMC Method</strong><small>{SMC_METHOD_BASELINE.version}</small></span>
        <span className="smc-approved">PO approved</span>
      </summary>
      <div className="smc-method-body">
        <p className="smc-profile">Context <strong>4H</strong> → Setup <strong>1H</strong> → Trigger <strong>15m</strong></p>
        <div className="smc-models">
          {MODEL_IDS.map((modelId) => {
            const model = SMC_MODEL_SUMMARIES[modelId];
            return (
              <div className="smc-model" key={modelId}>
                <span>{modelId === "SMC_RR_01" ? "R" : "C"}</span>
                <div><strong>{model.name}</strong><p>{model.sequence.join(" → ")}</p></div>
              </div>
            );
          })}
        </div>
        <div className="smc-venue">
          <span>STRUCTURE</span><strong>{policy.chartStructure}</strong>
          <span>FLOW SUPPORT</span><strong>{policy.liquidityEvidence}</strong>
        </div>
        <p className="smc-guardrail">Không có setup nếu thiếu location, displacement, accepted break hoặc thesis invalidation.</p>
      </div>
    </details>
  );
}
