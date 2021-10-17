
// List all published documentation versions here
window.versions = [
    "main",
    "1.0.0-releasecandidate.15",
    "1.0.0-releasecandidate.14",
];

$(function() {  // Will be executed when the DOM finishes loading

// First, detect the doc version of the current page. This can be done by
// looking at the URL, which is supposed to be of the form
// `https://docs.flame-engine.org/${version}/...`. Thus, the first part in the
// path is presumed to be the version.
var this_version = '--';
if (location.host == 'docs.flame-engine.org') {
  var parts = location.pathname.split('/');
  if (parts.length >= 2 && parts[0] == '') {
    this_version = parts[1];
  }
}

var version_buttons = "";
for (var version of window.versions) {
  var classes = "btn btn-secondary topbarbtn";
  if (version == this_version) {
    classes += " selected";
  }
  version_buttons +=
    `<a href="/${version}/index.html"><button class="${classes}">${version}</button></a>`;
}

$('div.topbar-main').append(
  '<div class="dropdown-buttons-trigger" id="versions-menu">' +
    '<button class="btn btn-secondary topbarbtn">' +
      '<span class="tag">version:</span> ' +
      '<span class="version-id">' + this_version + '</span>' +
    '</button>' +
    '<div class="dropdown-buttons">' +
      version_buttons +
    '</div>' +
  '</div>'
);
});
