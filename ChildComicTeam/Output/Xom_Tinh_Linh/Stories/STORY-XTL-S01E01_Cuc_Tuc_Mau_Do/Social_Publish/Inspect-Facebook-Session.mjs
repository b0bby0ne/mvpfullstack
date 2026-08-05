const endpoint = 'http://127.0.0.1:9223/json/list';

async function evaluate(wsUrl, expression) {
  const socket = new WebSocket(wsUrl);
  await new Promise((resolve, reject) => {
    socket.addEventListener('open', resolve, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });

  const id = 1;
  const result = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('CDP evaluation timeout')), 5000);
    socket.addEventListener('message', event => {
      const message = JSON.parse(event.data);
      if (message.id === id) {
        clearTimeout(timer);
        resolve(message);
      }
    });
    socket.send(JSON.stringify({
      id,
      method: 'Runtime.evaluate',
      params: { expression, returnByValue: true, awaitPromise: true }
    }));
  });
  socket.close();
  if (result.result?.exceptionDetails) {
    const description = result.result.exceptionDetails.exception?.description || result.result.exceptionDetails.text || 'Unknown CDP error';
    throw new Error(description);
  }
  return result.result?.result?.value;
}

let targets;
try {
  const response = await fetch(endpoint);
  if (!response.ok) throw new Error(`CDP endpoint returned ${response.status}`);
  targets = await response.json();
} catch (error) {
  console.error(`SESSION_UNAVAILABLE: ${error.message}`);
  process.exit(2);
}

const facebookTargets = targets.filter(target => target.type === 'page' && /facebook\.com/i.test(target.url));
if (!facebookTargets.length) {
  console.log(JSON.stringify({ session: 'running', facebookTabs: 0 }, null, 2));
  process.exit(1);
}

const states = [];
for (const target of facebookTargets) {
  const state = await evaluate(target.webSocketDebuggerUrl, `(() => {
    const text = document.body?.innerText || '';
    const labels = [...document.querySelectorAll('[aria-label]')].map(el => el.getAttribute('aria-label') || '');
    const loginForm = Boolean(document.querySelector('input[name="email"], input[name="pass"]'));
    const composer = labels.some(label => /Photo\\/video|Ảnh\\/video|Create post|Tạo bài viết/i.test(label)) || /Bạn đang nghĩ gì|What's on your mind/i.test(text);
    const pageSignal = /Tài Sản Cho Con/i.test(document.title + '\\n' + text.slice(0, 6000));
    return { url: location.href, title: document.title, loginForm, composer, pageSignal };
  })()`);
  states.push(state);
}

console.log(JSON.stringify({ session: 'running', facebookTabs: states.length, states }, null, 2));
