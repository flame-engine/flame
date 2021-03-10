
function initSideNav() {
  var leftNavToggle = document.getElementById('sidenav-left-toggle');
  var leftDrawer = document.querySelector('.sidebar-offcanvas-left');
  var overlay = document.getElementById('overlay-under-drawer');

  function toggleBoth() {
    if (leftDrawer) {
      leftDrawer.classList.toggle('active');
    }

    if (overlay) {
      overlay.classList.toggle('active');
    }
  }

  if (overlay) {
    overlay.addEventListener('click', function(e) {
      toggleBoth();
    });
  }

  if (leftNavToggle) {
    leftNavToggle.addEventListener('click', function(e) {
      toggleBoth();
    });
  }
}

function saveLeftScroll() {
  var leftSidebar = document.getElementById('dartdoc-sidebar-left');
  sessionStorage.setItem('dartdoc-sidebar-left-scrollt' + window.location.pathname, leftSidebar.scrollTop);
  sessionStorage.setItem('dartdoc-sidebar-left-scrolll' + window.location.pathname, leftSidebar.scrollLeft);
}

function saveMainContentScroll() {
  var mainContent = document.getElementById('dartdoc-main-content');
  sessionStorage.setItem('dartdoc-main-content-scrollt' + window.location.pathname, mainContent.scrollTop);
  sessionStorage.setItem('dartdoc-main-content-scrolll' + window.location.pathname, mainContent.scrollLeft);
}

function saveRightScroll() {
  var rightSidebar = document.getElementById('dartdoc-sidebar-right');
  sessionStorage.setItem('dartdoc-sidebar-right-scrollt' + window.location.pathname, rightSidebar.scrollTop);
  sessionStorage.setItem('dartdoc-sidebar-right-scrolll' + window.location.pathname, rightSidebar.scrollLeft);
}

function restoreScrolls() {
  var leftSidebar = document.getElementById('dartdoc-sidebar-left');
  var mainContent = document.getElementById('dartdoc-main-content');
  var rightSidebar = document.getElementById('dartdoc-sidebar-right');

  try {
    var leftSidebarX = sessionStorage.getItem('dartdoc-sidebar-left-scrolll' + window.location.pathname);
    var leftSidebarY = sessionStorage.getItem('dartdoc-sidebar-left-scrollt' + window.location.pathname);

    var mainContentX = sessionStorage.getItem('dartdoc-main-content-scrolll' + window.location.pathname);
    var mainContentY = sessionStorage.getItem('dartdoc-main-content-scrollt' + window.location.pathname);

    var rightSidebarX = sessionStorage.getItem('dartdoc-sidebar-right-scrolll' + window.location.pathname);
    var rightSidebarY = sessionStorage.getItem('dartdoc-sidebar-right-scrollt' + window.location.pathname);

    leftSidebar.scrollTo(leftSidebarX, leftSidebarY);
    mainContent.scrollTo(mainContentX, mainContentY);
    rightSidebar.scrollTo(rightSidebarX, rightSidebarY);
  } finally {
    // Set visibility to visible after scroll to prevent the brief appearance of the
    // panel in the wrong position.
    leftSidebar.style.visibility = 'visible';
    mainContent.style.visibility = 'visible';
    rightSidebar.style.visibility = 'visible';
  }
}

function initScrollSave() {
  var leftSidebar = document.getElementById('dartdoc-sidebar-left');
  var mainContent = document.getElementById('dartdoc-main-content');
  var rightSidebar = document.getElementById('dartdoc-sidebar-right');

  // For portablility, use two different ways of attaching saveLeftScroll to events.
  leftSidebar.onscroll = saveLeftScroll;
  leftSidebar.addEventListener("scroll", saveLeftScroll, true);
  mainContent.onscroll = saveMainContentScroll;
  mainContent.addEventListener("scroll", saveMainContentScroll, true);
  rightSidebar.onscroll = saveRightScroll;
  rightSidebar.addEventListener("scroll", saveRightScroll, true);
}

