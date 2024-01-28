type Div = HTMLDivElement;
type Dict<V> = Record<string, V>;
export declare function $id<E extends HTMLElement = Div>(id: string): E;
export declare function $<E extends HTMLElement = Div>(selector: string, root?: ParentNode): E;
export declare function $$<E extends HTMLElement = Div>(selector: string, root?: ParentNode): E[];
type Selectable<E extends HTMLElement> = string | E | E[];
export declare function $on<E extends HTMLElement = Div>(selectable: Selectable<E>, listeners: Dict<(ev: UIEvent, $target: E) => void>, root?: ParentNode): void;
export declare function $get<T extends HTMLElement>(El: (new () => T) & {
    selector: string;
}): T;
export declare function $all<T extends HTMLElement>(El: (new () => T) & {
    selector: string;
}): T[];
export declare function $inVerticalView($el: HTMLElement): boolean;
export {};
