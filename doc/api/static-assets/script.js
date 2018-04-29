
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

function initSearch() {
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

    $('#search-box').prop('disabled', false);
    $('#search-box').prop('placeholder', 'Search');
    $(document).keypress(function(event) {
      if (event.which == 47 /* / */) {
        event.preventDefault();
        $('#search-box').focus();
      }
    });

    $('#search-box.typeahead').typeahead({
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

    var typeaheadElement = $('#search-box.typeahead');
    var typeaheadElementParent = typeaheadElement.parent();
    var selectedSuggestion;

    typeaheadElement.on("keydown", function (e) {
      if (e.keyCode === 13) { // Enter
        if (selectedSuggestion == null) {
          var suggestion = typeaheadElementParent.find(".tt-suggestion.tt-selectable:eq(0)");
          if (suggestion.length > 0) {
            var href = suggestion.data("href");
            if (href != null) {
              window.location = href;
            }
          }
        }
      }
    });

    typeaheadElement.bind('typeahead:select', function(ev, suggestion) {
        selectedSuggestion = suggestion;
        window.location = suggestion.href;
    });
  }

  var jsonReq = new XMLHttpRequest();
  jsonReq.open('GET', 'index.json', true);
  jsonReq.addEventListener('load', function() {
    searchIndex = JSON.parse(jsonReq.responseText);
    initTypeahead();
  });
  jsonReq.addEventListener('error', function() {
    $('#search-box').prop('placeholder', 'Error loading search index');
  });
  jsonReq.send();
}

document.addEventListener("DOMContentLoaded", function() {
  hljs.initHighlightingOnLoad();
  initSideNav();
  initSearch();
});
