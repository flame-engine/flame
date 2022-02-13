
// Detect the doc version of the current page. This can be done by
// looking at the URL, which is supposed to be of the form
// `https://docs.flame-engine.org/${version}/...`. Thus, the first part in the
// path is presumed to be the version.
function getCurrentDocVersion() {
  if (location.host === 'docs.flame-engine.org') {
    const parts = location.pathname.split('/');
    if (parts.length >= 2 && parts[0] === '') {
      return parts[1];
    }
  }
  return 'local';
}

// Given a list of versions (as plain strings), convert them into HTML <A/>
// links, so that they can be placed into the menu.
function convertVersionsToHtmlLinks(versionsList, currentVersion) {
  let out = '';
  for (let version of versionsList) {
    version = version.trim();
    if (version === '') continue;
    let classes = 'btn btn-secondary topbarbtn';
    if (version === currentVersion) {
      classes += ' selected';
    }
    out += `<a href="/${version}/">
      <button class="${classes}">
        <i class="fa fa-code-branch"></i> ${version}
      </button>
    </a>`;
  }
  return out;
}

function buildVersionsMenu(data) {
  const currentVersion = getCurrentDocVersion();
  const versionButtons = convertVersionsToHtmlLinks(data.split('\n'), currentVersion);
  $('div.versions-placeholder').append(`
    <div id="versions-menu" tabindex="-1">
      <div class="btn">
        <i class="fa fa-code-branch"></i>
        <span class="version-id">${currentVersion}</span>
      </div>
      <div class="dropdown-buttons">
        <div class="header">View documentation for version:</div>
        ${versionButtons}
      </div>
    </div>
  `);
  $("#versions-menu").on("click", function() {
    $(this).toggleClass("active");
  }).on("blur", function() {
    // A timeout ensures that `click` can propagate to child <A/> elements.
    setTimeout(() => $(this).removeClass("active"), 200);
  });
}

// Start loading the versions list as soon as possible, don't wait for DOM
const versionsRequest = $.get(
    "/versions.txt"
);

// Now wait for DOM to finish loading
$(function() {
  // Lastly, wait for versions to finish loading too.
  versionsRequest.then(buildVersionsMenu)
    .fail(function() {
      console.log("Failed to load versions.txt, using default version list");
      buildVersionsMenu("local\nmain\n1.0.0\n");
    });
});
