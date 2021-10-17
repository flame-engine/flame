
// List all published documentation versions here
window.versions = [
    "main",
    "1.0.0-releasecandidate.15",
    "1.0.0-releasecandidate.14",
];

$(function() {
var version_buttons = "";
for (var version of window.versions) {
  var classes = "btn btn-secondary topbarbtn";
  if (location.href.includes('/' + version + '/')) {
    classes += " selected";
  }
  version_buttons +=
    `<a href="/${version}/index.html"><button class="${classes}">${version}</button></a>`;
}

$('div.topbar-main').append(
  '<div class="dropdown-buttons-trigger" id="versions-menu">' +
    '<button class="btn btn-secondary topbarbtn">' +
      '<span class="tag">version:</span> <span class="version-id">main</span>' +
    '</button>' +
    '<div class="dropdown-buttons">' +
      version_buttons +
    '</div>' +
  '</div>'
);
});
