'use strict';

/// Create an overlay with an iframe, the iframe's source is [url]. This also
/// creates an (x) button to hide the overlay.
function run_flutter_app(url) {
  let id = compute_iframe_id(url);
  create_overlay();
  if (!$('#' + id).length) {
    $('#flutter-app-overlay').append($(
      `<iframe id="${id}" class="flutter-app" src="${url}"></iframe>`
    ));
  }
  $('#flutter-app-overlay').addClass('active');
  $('#' + id).addClass('active');
}

function open_code_listings(id) {
  create_overlay();
  if (!$('#flutter-app-overlay #' + id).length) {
    $('#' + id).appendTo($('#flutter-app-overlay'));
  }
  $('#flutter-app-overlay').addClass('active');
  $('#' + id).addClass('active');
}

function create_overlay() {
  if (!$('#flutter-app-overlay').length) {
    $('body').append($(`
      <div id="flutter-app-overlay">
        <button id="flutter-app-close-button" onclick="close_flutter_app()">✖</button>
      </div>`
    ));
  }
}

/// Handler for the (x) close button on an app iframe.
function close_flutter_app() {
  $('#flutter-app-overlay > iframe').removeClass('active');
  $('#flutter-app-overlay > div').removeClass('active');
  $('#flutter-app-overlay').removeClass('active');
}

/// Convert a URL such as '_static/app/tutorial1/index.html?page1' into a string
/// that can be used as an id: 'app-tutorial1-index-html-page1'.
function compute_iframe_id(url) {
  if (url.startsWith('_static/')) {
    url = url.substr(8);
  }
  let matches = url.matchAll(new RegExp('\\w+', 'g'));
  return Array.from(matches, m => m[0]).join('-');
}
