import fs from 'node:fs';

const sourcePath = process.argv[2];
if (!sourcePath) {
  console.error('FAIL: Missing Pine source path.');
  process.exit(2);
}

const source = fs.readFileSync(sourcePath, 'utf8');
const body = new URLSearchParams();
body.append('source', source);

const compilerUri =
  'https://pine-facade.tradingview.com/pine-facade/translate_light' +
  '?user_name=Guest&pine_id=00000000-0000-0000-0000-000000000000';

let response;
try {
  response = await fetch(compilerUri, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      Referer: 'https://www.tradingview.com/',
    },
    body,
  });
} catch (error) {
  console.error(`FAIL: TradingView compiler request failed: ${error.message}`);
  process.exit(3);
}

if (!response.ok) {
  console.error(`FAIL: TradingView compiler returned HTTP ${response.status}.`);
  process.exit(4);
}

const payload = await response.json();
const errors = [...(payload?.result?.errors2 ?? [])];
const warnings = [...(payload?.result?.warnings2 ?? [])];
if (typeof payload?.error === 'string' && payload.error.length > 0) {
  errors.push({ message: payload.error });
}

if (errors.length > 0) {
  console.error(`FAIL: TradingView compiler reported ${errors.length} error(s).`);
  for (const error of errors) {
    const line = error?.start?.line ?? '?';
    const column = error?.start?.column ?? '?';
    console.error(`  - ${line}:${column} ${error.message}`);
  }
  process.exit(5);
}

console.log(`TradingView compiler: PASS (${warnings.length} warning(s))`);
