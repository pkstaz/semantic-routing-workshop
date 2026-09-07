(function () {
  const toggle = document.querySelector("[data-menu-toggle]");
  const nav = document.querySelector("[data-nav]");
  if (toggle && nav) {
    toggle.addEventListener("click", function () {
      const open = nav.classList.toggle("open");
      toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
  }

  function copyText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      const area = document.createElement("textarea");
      area.value = text;
      area.setAttribute("readonly", "");
      area.style.position = "fixed";
      area.style.left = "-9999px";
      document.body.appendChild(area);
      area.select();
      try {
        document.execCommand("copy");
        resolve();
      } catch (err) {
        reject(err);
      } finally {
        area.remove();
      }
    });
  }

  document.querySelectorAll("pre").forEach(function (pre) {
    if (pre.closest(".code-block")) return;
    const wrap = document.createElement("div");
    wrap.className = "code-block";
    pre.parentNode.insertBefore(wrap, pre);
    wrap.appendChild(pre);

    const button = document.createElement("button");
    button.type = "button";
    button.className = "copy-btn";
    button.textContent = "Copy";
    button.setAttribute("aria-label", "Copiar comando");
    wrap.appendChild(button);

    button.addEventListener("click", function () {
      const code = pre.querySelector("code");
      const text = (code ? code.textContent : pre.textContent).replace(/\n$/, "");
      copyText(text).then(function () {
        button.textContent = "Copied";
        button.classList.add("is-copied");
        window.setTimeout(function () {
          button.textContent = "Copy";
          button.classList.remove("is-copied");
        }, 1600);
      });
    });
  });
})();
