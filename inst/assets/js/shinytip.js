// Changes the text of a tooltip. Sent by `tip_update()`.
// A tooltip's mode follows from which of the two text attributes exist (see shinytip.css), so
// adding or removing a text is just setting or removing its attribute. A text that is missing
// from the message is left as it is, and one that is `null` is removed.
Shiny.addCustomMessageHandler("shinytip-update", function(msg) {
  document.querySelectorAll("[data-shinytip-id]").forEach(function(el) {
    if (el.getAttribute("data-shinytip-id") !== msg.id) return;

    // The new value of each text: what the message carries (a string, or null to remove), or
    // the current attribute when the message leaves that text out.
    var label = "content" in msg ? msg.content : el.getAttribute("data-shinytip-label");
    var disabled = "content_disabled" in msg ?
      msg.content_disabled : el.getAttribute("data-shinytip-content-disabled");

    if (label === null && disabled === null) {
      console.warn("shinytip: a tooltip needs at least one text, so '" + msg.id + "' was not updated");
      return;
    }

    apply(el, "data-shinytip-label", label);
    apply(el, "data-shinytip-content-disabled", disabled);
    // A tooltip only keeps its line breaks when balloon.css is told to expect them
    var multiline = /\n/.test(label || "") || /\n/.test(disabled || "");
    apply(el, "data-balloon-break", multiline ? "" : null);
  });

  function apply(el, attr, value) {
    if (value === null) el.removeAttribute(attr); else el.setAttribute(attr, value);
  }
});
