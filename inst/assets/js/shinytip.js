// Changes the text of a tooltip. Sent by `tip_update()`.
// A tooltip's mode follows from which of the two text attributes exist (see shinytip.css), so
// adding or removing a text is just setting or removing its attribute. A text that is missing
// from the message is left as it is, and one that is `null` is removed.
Shiny.addCustomMessageHandler("shinytip-update", function(msg) {
  var texts = { content: "data-shinytip-label", content_disabled: "data-shinytip-content-disabled" };

  document.querySelectorAll("[data-shinytip-id]").forEach(function(el) {
    if (el.getAttribute("data-shinytip-id") !== msg.id) return;

    var next = {};
    Object.keys(texts).forEach(function(key) {
      next[texts[key]] = key in msg ? msg[key] : el.getAttribute(texts[key]);
    });
    var attrs = Object.keys(next);
    if (attrs.every(function(attr) { return next[attr] === null; })) {
      console.warn("shinytip: a tooltip needs at least one text, so '" + msg.id + "' was not updated");
      return;
    }

    attrs.forEach(function(attr) {
      if (next[attr] === null) el.removeAttribute(attr); else el.setAttribute(attr, next[attr]);
    });
    // A tooltip only keeps its line breaks when balloon.css is told to expect them
    if (attrs.some(function(attr) { return /\n/.test(next[attr] || ""); })) {
      el.setAttribute("data-balloon-break", "");
    } else {
      el.removeAttribute("data-balloon-break");
    }
  });
});
