const screens = [...document.querySelectorAll('[data-screen]')];
const nav = document.querySelector('.bottom-nav');
let timerId;

function showScreen(name) {
  let active;
  screens.forEach((screen) => {
    const isActive = screen.dataset.screen === name;
    screen.classList.toggle('is-active', isActive);
    if (isActive) active = screen;
  });
  document.querySelectorAll('.dialog').forEach((dialog) => dialog.classList.remove('open'));
  const hasNav = active?.classList.contains('has-nav');
  nav.classList.toggle('visible', hasNav);
  const activeNav = active?.dataset.nav;
  document.querySelectorAll('[data-nav-item]').forEach((item) => item.classList.toggle('active', item.dataset.navItem === activeNav));
  if (name === 'studio') startTimer(); else stopTimer();
}

function startTimer() {
  stopTimer();
  let elapsed = 12;
  const output = document.querySelector('#studio-time');
  timerId = setInterval(() => {
    elapsed += 1;
    output.textContent = `${String(Math.floor(elapsed / 60)).padStart(2, '0')}:${String(elapsed % 60).padStart(2, '0')}`;
  }, 1000);
}

function stopTimer() {
  if (timerId) clearInterval(timerId);
  timerId = undefined;
}

document.addEventListener('click', (event) => {
  const destination = event.target.closest('[data-go]')?.dataset.go;
  if (destination) {
    showScreen(destination);
    return;
  }

  const authButton = event.target.closest('[data-auth]');
  if (authButton) {
    document.querySelectorAll('[data-auth]').forEach((button) => button.classList.toggle('selected', button === authButton));
    const isPhone = authButton.dataset.auth === 'phone';
    const label = document.querySelector('#identity-label');
    const input = document.querySelector('#identity-input');
    label.textContent = isPhone ? '電話番号' : 'メールアドレス';
    input.type = isPhone ? 'tel' : 'email';
    input.value = isPhone ? '090 1234 5678' : 'haru@example.jp';
    return;
  }

  const action = event.target.closest('[data-action]')?.dataset.action;
  if (action === 'confirm-end') document.querySelector('[data-dialog="end"]').classList.add('open');
  if (action === 'cancel-end') document.querySelector('[data-dialog="end"]').classList.remove('open');
});

const requestedScreen = new URLSearchParams(window.location.search).get('screen');
showScreen(screens.some((screen) => screen.dataset.screen === requestedScreen) ? requestedScreen : 'login');
