import { CustomElement } from '@vincentcarrier/boreas';
export default class Token extends CustomElement {
    #private;
    static tag: string;
    accessor selected: boolean;
    accessor n: number;
    accessor head: number;
    accessor definition: string;
    accessor lemma: string;
    accessor flags: string;
    accessor role: string;
    accessor pos: string;
    accessor case: string;
    off: {
        [k: string]: () => void;
    };
    static allSelected(): Token[];
    static clearSelected(): void;
    static inView(): Iterable<Token>;
    nearestAnchor(): HTMLAnchorElement | null;
    canonicalRef(): string | null;
    get $head(): Token | null;
    headUp(): Iterable<Token>;
    directDependents(opts?: {
        include?: string[];
        exclude?: string[];
    }): Generator<Token, void, unknown>;
    dependents(opts?: {
        include?: string[];
        exclude?: string[];
    }): Iterable<Token>;
    subtree(role: string): Generator<Token, void, undefined>;
    argument(...roles: string[]): Iterable<Token>;
    constituent(...roles: string[]): Generator<Token, void, unknown>;
    containingPhrase(): Token[];
    verb(): Token | undefined;
    isRole(...roles: string[]): boolean;
    toggleMemorize(show: boolean): void;
    get isVerb(): boolean;
    get morphology(): string;
}
export type TokenSelectInit = CustomEventInit<{
    word: Token;
}>;
