export function $id(id) {
    return document.getElementById(id);
}
export function $(selector, root = document) {
    return root.querySelector(selector);
}
export function $$(selector, root = document) {
    return Array.from(root.querySelectorAll(selector));
}
export function $on(els, listeners, root = document) {
    let $els;
    if (els instanceof HTMLElement)
        $els = [els];
    else if (typeof els === 'string')
        $els = $$(els, root);
    else
        $els = els;
    $els.forEach(el => {
        for (const event in listeners) {
            el.addEventListener(event, ev => listeners[event](ev.target));
        }
    });
}
export function $inVerticalView($el) {
    const bounds = $el.getBoundingClientRect();
    return bounds.top >= 0 && bounds.bottom <= window.innerHeight;
}
//# sourceMappingURL=dom.js.map