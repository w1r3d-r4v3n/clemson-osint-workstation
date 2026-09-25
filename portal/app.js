(() => {
  const filter = document.querySelector('#tool-filter');
  const cards = [...document.querySelectorAll('.tool-card')];
  const empty = document.querySelector('#empty-state');

  filter?.addEventListener('input', () => {
    const query = filter.value.trim().toLowerCase();
    let visible = 0;
    for (const card of cards) {
      const haystack = `${card.dataset.search || ''} ${card.textContent}`.toLowerCase();
      card.hidden = Boolean(query) && !haystack.includes(query);
      if (!card.hidden) visible += 1;
    }
    empty.hidden = visible !== 0;
  });

  document.querySelectorAll('[data-copy]').forEach((button) => {
    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(button.dataset.copy);
        const old = button.textContent;
        button.textContent = 'Copied';
        setTimeout(() => { button.textContent = old; }, 1200);
      } catch {
        button.textContent = 'Select command';
      }
    });
  });
})();
