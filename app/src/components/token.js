var __esDecorate = (this && this.__esDecorate) || function (ctor, descriptorIn, decorators, contextIn, initializers, extraInitializers) {
    function accept(f) { if (f !== void 0 && typeof f !== "function") throw new TypeError("Function expected"); return f; }
    var kind = contextIn.kind, key = kind === "getter" ? "get" : kind === "setter" ? "set" : "value";
    var target = !descriptorIn && ctor ? contextIn["static"] ? ctor : ctor.prototype : null;
    var descriptor = descriptorIn || (target ? Object.getOwnPropertyDescriptor(target, contextIn.name) : {});
    var _, done = false;
    for (var i = decorators.length - 1; i >= 0; i--) {
        var context = {};
        for (var p in contextIn) context[p] = p === "access" ? {} : contextIn[p];
        for (var p in contextIn.access) context.access[p] = contextIn.access[p];
        context.addInitializer = function (f) { if (done) throw new TypeError("Cannot add initializers after decoration has completed"); extraInitializers.push(accept(f || null)); };
        var result = (0, decorators[i])(kind === "accessor" ? { get: descriptor.get, set: descriptor.set } : descriptor[key], context);
        if (kind === "accessor") {
            if (result === void 0) continue;
            if (result === null || typeof result !== "object") throw new TypeError("Object expected");
            if (_ = accept(result.get)) descriptor.get = _;
            if (_ = accept(result.set)) descriptor.set = _;
            if (_ = accept(result.init)) initializers.unshift(_);
        }
        else if (_ = accept(result)) {
            if (kind === "field") initializers.unshift(_);
            else descriptor[key] = _;
        }
    }
    if (target) Object.defineProperty(target, contextIn.name, descriptor);
    done = true;
};
var __runInitializers = (this && this.__runInitializers) || function (thisArg, initializers, value) {
    var useValue = arguments.length > 2;
    for (var i = 0; i < initializers.length; i++) {
        value = useValue ? initializers[i].call(thisArg, value) : initializers[i].call(thisArg);
    }
    return useValue ? value : void 0;
};
import { BaseElement, register } from '@/components/baseElement.js';
import { $$, $id, $inVerticalView } from '@/lib/dom.js';
import decodeFlags from '@/lib/flags.js';
import { some } from 'lodash-es';
const $export = $id('export'), $selectedCount = $id('selected-count');
let selectedCount = 0, timeout;
let Token = (() => {
    let _classDecorators = [register('w-token')];
    let _classDescriptor;
    let _classExtraInitializers = [];
    let _classThis;
    let _classSuper = BaseElement(HTMLElement);
    var Token = class extends _classSuper {
        static { _classThis = this; }
        static {
            const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(_classSuper[Symbol.metadata] ?? null) : void 0;
            __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
            Token = _classThis = _classDescriptor.value;
            if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
            __runInitializers(_classThis, _classExtraInitializers);
        }
        // @attr(number) tokenId: number
        headId;
        lemma;
        flags;
        def;
        grammarRole;
        case;
        $onmousedown() {
            this.classList.toggle('selected');
            selectedCount = $$('.selected').length;
            $selectedCount.innerText = selectedCount > 0 ? `(${selectedCount})` : '';
            $export.disabled = selectedCount <= 0;
        }
        $onmouseenter() {
            if (this.classList.contains('punct'))
                return;
            // $bottomBar.word = this.attributes
        }
        $pointerenter() {
            timeout = setTimeout(() => {
                const $head = this.head();
                $head?.classList.add('head');
                if (this.isVerb()) {
                    this.subjOff = highlight(this.argument('SBJ'), 'subj');
                    this.dobjOff = highlight(this.argument('OBJ'), 'dobj');
                }
                this.dependentsOff = highlight(this.dependents(), 'hl');
            }, 100);
        }
        $pointerleave() {
            clearTimeout(timeout);
            const $head = this.head;
            $head?.classList.remove('head');
            this.subjOff?.();
            this.dobjOff?.();
            this.dependentsOff?.();
        }
        *wordsInView() {
            let prevInView;
            for (const $w of document.querySelectorAll('w-token')) {
                const inView = $inVerticalView($w);
                if (inView)
                    yield $w;
                if (prevInView && prevInView != inView)
                    break;
                prevInView = inView;
            }
        }
        get head() {
            const $sentence = this.closest('.sentence'), $head = $sentence?.querySelector(`[w-id="${this.headId}"]`);
            return $head ?? null;
        }
        *headUp() {
            const $head = this.head;
            if (!$head)
                return;
            yield $head;
            yield* $head.headUp();
        }
        *directDependents(opts) {
            const $sentence = this.closest('.sentence');
            const $children = $sentence.querySelectorAll(`[head="${this.tokenId}"]`);
            for (const $child of Array.from($children)) {
                if (opts?.exclude && $child.isRole(...opts.exclude))
                    continue;
                if (opts?.include && !$child.isRole(...opts.include))
                    continue;
                yield $child;
            }
        }
        *dependents(opts) {
            for (const $child of this.directDependents()) {
                if (opts?.exclude && $child.isRole(...opts.exclude))
                    continue;
                if (opts?.include && !$child.isRole(...opts.include))
                    continue;
                yield $child;
                yield* $child.dependents();
            }
        }
        verb() {
            for (const $a of this.headUp()) {
                if (this.isVerb)
                    return $a;
            }
        }
        *argument(...roles) {
            for (const $w of this.directDependents()) {
                yield* $w.constituent(...roles);
            }
        }
        *constituent(...roles) {
            if (this.isRole('COORD'))
                yield* this.directDependents({ include: roles });
            else if (this.isRole(...roles))
                yield this;
        }
        isRole(...roles) {
            return some(roles, r => this.role?.startsWith(r));
        }
        toggleMemorize(show) {
            const first = this.innerText[0], rest = this.innerText.slice(1);
            if (show)
                this.innerHTML = this.innerText;
            else
                this.innerHTML = `<span>${first}</span><span style="color: transparent">${rest}</span>`;
        }
        get isVerb() {
            return this.isRole('PRED', 'ATR', 'ADV');
        }
        get morphology() {
            return decodeFlags(this.flags);
        }
    };
    return Token = _classThis;
})();
export { Token };
//# sourceMappingURL=token.js.map