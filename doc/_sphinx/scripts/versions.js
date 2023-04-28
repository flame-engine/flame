
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

// global constant - special versions from the docs
const specialVersions = ['main', 'local'];

// Given a list of versions (as plain strings), return the latest version.
function getLatestVersion(versions) {
  return versions.filter(e => !specialVersions.includes(e))[0];
}

// Given a list of versions (as plain strings), convert them into HTML <A/>
// links, so that they can be placed into the menu.
function convertVersionsToHtmlLinks(versionsList, currentVersion) {
  let out = '';
  const latestVersion = getLatestVersion(versionsList);
  for (let version of versionsList) {
    version = version.trim();
    if (version === '') continue;
    let classes = 'btn btn-secondary topbarbtn';
    if (version === currentVersion) {
      classes += ' selected';
    }
    // Link to the 'latest/` path if it is the latest version.
    if (version === latestVersion) {
      out += `<a href="/latest/">
        <button class="${classes}">
          <i class="fa fa-code-branch"></i> ${version} (latest)
        </button>
      </a>`;
    } else {
      out += `<a href="/${version}/">
        <button class="${classes}">
          <i class="fa fa-code-branch"></i> ${version}
        </button>
      </a>`;
    }
  }
  return out;
}

function maybeAddWarning(versions, currentVersion) {
  const latestVersion = getLatestVersion(versions);
  const nonWarningVersions = [...specialVersions, 'latest', latestVersion];
  const showWarning = !nonWarningVersions.includes(currentVersion);
  if (showWarning) {
    $('#version-warning')
      .find('.version').text(currentVersion).end()
      .removeClass('hidden');
  }
}

function buildVersionsMenu(data) {
  const versions = data.split('\n');
  const currentVersion = getCurrentDocVersion();
  const versionButtons = convertVersionsToHtmlLinks(versions, currentVersion);
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

  maybeAddWarning(versions, currentVersion);
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
