# EUR/USD macro + technical backtest

Reproducible daily research pipeline combining the EUR-minus-US 2-year yield differential with a long-term EUR/USD trend filter. It downloads public official data, applies a conservative two-fix execution lag, includes transaction costs and approximate policy-rate carry, and produces event, regime, walk-forward and robustness evidence.

## Run

```powershell
npm run all
```

Requirements: Node.js 20 or newer and internet access. The run is research-only. ECB reference rates are not executable broker quotes, and the daily test does not validate H4/H1 entry execution.

## Model registered in `config/backtest.json`

- Macro impulse: 20-business-day change in ECB AAA euro-area 2Y minus US Treasury 2Y.
- Robust standardization: trailing 252 observations, current observation excluded.
- Hysteresis: enter outside ±0.5 robust z; exit inside ±0.25.
- Technical confirmation: EUR/USD above or below SMA200.
- Position: long or short only when macro and technical directions agree; otherwise flat.
- Timing: data known after day `t` is first allowed to earn P&L from ECB fix `t+1` to fix `t+2`.
- Costs: 1 pip one way in the main case; 0/0.5/1/2 pip sensitivity.
- Carry: ECB deposit rate minus effective fed funds, Actual/360 approximation.

See the generated run under `TradingTeam/output/runs/` for the report and evidence files.
