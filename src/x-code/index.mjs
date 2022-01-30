import hljs from 'highlight.js';
import elm from 'highlight.js/lib/languages/elm';
import 'highlight.js/styles/hybrid.css';
import './customizations.css';
hljs.registerLanguage('elm', elm);

const toHtml = (code) => {
  const highlightedCode = hljs.highlight('elm', code).value;
  return `<pre><code class="hljs">${highlightedCode}</code></pre>`;
};

customElements.define("x-code", class extends HTMLElement {
  static get observedAttributes() { return ['code']; }

  connectedCallback() {
    this.innerHTML = toHtml(this.getAttribute('code'));
  }
  
  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "code" && oldValue !== newValue) {
      this.innerHTML = toHtml(newValue);
    }
  }
});
