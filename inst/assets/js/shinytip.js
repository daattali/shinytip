Shiny.addCustomMessageHandler("shinytip-update", (msg) => {
  document.querySelectorAll("[data-shinytip-id]").forEach((el) => {
    if (el.getAttribute("data-shinytip-id") !== msg.id) return;

    const label = "content" in msg ? msg.content : el.getAttribute("data-shinytip-label");
    const disabled = "content_disabled" in msg
      ? msg.content_disabled : el.getAttribute("data-shinytip-content-disabled");

    if (label === null && disabled === null) {
      console.warn("shinytip: a tooltip needs at least one text, so '" + msg.id + "' was not updated");
      return;
    }

    apply(el, "data-shinytip-label", label);
    apply(el, "data-shinytip-content-disabled", disabled);
    const multiline = /\n/.test(label || "") || /\n/.test(disabled || "");
    apply(el, "data-balloon-break", multiline ? "" : null);
  });

  function apply(el, attr, value) {
    if (value === null) el.removeAttribute(attr); else el.setAttribute(attr, value);
  }
});
