import './customizations.css';

customElements.define("x-code", class extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `<pre><code class="hljs">${hljs.highlight(this.getAttribute('code'), {language: 'elm'}).value}</code></pre>`;
    hljs.initLineNumbersOnLoad();
  }
  
  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "code" && newValue !== newValue) {
      this.innerHTML = `<pre><code class="hljs">${hljs.highlight(newValue, {language: 'elm'}).value}</code></pre>`;
      hljs.initLineNumbersOnLoad();
    }
  }
});
