/*
 * Originally from:
 * https://github.com/sphinx-doc/sphinx/blob/2b42752219424cb09ba910b6f654145107e0387b/sphinx/themes/basic/static/doctools.js
 * -----------------------------------------------------------------------------
 * doctools.js
 * ~~~~~~~~~~~
 *
 * Base JavaScript utilities for all Sphinx HTML documentation.
 *
 * :copyright: Copyright 2007-2022 by the Sphinx team, see AUTHORS.
 * :license: BSD, see LICENSE for details.
 * -----------------------------------------------------------------------------
 */
"use strict";

const _ready = (callback) => {
  if (document.readyState !== "loading") {
    callback();
  } else {
    document.addEventListener("DOMContentLoaded", callback);
  }
};

const BLACKLISTED_KEY_CONTROL_ELEMENTS = new Set([
  "TEXTAREA",
  "INPUT",
  "SELECT",
  "BUTTON",
]);

/**
 * highlight a given string on a node by wrapping it in
 * span elements with the given class name.
 */
const _highlightFlame = (node, addItems, text, className, index) => {
  if (node.nodeType === Node.TEXT_NODE) {
    const val = node.nodeValue;
    const parent = node.parentNode;
    const pos = val.toLowerCase().indexOf(text);
    if (
      pos >= 0 &&
      !parent.classList.contains(className) &&
      !parent.classList.contains("nohighlight")
    ) {
      let span;

      const closestNode = parent.closest("body, svg, foreignObject");
      const isInSVG = closestNode && closestNode.matches("svg");
      if (isInSVG) {
        span = document.createElementNS("http://www.w3.org/2000/svg", "tspan");
      } else {
        span = document.createElement("span");
        span.classList.add(className);
        span.classList.add('i' + index);
      }

      span.appendChild(document.createTextNode(val.substr(pos, text.length)));
      parent.insertBefore(
        span,
        parent.insertBefore(
          document.createTextNode(val.substr(pos + text.length)),
          node.nextSibling
        )
      );
      node.nodeValue = val.substr(0, pos);

      if (isInSVG) {
        const rect = document.createElementNS(
          "http://www.w3.org/2000/svg",
          "rect"
        );
        const bbox = parent.getBBox();
        rect.x.baseVal.value = bbox.x;
        rect.y.baseVal.value = bbox.y;
        rect.width.baseVal.value = bbox.width;
        rect.height.baseVal.value = bbox.height;
        rect.setAttribute("class", className);
        addItems.push({ parent: parent, target: rect });
      }
    }
  } else if (node.matches && !node.matches("button, select, textarea")) {
    node.childNodes.forEach((el) => _highlightFlame(el, addItems, text, className, index));
  }
};
const _highlightTextFlame = (thisNode, text, className, index) => {
  let addItems = [];
  _highlightFlame(thisNode, addItems, text, className, index);
  addItems.forEach((obj) =>
    obj.parent.insertAdjacentElement("beforebegin", obj.target)
  );
};

/**
 * Small JavaScript module for the documentation.
 */
