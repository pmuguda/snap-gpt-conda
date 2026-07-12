const root = document.documentElement;
const btns = document.querySelectorAll('[data-theme-set]');

function syncThemeButtons() {
  const current = root.dataset.theme;
  btns.forEach((button) => {
    button.setAttribute('aria-pressed', String(button.dataset.themeSet === current));
  });
}

btns.forEach((button) => {
  button.addEventListener('click', () => {
    root.dataset.theme = button.dataset.themeSet;
    localStorage.setItem('theme', button.dataset.themeSet);
    syncThemeButtons();
  });
});

syncThemeButtons();
