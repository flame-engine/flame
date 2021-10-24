
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
  return '--';
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
    out += `<a href="/${version}/"><button class="${classes}">${version}</button></a>`;
  }
  return out;
}

function buildVersionsMenu(data) {
  const currentVersion = getCurrentDocVersion();
  const versionButtons = convertVersionsToHtmlLinks(data.split('\n'), currentVersion);
  $('div.topbar-main').append(`
    <div class="dropdown-buttons-trigger" id="versions-menu">
      <button class="btn btn-secondary topbarbtn">
        <span class="tag">version:</span>
        <span class="version-id">${currentVersion}</span>
      </button>
      <div class="dropdown-buttons">${versionButtons}</div>
    </div>
  `);
}

// Start loading the versions list as soon as possible, don't wait for DOM
const versionsRequest = $.get(
    "/versions.txt"
);

// Now wait for DOM to finish loading
$(function() {
  // Lastly, wait for versions to finish loading too.
  versionsRequest.then(buildVersionsMenu);
});
