// Apply the tooltip changes sent from the server by `tip_update()`.
//
// Every tooltip option lives as an attribute or CSS property on the element that carries
// the tooltip, and the CSS reads the tooltip text straight out of those attributes. An
// update is therefore nothing more than setting a few attributes: no re-render, no Shiny
// binding, and no need to know whether the tooltip sits on an input, a wrapper we created,
// an icon inside a label, or a plain piece of text.
(function() {
  "use strict";

  if (typeof Shiny === "undefined") {
    return;
  }

  // Tooltips keep their line breaks only when `data-balloon-break` is present. R derives
  // that attribute when building a tooltip, but after a partial update only the browser
  // knows both of the tooltip's texts.
  function syncNewlines(el) {
    var multiline = ["data-shinytip-label", "data-shinytip-content-disabled"].some(
      function(name) {
        var text = el.getAttribute(name);
        return text !== null && text.indexOf("\n") !== -1;
      }
    );
    if (multiline) {
      el.setAttribute("data-balloon-break", "");
    } else {
      el.removeAttribute("data-balloon-break");
    }
  }

  function update(el, msg) {
    Object.keys(msg.attrs || {}).forEach(function(name) {
      if (msg.attrs[name] === null) {
        el.removeAttribute(name);
      } else {
        el.setAttribute(name, msg.attrs[name]);
      }
    });
    // Set the properties one at a time instead of replacing `style` wholesale, so that any
    // styles given when the tooltip was created are left alone
    Object.keys(msg.style || {}).forEach(function(name) {
      if (msg.style[name] === null) {
        el.style.removeProperty(name);
      } else {
        el.style.setProperty(name, msg.style[name]);
      }
    });
    syncNewlines(el);
  }

  Shiny.addCustomMessageHandler("shinytip-update", function(msg) {
    // Matching on the attribute value rather than with an attribute selector, so that an
    // id containing CSS-significant characters needs no escaping
    var tips = Array.prototype.filter.call(
      document.querySelectorAll("[data-shinytip-id]"),
      function(el) { return el.getAttribute("data-shinytip-id") === msg.id; }
    );
    if (tips.length === 0) {
      console.warn("shinytip: no tooltip with id '" + msg.id + "' was found on the page");
      return;
    }
    tips.forEach(function(el) { update(el, msg); });
  });
})();
