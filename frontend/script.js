function runCode() {
  const code = document.getElementById('code').value;
  const output = document.getElementById('output');

  output.textContent = '';

  try {
    const result = eval(code); // for a toy tester this is fine, but never in real apps
    if (result !== undefined) {
      output.textContent += result + '\n';
    }
  } catch (err) {
    output.textContent = 'Error: ' + err.message;
  }

  console.log('Executed:', code);
}

// hook up the button without inline JS in HTML
document.addEventListener('DOMContentLoaded', () => {
  const runBtn = document.getElementById('runBtn');
  if (runBtn) {
    runBtn.addEventListener('click', runCode);
  }
});
