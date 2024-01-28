import { CustomElement } from '@vincentcarrier/boreas';
export default class BottomBar extends CustomElement {
    #private;
    static tag: string;
    $lemma: HTMLDivElement;
    $def: HTMLDivElement;
    $flags: HTMLDivElement;
    $lsj: HTMLAnchorElement;
}
