// Auto expand the first expandable node ("flame") when loaded.
window.addEventListener('load', (_event) => {
    expandFirstOnHome();
});

/**
 * This method expands the first expandable node on the home page.
 * 
 * If the current page is not the home page, this method does nothing.
 */
// When the path name ends with index.html or an empty string, it is home page.
function expandFirstOnHome() {
    const parts = location.pathname.split('/');
    const lastPart = parts[parts.length - 1];
    const isHomePage = (lastPart == '') || (lastPart == 'index.html');

    if (isHomePage) {
        // expand the first expandable node in the toctree
        $('li.toctree-l1').has('ul').first().addClass('current');
    }
}