function initSearch(name) {
  var searchIndex;  // the JSON data

  var weights = {
    'library' : 2,
    'class' : 2,
    'typedef' : 3,
    'method' : 4,
    'accessor' : 4,
    'operator' : 4,
    'property' : 4,
    'constructor' : 4
  };

  var baseHref = '';
  if (!$('body').data('using-base-href')) {
    // If dartdoc did not add a base-href tag, we will need to add the relative
    // path ourselves.
    baseHref = $('body').data('base-href');
  }

  function findMatches(q) {
    var allMatches = []; // list of matches

    function score(element, num) {
      num -= element.overriddenDepth * 10;
      var weightFactor = weights[element.type] || 4;
      return {e: element, score: (num / weightFactor) >> 0};
    }

    $.each(searchIndex, function(i, element) {
      // TODO: prefer matches in the current library
      // TODO: help prefer a named constructor

      var lowerName = element.name.toLowerCase();
      var lowerQualifiedName = element.qualifiedName.toLowerCase();
      var lowerQ = q.toLowerCase();
      var previousMatchCount = allMatches.length;

      if (element.name === q || element.qualifiedName === q) {
        // exact match, maximum score
        allMatches.push(score(element, 2000));
      } else if (element.name === 'dart:'+q) {
        // exact match for a dart: library
        allMatches.push(score(element, 2000));
      } else if (lowerName === 'dart:'+lowerQ) {
        // case-insensitive match for a dart: library
        allMatches.push(score(element, 1800));
      } else if (lowerName === lowerQ || lowerQualifiedName === lowerQ) {
        // case-insensitive exact match
        allMatches.push(score(element, 1700));
      }

      // only care about exact matches if length is 2 or less
      // and only continue if we didn't find a match above
      if (q.length <= 2 || previousMatchCount < allMatches.length) return;

      if (element.name.indexOf(q) === 0 || element.qualifiedName.indexOf(q) === 0) {
        // starts with
        allMatches.push(score(element, 750));
      } else if (lowerName.indexOf(lowerQ) === 0 || lowerQualifiedName.indexOf(lowerQ) === 0) {
        // case-insensitive starts with
        allMatches.push(score(element, 650));
      } else if (element.name.indexOf(q) >= 0 || element.qualifiedName.indexOf(q) >= 0) {
        // contains
        allMatches.push(score(element, 500));
      } else if (lowerName.indexOf(lowerQ) >= 0 || lowerQualifiedName.indexOf(lowerQ) >= 0) {
        // case insensitive contains
        allMatches.push(score(element, 400));
      }
    });

    allMatches.sort(function(a, b) {
      var x = b.score - a.score;
      if (x === 0) {
        // tie-breaker: shorter name wins
        return a.e.name.length - b.e.name.length;
      } else {
        return x;
      }
    });

    var sortedMatches = [];
    for (var i = 0; i < allMatches.length; i++) {
      sortedMatches.push(allMatches[i].e);
    }

    return sortedMatches;
  };

  function initTypeahead() {
    var search = new URI().query(true)["search"];
    if (search) {
      var matches = findMatches(search);
      if (matches.length != 0) {
        window.location = matches[0].href;
        return;
      }
    }

    $('#' + name).prop('disabled', false);
    $('#' + name).prop('placeholder', 'Search API Docs');
    $(document).keypress(function(event) {
      if (event.which == 47 /* / */) {
        event.preventDefault();
        $('#' + name).focus();
      }
    });

    $('#' + name + '.typeahead').typeahead({
      hint: true,
      highlight: true,
      minLength: 1
    },
    {
      name: 'elements',
      limit: 10,
      source: function(q, cb) { cb(findMatches(q)); },
      display: function(element) { return element.name; },
      templates: {
        suggestion: function(match) {
          return [
            '<div data-href="' + match.href + '">',
              match.name,
              ' ',
              match.type.toLowerCase(),
              (match.enclosedBy ? [
              '<div class="search-from-lib">from ',
              match.enclosedBy.name,
              '</div>'].join('') : ''),
            '</div>'
          ].join('');
        }
      }
    });

    var typeaheadElement = $('#' + name + '.typeahead');
    var typeaheadElementParent = typeaheadElement.parent();
    var selectedSuggestion;

    typeaheadElement.on("keydown", function (e) {
      if (e.keyCode === 13) { // Enter
        if (selectedSuggestion == null) {
          var suggestion = typeaheadElementParent.find(".tt-suggestion.tt-selectable:eq(0)");
          if (suggestion.length > 0) {
            var href = suggestion.data("href");
            if (href != null) {
              window.location = baseHref + href;
            }
          }
        }
      }
    });

    typeaheadElement.bind('typeahead:select', function(ev, suggestion) {
        selectedSuggestion = suggestion;
        window.location = baseHref + suggestion.href;
    });
  }

  var jsonReq = new XMLHttpRequest();
  jsonReq.open('GET', baseHref + 'index.json', true);
  jsonReq.addEventListener('load', function() {
    searchIndex = JSON.parse(jsonReq.responseText);
    initTypeahead();
  });
  jsonReq.addEventListener('error', function() {
    $('#' + name).prop('placeholder', 'Error loading search index');
  });
  jsonReq.send();
}

document.addEventListener("DOMContentLoaded", function() {
  // Place this first so that unexpected exceptions in other JavaScript do not block page visibility.
  restoreScrolls();
  hljs.initHighlightingOnLoad();
  initSideNav();
  initScrollSave();
  initSearch("search-box");
  initSearch("search-body");
  initSearch("search-sidebar");
});