const DocumentationFlame = {
  init: () => {
    DocumentationFlame.highlightSearchWords();
    DocumentationFlame.initDomainIndexTable();
    DocumentationFlame.initOnKeyListeners();
  },

  /**
   * i18n support
   */
  TRANSLATIONS: {},
  PLURAL_EXPR: (n) => (n === 1 ? 0 : 1),
  LOCALE: "unknown",

  // gettext and ngettext don't access this so that the functions
  // can safely bound to a different name (_ = DocumentationFlame.gettext)
  gettext: (string) => {
    const translated = DocumentationFlame.TRANSLATIONS[string];
    switch (typeof translated) {
      case "undefined":
        return string; // no translation
      case "string":
        return translated; // translation exists
      default:
        return translated[0]; // (singular, plural) translation tuple exists
    }
  },

  ngettext: (singular, plural, n) => {
    const translated = DocumentationFlame.TRANSLATIONS[singular];
    if (typeof translated !== "undefined")
      return translated[DocumentationFlame.PLURAL_EXPR(n)];
    return n === 1 ? singular : plural;
  },

  addTranslations: (catalog) => {
    Object.assign(DocumentationFlame.TRANSLATIONS, catalog.messages);
    DocumentationFlame.PLURAL_EXPR = new Function(
      "n",
      `return (${catalog.plural_expr})`
    );
    DocumentationFlame.LOCALE = catalog.locale;
  },

  /**
   * highlight the search words provided in the url in the text
   */
  highlightSearchWords: () => {
    const highlight =
      new URLSearchParams(window.location.search).get("highlight") || "";
    const terms = highlight.toLowerCase().split(/\s+/).filter(x => x);
    if (terms.length === 0) return; // nothing to do

    // There should never be more than one element matching "div.body"
    const divBody = document.querySelectorAll("div.body");
    const body = divBody.length ? divBody[0] : document.querySelector("body");
    const hbox = $("#highlight-content");
    window.setTimeout(() => {
      terms.forEach((term, index) => {
        _highlightTextFlame(body, term, "highlighted", index);
        hbox.append($('<span>' + term + '</span>').click(function(){
          $(this).toggleClass("off");
          DocumentationFlame.toggleSearchWord(index);
        }));
      });
    }, 10);

    $("div.highlight-box").show();
    $("div.highlight-box button.close").click(DocumentationFlame.hideSearchWords);
    const searchBox = document.getElementById("searchbox");
    if (searchBox === null) return;
    searchBox.appendChild(
      document
        .createRange()
        .createContextualFragment(
          '<p class="highlight-link">' +
            '<a href="javascript:DocumentationFlame.hideSearchWords()">' +
            DocumentationFlame.gettext("Hide Search Matches") +
            "</a></p>"
        )
    );
  },

  /**
   * helper function to hide the search marks again
   */
  hideSearchWords: () => {
    $("div.highlight-box").fadeOut(300);
    document
      .querySelectorAll("#searchbox .highlight-link")
      .forEach((el) => el.remove());
    document
      .querySelectorAll("span.highlighted")
      .forEach((el) => el.classList.remove("highlighted"));
    const url = new URL(window.location);
    url.searchParams.delete("highlight");
    window.history.replaceState({}, "", url);
  },

  /**
   * helper function to focus on search bar
   */
  focusSearchBar: () => {
    document.querySelectorAll("input[name=q]")[0]?.focus();
  },

  toggleSearchWord : function(i) {
    $('span.highlighted.i' + i).toggleClass('off');
  },

  /**
   * Initialize the domain index toggle buttons
   */
  initDomainIndexTable: () => {
    const toggler = (el) => {
      const idNumber = el.id.substr(7);
      const toggledRows = document.querySelectorAll(`tr.cg-${idNumber}`);
      if (el.src.substr(-9) === "minus.png") {
        el.src = `${el.src.substr(0, el.src.length - 9)}plus.png`;
        toggledRows.forEach((el) => (el.style.display = "none"));
      } else {
        el.src = `${el.src.substr(0, el.src.length - 8)}minus.png`;
        toggledRows.forEach((el) => (el.style.display = ""));
      }
    };

    const togglerElements = document.querySelectorAll("img.toggler");
    togglerElements.forEach((el) =>
      el.addEventListener("click", (event) => toggler(event.currentTarget))
    );
    togglerElements.forEach((el) => (el.style.display = ""));
    if (DOCUMENTATION_OPTIONS.COLLAPSE_INDEX) togglerElements.forEach(toggler);
  },

  initOnKeyListeners: () => {
    // only install a listener if it is really needed
    if (
      !DOCUMENTATION_OPTIONS.NAVIGATION_WITH_KEYS &&
      !DOCUMENTATION_OPTIONS.ENABLE_SEARCH_SHORTCUTS
    )
      return;

    document.addEventListener("keydown", (event) => {
      if (BLACKLISTED_KEY_CONTROL_ELEMENTS.has(document.activeElement.tagName)) return; // bail for input elements
      if (event.altKey || event.ctrlKey || event.metaKey) return; // bail with special keys

      if (!event.shiftKey) {
        switch (event.key) {
          case "ArrowLeft":
            if (!DOCUMENTATION_OPTIONS.NAVIGATION_WITH_KEYS) break;

            const prevLink = document.querySelector('link[rel="prev"]');
            if (prevLink && prevLink.href) {
              window.location.href = prevLink.href;
              event.preventDefault();
            }
            break;
          case "ArrowRight":
            if (!DOCUMENTATION_OPTIONS.NAVIGATION_WITH_KEYS) break;

            const nextLink = document.querySelector('link[rel="next"]');
            if (nextLink && nextLink.href) {
              window.location.href = nextLink.href;
              event.preventDefault();
            }
            break;
          case "Escape":
            if (!DOCUMENTATION_OPTIONS.ENABLE_SEARCH_SHORTCUTS) break;
            DocumentationFlame.hideSearchWords();
            event.preventDefault();
        }
      }

      // some keyboard layouts may need Shift to get /
      switch (event.key) {
        case "/":
          if (!DOCUMENTATION_OPTIONS.ENABLE_SEARCH_SHORTCUTS) break;
          DocumentationFlame.focusSearchBar();
          event.preventDefault();
      }
    });
  },
};

// quick alias for translations
const _ = DocumentationFlame.gettext;

_ready(DocumentationFlame.init);
