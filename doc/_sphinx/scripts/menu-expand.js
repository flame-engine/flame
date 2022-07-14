// Auto expand the first expandable node ("flame") when loaded.
window.addEventListener('load', (_event) => {
    // expand first node when on home page
    expandFirstOnHome();
});

/**
 * This method expands the first expandable node on the home page.
 * 
 * If the current page is not the home page, this method does nothing.
 */
// Two scenarios are possible here:
// 1. docs.flame-engine.org/ host
//  - the pathname for homepage can be /{version}/index.html or /{version}/
// 2. local host
// - the pathname for homepage will end with /html/index.html
function expandFirstOnHome() {
    const parts = location.pathname.split('/');
    const partsLength = parts.length;
    let canExpandFirst = false;
    if (location.host === 'docs.flame-engine.org') {
        if (partsLength == 3 && parts[0] === '' && (parts[2] === '' || parts[2] === 'index.html')) {
            canExpandFirst = true;
        }
    } else {
        // local
        if (parts[partsLength-2] == 'html' && parts[partsLength-1] == 'index.html') {
            canExpandFirst = true;
        }
    }

    if (canExpandFirst) {
        // expand the first expandable node in the toctree
        var menu = document.querySelector(".toctree-l1")
        expand(menu);
    }
}

/**
 * Given a Node, if is expandable, it expands unless it is already expanded.
 * 
 * @param {Node} node 
 */
function expand(node) {
    if (is_expandable(node) && !is_expanded(node)) {
        node.classList.add("current");
    }
}

/**
 * Returns whether or not the given node is an expandable list.
 * 
 * @param {Node} node 
 * @returns {boolean} true if the node is a toctree that can be expanded, false otherwise.
 */
function is_expandable(node) {
    return node.querySelectorAll("li").length > 0
}

/**
 * Returns whether or not the given expandable node is already expanded.
 * Nodes are considered expandaded if they are 'current'ly selected, so we take advantage of this.
 * 
 * @param {Node} node 
 * @returns {boolean} true if the node is already expanded, false otherwise.
 */
function is_expanded(node) {
    return node.classList.contains("current")
}
