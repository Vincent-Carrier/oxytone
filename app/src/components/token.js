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
import { BaseElement, attr, register } from '@/components/baseElement.js';
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
    let _instanceExtraInitializers = [];
    let _tokenId_decorators;
    let _tokenId_initializers = [];
    let _headId_decorators;
    let _headId_initializers = [];
    let _definition_decorators;
    let _definition_initializers = [];
    let _lemma_decorators;
    let _lemma_initializers = [];
    let _flags_decorators;
    let _flags_initializers = [];
    let _role_decorators;
    let _role_initializers = [];
    let _case_decorators;
    let _case_initializers = [];
    var Token = class extends _classSuper {
        static { _classThis = this; }
        static {
            const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(_classSuper[Symbol.metadata] ?? null) : void 0;
            _tokenId_decorators = [attr(Number)];
            _headId_decorators = [attr(Number)];
            _definition_decorators = [attr()];
            _lemma_decorators = [attr()];
            _flags_decorators = [attr()];
            _role_decorators = [attr()];
            _case_decorators = [attr()];
            __esDecorate(this, null, _tokenId_decorators, { kind: "accessor", name: "tokenId", static: false, private: false, access: { has: obj => "tokenId" in obj, get: obj => obj.tokenId, set: (obj, value) => { obj.tokenId = value; } }, metadata: _metadata }, _tokenId_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _headId_decorators, { kind: "accessor", name: "headId", static: false, private: false, access: { has: obj => "headId" in obj, get: obj => obj.headId, set: (obj, value) => { obj.headId = value; } }, metadata: _metadata }, _headId_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _definition_decorators, { kind: "accessor", name: "definition", static: false, private: false, access: { has: obj => "definition" in obj, get: obj => obj.definition, set: (obj, value) => { obj.definition = value; } }, metadata: _metadata }, _definition_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _lemma_decorators, { kind: "accessor", name: "lemma", static: false, private: false, access: { has: obj => "lemma" in obj, get: obj => obj.lemma, set: (obj, value) => { obj.lemma = value; } }, metadata: _metadata }, _lemma_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _flags_decorators, { kind: "accessor", name: "flags", static: false, private: false, access: { has: obj => "flags" in obj, get: obj => obj.flags, set: (obj, value) => { obj.flags = value; } }, metadata: _metadata }, _flags_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _role_decorators, { kind: "accessor", name: "role", static: false, private: false, access: { has: obj => "role" in obj, get: obj => obj.role, set: (obj, value) => { obj.role = value; } }, metadata: _metadata }, _role_initializers, _instanceExtraInitializers);
            __esDecorate(this, null, _case_decorators, { kind: "accessor", name: "case", static: false, private: false, access: { has: obj => "case" in obj, get: obj => obj.case, set: (obj, value) => { obj.case = value; } }, metadata: _metadata }, _case_initializers, _instanceExtraInitializers);
            __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
            Token = _classThis = _classDescriptor.value;
            if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
            __runInitializers(_classThis, _classExtraInitializers);
        }
        #tokenId_accessor_storage = (__runInitializers(this, _instanceExtraInitializers), __runInitializers(this, _tokenId_initializers, void 0));
        get tokenId() { return this.#tokenId_accessor_storage; }
        set tokenId(value) { this.#tokenId_accessor_storage = value; }
        #headId_accessor_storage = __runInitializers(this, _headId_initializers, void 0);
        get headId() { return this.#headId_accessor_storage; }
        set headId(value) { this.#headId_accessor_storage = value; }
        #definition_accessor_storage = __runInitializers(this, _definition_initializers, void 0);
        get definition() { return this.#definition_accessor_storage; }
        set definition(value) { this.#definition_accessor_storage = value; }
        #lemma_accessor_storage = __runInitializers(this, _lemma_initializers, void 0);
        get lemma() { return this.#lemma_accessor_storage; }
        set lemma(value) { this.#lemma_accessor_storage = value; }
        #flags_accessor_storage = __runInitializers(this, _flags_initializers, void 0);
        get flags() { return this.#flags_accessor_storage; }
        set flags(value) { this.#flags_accessor_storage = value; }
        #role_accessor_storage = __runInitializers(this, _role_initializers, void 0);
        get role() { return this.#role_accessor_storage; }
        set role(value) { this.#role_accessor_storage = value; }
        #case_accessor_storage = __runInitializers(this, _case_initializers, void 0);
        get case() { return this.#case_accessor_storage; }
        set case(value) { this.#case_accessor_storage = value; }
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
                this.head?.classList.add('head');
                if (this.isVerb()) {
                    this.subjOff = highlight(this.argument('SBJ'), 'subj');
                    this.dobjOff = highlight(this.argument('OBJ'), 'dobj');
                }
                this.dependentsOff = highlight(this.dependents(), 'hl');
            }, 100);
        }
        $pointerleave() {
            clearTimeout(timeout);
            this.head?.classList.remove('head');
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