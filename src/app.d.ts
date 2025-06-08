import 'unplugin-icons/types/svelte'
import { HTMLAttributes } from 'svelte/elements'

// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
  namespace App {
    // interface Error {}
    // interface Locals {}
    // interface PageData {}
    // interface PageState {}
    // interface Platform {}
  }
  type Nullish<T> = T | null | undefined

  type WordElement = HTMLElement & {
    id: number
    head: number
    sentence: number
    form?: string
    lemma?: string
    relation?: string
    pos?: string
    person?: string
    tense?: string
    mood?: string
    voice?: string
    number?: string
    gender?: string
    case?: string
    degree?: string
    children: string
    clear: (() => void)[]
    toggleSmoothBreathing: (boolean) => void
  }
}

declare module 'svelte/elements' {
  export interface SvelteHTMLElement {
    // 'ox-w': {}
    // 'ox-ref': {}
  }

  export interface HTMLAttributes {
    onlemma?: (event: any) => any
  }
}

export { }
