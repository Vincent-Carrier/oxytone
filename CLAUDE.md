# Oxytone Project Guidelines

## Build/Run Commands
- `pnpm run dev` - Start development server
- `pnpm run build` - Build production bundle
- `pnpm run check` - Run TypeScript checks
- `pnpm run lint` - Run linting and formatting checks
- `pnpm run format` - Format all files with Prettier
- `just seed` - Seed databases (see Justfile for sub-commands)
- `basex -Q path/to/query.xq` - Run BaseX query

## Code Style
- **Formatting**: Use Prettier with tabs, single quotes, 100 char line width
- **TypeScript**: Strict mode enabled, detailed types required
- **Svelte**: Follow Svelte component conventions, use customElement
- **Imports**: Group imports by type (standard lib, external, internal)
- **Naming**: camelCase for variables/functions, PascalCase for components
- **CSS**: Use Tailwind with component-specific stylesheets when needed
- **Error Handling**: Prefer explicit error handling with type checking

## Project Structure
- Backend: Python (FastAPI) + BaseX for XML database operations
- Frontend: Svelte 5 + SvelteKit with TypeScript and Tailwind CSS
  - Individual words are rendered as `ox-w` Custom Elements

Here is what a rendered treebank line might look on the frontend:

```html
<div class="line"><ox-w id="100004224" head="100004219" relation="ATR" sentence="1" lemma="ὄλλυμι" pos="adj." number="sg." gender="fem." case="acc.">οὐλομένην</ox-w><ox-w id="100004225" head="100004241" relation="AuxX" sentence="1" lemma="," pos="punct.">,</ox-w> <ox-w id="100004226" head="100004241" relation="SBJ" sentence="1" lemma="ὅς" pos="pronoun" number="sg." gender="fem." case="nom.">ἣ</ox-w> <ox-w id="100004227" head="100004229" relation="ATR" sentence="1" lemma="μυρίος" pos="adj." number="pl." gender="neut." case="acc.">μυρί’</ox-w><ox-w id="100004228" head="100004230" relation="OBJ" sentence="1" lemma="Ἀχαιός" pos="adj." number="pl." gender="masc." case="dat.">Ἀχαιοῖς</ox-w> <ox-w id="100004229" head="100004230" relation="OBJ" sentence="1" lemma="ἄλγος" pos="noun" number="pl." gender="neut." case="acc.">ἄλγε’</ox-w><ox-w id="100004230" head="100004241" relation="ATR_CO" sentence="1" lemma="τίθημι" pos="verb" person="3rd" number="sg." tense="aor." mood="ind." voice="act.">ἔθηκε</ox-w><ox-w id="100004231" head="100004241" relation="AuxX" sentence="1" lemma="," pos="punct.">,</ox-w></div>
```

What follows is the documentation for Svelte 5 + SvelteKit.

## docs/svelte/01-introduction/01-overview.md

# Svelte 5 Reference

## Overview

Svelte is a compiler-based framework for building web UIs. It turns declarative components into optimized JavaScript.

```svelte
<!file: App.svelte>
<script>
	function greet() {
		alert('Welcome to Svelte!');
	}
</script>

<button onclick={greet}>click me</button>

<style>
	button {
		font-size: 2em;
	}
</style>
```

Components contain HTML, CSS, and JavaScript. Use with SvelteKit for full-stack apps.

## docs/svelte/01-introduction/02-getting-started.md

# Getting started

## Quick start with SvelteKit (recommended)

```bash
npx sv create myapp
cd myapp
npm install
npm run dev
```

## Alternatives

**Vite standalone:**
```bash
npm create vite@latest
# Select 'svelte' option
npm run build # Generates files in dist/
```

**Other build tools:** Rollup, Webpack plugins available but Vite recommended.

## Editor tooling

- VS Code extension available
- Command line checking: `sv check`

## Getting help

- Discord chatroom
- Stack Overflow (svelte tag)

## docs/svelte/01-introduction/03-svelte-files.md

# .svelte files

Components are written in `.svelte` files using a superset of HTML. All sections are optional.

```svelte
<script module>
	// module-level logic (rarely used)
</script>

<script>
	// instance-level logic
</script>

<style>
	/* scoped styles */
</style>
```

## `<script>`

Contains JavaScript/TypeScript (`lang="ts"`) that runs when component instance is created. Top-level variables can be referenced in markup.

Use runes for component props and reactivity.

## `<script module>`

Runs once when module first evaluates, not per component instance. Variables accessible elsewhere in component but not vice versa.

```svelte
<script module>
	let total = 0;
</script>

<script>
	total += 1;
	console.log(`instantiated ${total} times`);
</script>
```

Can `export` bindings (becomes module exports). Cannot `export default` - component is default export.

## `<style>`

CSS scoped to component only.

```svelte
<style>
	p {
		/* only affects <p> elements in this component */
		color: burlywood;
	}
</style>
```

## docs/svelte/01-introduction/04-svelte-js-files.md

# .svelte.js and .svelte.ts files

`.svelte.js` and `.svelte.ts` files behave like regular JS/TS modules but can use runes. Useful for reusable reactive logic and sharing reactive state across your app.

> Note: You cannot export reassigned state.

> New in Svelte 5

## docs/svelte/02-runes/01-what-are-runes.md

# Runes

Runes are symbols with `$` prefix that control the Svelte compiler. They're keywords, not functions.

```js
let message = $state('hello');
```

Key differences from functions:
- No import needed - they're globals
- Not values - can't assign to variables or pass as arguments
- Only valid in specific positions (compiler enforces this)

## docs/svelte/02-runes/02-$state.md

# $state

Creates reactive state that triggers UI updates when changed.

```svelte
<script>
	let count = $state(0);
</script>

<button onclick={() => count++}>
	clicks: {count}
</button>
```

State values are plain JavaScript - no special API needed for updates.

## Deep state

Arrays and objects become deeply reactive proxies:

```js
let todos = $state([
	{
		done: false,
		text: 'add more todos'
	}
]);
```

Granular updates work:
```js
todos[0].done = !todos[0].done; // triggers updates
todos.push({ done: false, text: 'eat lunch' }); // also reactive
```

**Gotcha:** Destructuring breaks reactivity:
```js
let { done, text } = todos[0];
// `done` won't update when todos[0].done changes
```

## Classes

Use `$state` in class fields or constructor assignments:

```js
class Todo {
	done = $state(false);

	constructor(text) {
		this.text = $state(text);
	}

	reset() {
		this.text = '';
		this.done = false;
	}
}
```

**Method binding gotcha:** Use arrow functions or inline functions:
```svelte
<!-- Wrong - `this` will be the button -->
<button onclick={todo.reset}>reset</button>

<!-- Correct options -->
<button onclick={() => todo.reset()}>reset</button>
```

Or use arrow functions in class:
```js
class Todo {
	reset = () => {
		this.text = '';
		this.done = false;
	}
}
```

## $state.raw

Non-reactive state - can only be reassigned, not mutated:

```js
let person = $state.raw({
	name: 'Heraclitus',
	age: 49
});

person.age += 1; // no effect
person = { name: 'Heraclitus', age: 50 }; // works
```

Better performance for large objects you won't mutate.

## $state.snapshot

Get static snapshot of reactive state:

```svelte
<script>
	let counter = $state({ count: 0 });

	function onclick() {
		console.log($state.snapshot(counter)); // logs object, not proxy
	}
</script>
```

Useful for external libraries that don't expect proxies.

## Sharing state across modules

**Can't directly export reassignable state:**
```js
// ❌ Won't work
export let count = $state(0);
```

**Solutions:**

Export object properties:
```js
export const counter = $state({ count: 0 });

export function increment() {
	counter.count += 1;
}
```

Or use getter functions:
```js
let count = $state(0);

export function getCount() {
	return count;
}

export function increment() {
	count += 1;
}
```

## docs/svelte/02-runes/03-$derived.md

# $derived

Derived state is declared with the `$derived` rune:

```svelte
<script>
	let count = $state(0);
	let doubled = $derived(count * 2);
</script>

<button onclick={() => count++}>
	{doubled}
</button>

<p>{count} doubled is {doubled}</p>
```

The expression inside `$derived(...)` should be free of side-effects. Svelte will disallow state changes (e.g. `count++`) inside derived expressions.

Code in Svelte components is only executed once at creation. Without the `$derived` rune, `doubled` would maintain its original value even when `count` changes.

## `$derived.by`

For complex derivations that don't fit inside a short expression, use `$derived.by` which accepts a function:

```svelte
<script>
	let numbers = $state([1, 2, 3]);
	let total = $derived.by(() => {
		let total = 0;
		for (const n of numbers) {
			total += n;
		}
		return total;
	});
</script>

<button onclick={() => numbers.push(numbers.length + 1)}>
	{numbers.join(' + ')} = {total}
</button>
```

`$derived(expression)` is equivalent to `$derived.by(() => expression)`.

## Dependencies

Anything read synchronously inside the `$derived` expression is considered a dependency. When state changes, the derived is marked as dirty and recalculated when next read.

To exempt state from being a dependency, use `untrack`.

## Overriding derived values

You can temporarily override derived values by reassigning them (unless declared with `const`). Useful for optimistic UI:

```svelte
<script>
	let { post, like } = $props();

	let likes = $derived(post.likes);

	async function onclick() {
		// increment the `likes` count immediately...
		likes += 1;

		// and tell the server, which will eventually update `post`
		try {
			await like();
		} catch {
			// failed! roll back the change
			likes -= 1;
		}
	}
</script>

<button {onclick}>🧡 {likes}</button>
```

## Deriveds and reactivity

Unlike `$state`, `$derived` values are left as-is (not converted to deeply reactive proxies):

```svelte
let items = $state([...]);

let index = $state(0);
let selected = $derived(items[index]);
```

You can change properties of `selected` and it will affect the underlying `items` array.

## Update propagation

Svelte uses push-pull reactivity — when state updates, everything that depends on it is immediately notified (push), but derived values aren't re-evaluated until read (pull).

If a derived's new value is referentially identical to its previous value, downstream updates are skipped:

```svelte
<script>
	let count = $state(0);
	let large = $derived(count > 10);
</script>

<button onclick={() => count++}>
	{large}
</button>
```

The button only updates when `large` changes, not when `count` changes.

## docs/svelte/02-runes/04-$effect.md

# $effect

Effects run when state updates. Used for third-party libraries, canvas drawing, network requests. Only run in browser, not SSR.

**Don't update state inside effects** - leads to infinite loops. Use alternatives below.

## Basic Usage

```svelte
<script>
	let size = $state(50);
	let color = $state('#ff3e00');

	let canvas;

	$effect(() => {
		const context = canvas.getContext('2d');
		context.clearRect(0, 0, canvas.width, canvas.height);

		// this will re-run whenever `color` or `size` change
		context.fillStyle = color;
		context.fillRect(0, 0, size, size);
	});
</script>

<canvas bind:this={canvas} width="100" height="100"></canvas>
```

## Lifecycle & Teardown

Effects run after mount in microtasks. Re-runs are batched. Can return teardown function:

```svelte
<script>
	let count = $state(0);
	let milliseconds = $state(1000);

	$effect(() => {
		// This will be recreated whenever `milliseconds` changes
		const interval = setInterval(() => {
			count += 1;
		}, milliseconds);

		return () => {
			// if a teardown function is provided, it will run
			// a) immediately before the effect re-runs
			// b) when the component is destroyed
			clearInterval(interval);
		};
	});
</script>

<h1>{count}</h1>

<button onclick={() => (milliseconds *= 2)}>slower</button>
<button onclick={() => (milliseconds /= 2)}>faster</button>
```

## Dependencies

Auto-tracks reactive values read **synchronously**. Async reads (after `await`, `setTimeout`) not tracked:

```ts
$effect(() => {
	const context = canvas.getContext('2d');
	context.clearRect(0, 0, canvas.width, canvas.height);

	// this will re-run whenever `color` changes...
	context.fillStyle = color;

	setTimeout(() => {
		// ...but not when `size` changes
		context.fillRect(0, 0, size, size);
	}, 0);
});
```

**Object vs property tracking:**

```svelte
<script>
	let state = $state({ value: 0 });
	let derived = $derived({ value: state.value * 2 });

	// this will run once, because `state` is never reassigned (only mutated)
	$effect(() => {
		state;
	});

	// this will run whenever `state.value` changes...
	$effect(() => {
		state.value;
	});

	// ...and so will this, because `derived` is a new object each time
	$effect(() => {
		derived;
	});
</script>

<button onclick={() => (state.value += 1)}>
	{state.value}
</button>

<p>{state.value} doubled is {derived.value}</p>
```

**Conditional dependencies:** Only tracks values read in last run.

## $effect.pre

Runs **before** DOM updates:

```svelte
<script>
	import { tick } from 'svelte';

	let div = $state();
	let messages = $state([]);

	// ...

	$effect.pre(() => {
		if (!div) return; // not yet mounted

		// reference `messages` array length so that this code re-runs whenever it changes
		messages.length;

		// autoscroll when new messages are added
		if (div.offsetHeight + div.scrollTop > div.scrollHeight - 20) {
			tick().then(() => {
				div.scrollTo(0, div.scrollHeight);
			});
		}
	});
</script>

<div bind:this={div}>
	{#each messages as message}
		<p>{message}</p>
	{/each}
</div>
```

## $effect.tracking

Returns if code runs in tracking context:

```svelte
<script>
	console.log('in component setup:', $effect.tracking()); // false

	$effect(() => {
		console.log('in effect:', $effect.tracking()); // true
	});
</script>

<p>in template: {$effect.tracking()}</p>
```

## $effect.root

Creates non-tracked scope with manual cleanup:

```js
const destroy = $effect.root(() => {
	$effect(() => {
		// setup
	});

	return () => {
		// cleanup
	};
});

// later...
destroy();
```

## When NOT to use $effect

**❌ Don't sync state:**

```svelte
<script>
	let count = $state(0);
	let doubled = $state();

	// don't do this!
	$effect(() => {
		doubled = count * 2;
	});
</script>
```

**✅ Use $derived:**

```svelte
<script>
	let count = $state(0);
	let doubled = $derived(count * 2);
</script>
```

**❌ Don't link values with effects:**

```svelte
<script>
	const total = 100;
	let spent = $state(0);
	let left = $state(total);

	$effect(() => {
		left = total - spent;
	});

	$effect(() => {
		spent = total - left;
	});
</script>
```

**✅ Use derived + callbacks:**

```svelte
<script>
	const total = 100;
	let spent = $state(0);
	let left = $derived(total - spent);

function updateLeft(left) {
		spent = total - left;
	}
</script>

<label>
	<input type="range" bind:value={spent} max={total} />
	{spent}/{total} spent
</label>

<label>
	<input type="range"bind:value={() => left, updateLeft}max={total} />
	{left}/{total} left
</label>
```

Use `untrack()` if you must read/write same state in effect to avoid loops.

## docs/svelte/02-runes/05-$props.md

# $props

Pass props to components like attributes:

```svelte
<!file: App.svelte>
<script>
	import MyComponent from './MyComponent.svelte';
</script>

<MyComponent adjective="cool" />
```

Receive props with `$props` rune:

```svelte
<!file: MyComponent.svelte>
<script>
	let props = $props();
</script>

<p>this component is {props.adjective}</p>
```

More commonly, destructure props:

```svelte
<!file: MyComponent.svelte>
<script>
	let{ adjective }= $props();
</script>

<p>this component is {adjective}</p>
```

## Fallback values

```js
let { adjective = 'happy' } = $props();
```

> Fallback values are not turned into reactive state proxies

## Renaming props

```js
let { super: trouper = 'lights are gonna find me' } = $props();
```

## Rest props

```js
let { a, b, c, ...others } = $props();
```

## Updating props

Props update when parent changes. Child can temporarily override prop values:

```svelte
<!file: App.svelte>
<script>
	import Child from './Child.svelte';

	let count = $state(0);
</script>

<button onclick={() => (count += 1)}>
	clicks (parent): {count}
</button>

<Child {count} />
```

```svelte
<!file: Child.svelte>
<script>
	let { count } = $props();
</script>

<button onclick={() => (count += 1)}>
	clicks (child): {count}
</button>
```

**Don't mutate props** unless they are `$bindable`. Mutating regular objects has no effect. Mutating reactive state proxies causes `ownership_invalid_mutation` warning.

## Type safety

TypeScript:
```svelte
<script lang="ts">
	let { adjective }: { adjective: string } = $props();
</script>
```

JSDoc:
```svelte
<script>
	/** @type {{ adjective: string }} */
	let { adjective } = $props();
</script>
```

Interface:
```svelte
<script lang="ts">
	interface Props {
		adjective: string;
	}

	let { adjective }: Props = $props();
</script>
```

## `$props.id()`

Generates unique ID per component instance, consistent between server/client:

```svelte
<script>
	const uid = $props.id();
</script>

<form>
	<label for="{uid}-firstname">First Name: </label>
	<input id="{uid}-firstname" type="text" />

	<label for="{uid}-lastname">Last Name: </label>
	<input id="{uid}-lastname" type="text" />
</form>
```

## docs/svelte/02-runes/06-$bindable.md

# $bindable

Props normally flow one-way from parent to child. `$bindable` allows two-way data flow and state mutation in the child component.

## Basic Usage

Mark a prop as bindable with `$bindable()`:

```svelte
/// file: FancyInput.svelte
<script>
	let { value = $bindable(), ...props } = $props();
</script>

<input bind:value={value} {...props} />

<style>
	input {
		font-family: 'Comic Sans MS';
		color: deeppink;
	}
</style>
```

Parent can bind to it with `bind:`:

```svelte
/// file: App.svelte
<script>
	import FancyInput from './FancyInput.svelte';

	let message = $state('hello');
</script>

<FancyInput bind:value={message} />
<p>{message}</p>
```

## Fallback Values

Provide fallback when no prop is passed:

```js
/// file: FancyInput.svelte
let { value = $bindable('fallback'), ...props } = $props();
```

**Note:** Parent can still pass normal props without `bind:` - binding is optional.

## docs/svelte/02-runes/07-$inspect.md

# $inspect

> [!NOTE] `$inspect` only works during development. In a production build it becomes a noop.

The `$inspect` rune is equivalent to `console.log` but re-runs when its arguments change. Tracks reactive state deeply.

```svelte
<script>
	let count = $state(0);
	let message = $state('hello');

	$inspect(count, message); // will console.log when `count` or `message` change
</script>

<button onclick={() => count++}>Increment</button>
<input bind:value={message} />
```

## $inspect(...).with

Use custom callback instead of `console.log`. First argument is `"init"` or `"update"`:

```svelte
<script>
	let count = $state(0);

	$inspect(count).with((type, count) => {
		if (type === 'update') {
			debugger; // or `console.trace`, or whatever you want
		}
	});
</script>

<button onclick={() => count++}>Increment</button>
```

Find origin of changes:

```js
// @errors: 2304
$inspect(stuff).with(console.trace);
```

## $inspect.trace(...)

Traces function re-runs in effects/derived. Must be first statement in function body:

```svelte
<script>
	import { doSomeWork } from './elsewhere';

	$effect(() => {
		// $inspect.trace must be the first statement of a function body
		$inspect.trace();
		doSomeWork();
	});
</script>
```

Takes optional label as first argument.

## docs/svelte/02-runes/08-$host.md

# $host

The `$host` rune provides access to the host element when compiling a component as a custom element. Commonly used to dispatch custom events.

```svelte
/// file: Stepper.svelte
<svelte:options customElement="my-stepper" />

<script>
	function dispatch(type) {
		$host().dispatchEvent(new CustomEvent(type));
	}
</script>

<button onclick={() => dispatch('decrement')}>decrement</button>
<button onclick={() => dispatch('increment')}>increment</button>
```

```svelte
/// file: App.svelte
<script>
	import './Stepper.svelte';

	let count = $state(0);
</script>

<my-stepper
	ondecrement={() => count -= 1}
	onincrement={() => count += 1}
></my-stepper>

<p>count: {count}</p>
```

## docs/svelte/03-template-syntax/01-basic-markup.md

# Basic markup

Markup inside Svelte components is HTML++.

## Tags

- Lowercase tags (`<div>`) = HTML elements
- Capitalized/dot notation (`<Widget>`, `<my.stuff>`) = components

```svelte
<script>
	import Widget from './Widget.svelte';
</script>

<div>
	<Widget />
</div>
```

## Element attributes

Work like HTML. Values can contain or be JavaScript expressions:

```svelte
<div class="foo">
	<button disabled>can't touch this</button>
</div>
```

```svelte
<input type=checkbox />
```

```svelte
<a href="page/{p}">page {p}</a>
```

```svelte
<button disabled={!clickable}>...</button>
```

**Attribute rules:**
- Boolean attributes: included if truthy, excluded if falsy
- Other attributes: included unless nullish (`null`/`undefined`)
- Shorthand: `{name}` instead of `name={name}`

```svelte
<input required={false} placeholder="This input field is not required" />
<div title={null}>This div has no title attribute</div>
```

```svelte
<button {disabled}>...</button>
```

## Component props

Same rules as attributes. Use `{name}` shorthand:

```svelte
<Widget foo={bar} answer={42} text="hello" />
```

## Spread attributes

Pass multiple attributes at once. Order matters:

```svelte
<Widget a="b" {...things} c="d" />
```

## Events

Use `on` prefix (case sensitive). No colon syntax in Svelte 5:

```svelte
<button onclick={() => console.log('clicked')}>click me</button>
```

Event attributes support:
- Shorthand: `<button {onclick}>click me</button>`
- Spreading: `<button {...eventAttrs}>click me</button>`

**Event delegation:** These events are delegated for performance:
`beforeinput`, `click`, `change`, `dblclick`, `contextmenu`, `focusin`, `focusout`, `input`, `keydown`, `keyup`, `mousedown`, `mousemove`, `mouseout`, `mouseover`, `mouseup`, `pointerdown`, `pointermove`, `pointerout`, `pointerover`, `pointerup`, `touchend`, `touchmove`, `touchstart`

**Gotchas:**
- Manual events need `{ bubbles: true }`
- Avoid `stopPropagation` with `addEventListener`
- Use `on` from `svelte/events` instead of `addEventListener`

## Text expressions

JavaScript expressions in curly braces. `null`/`undefined` omitted, others stringified:

```svelte
<h1>Hello {name}!</h1>
<p>{a} + {b} = {a + b}.</p>

<div>{(/^[A-Za-z ]+$/).test(value) ? x : y}</div>
```

Render HTML (dangerous):

```svelte
{@html potentiallyUnsafeHtmlString}
```

## Comments

HTML comments work. Use `svelte-ignore` to disable warnings:

```svelte
<h1>Hello world</h1>
```

```svelte

<input bind:value={name} autofocus />
```

Component documentation with `@component`:

````svelte

<script>
	let { name } = $props();
</script>

<main>
	<h1>
		Hello, {name}
	</h1>
</main>
````

## docs/svelte/03-template-syntax/02-if.md

# {#if ...}

Conditionally render content using if blocks.

## Syntax

```svelte
{#if expression}...{/if}
{#if expression}...{:else if expression}...{/if}
{#if expression}...{:else}...{/if}
```

## Examples

Basic conditional:
```svelte
{#if answer === 42}
	<p>what was the question?</p>
{/if}
```

Multiple conditions:
```svelte
{#if porridge.temperature > 100}
	<p>too hot!</p>
{:else if 80 > porridge.temperature}
	<p>too cold!</p>
{:else}
	<p>just right!</p>
{/if}
```

Blocks can wrap elements or text within elements.

## docs/svelte/03-template-syntax/03-each.md

# {#each ...}

## Basic syntax

```svelte
{#each expression as name}...{/each}
{#each expression as name, index}...{/each}
```

Works with arrays, array-like objects (with `length` property), or iterables like `Map` and `Set`.

```svelte
<h1>Shopping list</h1>
<ul>
	{#each items as item}
		<li>{item.name} x {item.qty}</li>
	{/each}
</ul>
```

With index:

```svelte
{#each items as item, i}
	<li>{i + 1}: {item.name} x {item.qty}</li>
{/each}
```

## Keyed each blocks

```svelte
{#each expression as name (key)}...{/each}
{#each expression as name, index (key)}...{/each}
```

Keys enable intelligent updates (insert/move/delete) instead of updating all items. Use strings/numbers for persistent identity.

```svelte
{#each items as item (item.id)}
	<li>{item.name} x {item.qty}</li>
{/each}

{#each items as item, i (item.id)}
	<li>{i + 1}: {item.name} x {item.qty}</li>
{/each}
```

## Destructuring

```svelte
{#each items as { id, name, qty }, i (id)}
	<li>{i + 1}: {name} x {qty}</li>
{/each}

{#each objects as { id, ...rest }}
	<li><span>{id}</span><MyComponent {...rest} /></li>
{/each}

{#each items as [id, ...rest]}
	<li><span>{id}</span><MyComponent values={rest} /></li>
{/each}
```

## Without item variable

```svelte
{#each expression}...{/each}
{#each expression, index}...{/each}
```

For rendering something `n` times:

```svelte
<div class="chess-board">
	{#each { length: 8 }, rank}
		{#each { length: 8 }, file}
			<div class:black={(rank + file) % 2 === 1}></div>
		{/each}
	{/each}
</div>
```

## Else blocks

```svelte
{#each expression as name}...{:else}...{/each}
```

Renders when list is empty:

```svelte
{#each todos as todo}
	<p>{todo.text}</p>
{:else}
	<p>No tasks today!</p>
{/each}
```

## docs/svelte/03-template-syntax/04-key.md

# {#key ...}

```svelte
{#key expression}...{/key}
```

Destroys and recreates contents when expression changes.

**Component reinstantiation:**
```svelte
{#key value}
	<Component />
{/key}
```

**Trigger transitions on value change:**
```svelte
{#key value}
	<div transition:fade>{value}</div>
{/key}
```

## docs/svelte/03-template-syntax/05-await.md

# {#await ...}

Await blocks handle Promise states: pending, fulfilled, rejected.

## Syntax

```svelte
{#await expression}...{:then name}...{:catch name}...{/await}
{#await expression}...{:then name}...{/await}
{#await expression then name}...{/await}
{#await expression catch name}...{/await}
```

## Basic Usage

```svelte
{#await promise}
	<p>waiting for the promise to resolve...</p>
{:then value}
	<p>The value is {value}</p>
{:catch error}
	<p>Something went wrong: {error.message}</p>
{/await}
```

## Shortened Forms

Omit catch block:
```svelte
{#await promise}
	<p>waiting for the promise to resolve...</p>
{:then value}
	<p>The value is {value}</p>
{/await}
```

Omit pending state:
```svelte
{#await promise then value}
	<p>The value is {value}</p>
{/await}
```

Error only:
```svelte
{#await promise catch error}
	<p>The error is {error}</p>
{/await}
```

## Lazy Component Loading

```svelte
{#await import('./Component.svelte') then { default: Component }}
	<Component />
{/await}
```

## Important Notes

- SSR only renders pending branch
- Non-Promise expressions only render `:then` branch
- Catch block is optional if no error handling needed

## docs/svelte/03-template-syntax/06-snippet.md

# {#snippet ...}

Create reusable chunks of markup inside components.

## Syntax

```svelte
{#snippet name()}...{/snippet}
```

```svelte
{#snippet name(param1, param2, paramN)}...{/snippet}
```

## Basic Usage

Instead of duplicating markup:

```svelte
{#each images as image}
	{#if image.href}
		<a href={image.href}>
			<figure>
				<img src={image.src} alt={image.caption} width={image.width} height={image.height} />
				<figcaption>{image.caption}</figcaption>
			</figure>
		</a>
	{:else}
		<figure>
			<img src={image.src} alt={image.caption} width={image.width} height={image.height} />
			<figcaption>{image.caption}</figcaption>
		</figure>
	{/if}
{/each}
```

Use snippets:

```svelte
{#snippet figure(image)}
	<figure>
		<img src={image.src} alt={image.caption} width={image.width} height={image.height} />
		<figcaption>{image.caption}</figcaption>
	</figure>
{/snippet}

{#each images as image}
	{#if image.href}
		<a href={image.href}>
			{@render figure(image)}
		</a>
	{:else}
		{@render figure(image)}
	{/if}
{/each}
```

## Snippet Scope

Snippets can reference values from `<script>` or blocks:

```svelte
<script>
	let { message = `it's great to see you!` } = $props();
</script>

{#snippet hello(name)}
	<p>hello {name}! {message}!</p>
{/snippet}

{@render hello('alice')}
{@render hello('bob')}
```

Snippets can reference themselves and each other:

```svelte
{#snippet blastoff()}
	<span>🚀</span>
{/snippet}

{#snippet countdown(n)}
	{#if n > 0}
		<span>{n}...</span>
		{@render countdown(n - 1)}
	{:else}
		{@render blastoff()}
	{/if}
{/snippet}

{@render countdown(10)}
```

## Passing Snippets to Components

### Explicit Props

```svelte
<script>
	import Table from './Table.svelte';

	const fruits = [
		{ name: 'apples', qty: 5, price: 2 },
		{ name: 'bananas', qty: 10, price: 1 },
		{ name: 'cherries', qty: 20, price: 0.5 }
	];
</script>

{#snippet header()}
	<th>fruit</th>
	<th>qty</th>
	<th>price</th>
	<th>total</th>
{/snippet}

{#snippet row(d)}
	<td>{d.name}</td>
	<td>{d.qty}</td>
	<td>{d.price}</td>
	<td>{d.qty * d.price}</td>
{/snippet}

<Table data={fruits} {header} {row} />
```

### Implicit Props

Snippets declared inside a component become props:

```svelte
<Table data={fruits}>
	{#snippet header()}
		<th>fruit</th>
		<th>qty</th>
		<th>price</th>
		<th>total</th>
	{/snippet}

	{#snippet row(d)}
		<td>{d.name}</td>
		<td>{d.qty}</td>
		<td>{d.price}</td>
		<td>{d.qty * d.price}</td>
	{/snippet}
</Table>
```

### Implicit `children` Snippet

Content inside component tags becomes the `children` snippet:

```svelte
<!file: App.svelte>
<Button>click me</Button>
```

```svelte
<!file: Button.svelte>
<script>
	let { children } = $props();
</script>

<button>{@render children()}</button>
```

### Optional Snippets

Use optional chaining:

```svelte
<script>
    let { children } = $props();
</script>

{@render children?.()}
```

Or `#if` with fallback:

```svelte
<script>
    let { children } = $props();
</script>

{#if children}
    {@render children()}
{:else}
    fallback content
{/if}
```

## TypeScript

Use the `Snippet` interface:

```svelte
<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		data: any[];
		children: Snippet;
		row: Snippet<[any]>;
	}

	let { data, children, row }: Props = $props();
</script>
```

With generics:

```svelte
<script lang="ts" generics="T">
	import type { Snippet } from 'svelte';

	let {
		data,
		children,
		row
	}: {
		data: T[];
		children: Snippet;
		row: Snippet<[T]>;
	} = $props();
</script>
```

## Exporting Snippets

Export from `<script module>` (Svelte 5.5.0+):

```svelte
<script module>
	export { add };
</script>

{#snippet add(a, b)}
	{a} + {b} = {a + b}
{/snippet}
```

## Notes

- Parameters can have default values and be destructured
- No rest parameters allowed
- Snippets replace deprecated slots from Svelte 4
- Use `createRawSnippet` API for programmatic creation

## docs/svelte/03-template-syntax/07-@render.md

# {@render ...}

Render [snippets](snippet) using `{@render ...}` tags.

```svelte
{#snippet sum(a, b)}
	<p>{a} + {b} = {a + b}</p>
{/snippet}

{@render sum(1, 2)}
{@render sum(3, 4)}
{@render sum(5, 6)}
```

Expression can be identifier or JavaScript expression:

```svelte
{@render (cool ? coolSnippet : lameSnippet)()}
```

## Optional snippets

Use optional chaining for potentially undefined snippets:

```svelte
{@render children?.()}
```

Or `{#if}` with fallback:

```svelte
{#if children}
	{@render children()}
{:else}
	<p>fallback content</p>
{/if}
```

## docs/svelte/03-template-syntax/08-@html.md

# {@html ...}

Inject raw HTML into components:

```svelte
<article>
	{@html content}
</article>
```

**Security**: Always escape or control content to prevent XSS attacks. Never render unsanitized content.

**Requirements**:
- Expression must be valid standalone HTML
- Cannot split HTML tags across multiple `{@html}` blocks
- Does not compile Svelte code

## Styling

`{@html}` content is invisible to Svelte scoped styles. Use `:global` modifier:

```svelte
<style>
	article :global(a) { color: hotpink }
	article :global(img) { width: 100% }
</style>
```

## docs/svelte/03-template-syntax/09-@attach.md

# {@attach ...}

Attachments are functions that run in an effect when an element mounts or when state updates. They can return a cleanup function.

```svelte
<script>
	/** @type {import('svelte/attachments').Attachment} */
	function myAttachment(element) {
		console.log(element.nodeName); // 'DIV'

		return () => {
			console.log('cleaning up');
		};
	}
</script>

<div {@attach myAttachment}>...</div>
```

## Attachment factories

Functions can return attachments for reusability:

```svelte
<script>
	import tippy from 'tippy.js';

	let content = $state('Hello!');

	/**
	 * @param {string} content
	 * @returns {import('svelte/attachments').Attachment}
	 */
	function tooltip(content) {
		return (element) => {
			const tooltip = tippy(element, { content });
			return tooltip.destroy;
		};
	}
</script>

<input bind:value={content} />

<button {@attach tooltip(content)}>
	Hover me
</button>
```

Attachments recreate when dependencies change.

## Inline attachments

```svelte
<canvas
	width={32}
	height={32}
	{@attach (canvas) => {
		const context = canvas.getContext('2d');

		$effect(() => {
			context.fillStyle = color;
			context.fillRect(0, 0, canvas.width, canvas.height);
		});
	}}
></canvas>
```

## Component attachments

Attachments on components become props that spread to elements:

```svelte
<!file: Button.svelte>
<script>
	/** @type {import('svelte/elements').HTMLButtonAttributes} */
	let { children, ...props } = $props();
</script>

<button {...props}>
	{@render children?.()}
</button>
```

```svelte
<!file: App.svelte>
<script>
	import tippy from 'tippy.js';
	import Button from './Button.svelte';

	let content = $state('Hello!');

	/**
	 * @param {string} content
	 * @returns {import('svelte/attachments').Attachment}
	 */
	function tooltip(content) {
		return (element) => {
			const tooltip = tippy(element, { content });
			return tooltip.destroy;
		};
	}
</script>

<input bind:value={content} />

<Button {@attach tooltip(content)}>
	Hover me
</Button>
```

## Controlling re-runs

Attachments are fully reactive. To prevent expensive re-runs, pass data in a function:

```js
function foo(getBar) {
	return (node) => {
		veryExpensiveSetupWork(node);

		$effect(() => {
			update(node, getBar());
		});
	}
}
```

## Utilities

- `createAttachmentKey` - Add attachments to objects programmatically
- `fromAction` - Convert actions to attachments

## docs/svelte/03-template-syntax/10-@const.md

# {@const ...}

The `{@const ...}` tag defines a local constant within blocks.

```svelte
{#each boxes as box}
	{@const area = box.width * box.height}
	{box.width} * {box.height} = {area}
{/each}
```

**Usage**: Only allowed as immediate child of blocks (`{#if}`, `{#each}`, `{#snippet}`), components (`<Component />`), or `<svelte:boundary>`.

## docs/svelte/03-template-syntax/11-@debug.md

# {@debug ...}

The `{@debug ...}` tag logs variable values when they change and pauses execution if devtools are open.

```svelte
<script>
	let user = {
		firstname: 'Ada',
		lastname: 'Lovelace'
	};
</script>

{@debug user}

<h1>Hello {user.firstname}!</h1>
```

**Usage patterns:**
- Single variable: `{@debug user}`
- Multiple variables: `{@debug user1, user2, user3}`
- No arguments: `{@debug}` - triggers on any state change

**Important:** Only accepts variable names, not arbitrary expressions like `{@debug !isReady}` or `{@debug typeof user === 'object'}`.

## docs/svelte/03-template-syntax/12-bind.md

# bind:

Data flows down by default. `bind:` allows data to flow from child to parent.

Syntax: `bind:property={expression}` or `bind:property` (shorthand when names match)

```svelte
<input bind:value={value} />
<input bind:value />
```

Most bindings are two-way. Some are readonly.

## Function bindings

Use `bind:property={get, set}` for validation/transformation:

```svelte
<input bind:value={
	() => value,
	(v) => value = v.toLowerCase()}
/>
```

For readonly bindings, set `get` to `null`:

```svelte
<div
	bind:clientWidth={null, redraw}
	bind:clientHeight={null, redraw}
>...</div>
```

## Input bindings

### `bind:value`

```svelte
<script>
	let message = $state('hello');
</script>

<input bind:value={message} />
<p>{message}</p>
```

Numeric inputs coerce to numbers:

```svelte
<script>
	let a = $state(1);
	let b = $state(2);
</script>

<label>
	<input type="number" bind:value={a} min="0" max="10" />
	<input type="range" bind:value={a} min="0" max="10" />
</label>

<label>
	<input type="number" bind:value={b} min="0" max="10" />
	<input type="range" bind:value={b} min="0" max="10" />
</label>

<p>{a} + {b} = {a + b}</p>
```

Empty/invalid numeric inputs return `undefined`.

### `bind:checked`

```svelte
<label>
	<input type="checkbox" bind:checked={accepted} />
	Accept terms and conditions
</label>
```

### `bind:indeterminate`

```svelte
<script>
	let checked = $state(false);
	let indeterminate = $state(true);
</script>

<form>
	<input type="checkbox" bind:checked bind:indeterminate>

	{#if indeterminate}
		waiting...
	{:else if checked}
		checked
	{:else}
		unchecked
	{/if}
</form>
```

### `bind:group`

For radio buttons and checkbox groups:

```svelte
<script>
	let tortilla = $state('Plain');

	/** @type {string[]} */
	let fillings = $state([]);
</script>


<label><input type="radio" bind:group={tortilla} value="Plain" /> Plain</label>
<label><input type="radio" bind:group={tortilla} value="Whole wheat" /> Whole wheat</label>
<label><input type="radio" bind:group={tortilla} value="Spinach" /> Spinach</label>


<label><input type="checkbox" bind:group={fillings} value="Rice" /> Rice</label>
<label><input type="checkbox" bind:group={fillings} value="Beans" /> Beans</label>
<label><input type="checkbox" bind:group={fillings} value="Cheese" /> Cheese</label>
<label><input type="checkbox" bind:group={fillings} value="Guac (extra)" /> Guac (extra)</label>
```

### `bind:files`

```svelte
<script>
	let files = $state();

	function clear() {
		files = new DataTransfer().files; // null or undefined does not work
	}
</script>

<label for="avatar">Upload a picture:</label>
<input accept="image/png, image/jpeg" bind:files id="avatar" name="avatar" type="file" />
<button onclick={clear}>clear</button>
```

## Select bindings

Single select:
```svelte
<select bind:value={selected}>
	<option value={a}>a</option>
	<option value={b}>b</option>
	<option value={c}>c</option>
</select>
```

Multiple select:
```svelte
<select multiple bind:value={fillings}>
	<option>Rice</option>
	<option>Beans</option>
	<option>Cheese</option>
	<option>Guac (extra)</option>
</select>
```

## Media bindings

### `<audio>`
Two-way: `currentTime`, `playbackRate`, `paused`, `volume`, `muted`
Readonly: `duration`, `buffered`, `seekable`, `seeking`, `ended`, `readyState`, `played`

```svelte
<audio src={clip} bind:duration bind:currentTime bind:paused></audio>
```

### `<video>`
Same as audio plus readonly `videoWidth`, `videoHeight`

### `<img>`
Readonly: `naturalWidth`, `naturalHeight`

## Other bindings

### `<details>`
```svelte
<details bind:open={isOpen}>
	<summary>How do you comfort a JavaScript bug?</summary>
	<p>You console it.</p>
</details>
```

### Contenteditable
Bindings: `innerHTML`, `innerText`, `textContent`

```svelte
<div contenteditable="true" bind:innerHTML={html}></div>
```

### Dimensions (readonly)
`clientWidth`, `clientHeight`, `offsetWidth`, `offsetHeight`, `contentRect`, `contentBoxSize`, `borderBoxSize`, `devicePixelContentBoxSize`

```svelte
<div bind:offsetWidth={width} bind:offsetHeight={height}>
	<Chart {width} {height} />
</div>
```

### `bind:this`
Get DOM node reference:

```svelte
<script>
	/** @type {HTMLCanvasElement} */
	let canvas;

	$effect(() => {
		const ctx = canvas.getContext('2d');
		drawStuff(ctx);
	});
</script>

<canvas bind:this={canvas}></canvas>
```

## Component bindings

Bind to component props using `$bindable()`:

```svelte
<Keypad bind:value={pin} />
```

Component must mark property as bindable:

```svelte
<script>
	let { readonlyProperty, bindableProperty = $bindable() } = $props();
</script>
```

With fallback value:

```svelte
<script>
	let { bindableProperty = $bindable('fallback value') } = $props();
</script>
```

## docs/svelte/03-template-syntax/13-use.md

# use:

> [!NOTE]
> In Svelte 5.29+, consider using [attachments](@attach) instead - more flexible and composable.

Actions are functions called when an element is mounted. Use `use:` directive with `$effect` for cleanup:

```svelte
<!file: App.svelte>
<script>
	/** @type {import('svelte/action').Action} */
	function myaction(node) {
		// node mounted in DOM

		$effect(() => {
			// setup goes here

			return () => {
				// teardown goes here
			};
		});
	}
</script>

<div use:myaction>...</div>
```

## With Arguments

```svelte
<!file: App.svelte>
<script>
	/** @type {import('svelte/action').Action} */
	function myaction(node,data) {
		// ...
	}
</script>

<div use:myaction={data}>...</div>
```

**Key:** Action called once only (not on SSR). Won't re-run if argument changes.

## Typing

`Action` interface: `Action<NodeType, Parameter, CustomEvents>`

```svelte
<!file: App.svelte>
<script>
	/**
	 * @type {import('svelte/action').Action<
	 * 	HTMLDivElement,
	 * 	undefined,
	 * 	{
	 * 		onswiperight: (e: CustomEvent) => void;
	 * 		onswipeleft: (e: CustomEvent) => void;
	 * 		// ...
	 * 	}
	 * >}
	 */
	function gestures(node) {
		$effect(() => {
			// ...
			node.dispatchEvent(new CustomEvent('swipeleft'));

			// ...
			node.dispatchEvent(new CustomEvent('swiperight'));
		});
	}
</script>

<div
	use:gestures
	onswipeleft={next}
	onswiperight={prev}
>...</div>
```

## docs/svelte/03-template-syntax/14-transition.md

# transition:

Transitions trigger when elements enter/leave DOM due to state changes. All elements in a transitioning block stay in DOM until all transitions complete.

`transition:` creates bidirectional transitions that can reverse smoothly.

```svelte
<script>
	import { fade } from 'svelte/transition';

	let visible = $state(false);
</script>

<button onclick={() => visible = !visible}>toggle</button>

{#if visible}
	<divtransition:fade>fades in and out</div>
{/if}
```

## Local vs Global

Local (default): only play when their block is created/destroyed
Global: play when any parent block changes

```svelte
{#if x}
	{#if y}
		<p transition:fade>fades in and out only when y changes</p>

		<p transition:fade|global>fades in and out when x or y change</p>
	{/if}
{/if}
```

## Built-in Transitions

Import from `svelte/transition` module.

## Parameters

```svelte
{#if visible}
	<div transition:fade={{ duration: 2000 }}>fades in and out over two seconds</div>
{/if}
```

## Custom Functions

```js
transition = (node: HTMLElement, params: any, options: { direction: 'in' | 'out' | 'both' }) => {
	delay?: number,
	duration?: number,
	easing?: (t: number) => number,
	css?: (t: number, u: number) => string,
	tick?: (t: number, u: number) => void
}
```

`t`: 0-1 after easing (1 = natural state)
`u`: 1-t

### CSS-based (preferred - runs off main thread):

```svelte
<!file: App.svelte>
<script>
	import { elasticOut } from 'svelte/easing';

	/** @type {boolean} */
	export let visible;

	/**
	 * @param {HTMLElement} node
	 * @param {{ delay?: number, duration?: number, easing?: (t: number) => number }} params
	 */
	function whoosh(node, params) {
		const existingTransform = getComputedStyle(node).transform.replace('none', '');

		return {
			delay: params.delay || 0,
			duration: params.duration || 400,
			easing: params.easing || elasticOut,
			css: (t, u) => `transform: ${existingTransform} scale(${t})`
		};
	}
</script>

{#if visible}
	<div in:whoosh>whooshes in</div>
{/if}
```

### Tick-based:

```svelte
<!file: App.svelte>
<script>
	export let visible = false;

	/**
	 * @param {HTMLElement} node
	 * @param {{ speed?: number }} params
	 */
	function typewriter(node, { speed = 1 }) {
		const valid = node.childNodes.length === 1 && node.childNodes[0].nodeType === Node.TEXT_NODE;

		if (!valid) {
			throw new Error(`This transition only works on elements with a single text node child`);
		}

		const text = node.textContent;
		const duration = text.length / (speed * 0.01);

		return {
			duration,
			tick: (t) => {
				const i = ~~(text.length * t);
				node.textContent = text.slice(0, i);
			}
		};
	}
</script>

{#if visible}
	<p in:typewriter={{ speed: 1 }}>The quick brown fox jumps over the lazy dog</p>
{/if}
```

## Events

Elements dispatch transition events:
- `introstart`
- `introend`
- `outrostart`
- `outroend`

```svelte
{#if visible}
	<p
		transition:fly={{ y: 200, duration: 2000 }}
		onintrostart={() => (status = 'intro started')}
		onoutrostart={() => (status = 'outro started')}
		onintroend={() => (status = 'intro ended')}
		onoutroend={() => (status = 'outro ended')}
	>
		Flies in and out
	</p>
{/if}
```

## docs/svelte/03-template-syntax/15-in-and-out.md

# in: and out:

The `in:` and `out:` directives work like [`transition:`](transition) but are unidirectional. Unlike bidirectional transitions, `in` transitions don't reverse when interrupted - they continue playing alongside `out` transitions.

```svelte
<script>
  import { fade, fly } from 'svelte/transition';

  let visible = $state(false);
</script>

<label>
  <input type="checkbox" bind:checked={visible}>
  visible
</label>

{#if visible}
	<div in:fly={{ y: 200 }} out:fade>flies in, fades out</div>
{/if}
```

**Key difference**: If an out transition is aborted, transitions restart from scratch rather than reversing.

## docs/svelte/03-template-syntax/16-animate.md

# animate:

Animations trigger when keyed each block contents are re-ordered. Only runs when existing item index changes, not on add/remove. Must be on immediate child of keyed each block.

```svelte
{#each list as item, index (item)}
	<li animate:flip>{item}</li>
{/each}
```

## Animation Parameters

```svelte
{#each list as item, index (item)}
	<li animate:flip={{ delay: 500 }}>{item}</li>
{/each}
```

## Custom Animation Functions

```js
animation = (node: HTMLElement, { from: DOMRect, to: DOMRect } , params: any) => {
	delay?: number,
	duration?: number,
	easing?: (t: number) => number,
	css?: (t: number, u: number) => string,
	tick?: (t: number, u: number) => void
}
```

Function receives `node`, `animation` object with `from`/`to` DOMRect properties, and `parameters`. `from` is starting position, `to` is final position after reorder.

If returned object has `css` method, Svelte creates web animation. `t` goes from 0 to 1 after easing, `u` equals `1 - t`.

```svelte
<script>
	import { cubicOut } from 'svelte/easing';

	/**
	 * @param {HTMLElement} node
	 * @param {{ from: DOMRect; to: DOMRect }} states
	 * @param {any} params
	 */
	function whizz(node, { from, to }, params) {
		const dx = from.left - to.left;
		const dy = from.top - to.top;

		const d = Math.sqrt(dx * dx + dy * dy);

		return {
			delay: 0,
			duration: Math.sqrt(d) * 120,
			easing: cubicOut,
			css: (t, u) => `transform: translate(${u * dx}px, ${u * dy}px) rotate(${t * 360}deg);`
		};
	}
</script>

{#each list as item, index (item)}
	<div animate:whizz>{item}</div>
{/each}
```

Can also return `tick` function called during animation with same `t`/`u` arguments.

> Use `css` over `tick` when possible - web animations run off main thread, preventing jank.

```svelte
<script>
	import { cubicOut } from 'svelte/easing';

	/**
	 * @param {HTMLElement} node
	 * @param {{ from: DOMRect; to: DOMRect }} states
	 * @param {any} params
	 */
	function whizz(node, { from, to }, params) {
		const dx = from.left - to.left;
		const dy = from.top - to.top;

		const d = Math.sqrt(dx * dx + dy * dy);

		return {
			delay: 0,
			duration: Math.sqrt(d) * 120,
			easing: cubicOut,
			tick: (t, u) => Object.assign(node.style, { color: t > 0.5 ? 'Pink' : 'Blue' })
		};
	}
</script>

{#each list as item, index (item)}
	<div animate:whizz>{item}</div>
{/each}
```

## docs/svelte/03-template-syntax/17-style.md

# style:

The `style:` directive provides shorthand for setting multiple styles on an element.

## Basic Usage

```svelte
<div style:color="red">...</div>
<div style="color: red;">...</div>
```

## Dynamic Values

```svelte
<div style:color={myColor}>...</div>
```

## Shorthand Form

```svelte
<div style:color>...</div>
```

## Multiple Styles

```svelte
<div style:color style:width="12rem" style:background-color={darkMode ? 'black' : 'white'}>...</div>
```

## Important Modifier

```svelte
<div style:color|important="red">...</div>
```

## Precedence

`style:` directives take precedence over `style` attributes:

```svelte
<div style="color: blue;" style:color="red">This will be red</div>
```

## docs/svelte/03-template-syntax/18-class.md

# class

Two ways to set classes: `class` attribute and `class:` directive.

## Attributes

Basic usage:
```svelte
<div class={large ? 'large' : 'small'}>...</div>
```

> Falsy values stringify (`class="false"`), except `undefined`/`null` which omit the attribute.

### Objects and arrays

Since Svelte 5.16, `class` accepts objects/arrays using [clsx](https://github.com/lukeed/clsx).

**Objects** - truthy keys are added:
```svelte
<script>
	let { cool } = $props();
</script>

<div class={{ cool, lame: !cool }}>...</div>
```

**Arrays** - truthy values combined:
```svelte
<div class={[faded && 'saturate-0 opacity-50', large && 'scale-200']}>...</div>
```

**Nested arrays/objects** for combining local classes with props:
```svelte
<!file: Button.svelte>
<script>
	let props = $props();
</script>

<button {...props} class={['cool-button', props.class]}>
	{@render props.children?.()}
</button>
```

Usage:
```svelte
<!file: App.svelte>
<script>
	import Button from './Button.svelte';
	let useTailwind = $state(false);
</script>

<Button
	onclick={() => useTailwind = true}
	class={{ 'bg-blue-700 sm:w-1/2': useTailwind }}
>
	Accept the inevitability of Tailwind
</Button>
```

**TypeScript** - use `ClassValue` type:
```svelte
<script lang="ts">
	import type { ClassValue } from 'svelte/elements';

	const props: { class: ClassValue } = $props();
</script>

<div class={['original', props.class]}>...</div>
```

## The `class:` directive

Legacy conditional class setting:
```svelte
<div class={{ cool, lame: !cool }}>...</div>
<div class:cool={cool} class:lame={!cool}>...</div>
```

Shorthand when class name matches value:
```svelte
<div class:cool class:lame={!cool}>...</div>
```

> Consider using `class` attribute instead - more powerful and composable.

## docs/svelte/04-styling/01-scoped-styles.md

# Scoped styles

Svelte components include `<style>` elements with CSS scoped by default using hashed classes (e.g. `svelte-123xyz`).

```svelte
<style>
	p {
		/* this will only affect <p> elements in this component */
		color: burlywood;
	}
</style>
```

## Specificity

Scoped selectors get +0-1-0 specificity from the scoping class, so component styles override global styles even if global stylesheet loads later.

Multiple scoping classes use `:where(.svelte-xyz123)` to avoid further specificity increases.

## Scoped keyframes

`@keyframes` names are scoped to components. Animation rules adjust automatically:

```svelte
<style>
	.bouncy {
		animation: bounce 10s;
	}

	/* these keyframes are only accessible inside this component */
	@keyframes bounce {
		/* ... */
	}
</style>
```

## docs/svelte/04-styling/02-global-styles.md

# Global styles

## :global(...)

Apply styles to a single selector globally:

```svelte
<style>
	:global(body) {
		/* applies to <body> */
		margin: 0;
	}

	div :global(strong) {
		/* applies to all <strong> elements, in any component,
		   that are inside <div> elements belonging
		   to this component */
		color: goldenrod;
	}

	p:global(.big.red) {
		/* applies to all <p> elements belonging to this component
		   with `class="big red"`, even if it is applied
		   programmatically (for example by a library) */
	}
</style>
```

For global keyframes, prepend with `-global-`:

```svelte
<style>
	@keyframes -global-my-animation-name {
		/* code goes here */
	}
</style>
```

## :global

Apply styles to multiple selectors globally using blocks:

```svelte
<style>
	:global {
		/* applies to every <div> in your application */
		div { ... }

		/* applies to every <p> in your application */
		p { ... }
	}

	.a :global {
		/* applies to every `.b .c .d` element, in any component,
		   that is inside an `.a` element in this component */
		.b .c .d {...}
	}
</style>
```

## docs/svelte/04-styling/03-custom-properties.md

# Custom Properties

Pass CSS custom properties (static and dynamic) to components:

```svelte
<Slider
	bind:value
	min={0}
	max={100}
	--track-color="black"
	--thumb-color="rgb({r} {g} {b})"
/>
```

This desugars to a wrapper element:

```svelte
<svelte-css-wrapper style="display: contents; --track-color: black; --thumb-color: rgb({r} {g} {b})">
	<Slider
		bind:value
		min={0}
		max={100}
	/>
</svelte-css-wrapper>
```

For SVG elements, uses `<g>`:

```svelte
<g style="--track-color: black; --thumb-color: rgb({r} {g} {b})">
	<Slider
		bind:value
		min={0}
		max={100}
	/>
</g>
```

Inside components, use `var()` with fallbacks:

```svelte
<style>
	.track {
		background: var(--track-color, #aaa);
	}

	.thumb {
		background: var(--thumb-color, blue);
	}
</style>
```

Custom properties inherit from parent elements. Define on `:root` for global access.

> **Note:** Wrapper element won't affect layout but may affect CSS selectors using `>` combinator.

## docs/svelte/04-styling/04-nested-style-elements.md

# Nested `<style>` elements

Only one top-level `<style>` tag allowed per component.

`<style>` tags nested inside elements/logic blocks are inserted as-is into DOM with no scoping or processing.

```svelte
<div>
	<style>
		/* this style tag will be inserted as-is */
		div {
			/* this will apply to all `<div>` elements in the DOM */
			color: red;
		}
	</style>
</div>
```

## docs/svelte/05-special-elements/01-svelte-boundary.md

# `<svelte:boundary>`

```svelte
<svelte:boundary onerror={handler}>...</svelte:boundary>
```

Guards against errors in part of your app from breaking the whole app. Catches errors during rendering/updating children and `$effect` functions.

**Does NOT catch**: Event handlers, `setTimeout`, async work outside rendering.

## Properties

### `failed`

Renders when error occurs. Receives `error` and `reset` function:

```svelte
<svelte:boundary>
	<FlakyComponent />

	{#snippet failed(error, reset)}
		<button onclick={reset}>oops! try again</button>
	{/snippet}
</svelte:boundary>
```

Can be passed explicitly: `<svelte:boundary {failed}>...</svelte:boundary>`

### `onerror`

Called with `error` and `reset` arguments. Useful for error reporting:

```svelte
<svelte:boundary onerror={(e) => report(e)}>
	...
</svelte:boundary>
```

Or managing error state externally:

```svelte
<script>
	let error = $state(null);
	let reset = $state(() => {});

	function onerror(e, r) {
		error = e;
		reset = r;
	}
</script>

<svelte:boundary {onerror}>
	<FlakyComponent />
</svelte:boundary>

{#if error}
	<button onclick={() => {
		error = null;
		reset();
	}}>
		oops! try again
	</button>
{/if}
```

Errors in `onerror` bubble to parent boundary if it exists.

## docs/svelte/05-special-elements/02-svelte-window.md

# `<svelte:window>`

```svelte
<svelte:window onevent={handler} />
<svelte:window bind:prop={value} />
```

Adds event listeners to `window` object. Auto-removes on component destroy. SSR-safe.

Must be at component top level, not inside blocks/elements.

## Event Listeners

```svelte
<script>
	function handleKeydown(event) {
		alert(`pressed the ${event.key} key`);
	}
</script>

<svelte:window onkeydown={handleKeydown} />
```

## Bindable Properties

```svelte
<svelte:window bind:scrollY={y} />
```

**Readonly:** `innerWidth`, `innerHeight`, `outerWidth`, `outerHeight`, `online`, `devicePixelRatio`

**Writable:** `scrollX`, `scrollY`

> **Note:** Page won't scroll to initial bound values. Only subsequent changes trigger scrolling. Use `scrollTo()` in `$effect` if needed.

## docs/svelte/05-special-elements/03-svelte-document.md

# `<svelte:document>`

Adds event listeners and actions to the `document` object. Must be at component top level, never inside blocks or elements.

## Syntax

```svelte
<svelte:document onevent={handler} />
<svelte:document bind:prop={value} />
```

## Usage

```svelte
<svelte:document onvisibilitychange={handleVisibilityChange} use:someAction />
```

## Bindable Properties (readonly)

- `activeElement`
- `fullscreenElement`
- `pointerLockElement`
- `visibilityState`

## docs/svelte/05-special-elements/04-svelte-body.md

# `<svelte:body>`

```svelte
<svelte:body onevent={handler} />
```

Adds event listeners to `document.body` for events that don't fire on `window` (like `mouseenter`/`mouseleave`). Also allows [actions](use) on `<body>`.

**Requirements:**
- Must be at top level of component
- Cannot be inside blocks or elements

```svelte
<svelte:body onmouseenter={handleMouseenter} onmouseleave={handleMouseleave} use:someAction />
```

## docs/svelte/05-special-elements/05-svelte-head.md

# `<svelte:head>`

Inserts elements into `document.head`. Must be at component top level, never inside blocks or elements.

```svelte
<svelte:head>
	<title>Hello world!</title>
	<meta name="description" content="This is where the description goes for SEO" />
</svelte:head>
```

During SSR, head content is exposed separately from body content.

## docs/svelte/05-special-elements/06-svelte-element.md

# `<svelte:element>`

```svelte
<svelte:element this={expression} />
```

Renders dynamic elements unknown at author time (e.g., from CMS).

## Basic Usage

```svelte
<script>
	let tag = $state('hr');
</script>

<svelte:element this={tag}>
	This text cannot appear inside an hr element
</svelte:element>
```

## Key Points

- Properties and event listeners are applied to the element
- Only `bind:this` binding supported
- If `this` is nullish, element and children won't render
- Void elements (br, hr) with children throw runtime error in dev
- `this` must be valid DOM element tag

## Namespace Control

```svelte
<svelte:element this={tag} xmlns="http://www.w3.org/2000/svg" />
```

Use `xmlns` when Svelte can't infer correct namespace.

## docs/svelte/05-special-elements/07-svelte-options.md

# `<svelte:options>`

```svelte
<svelte:options option={value} />
```

Specifies per-component compiler options.

## Options

- `runes={true}` — forces runes mode
- `runes={false}` — forces legacy mode
- `namespace="..."` — "html" (default), "svg", or "mathml"
- `customElement={...}` — custom element options, or string for tag name
- `css="injected"` — injects styles inline (`<style>` tag in SSR, JS in client)

```svelte
<svelte:options customElement="my-custom-element" />
```

## docs/svelte/06-runtime/01-stores.md

# Stores

A store is an object that allows reactive access to a value via a simple store contract. Access store values in components by prefixing with `$`.

```svelte
<script>
	import { writable } from 'svelte/store';

	const count = writable(0);
	console.log($count); // logs 0

	count.set(1);
	console.log($count); // logs 1

	$count = 2;
	console.log($count); // logs 2
</script>
```

**Rules:**
- Store must be declared at component top level
- Local variables must NOT have `$` prefix
- `$`-prefixed assignments require writable store

## When to use stores

With Svelte 5 runes, stores are less needed:

**Use runes instead for:**
- Extracting logic - use runes in `.svelte.js/.svelte.ts` files
- Shared state - create `$state` objects

```ts
/// file: state.svelte.js
export const userState = $state({
	name: 'name',
	/* ... */
});
```

```svelte
<!file: App.svelte>
<script>
	import { userState } from './state.svelte.js';
</script>

<p>User name: {userState.name}</p>
<button onclick={() => {
	userState.name = 'new name';
}}>
	change name
</button>
```

**Still use stores for:**
- Complex asynchronous data streams
- Manual control over updates/listeners
- RxJs compatibility

## svelte/store

### `writable`

Creates store with `set` and `update` methods.

```js
/// file: store.js
import { writable } from 'svelte/store';

const count = writable(0);

count.subscribe((value) => {
	console.log(value);
}); // logs '0'

count.set(1); // logs '1'

count.update((n) => n + 1); // logs '2'
```

Optional second argument - function called when subscribers go from 0→1, must return stop function:

```js
/// file: store.js
import { writable } from 'svelte/store';

const count = writable(0, () => {
	console.log('got a subscriber');
	return () => console.log('no more subscribers');
});

count.set(1); // does nothing

const unsubscribe = count.subscribe((value) => {
	console.log(value);
}); // logs 'got a subscriber', then '1'

unsubscribe(); // logs 'no more subscribers'
```

### `readable`

Creates read-only store. Same API as `writable` but no external `set` method.

```ts
import { readable } from 'svelte/store';

const time = readable(new Date(), (set) => {
	set(new Date());

	const interval = setInterval(() => {
		set(new Date());
	}, 1000);

	return () => clearInterval(interval);
});

const ticktock = readable('tick', (set, update) => {
	const interval = setInterval(() => {
		update((sound) => (sound === 'tick' ? 'tock' : 'tick'));
	}, 1000);

	return () => clearInterval(interval);
});
```

### `derived`

Derives store from other stores. Callback runs on first subscription and when dependencies change.

```ts
import { derived } from 'svelte/store';

const doubled = derived(a, ($a) => $a * 2);
```

Async with `set`/`update` and optional initial value:

```ts
import { derived } from 'svelte/store';

const delayed = derived(
	a,
	($a, set) => {
		setTimeout(() => set($a), 1000);
	},
	2000
);

const delayedIncrement = derived(a, ($a, set, update) => {
	set($a);
	setTimeout(() => update((x) => x + 1), 1000);
	// every time $a produces a value, this produces two
	// values, $a immediately and then $a + 1 a second later
});
```

Return cleanup function:

```ts
import { derived } from 'svelte/store';

const tick = derived(
	frequency,
	($frequency, set) => {
		const interval = setInterval(() => {
			set(Date.now());
		}, 1000 / $frequency);

		return () => {
			clearInterval(interval);
		};
	},
	2000
);
```

Multiple stores:

```ts
import { derived } from 'svelte/store';

const summed = derived([a, b], ([$a, $b]) => $a + $b);

const delayed = derived([a, b], ([$a, $b], set) => {
	setTimeout(() => set($a + $b), 1000);
});
```

### `readonly`

Makes store read-only:

```js
import { readonly, writable } from 'svelte/store';

const writableStore = writable(1);
const readableStore = readonly(writableStore);

readableStore.subscribe(console.log);

writableStore.set(2); // console: 2
// @errors: 2339
readableStore.set(2); // ERROR
```

### `get`

Retrieve store value without subscription (avoid in hot code paths):

```ts
import { get } from 'svelte/store';

const value = get(store);
```

## Store contract

```ts
store = { subscribe: (subscription: (value: any) => void) => (() => void), set?: (value: any) => void }
```

Custom stores must implement:

1. `.subscribe(fn)` - immediately calls `fn` with current value, returns unsubscribe function
2. Unsubscribe function stops subscription
3. Optional `.set(value)` for writable stores - synchronously calls all subscribers

Compatible with RxJS Observables (`.subscribe` can return object with `.unsubscribe` method).

## docs/svelte/06-runtime/02-context.md

# Context

Context allows components to access values from parent components without prop-drilling.

## Basic Usage

Parent sets context with `setContext(key, value)`:

```svelte
<!file: Parent.svelte>
<script>
	import { setContext } from 'svelte';

	setContext('my-context', 'hello from Parent.svelte');
</script>
```

Child retrieves with `getContext`:

```svelte
<!file: Child.svelte>
<script>
	import { getContext } from 'svelte';

	const message = getContext('my-context');
</script>

<h1>{message}, inside Child.svelte</h1>
```

Works with children snippets:

```svelte
<Parent>
	<Child />
</Parent>
```

Key and value can be any JavaScript value.

Available functions: `setContext`, `getContext`, `hasContext`, `getAllContexts`.

## Using Context with State

Store reactive state in context:

```svelte
<script>
	import { setContext } from 'svelte';
	import Child from './Child.svelte';

	let counter = $state({
		count: 0
	});

	setContext('counter', counter);
</script>

<button onclick={() => counter.count += 1}>
	increment
</button>

<Child />
<Child />
<Child />
```

**Important**: Update properties, don't reassign objects:

```svelte
<!-- ❌ Breaks the link -->
<button onclick={() => counter = { count: 0 }}>
	reset
</button>

<!-- ✅ Correct -->
<button onclick={() =>counter.count = 0}>
	reset
</button>
```

## Type-safe Context

Wrap context calls in helper functions:

```js
/// file: context.js
// @filename: ambient.d.ts
interface User {}

// @filename: index.js
//cut
import { getContext, setContext } from 'svelte';

const key = {};

/** @param {User} user */
export function setUserContext(user) {
	setContext(key, user);
}

export function getUserContext() {
	return /** @type {User} */ (getContext(key));
}
```

## Replacing Global State

Avoid global state modules in SSR:

```js
/// file: state.svelte.js
export const myGlobalState = $state({
	user: {
		// ...
	}
	// ...
});
```

This can leak data between SSR requests:

```svelte
<!file: App.svelte->
<script>
	import { myGlobalState } from './state.svelte.js';

	let { data } = $props();

	if (data.user) {
		myGlobalState.user = data.user;
	}
</script>
```

Context solves this by being request-scoped.

## docs/svelte/06-runtime/03-lifecycle-hooks.md

# Lifecycle hooks

Svelte 5 lifecycle has only creation and destruction. No "before/after update" hooks - effects handle granular state changes instead.

## `onMount`

Runs after component mounts to DOM. Must be called during component initialization. Doesn't run on server.

```svelte
<script>
	import { onMount } from 'svelte';

	onMount(() => {
		console.log('the component has mounted');
	});
</script>
```

Return function for cleanup on unmount:

```svelte
<script>
	import { onMount } from 'svelte';

	onMount(() => {
		const interval = setInterval(() => {
			console.log('beep');
		}, 1000);

		return () => clearInterval(interval);
	});
</script>
```

**Note:** Only works with synchronous return. Async functions return Promise, can't synchronously return cleanup function.

## `onDestroy`

Runs before component unmounts. Only lifecycle hook that runs server-side.

```svelte
<script>
	import { onDestroy } from 'svelte';

	onDestroy(() => {
		console.log('the component is being destroyed');
	});
</script>
```

## `tick`

Promise that resolves after pending state changes apply. Use instead of "after update" hook.

```svelte
<script>
	import { tick } from 'svelte';

	$effect.pre(() => {
		console.log('the component is about to update');
		tick().then(() => {
				console.log('the component just updated');
		});
	});
</script>
```

## Migration from Svelte 4

**Deprecated:** `beforeUpdate` / `afterUpdate` - use `$effect.pre` / `$effect` instead for granular control.

**Example:** Chat autoscroll - `$effect.pre` only runs when `messages` changes, not on every update:

```svelte
<script>
	import {beforeUpdate, afterUpdate,tick } from 'svelte';

	let updatingMessages = false;
	let theme =$state('dark');
	let messages =$state([]);

	let viewport;

	beforeUpdate(() => {
	$effect.pre(() => {
		if (!updatingMessages) return;
		messages;
		const autoscroll = viewport && viewport.offsetHeight + viewport.scrollTop > viewport.scrollHeight - 50;

		if (autoscroll) {
			tick().then(() => {
				viewport.scrollTo(0, viewport.scrollHeight);
			});
		}

		updatingMessages = false;
	});

	function handleKeydown(event) {
		if (event.key === 'Enter') {
			const text = event.target.value;
			if (!text) return;

			updatingMessages = true;
			messages = [...messages, text];
			event.target.value = '';
		}
	}

	function toggle() {
		theme = theme === 'dark' ? 'light' : 'dark';
	}
</script>

<div class:dark={theme === 'dark'}>
	<div bind:this={viewport}>
		{#each messages as message}
			<p>{message}</p>
		{/each}
	</div>

	<inputonkeydown={handleKeydown} />

	<buttononclick={toggle}> Toggle dark mode </button>
</div>
```

## docs/svelte/06-runtime/04-imperative-component-api.md

# Imperative component API

Functions for creating and managing Svelte components imperatively.

## `mount`

Creates and mounts a component to a DOM element:

```js
// @errors: 2322
import { mount } from 'svelte';
import App from './App.svelte';

const app = mount(App, {
	target: document.querySelector('#app'),
	props: { some: 'property' }
});
```

**Note:** Effects (including `onMount` callbacks) don't run during `mount`. Use `flushSync()` to force pending effects to run.

## `unmount`

Removes a mounted component:

```js
import { mount, unmount } from 'svelte';
import App from './App.svelte';

const app = mount(App, { target: document.body });

// later
unmount(app, { outro: true });
```

Returns a `Promise` if `options.outro` is true (waits for transitions).

## `render`

Server-only function that renders component to HTML:

```js
// @errors: 2724 2305 2307
import { render } from 'svelte/server';
import App from './App.svelte';

const result = render(App, {
	props: { some: 'property' }
});
result.body; // HTML for somewhere in this <body> tag
result.head; // HTML for somewhere in this <head> tag
```

## `hydrate`

Makes server-rendered HTML interactive:

```js
// @errors: 2322
import { hydrate } from 'svelte';
import App from './App.svelte';

const app = hydrate(App, {
	target: document.querySelector('#app'),
	props: { some: 'property' }
});
```

**Note:** Like `mount`, effects don't run during `hydrate`. Use `flushSync()` if needed.

## docs/svelte/07-misc/02-testing.md

# Testing

Testing frameworks help you write unit tests, integration tests, and end-to-end tests. Svelte works with [Vitest](https://vitest.dev/), [Jasmine](https://jasmine.github.io/), [Cypress](https://www.cypress.io/) and [Playwright](https://playwright.dev/).

## Unit and integration testing using Vitest

Install Vitest:

```bash
npm install -D vitest
```

Configure `vite.config.js`:

```js
/// file: vite.config.js
import { defineConfig } from'vitest/config';

export default defineConfig({
	// Tell Vitest to use the `browser` entry points in `package.json` files, even though it's running in Node
	resolve: process.env.VITEST
		? {
				conditions: ['browser']
			}
		: undefined
});
```

### Testing runes

Test `.js/.ts` files with runes:

```js
/// file: multiplier.svelte.test.js
import { flushSync } from 'svelte';
import { expect, test } from 'vitest';
import { multiplier } from './multiplier.svelte.js';

test('Multiplier', () => {
	let double = multiplier(0, 2);

	expect(double.value).toEqual(0);

	double.set(5);

	expect(double.value).toEqual(10);
});
```

```js
/// file: multiplier.svelte.js
/**
 * @param {number} initial
 * @param {number} k
 */
export function multiplier(initial, k) {
	let count = $state(initial);

	return {
		get value() {
			return count * k;
		},
		/** @param {number} c */
		set: (c) => {
			count = c;
		}
	};
}
```

### Using runes in test files

Use runes in test files with `.svelte` extension:

```js
/// file: multiplier.svelte.test.js
import { flushSync } from 'svelte';
import { expect, test } from 'vitest';
import { multiplier } from './multiplier.svelte.js';

test('Multiplier', () => {
	let count = $state(0);
	let double = multiplier(() => count, 2);

	expect(double.value).toEqual(0);

	count = 5;

	expect(double.value).toEqual(10);
});
```

### Testing effects

Wrap tests with effects in `$effect.root`:

```js
/// file: logger.svelte.test.js
import { flushSync } from 'svelte';
import { expect, test } from 'vitest';
import { logger } from './logger.svelte.js';

test('Effect', () => {
	const cleanup = $effect.root(() => {
		let count = $state(0);

		// logger uses an $effect to log updates of its input
		let log = logger(() => count);

		// effects normally run after a microtask,
		// use flushSync to execute all pending effects synchronously
		flushSync();
		expect(log.value).toEqual([0]);

		count = 1;
		flushSync();

		expect(log.value).toEqual([0, 1]);
	});

	cleanup();
});
```

### Component testing

Install jsdom:

```bash
npm install -D jsdom
```

Configure environment:

```js
/// file: vite.config.js
import { defineConfig } from 'vitest/config';

export default defineConfig({
	test: {
		environment: 'jsdom'
	},
	resolve: process.env.VITEST
		? {
				conditions: ['browser']
			}
		: undefined
});
```

Test components with `mount`/`unmount`:

```js
/// file: component.test.js
import { flushSync, mount, unmount } from 'svelte';
import { expect, test } from 'vitest';
import Component from './Component.svelte';

test('Component', () => {
	const component = mount(Component, {
		target: document.body,
		props: { initial: 0 }
	});

	expect(document.body.innerHTML).toBe('<button>0</button>');

	document.body.querySelector('button').click();
	flushSync();

	expect(document.body.innerHTML).toBe('<button>1</button>');

	unmount(component);
});
```

Or use [@testing-library/svelte](https://testing-library.com/docs/svelte-testing-library/intro/):

```js
/// file: component.test.js
import { render, screen } from '@testing-library/svelte';
import userEvent from '@testing-library/user-event';
import { expect, test } from 'vitest';
import Component from './Component.svelte';

test('Component', async () => {
	const user = userEvent.setup();
	render(Component);

	const button = screen.getByRole('button');
	expect(button).toHaveTextContent(0);

	await user.click(button);
	expect(button).toHaveTextContent(1);
});
```

## E2E tests using Playwright

Configure Playwright:

```js
/// file: playwright.config.js
const config = {
	webServer: {
		command: 'npm run build && npm run preview',
		port: 4173
	},
	testDir: 'tests',
	testMatch: /(.+\.)?(test|spec)\.[jt]s/
};

export default config;
```

Write E2E tests:

```js
/// file: tests/hello-world.spec.js
import { expect, test } from '@playwright/test';

test('home page has expected h1', async ({ page }) => {
	await page.goto('/');
	await expect(page.locator('h1')).toBeVisible();
});
```

## docs/svelte/07-misc/03-typescript.md

# TypeScript

Use TypeScript in Svelte components with IDE support via [Svelte VS Code extension](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode) and [`svelte-check`](https://www.npmjs.com/package/svelte-check).

## `<script lang="ts">`

Add `lang="ts"` to script tags:

```svelte
<script lang="ts">
	let name: string = 'world';

	function greet(name: string) {
		alert(`Hello, ${name}!`);
	}
</script>

<button onclick={(e: Event) => greet(e.target.innerText)}>
	{name as string}
</button>
```

**Limitations**: Only type-only features work. No enums, constructor modifiers, or non-standard ECMAScript features. Use preprocessor for these.

## Preprocessor Setup

For full TypeScript features, add preprocessor:

```ts
/// file: svelte.config.js
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const config = {
	preprocess: vitePreprocess({ script: true })
};

export default config;
```

**SvelteKit/Vite**: Use `npx sv create` (TypeScript option) or `npm create vite@latest` (svelte-ts).

## tsconfig.json

Required settings:
- `target`: ES2022+ or ES2015+ with `useDefineForClassFields`
- `verbatimModuleSyntax`: true
- `isolatedModules`: true

## Typing `$props`

```svelte
<script lang="ts">
	import type { Snippet } from 'svelte';

	interface Props {
		requiredProperty: number;
		optionalProperty?: boolean;
		snippetWithStringArgument: Snippet<[string]>;
		eventHandler: (arg: string) => void;
		[key: string]: unknown;
	}

	let {
		requiredProperty,
		optionalProperty,
		snippetWithStringArgument,
		eventHandler,
		...everythingElse
	}: Props = $props();
</script>

<button onclick={() => eventHandler('clicked button')}>
	{@render snippetWithStringArgument('hello')}
</button>
```

## Generic `$props`

Use `generics` attribute for generic components:

```svelte
<script lang="ts" generics="Item extends { text: string }">
	interface Props {
		items: Item[];
		select(item: Item): void;
	}

	let { items, select }: Props = $props();
</script>

{#each items as item}
	<button onclick={() => select(item)}>
		{item.text}
	</button>
{/each}
```

## Wrapper Components

Use `svelte/elements` types for native element wrappers:

```svelte
<script lang="ts">
	import type { HTMLButtonAttributes } from 'svelte/elements';

	let { children, ...rest }: HTMLButtonAttributes = $props();
</script>

<button {...rest}>
	{@render children?.()}
</button>
```

For elements without dedicated types:

```svelte
<script lang="ts">
	import type { SvelteHTMLElements } from 'svelte/elements';

	let { children, ...rest }: SvelteHTMLElements['div'] = $props();
</script>

<div {...rest}>
	{@render children?.()}
</div>
```

## Typing `$state`

```ts
let count: number = $state(0);
```

Without initial value, type includes `undefined`. Use casting when needed:

```ts
class Counter {
	count = $state() as number;
	constructor(initial: number) {
		this.count = initial;
	}
}
```

## Component Types

Use `Component` type for dynamic components:

```svelte
<script lang="ts">
	import type { Component } from 'svelte';

	interface Props {
		DynamicComponent: Component<{ prop: string }>;
	}

	let { DynamicComponent }: Props = $props();
</script>

<DynamicComponent prop="foo" />
```

Extract component props with `ComponentProps`:

```ts
import type { Component, ComponentProps } from 'svelte';
import MyComponent from './MyComponent.svelte';

function withProps<TComponent extends Component<any>>(
	component: TComponent,
	props: ComponentProps<TComponent>
) {}

withProps(MyComponent, { foo: 'bar' });
```

Component constructor/instance types:

```svelte
<script lang="ts">
	import MyComponent from './MyComponent.svelte';

	let componentConstructor: typeof MyComponent = MyComponent;
	let componentInstance: MyComponent;
</script>

<MyComponent bind:this={componentInstance} />
```

## Enhancing DOM Types

For custom attributes/events, augment types:

```ts
/// file: additional-svelte-typings.d.ts
declare namespace svelteHTML {
	interface IntrinsicElements {
		'my-custom-element': { someattribute: string; 'on:event': (e: CustomEvent<any>) => void };
	}
	interface HTMLAttributes<T> {
		onbeforeinstallprompt?: (event: any) => any;
		mycustomattribute?: any;
	}
}
```

Or augment `svelte/elements`:

```ts
/// file: additional-svelte-typings.d.ts
import { HTMLButtonAttributes } from 'svelte/elements';

declare module 'svelte/elements' {
	export interface SvelteHTMLElements {
		'custom-button': HTMLButtonAttributes;
	}

	export interface HTMLButtonAttributes {
		veryexperimentalattribute?: string;
	}
}

export {};
```

## docs/kit/10-getting-started/10-introduction.md

# Introduction

## What is SvelteKit?

SvelteKit is a framework for rapidly developing robust, performant web applications using Svelte. Similar to Next.js (React) or Nuxt (Vue).

## What is Svelte?

Svelte is a way of writing UI components that compiles to JavaScript and CSS. The compiler converts components to optimized code that renders HTML and styles.

## SvelteKit vs Svelte

- **Svelte**: Renders UI components
- **SvelteKit**: Full-stack framework with routing, build optimizations, offline support, preloading, configurable rendering (SSR/CSR/prerendering), image optimization, and more

SvelteKit provides modern best practices and leverages Vite with Hot Module Replacement for fast development.

## docs/kit/10-getting-started/20-creating-a-project.md

# Creating a project

Start building a SvelteKit app:

```bash
npx sv create my-app
cd my-app
npm install
npm run dev
```

This scaffolds a project in `my-app` directory with optional TypeScript setup, installs dependencies, and starts server on [localhost:5173](http://localhost:5173).

## Key concepts

- Each page is a Svelte component
- Create pages by adding files to `src/routes` directory
- Pages are server-rendered first, then client-side app takes over

## Editor setup

Use [Visual Studio Code](https://code.visualstudio.com/download) with [the Svelte extension](https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode).

## docs/kit/10-getting-started/25-project-types.md

# Project Types

SvelteKit offers configurable rendering for different deployment scenarios. Rendering settings are not mutually exclusive - you can mix different approaches within the same app.

## Default Rendering

First page uses SSR, subsequent pages use CSR. This hybrid approach improves SEO and perceived performance while maintaining fast navigation.

## Static Site Generation

Use `adapter-static` to prerender your entire site, or use the `prerender` option to prerender specific pages:

```js
// +page.js
export const prerender = true;
```

For large sites, use Incremental Static Regeneration with `adapter-vercel`.

## Single-Page App

Build SPAs using CSR exclusively. Skip server-related docs if using no backend or separate backend.

## Multi-Page App

Remove JavaScript with `csr = false` or use `data-sveltekit-reload` for server-rendered links:

```js
// +page.js
export const csr = false;
```

## Separate Backend

Deploy frontend separately using `adapter-node` or serverless adapters. Skip server file documentation.

## Deployment Options

- **Serverless**: Use `adapter-auto`, `adapter-vercel`, `adapter-netlify`, or `adapter-cloudflare`
- **Own Server**: Use `adapter-node`
- **Container**: Use `adapter-node` with Docker/LXC
- **Library**: Use `@sveltejs/package` with `sv create`

## Specialized Apps

- **Offline/PWA**: Full service worker support
- **Mobile**: Convert SPA using Tauri or Capacitor
- **Desktop**: Convert SPA using Tauri, Wails, or Electron
- **Browser Extension**: Use `adapter-static` or specialized adapters
- **Embedded**: Use `bundleStrategy: 'single'` to reduce concurrent requests

```js
// svelte.config.js
export default {
  kit: {
    output: {
      bundleStrategy: 'single'
    }
  }
};
```

## docs/kit/10-getting-started/30-project-structure.md

# Project structure

## Basic structure

```bash
my-project/
├ src/
│ ├ lib/
│ │ ├ server/
│ │ │ └ [server-only lib files]
│ │ └ [lib files]
│ ├ params/
│ │ └ [param matchers]
│ ├ routes/
│ │ └ [routes]
│ ├ app.html
│ ├ error.html
│ ├ hooks.client.js
│ ├ hooks.server.js
│ └ service-worker.js
├ static/
│ └ [static assets]
├ package.json
├ svelte.config.js
└ vite.config.js
```

## Key directories

### src/
- `lib` - Library code, imported via `$lib` alias
- `lib/server` - Server-only code, imported via `$lib/server` alias
- `params` - Param matchers for advanced routing
- `routes` - Application routes
- `app.html` - Page template with placeholders:
  - `%sveltekit.head%` - Links, scripts, `<svelte:head>` content
  - `%sveltekit.body%` - Rendered page markup (wrap in `<div>`, not directly in `<body>`)
  - `%sveltekit.assets%` - Asset path
  - `%sveltekit.nonce%` - CSP nonce
  - `%sveltekit.env.[NAME]%` - Environment variables (must start with `publicPrefix`)
- `error.html` - Error page with `%sveltekit.status%` and `%sveltekit.error.message%`
- `hooks.client.js` - Client hooks
- `hooks.server.js` - Server hooks
- `service-worker.js` - Service worker

### static/
Static assets served as-is (robots.txt, favicon.png, etc.)

## Config files

### package.json
Must include `@sveltejs/kit`, `svelte`, `vite` as `devDependencies`. Requires `"type": "module"`.

### svelte.config.js
Svelte and SvelteKit configuration.

### vite.config.js
Vite project using `@sveltejs/kit/vite` plugin.

### .svelte-kit
Generated files (can be deleted, will regenerate).

## docs/kit/10-getting-started/40-web-standards.md

# Web Standards

SvelteKit builds on standard [Web APIs](https://developer.mozilla.org/en-US/docs/Web/API) rather than reinventing them. These APIs work in all modern browsers and many non-browser environments.

## Fetch APIs

SvelteKit uses [`fetch`](https://developer.mozilla.org/en-US/docs/Web/API/fetch) for network requests. Available in hooks, server routes, and browsers.

> **Note:** Special version available in `load` functions, server hooks, and API routes for direct endpoint invocation during SSR without HTTP calls, preserving credentials.

### Request
[`Request`](https://developer.mozilla.org/en-US/docs/Web/API/Request) accessible as `event.request` in hooks and server routes. Use `request.json()` and `request.formData()` for posted data.

### Response
[`Response`](https://developer.mozilla.org/en-US/docs/Web/API/Response) returned from `await fetch(...)` and `+server.js` handlers.

### Headers
[`Headers`](https://developer.mozilla.org/en-US/docs/Web/API/Headers) interface for reading `request.headers` and setting `response.headers`:

```js
// @errors: 2461
/// file: src/routes/what-is-my-user-agent/+server.js
import { json } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export function GET({ request }) {
	// log all headers
	console.log(...request.headers);

	// create a JSON Response using a header we received
	return json({
		// retrieve a specific header
		userAgent: request.headers.get('user-agent')
	}, {
		// set a header on the response
		headers: { 'x-custom-header': 'potato' }
	});
}
```

## FormData

For HTML form submissions, use [`FormData`](https://developer.mozilla.org/en-US/docs/Web/API/FormData):

```js
// @errors: 2461
/// file: src/routes/hello/+server.js
import { json } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export async function POST(event) {
	const body = await event.request.formData();

	// log all fields
	console.log([...body]);

	return json({
		// get a specific field's value
		name: body.get('name') ?? 'world'
	});
}
```

## Stream APIs

For large or chunked responses, use [streams](https://developer.mozilla.org/en-US/docs/Web/API/Streams_API): [ReadableStream](https://developer.mozilla.org/en-US/docs/Web/API/ReadableStream), [WritableStream](https://developer.mozilla.org/en-US/docs/Web/API/WritableStream), [TransformStream](https://developer.mozilla.org/en-US/docs/Web/API/TransformStream).

## URL APIs

[`URL`](https://developer.mozilla.org/en-US/docs/Web/API/URL) interface with `origin`, `pathname` properties. Found in `event.url`, `page.url`, navigation functions.

### URLSearchParams
Access query parameters via `url.searchParams` ([`URLSearchParams`](https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams)):

```js
const foo = url.searchParams.get('foo');
```

## Web Crypto

[Web Crypto API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Crypto_API) via `crypto` global. Used for CSP headers and UUID generation:

```js
const uuid = crypto.randomUUID();
```

## docs/kit/20-core-concepts/10-routing.md

# Routing

SvelteKit uses filesystem-based routing where directories define URL paths:

- `src/routes` → root route
- `src/routes/about` → `/about` route
- `src/routes/blog/[slug]` → route with parameter `slug`

Route files are identified by `+` prefix. Key rules:
* All files run on server
* All files run on client except `+server` files
* `+layout` and `+error` files apply to subdirectories

## +page

### +page.svelte

Defines a page component. Rendered on server (SSR) initially, then client (CSR) for navigation.

```svelte
<!file: src/routes/+page.svelte>
<h1>Hello and welcome to my site!</h1>
<a href="/about">About my site</a>
```

Pages receive data via `data` prop:

```svelte
<!file: src/routes/blog/[slug]/+page.svelte>
<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
</script>

<h1>{data.title}</h1>
<div>{@html data.content}</div>
```

### +page.js

Exports `load` function to fetch data. Runs on server and client.

```js
/// file: src/routes/blog/[slug]/+page.js
import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export function load({ params }) {
	if (params.slug === 'hello-world') {
		return {
			title: 'Hello world!',
			content: 'Welcome to our blog. Lorem ipsum dolor sit amet...'
		};
	}

	error(404, 'Not found');
}
```

Can export page options: `prerender`, `ssr`, `csr`.

### +page.server.js

Server-only `load` function for database access or private environment variables.

```js
/// file: src/routes/blog/[slug]/+page.server.js
import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
	const post = await getPostFromDatabase(params.slug);

	if (post) {
		return post;
	}

	error(404, 'Not found');
}
```

Return value must be serializable. Can also export actions for form handling.

## +error

Customizes error pages. SvelteKit walks up tree to find closest error boundary.

```svelte
<!file: src/routes/blog/[slug]/+error.svelte>
<script>
	import { page } from '$app/state';
</script>

<h1>{page.status}: {page.error.message}</h1>
```

For 404s, uses `src/routes/+error.svelte`. Fallback is `src/error.html`.

## +layout

### +layout.svelte

Wraps pages with shared UI. Must include `{@render children()}`.

```svelte
<!file: src/routes/+layout.svelte>
<script>
	let { children } = $props();
</script>

<nav>
	<a href="/">Home</a>
	<a href="/about">About</a>
	<a href="/settings">Settings</a>
</nav>

{@render children()}
```

Layouts can be nested and inherit from parent layouts.

### +layout.js

Provides data to layout and all child pages:

```js
/// file: src/routes/settings/+layout.js
/** @type {import('./$types').LayoutLoad} */
export function load() {
	return {
		sections: [
			{ slug: 'profile', title: 'Profile' },
			{ slug: 'notifications', title: 'Notifications' }
		]
	};
}
```

### +layout.server.js

Server-only layout load function. Change `LayoutLoad` to `LayoutServerLoad`.

## +server

API routes with HTTP verb handlers. Return `Response` objects.

```js
/// file: src/routes/api/random-number/+server.js
import { error } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export function GET({ url }) {
	const min = Number(url.searchParams.get('min') ?? '0');
	const max = Number(url.searchParams.get('max') ?? '1');

	const d = max - min;

	if (isNaN(d) || d < 0) {
		error(400, 'min and max must be numbers, and min must be less than max');
	}

	const random = min + Math.random() * d;

	return new Response(String(random));
}
```

### Receiving data

Handle POST/PUT/PATCH/DELETE requests:

```js
/// file: src/routes/api/add/+server.js
import { json } from '@sveltejs/kit';

/** @type {import('./$types').RequestHandler} */
export async function POST({ request }) {
	const { a, b } = await request.json();
	return json(a + b);
}
```

### Fallback handler

Handles unmatched HTTP methods:

```js
/** @type {import('./$types').RequestHandler} */
export async function fallback({ request }) {
	return text(`I caught your ${request.method} request!`);
}
```

### Content negotiation

Same directory can have `+page` and `+server`:
- `PUT`/`PATCH`/`DELETE`/`OPTIONS` → always `+server.js`
- `GET`/`POST`/`HEAD` → `+page` if `accept` header prioritizes `text/html`, else `+server.js`

## $types

SvelteKit generates TypeScript types in `$types.d.ts`:

```svelte
<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
</script>
```

Available types:
- `PageProps`, `LayoutProps` (components)
- `PageLoad`, `PageServerLoad` (page load functions)
- `LayoutLoad`, `LayoutServerLoad` (layout load functions)
- `RequestHandler` (server routes)

IDE tooling can auto-insert these types.

## Other files

Non-route files in route directories are ignored. Use `$lib` for shared components.

## docs/kit/20-core-concepts/20-load.md

# Loading data

Before `+page.svelte` and `+layout.svelte` components render, get data using `load` functions.

## Page data

`+page.js` exports a `load` function, return value available via `data` prop:

```js
/// file: src/routes/blog/[slug]/+page.js
/** @type {import('./$types').PageLoad} */
export function load({ params }) {
	return {
		post: {
			title: `Title for ${params.slug} goes here`,
			content: `Content for ${params.slug} goes here`
		}
	};
}
```

```svelte
<!file: src/routes/blog/[slug]/+page.svelte>
<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
</script>

<h1>{data.post.title}</h1>
<div>{@html data.post.content}</div>
```

`+page.js` runs on server and browser. For server-only (database access, private env vars), use `+page.server.js`:

```js
/// file: src/routes/blog/[slug]/+page.server.js
import * as db from '$lib/server/database';

/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
	return {
		post: await db.getPost(params.slug)
	};
}
```

## Layout data

`+layout.js` or `+layout.server.js` load data for layouts:

```js
/// file: src/routes/blog/[slug]/+layout.server.js
import * as db from '$lib/server/database';

/** @type {import('./$types').LayoutServerLoad} */
export async function load() {
	return {
		posts: await db.getPostSummaries()
	};
}
```

```svelte
<!file: src/routes/blog/[slug]/+layout.svelte>
<script>
	/** @type {import('./$types').LayoutProps} */
	let { data, children } = $props();
</script>

<main>
	{@render children()}
</main>

<aside>
	<h2>More posts</h2>
	<ul>
		{#each data.posts as post}
			<li>
				<a href="/blog/{post.slug}">
					{post.title}
				</a>
			</li>
		{/each}
	</ul>
</aside>
```

Layout data is available to child layouts and pages. If multiple `load` functions return same key, last one wins.

## page.data

Parent layouts can access page data via `page.data`:

```svelte
<!file: src/routes/+layout.svelte>
<script>
	import { page } from '$app/state';
</script>

<svelte:head>
	<title>{page.data.title}</title>
</svelte:head>
```

## Universal vs server

**Universal** (`+page.js`, `+layout.js`): Run on server during SSR, then in browser
**Server** (`+page.server.js`, `+layout.server.js`): Server-only

Server `load` runs first if both exist. Universal gets server data via `data` property:

```js
/// file: src/routes/+page.server.js
/** @type {import('./$types').PageServerLoad} */
export async function load() {
	return {
		serverMessage: 'hello from server load function'
	};
}
```

```js
/// file: src/routes/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ data }) {
	return {
		serverMessage: data.serverMessage,
		universalMessage: 'hello from universal load function'
	};
}
```

**Use server** for: database access, private credentials
**Use universal** for: external APIs, non-serializable data

## URL data

Access `url`, `route`, `params`:

```js
/// file: src/routes/a/[b]/[...c]/+page.js
/** @type {import('./$types').PageLoad} */
export function load({ route, url, params }) {
	console.log(route.id); // '/a/[b]/[...c]'
	// url.pathname: '/a/x/y/z' → params: { "b": "x", "c": "y/z" }
}
```

## Making fetch requests

Use provided `fetch` function:

```js
/// file: src/routes/items/[id]/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ fetch, params }) {
	const res = await fetch(`/api/items/${params.id}`);
	const item = await res.json();

	return { item };
}
```

Benefits: inherits cookies/auth, relative URLs work, internal requests optimized, responses inlined during SSR.

## Cookies

Server `load` functions can access cookies:

```js
/// file: src/routes/+layout.server.js
import * as db from '$lib/server/database';

/** @type {import('./$types').LayoutServerLoad} */
export async function load({ cookies }) {
	const sessionid = cookies.get('sessionid');

	return {
		user: await db.getUser(sessionid)
	};
}
```

## Headers

Set response headers with `setHeaders`:

```js
/// file: src/routes/products/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ fetch, setHeaders }) {
	const response = await fetch('https://cms.example.com/products.json');

	setHeaders({
		age: response.headers.get('age'),
		'cache-control': response.headers.get('cache-control')
	});

	return response.json();
}
```

## Using parent data

Access parent `load` data with `await parent()`:

```js
/// file: src/routes/+layout.js
/** @type {import('./$types').LayoutLoad} */
export function load() {
	return { a: 1 };
}
```

```js
/// file: src/routes/abc/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ parent }) {
	const { a } = await parent();
	return { c: a + 1 };
}
```

Avoid waterfalls - call independent functions first:

```js
/// file: +page.js
/** @type {import('./$types').PageLoad} */
export async function load({ params, parent }) {
	const data = await getData(params);
	const parentData = await parent();

	return {
		...data,
		meta: { ...parentData.meta, ...data.meta }
	};
}
```

## Errors

Use `error` helper for expected errors:

```js
/// file: src/routes/admin/+layout.server.js
import { error } from '@sveltejs/kit';

/** @type {import('./$types').LayoutServerLoad} */
export function load({ locals }) {
	if (!locals.user) {
		error(401, 'not logged in');
	}

	if (!locals.user.isAdmin) {
		error(403, 'not an admin');
	}
}
```

## Redirects

Use `redirect` helper:

```js
/// file: src/routes/user/+layout.server.js
import { redirect } from '@sveltejs/kit';

/** @type {import('./$types').LayoutServerLoad} */
export function load({ locals }) {
	if (!locals.user) {
		redirect(307, '/login');
	}
}
```

## Streaming with promises

Server `load` can return promises for streaming:

```js
/// file: src/routes/blog/[slug]/+page.server.js
/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
	return {
		comments: loadComments(params.slug), // streamed
		post: await loadPost(params.slug)    // awaited
	};
}
```

```svelte
<!file: src/routes/blog/[slug]/+page.svelte>
<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();
</script>

<h1>{data.post.title}</h1>
<div>{@html data.post.content}</div>

{#await data.comments}
	Loading comments...
{:then comments}
	{#each comments as comment}
		<p>{comment.content}</p>
	{/each}
{:catch error}
	<p>error loading comments: {error.message}</p>
{/await}
```

## Rerunning load functions

`load` functions rerun when:
- Referenced `params` change
- Referenced `url` properties change
- `await parent()` and parent reruns
- Dependency marked invalid with `invalidate(url)`
- `invalidateAll()` called

### Manual invalidation

```js
/// file: src/routes/random-number/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ fetch, depends }) {
	const response = await fetch('https://api.example.com/random-number');
	depends('app:random');

	return {
		number: await response.json()
	};
}
```

```svelte
<!file: src/routes/random-number/+page.svelte>
<script>
	import { invalidate, invalidateAll } from '$app/navigation';

	/** @type {import('./$types').PageProps} */
	let { data } = $props();

	function rerunLoadFunction() {
		invalidate('app:random');
		// or invalidate('https://api.example.com/random-number');
		// or invalidateAll();
	}
</script>

<p>random number: {data.number}</p>
<button onclick={rerunLoadFunction}>Update random number</button>
```

### Untracking dependencies

Exclude from dependency tracking with `untrack`:

```js
/// file: src/routes/+page.js
/** @type {import('./$types').PageLoad} */
export async function load({ untrack, url }) {
	if (untrack(() => url.pathname === '/')) {
		return { message: 'Welcome!' };
	}
}
```

## Using getRequestEvent

Access request event in shared logic:

```js
/// file: src/lib/server/auth.js
import { redirect } from '@sveltejs/kit';
import { getRequestEvent } from '$app/server';

export function requireLogin() {
	const { locals, url } = getRequestEvent();

	if (!locals.user) {
		const redirectTo = url.pathname + url.search;
		const params = new URLSearchParams({ redirectTo });
		redirect(307, `/login?${params}`);
	}

	return locals.user;
}
```

```js
/// file: +page.server.js
import { requireLogin } from '$lib/server/auth';

export function load() {
	const user = requireLogin();
	return {
		message: `hello ${user.name}!`
	};
}
```

## docs/kit/20-core-concepts/30-form-actions.md

# Form actions

A `+page.server.js` file can export _actions_ for `POST` data using `<form>` elements. Client-side JavaScript is optional but enables progressive enhancement.

## Default actions

```js
/// file: src/routes/login/+page.server.js
/** @satisfies {import('./$types').Actions} */
export const actions = {
	default: async (event) => {
		// TODO log the user in
	}
};
```

```svelte
<!file: src/routes/login/+page.svelte>
<form method="POST">
	<label>
		Email
		<input name="email" type="email">
	</label>
	<label>
		Password
		<input name="password" type="password">
	</label>
	<button>Log in</button>
</form>
```

Actions always use `POST` requests. Invoke from other pages with `action` attribute:

```html
/// file: src/routes/+layout.svelte
<form method="POST" action="/login">

</form>
```

## Named actions

```js
/// file: src/routes/login/+page.server.js
/** @satisfies {import('./$types').Actions} */
export const actions = {
	login: async (event) => {
		// TODO log the user in
	},
	register: async (event) => {
		// TODO register the user
	}
};
```

Invoke with query parameter prefixed by `/`:

```svelte
<!file: src/routes/login/+page.svelte>
<form method="POST" action="?/register">
```

Use `formaction` on buttons:

```svelte
/// file: src/routes/login/+page.svelte
<form method="POST" action="?/login">
	<label>
		Email
		<input name="email" type="email">
	</label>
	<label>
		Password
		<input name="password" type="password">
	</label>
	<button>Log in</button>
	<button formaction="?/register">Register</button>
</form>
```

> Can't have default actions next to named actions due to query parameter persistence.

## Anatomy of an action

Actions receive `RequestEvent` and can return data available through `form` prop:

```js
/// file: src/routes/login/+page.server.js
import * as db from '$lib/server/db';

/** @satisfies {import('./$types').Actions} */
export const actions = {
	login: async ({ cookies, request }) => {
		const data = await request.formData();
		const email = data.get('email');
		const password = data.get('password');

		const user = await db.getUser(email);
		cookies.set('sessionid', await db.createSession(user), { path: '/' });

		return { success: true };
	}
};
```

```svelte
<!file: src/routes/login/+page.svelte>
<script>
	/** @type {import('./$types').PageProps} */
	let { data, form } = $props();
</script>

{#if form?.success}
	<p>Successfully logged in! Welcome back, {data.user.name}</p>
{/if}
```

### Validation errors

Use `fail()` to return validation errors with HTTP status codes:

```js
/// file: src/routes/login/+page.server.js
import { fail } from '@sveltejs/kit';
import * as db from '$lib/server/db';

/** @satisfies {import('./$types').Actions} */
export const actions = {
	login: async ({ cookies, request }) => {
		const data = await request.formData();
		const email = data.get('email');
		const password = data.get('password');

		if (!email) {
			return fail(400, { email, missing: true });
		}

		const user = await db.getUser(email);

		if (!user || user.password !== db.hash(password)) {
			return fail(400, { email, incorrect: true });
		}

		cookies.set('sessionid', await db.createSession(user), { path: '/' });

		return { success: true };
	}
};
```

```svelte
/// file: src/routes/login/+page.svelte
<form method="POST" action="?/login">
	{#if form?.missing}<p class="error">The email field is required</p>{/if}
	{#if form?.incorrect}<p class="error">Invalid credentials!</p>{/if}
	<label>
		Email
		<input name="email" type="email" value={form?.email ?? ''}>
	</label>
	<label>
		Password
		<input name="password" type="password">
	</label>
	<button>Log in</button>
</form>
```

### Redirects

```js
/// file: src/routes/login/+page.server.js
import { fail, redirect } from '@sveltejs/kit';

/** @satisfies {import('./$types').Actions} */
export const actions = {
	login: async ({ cookies, request, url }) => {
		// ... validation logic

		cookies.set('sessionid', await db.createSession(user), { path: '/' });

		if (url.searchParams.has('redirectTo')) {
			redirect(303, url.searchParams.get('redirectTo'));
		}

		return { success: true };
	}
};
```

## Progressive enhancement

### use:enhance

Add `use:enhance` for progressive enhancement:

```svelte
/// file: src/routes/login/+page.svelte
<script>
	import { enhance } from '$app/forms';

	/** @type {import('./$types').PageProps} */
	let { form } = $props();
</script>

<form method="POST" use:enhance>
```

> Only works with `method="POST"` forms pointing to `+page.server.js` actions.

Without arguments, `use:enhance` emulates browser behavior without full-page reloads.

### Customising use:enhance

```svelte
<form
	method="POST"
	use:enhance={({ formElement, formData, action, cancel, submitter }) => {
		// `formElement` is this `<form>` element
		// `formData` is its `FormData` object that's about to be submitted
		// `action` is the URL to which the form is posted
		// calling `cancel()` will prevent the submission
		// `submitter` is the `HTMLElement` that caused the form to be submitted

		return async ({ result, update }) => {
			// `result` is an `ActionResult` object
			// `update` is a function which triggers the default logic that would be triggered if this callback wasn't set
		};
	}}
>
```

Use `applyAction` to reproduce default behavior:

```svelte
/// file: src/routes/login/+page.svelte
<script>
	import { enhance, applyAction } from '$app/forms';

	/** @type {import('./$types').PageProps} */
	let { form } = $props();
</script>

<form
	method="POST"
	use:enhance={({ formElement, formData, action, cancel }) => {
		return async ({ result }) => {
			if (result.type === 'redirect') {
				goto(result.location);
			} else {
				await applyAction(result);
			}
		};
	}}
>
```

### Custom event listener

```svelte
<!file: src/routes/login/+page.svelte>
<script>
	import { invalidateAll, goto } from '$app/navigation';
	import { applyAction, deserialize } from '$app/forms';

	/** @type {import('./$types').PageProps} */
	let { form } = $props();

	/** @param {SubmitEvent & { currentTarget: EventTarget & HTMLFormElement}} event */
	async function handleSubmit(event) {
		event.preventDefault();
		const data = new FormData(event.currentTarget);

		const response = await fetch(event.currentTarget.action, {
			method: 'POST',
			body: data
		});

		/** @type {import('@sveltejs/kit').ActionResult} */
		const result = deserialize(await response.text());

		if (result.type === 'success') {
			await invalidateAll();
		}

		applyAction(result);
	}
</script>

<form method="POST" onsubmit={handleSubmit}>

</form>
```

Use `deserialize()` instead of `JSON.parse()`. For `+server.js` alongside `+page.server.js`, add header:

```js
const response = await fetch(this.action, {
	method: 'POST',
	body: data,
	headers: {
		'x-sveltekit-action': 'true'
	}
});
```

## GET vs POST

Use `method="GET"` for forms that don't need to POST data (like search):

```html
<form action="/search">
	<label>
		Search
		<input name="q">
	</label>
</form>
```

This navigates to `/search?q=...` and invokes load functions but not actions. Supports `data-sveltekit-*` attributes like `<a>` elements.

## docs/kit/20-core-concepts/40-page-options.md

# Page Options

Control rendering behavior by exporting options from `+page.js`, `+page.server.js`, `+layout.js`, or `+layout.server.js`. Child layouts/pages override parent values.

## prerender

Generate static HTML at build time:

```js
/// file: +page.js/+page.server.js/+server.js
export const prerender = true;
```

Set in root layout to prerender everything, then opt-out specific pages:

```js
/// file: +page.js/+page.server.js/+server.js
export const prerender = false;
```

Include in manifest for dynamic SSR:

```js
/// file: +page.js/+page.server.js/+server.js
export const prerender = 'auto';
```

**Requirements:**
- All users must get same content from server
- No personalized data (fetch in `onMount` instead)
- No `url.searchParams` access during prerendering
- No form actions

**Server routes:** Inherit prerender setting from pages that fetch from them.

**Conflicts:** Avoid same-name files/directories. Use extensions: `foo.json/+server.js` not `foo/+server.js`.

## entries

Define dynamic routes to prerender when not discoverable by crawling:

```js
/// file: src/routes/blog/[slug]/+page.server.js
/** @type {import('./$types').EntryGenerator} */
export function entries() {
	return [
		{ slug: 'hello-world' },
		{ slug: 'another-blog-post' }
	];
}

export const prerender = true;
```

## ssr

Disable server-side rendering (renders empty shell):

```js
/// file: +page.js
export const ssr = false;
// If both `ssr` and `csr` are `false`, nothing renders!
```

## csr

Disable client-side JavaScript:

```js
/// file: +page.js
export const csr = false;
```

**Effects:**
- No JavaScript shipped to client
- `<script>` tags removed from components
- No form progressive enhancement
- Full-page navigation only
- No HMR

Enable during development:

```js
/// file: +page.js
import { dev } from '$app/environment';

export const csr = dev;
```

## trailingSlash

Control URL trailing slash behavior:

```js
/// file: src/routes/+layout.js
export const trailingSlash = 'always';
```

Options: `'never'` (default), `'always'`, `'ignore'`

Affects prerendering: `'always'` creates `about/index.html`, otherwise `about.html`.

## config

Adapter-specific deployment configuration:

```js
/// file: src/routes/+page.js
/** @type {import('some-adapter').Config} */
export const config = {
	runtime: 'edge'
};
```

Configs merge at top level only. Child configs override parent values but don't deep merge nested objects.

## docs/kit/20-core-concepts/50-state-management.md

# State Management

## Avoid shared state on the server

Servers are stateless and shared by multiple users. Never store data in shared variables:

```js
// @errors: 7034 7005
/// file: +page.server.js
let user;

/** @type {import('./$types').PageServerLoad} */
export function load() {
	return { user };
}

/** @satisfies {import('./$types').Actions} */
export const actions = {
	default: async ({ request }) => {
		const data = await request.formData();

		// NEVER DO THIS!
		user = {
			name: data.get('name'),
			embarrassingSecret: data.get('secret')
		};
	}
}
```

Instead, authenticate users with cookies and persist data to a database.

## No side-effects in load

Load functions should be pure. Don't write to stores or global state:

```js
/// file: +page.js
// @filename: ambient.d.ts
declare module '$lib/user' {
	export const user: { set: (value: any) => void };
}

// @filename: index.js
//cut
import { user } from '$lib/user';

/** @type {import('./$types').PageLoad} */
export async function load({ fetch }) {
	const response = await fetch('/api/user');

	// NEVER DO THIS!
	user.set(await response.json());
}
```

Instead, return the data:

```js
/// file: +page.js
/** @type {import('./$types').PageServerLoad} */
export async function load({ fetch }) {
	const response = await fetch('/api/user');

return {
		user: await response.json()
	};
}
```

## Using state with context

Use Svelte's context API for server-safe state management:

```svelte
<!file: src/routes/+layout.svelte>
<script>
	import { setContext } from 'svelte';

	/** @type {import('./$types').LayoutProps} */
	let { data } = $props();

	// Pass a function referencing our state
	// to the context for child components to access
	setContext('user', () => data.user);
</script>
```

```svelte
<!file: src/routes/user/+page.svelte>
<script>
	import { getContext } from 'svelte';

	// Retrieve user store from context
	const user = getContext('user');
</script>

<p>Welcome {user().name}</p>
```

> Pass functions to `setContext` to maintain reactivity. State updates during SSR won't affect parent components already rendered.

## Component state is preserved

Components are reused during navigation. Make values reactive:

```svelte
/// file: src/routes/blog/[slug]/+page.svelte
<script>
	/** @type {import('./$types').PageProps} */
	let { data } = $props();

let wordCount = $derived(data.content.split(' ').length);
	let estimatedReadingTime = $derived(wordCount / 250);
</script>
```

To force component recreation:

```svelte
<script>
	import { page } from '$app/state';
</script>

{#key page.url.pathname}
	<BlogPost title={data.title} content={data.title} />
{/key}
```

## State storage patterns

- **URL search params**: For state that should survive reloads (`?sort=price&order=ascending`)
- **Snapshots**: For ephemeral UI state that should persist across navigation but not reloads

## docs/kit/25-build-and-deploy/10-building-your-app.md

# Building your app

Building happens in two stages when running `vite build`:

1. Vite creates optimized production build of server code, browser code, and service worker
2. An _adapter_ tunes the build for your target environment

## During the build

SvelteKit loads `+page/layout(.server).js` files for analysis during build. Code that shouldn't execute at build time must check `building` from `$app/environment`:

```js
import { building } from '$app/environment';
import { setupMyDatabase } from '$lib/server/database';

if (!building) {
	setupMyDatabase();
}

export function load() {
	// ...
}
```

## Preview

View production build locally with `vite preview`. Runs in Node, so adapter-specific features like `platform` object don't apply.

## docs/kit/25-build-and-deploy/20-adapters.md

# Adapters

Adapters are plugins that prepare your SvelteKit app for deployment to specific platforms.

## Official Adapters

- `@sveltejs/adapter-cloudflare` - Cloudflare Workers/Pages
- `@sveltejs/adapter-netlify` - Netlify
- `@sveltejs/adapter-node` - Node servers
- `@sveltejs/adapter-static` - Static site generation
- `@sveltejs/adapter-vercel` - Vercel

## Usage

Configure in `svelte.config.js`:

```js
import adapter from 'svelte-adapter-foo';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter({
			// adapter options go here
		})
	}
};

export default config;
```

## Platform Context

Adapters can provide platform-specific data via the `platform` property in `RequestEvent` (available in hooks and server routes).

## docs/kit/25-build-and-deploy/55-single-page-apps.md

# Single-page apps

Turn any SvelteKit app into a client-rendered SPA by disabling SSR:

```js
/// file: src/routes/+layout.js
export const ssr = false;
```

> [!NOTE] Not recommended: harms SEO, slows perceived performance, breaks accessibility when JavaScript fails.

## Usage with adapter-static

For apps without server-side logic, use `adapter-static` with a fallback page:

```js
// @errors: 2307
/// file: svelte.config.js
import adapter from '@sveltejs/adapter-static';

export default {
	kit: {
		adapter: adapter({
			fallback: '200.html' // may differ from host to host
		})
	}
};
```

The fallback page loads your app and navigates to the correct route. Common names: `200.html`, `index.html` - check your host's documentation.

## Apache

Add `static/.htaccess` for Apache hosting:

```
<IfModule mod_rewrite.c>
	RewriteEngine On
	RewriteBase /
	RewriteRule ^200\.html$ - [L]
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d
	RewriteRule . /200.html [L]
</IfModule>
```

## Prerendering individual pages

Re-enable SSR for specific pages:

```js
/// file: src/routes/my-prerendered-page/+page.js
export const prerender = true;
export const ssr = true;
```

## docs/kit/30-advanced/10-advanced-routing.md

# Advanced routing

## Rest parameters

Use rest syntax for unknown number of route segments:

```bash
/[org]/[repo]/tree/[branch]/[...file]
```

Request `/sveltejs/kit/tree/main/documentation/docs/04-advanced-routing.md` results in:

```js
// @noErrors
{
	org: 'sveltejs',
	repo: 'kit',
	branch: 'main',
	file: 'documentation/docs/04-advanced-routing.md'
}
```

> `src/routes/a/[...rest]/z/+page.svelte` matches `/a/z`, `/a/b/z`, `/a/b/c/z` etc. Validate rest parameter values using matchers.

### 404 pages

Create custom 404s with rest parameters:

```tree
src/routes/
├ marx-brothers/
| ├ [...path]/
│ ├ chico/
│ ├ harpo/
│ ├ groucho/
│ └ +error.svelte
└ +error.svelte
```

```js
/// file: src/routes/marx-brothers/[...path]/+page.js
import { error } from '@sveltejs/kit';

/** @type {import('./$types').PageLoad} */
export function load(event) {
	error(404, 'Not Found');
}
```

## Optional parameters

Make parameters optional with double brackets: `[[lang]]/home` matches both `home` and `en/home`.

> Optional parameters cannot follow rest parameters.

## Matching

Validate route parameters with matchers:

```js
/// file: src/params/fruit.js
/**
 * @param {string} param
 * @return {param is ('apple' | 'orange')}
 * @satisfies {import('@sveltejs/kit').ParamMatcher}
 */
export function match(param) {
	return param === 'apple' || param === 'orange';
}
```

Use in routes: `src/routes/fruits/[page=fruit]`

> Matchers run on server and browser.

## Sorting

Route priority (highest to lowest):
- More specific routes
- Parameters with matchers `[name=type]` over `[name]`
- `[[optional]]` and `[...rest]` have lowest priority
- Alphabetical for ties

## Encoding

Use hex escape sequences for special characters:
- `\` — `[x+5c]`
- `/` — `[x+2f]`
- `:` — `[x+3a]`
- `*` — `[x+2a]`
- `?` — `[x+3f]`
- `"` — `[x+22]`
- `<` — `[x+3c]`
- `>` — `[x+3e]`
- `|` — `[x+7c]`
- `#` — `[x+23]`
- `%` — `[x+25]`
- `[` — `[x+5b]`
- `]` — `[x+5d]`
- `(` — `[x+28]`
- `)` — `[x+29]`

Unicode escape sequences: `[u+nnnn]` (equivalent routes):
```
src/routes/[u+d83e][u+dd2a]/+page.svelte
src/routes/🤪/+page.svelte
```

## Advanced layouts

### (group)

Group routes with different layouts using parentheses:

```tree
src/routes/
│ (app)/
│ ├ dashboard/
│ ├ item/
│ └ +layout.svelte
│ (marketing)/
│ ├ about/
│ ├ testimonials/
│ └ +layout.svelte
├ admin/
└ +layout.svelte
```

Groups don't affect URL paths. `/admin` doesn't inherit group layouts.

### +page@

Break out of layout hierarchy with `@`:

```tree
src/routes/
├ (app)/
│ ├ item/
│ │ ├ [id]/
│ │ │ ├ embed/
│ │ │ │ └ +page@(app).svelte
│ │ │ └ +layout.svelte
│ │ └ +layout.svelte
│ └ +layout.svelte
└ +layout.svelte
```

Options:
- `+page@[id].svelte` - inherits from `[id]/+layout.svelte`
- `+page@item.svelte` - inherits from `item/+layout.svelte`
- `+page@(app).svelte` - inherits from `(app)/+layout.svelte`
- `+page@.svelte` - inherits from root layout

### +layout@

Layouts can also break out of hierarchy:

```
src/routes/
├ (app)/
│ ├ item/
│ │ ├ [id]/
│ │ │ ├ embed/
│ │ │ │ └ +page.svelte  // uses (app)/item/[id]/+layout.svelte
│ │ │ ├ +layout.svelte  // inherits from (app)/item/+layout@.svelte
│ │ │ └ +page.svelte    // uses (app)/item/+layout@.svelte
│ │ └ +layout@.svelte   // inherits from root layout, skipping (app)/+layout.svelte
│ └ +layout.svelte
└ +layout.svelte
```

### When to use layout groups

Alternative approach using composition:

```svelte
<!file: src/routes/nested/route/+layout@.svelte>
<script>
	import ReusableLayout from '$lib/ReusableLayout.svelte';
	let { data, children } = $props();
</script>

<ReusableLayout {data}>
	{@render children()}
</ReusableLayout>
```

```js
/// file: src/routes/nested/route/+layout.js
// @filename: ambient.d.ts
declare module "$lib/reusable-load-function" {
	export function reusableLoad(event: import('@sveltejs/kit').LoadEvent): Promise<Record<string, any>>;
}
// @filename: index.js
//cut
import { reusableLoad } from '$lib/reusable-load-function';

/** @type {import('./$types').PageLoad} */
export function load(event) {
	// Add additional logic here, if needed
	return reusableLoad(event);
}
```

## docs/kit/30-advanced/20-hooks.md

# Hooks

App-wide functions that SvelteKit calls in response to specific events.

Three optional hook files:
- `src/hooks.server.js` — server hooks
- `src/hooks.client.js` — client hooks
- `src/hooks.js` — universal hooks (both client and server)

Code runs when app starts up, useful for initializing database clients.

## Server hooks

### handle

Runs on every server request. Receives `event` and `resolve` function.

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	if (event.url.pathname.startsWith('/custom')) {
		return new Response('custom response');
	}

	const response = await resolve(event);
	return response;
}
```

Default: `({ event, resolve }) => resolve(event)`

#### locals

Add custom data to `event.locals` for handlers and server `load` functions:

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	event.locals.user = await getUserInformation(event.cookies.get('sessionid'));

	const response = await resolve(event);

	// Note that modifying response headers isn't always safe.
	// Response objects can have immutable headers
	// (e.g. Response.redirect() returned from an endpoint).
	// Modifying immutable headers throws a TypeError.
	// In that case, clone the response or avoid creating a
	// response object with immutable headers.
	response.headers.set('x-custom-header', 'potato');

	return response;
}
```

#### resolve options

Second parameter to `resolve()`:
- `transformPageChunk` — transform HTML chunks
- `filterSerializedResponseHeaders` — filter headers in serialized responses
- `preload` — determine which files to preload

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	const response = await resolve(event, {
		transformPageChunk: ({ html }) => html.replace('old', 'new'),
		filterSerializedResponseHeaders: (name) => name.startsWith('x-'),
		preload: ({ type, path }) => type === 'js' || path.includes('/important/')
	});

	return response;
}
```

### handleFetch

Modify `event.fetch` calls on server/during prerendering:

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').HandleFetch} */
export async function handleFetch({ request, fetch }) {
	if (request.url.startsWith('https://api.yourapp.com/')) {
		// clone the original request, but change the URL
		request = new Request(
			request.url.replace('https://api.yourapp.com/', 'http://localhost:9999/'),
			request
		);
	}

	return fetch(request);
}
```

For sibling subdomains, manually include cookies:

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').HandleFetch} */
export async function handleFetch({ event, request, fetch }) {
	if (request.url.startsWith('https://api.my-domain.com/')) {
		request.headers.set('cookie', event.request.headers.get('cookie'));
	}

	return fetch(request);
}
```

## Shared hooks

Available in both `src/hooks.server.js` and `src/hooks.client.js`:

### handleError

Handle unexpected errors. Log errors and return safe user representation:

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').HandleServerError} */
export async function handleError({ error, event, status, message }) {
	const errorId = crypto.randomUUID();

	// example integration with https://sentry.io/
	Sentry.captureException(error, {
		extra: { event, errorId, status }
	});

	return {
		message: 'Whoops!',
		errorId
	};
}
```

Customize error shape with `App.Error` interface:

```ts
/// file: src/app.d.ts
declare global {
	namespace App {
		interface Error {
			message: string;
			errorId: string;
		}
	}
}

export {};
```

### init

Runs once when server starts or app starts in browser:

```js
/// file: src/hooks.server.js
/** @type {import('@sveltejs/kit').ServerInit} */
export async function init() {
	await db.connect();
}
```

## Universal hooks

In `src/hooks.js`, run on both server and client:

### reroute

Change URL-to-route translation before `handle`:

```js
/// file: src/hooks.js
/** @type {Record<string, string>} */
const translated = {
	'/en/about': '/en/about',
	'/de/ueber-uns': '/de/about',
	'/fr/a-propos': '/fr/about',
};

/** @type {import('@sveltejs/kit').Reroute} */
export function reroute({ url }) {
	if (url.pathname in translated) {
		return translated[url.pathname];
	}
}
```

Can be async (use carefully):

```js
/// file: src/hooks.js
/** @type {import('@sveltejs/kit').Reroute} */
export async function reroute({ url, fetch }) {
	// Ask a special endpoint within your app about the destination
	if (url.pathname === '/api/reroute') return;

	const api = new URL('/api/reroute', url);
	api.searchParams.set('pathname', url.pathname);

	const result = await fetch(api).then(r => r.json());
	return result.pathname;
}
```

### transport

Pass custom types across server/client boundary:

```js
/// file: src/hooks.js
/** @type {import('@sveltejs/kit').Transport} */
export const transport = {
	Vector: {
		encode: (value) => value instanceof Vector && [value.x, value.y],
		decode: ([x, y]) => new Vector(x, y)
	}
};
```

## docs/kit/30-advanced/25-errors.md

# Errors

SvelteKit handles expected and unexpected errors differently based on where they occur and request type.

## Error Objects

All errors are `{ message: string }` objects by default. Add custom properties via TypeScript interface redefinition.

## Expected Errors

Created with `error()` helper from `@sveltejs/kit`:

```js
/// file: src/routes/blog/[slug]/+page.server.js
import { error } from '@sveltejs/kit';
import * as db from '$lib/server/database';

/** @type {import('./$types').PageServerLoad} */
export async function load({ params }) {
	const post = await db.getPost(params.slug);

	if (!post) {
		error(404, {
			message: 'Not found'
		});
	}

	return { post };
}
```

Renders nearest `+error.svelte` component with `page.error` containing the error object:

```svelte
<!file: src/routes/+error.svelte>
<script>
	import { page } from '$app/state';
</script>

<h1>{page.error.message}</h1>
```

Add custom properties:

```js
error(404, {
	message: 'Not found',
	code: 'NOT_FOUND'
});
```

Or use string shorthand:

```js
error(404, 'Not found');
```

## Unexpected Errors

Any other exceptions during request handling. Messages/stack traces not exposed to users.

Default user-facing error: `{ "message": "Internal Error" }`

Goes through `handleError` hook for custom handling/logging.

## Responses

**In `handle` or `+server.js`**: Returns fallback error page or JSON based on `Accept` headers.

**In `load` functions**: Renders nearest `+error.svelte` component.

**Root layout errors**: Uses fallback error page.

### Custom Error Page

Create `src/error.html`:

```html
<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<title>%sveltekit.error.message%</title>
	</head>
	<body>
		<h1>My custom error page</h1>
		<p>Status: %sveltekit.status%</p>
		<p>Message: %sveltekit.error.message%</p>
	</body>
</html>
```

## Type Safety

Define custom error shape:

```ts
/// file: src/app.d.ts
declare global {
	namespace App {
		interface Error {
			code: string;
			id: string;
		}
	}
}

export {};
```

Always includes `message: string` property.

## docs/kit/30-advanced/30-link-options.md

# Link options

SvelteKit uses `<a>` elements for navigation. Customize link behavior with `data-sveltekit-*` attributes on the link or parent element. These also apply to `<form>` elements with `method="GET"`.

## data-sveltekit-preload-data

Preloads page data on hover/touch before click occurs.

Values:
- `"hover"` - preload on mouse hover (desktop) or touchstart (mobile)
- `"tap"` - preload on touchstart/mousedown only

```html
<body data-sveltekit-preload-data="hover">
	<div style="display: contents">%sveltekit.body%</div>
</body>
```

```html
<a data-sveltekit-preload-data="tap" href="/stonks">
	Get current stonk values
</a>
```

Ignored when `navigator.connection.saveData` is `true`.

## data-sveltekit-preload-code

Preloads page code only.

Values (decreasing eagerness):
- `"eager"` - preload immediately
- `"viewport"` - preload when entering viewport
- `"hover"` - preload on hover/touch
- `"tap"` - preload on touchstart/mousedown

Only affects links present in DOM after navigation. Added later links use hover/tap only.

## data-sveltekit-reload

Forces full-page navigation instead of SvelteKit handling.

```html
<a data-sveltekit-reload href="/path">Path</a>
```

Links with `rel="external"` get same treatment and are ignored during prerendering.

## data-sveltekit-replacestate

Replaces current history entry instead of creating new one.

```html
<a data-sveltekit-replacestate href="/path">Path</a>
```

## data-sveltekit-keepfocus

Prevents focus reset after navigation.

```html
<form data-sveltekit-keepfocus>
	<input type="text" name="query">
</form>
```

Avoid on links. Only use on elements that exist after navigation.

## data-sveltekit-noscroll

Prevents scroll position reset after navigation.

```html
<a href="path" data-sveltekit-noscroll>Path</a>
```

## Disabling options

Use `"false"` value to disable inherited options:

```html
<div data-sveltekit-preload-data>
	<a href="/a">a</a>
	<a href="/b">b</a>
	<a href="/c">c</a>

	<div data-sveltekit-preload-data="false">
		<a href="/d">d</a>
		<a href="/e">e</a>
		<a href="/f">f</a>
	</div>
</div>
```

Conditional attributes:

```svelte
<div data-sveltekit-preload-data={condition ? 'hover' : false}>
```

## docs/kit/30-advanced/40-service-workers.md

# Service workers

Service workers act as proxy servers handling network requests. Enable offline support and speed up navigation by precaching built JS/CSS.

## Setup

Create `src/service-worker.js` (or `src/service-worker/index.js`) - it's automatically bundled and registered.

Default registration:
```js
if ('serviceWorker' in navigator) {
	addEventListener('load', function () {
		navigator.serviceWorker.register('./path/to/service-worker.js');
	});
}
```

## $service-worker module

Access paths to static assets, build files, prerendered pages, app version, and base path.

Example - cache app eagerly, other requests on-demand:

```js
// @errors: 2339
/// <reference types="@sveltejs/kit" />
import { build, files, version } from '$service-worker';

// Create a unique cache name for this deployment
const CACHE = `cache-${version}`;

const ASSETS = [
	...build, // the app itself
	...files  // everything in `static`
];

self.addEventListener('install', (event) => {
	// Create a new cache and add all files to it
	async function addFilesToCache() {
		const cache = await caches.open(CACHE);
		await cache.addAll(ASSETS);
	}

	event.waitUntil(addFilesToCache());
});

self.addEventListener('activate', (event) => {
	// Remove previous cached data from disk
	async function deleteOldCaches() {
		for (const key of await caches.keys()) {
			if (key !== CACHE) await caches.delete(key);
		}
	}

	event.waitUntil(deleteOldCaches());
});

self.addEventListener('fetch', (event) => {
	// ignore POST requests etc
	if (event.request.method !== 'GET') return;

	async function respond() {
		const url = new URL(event.request.url);
		const cache = await caches.open(CACHE);

		// `build`/`files` can always be served from the cache
		if (ASSETS.includes(url.pathname)) {
			const response = await cache.match(url.pathname);

			if (response) {
				return response;
			}
		}

		// for everything else, try the network first, but
		// fall back to the cache if we're offline
		try {
			const response = await fetch(event.request);

			// if we're offline, fetch can return a value that is not a Response
			// instead of throwing - and we can't pass this non-Response to respondWith
			if (!(response instanceof Response)) {
				throw new Error('invalid response from fetch');
			}

			if (response.status === 200) {
				cache.put(event.request, response.clone());
			}

			return response;
		} catch (err) {
			const response = await cache.match(event.request);

			if (response) {
				return response;
			}

			// if there's no cache, then just error out
			// as there is nothing we can do to respond to this request
			throw err;
		}
	}

	event.respondWith(respond());
});
```

**Gotcha:** Be careful caching large assets - browsers empty caches when full.

## Development

Service worker bundled for production only. For dev with manual registration:

```js
import { dev } from '$app/environment';

navigator.serviceWorker.register('/service-worker.js', {
	type: dev ? 'module' : 'classic'
});
```

**Note:** `build` and `prerendered` are empty arrays in development.

## Type safety

Add to top of `service-worker.js`:

```original-js
/// <reference types="@sveltejs/kit" />
/// <reference no-default-lib="true"/>
/// <reference lib="esnext" />
/// <reference lib="webworker" />

const sw = /** @type {ServiceWorkerGlobalScope} */ (/** @type {unknown} */ (self));
```

Use `sw` instead of `self`. For `$env/static/public` imports, add `/// <reference types="../.svelte-kit/ambient.d.ts" />`.

## docs/kit/30-advanced/50-server-only-modules.md

# Server-only modules

SvelteKit prevents accidental import of sensitive data into frontend code through server-only modules.

## Private environment variables

`$env/static/private` and `$env/dynamic/private` modules can only be imported in server-only modules like `hooks.server.js` or `+page.server.js`.

## Server-only utilities

`$app/server` module (contains `read` function for filesystem access) can only be imported by server code.

## Your modules

Make modules server-only by:
- Adding `.server` to filename: `secrets.server.js`
- Placing in `$lib/server`: `$lib/server/secrets.js`

## How it works

SvelteKit errors on any import chain from public code to server-only code:

```js
/// file: $lib/server/secrets.js
export const atlantisCoordinates = [/* redacted */];
```

```js
/// file: src/routes/utils.js
export { atlantisCoordinates } from '$lib/server/secrets.js';
export const add = (a, b) => a + b;
```

```html
/// file: src/routes/+page.svelte
<script>
	import { add } from './utils.js';
</script>
```

**Error:**
```
Cannot import $lib/server/secrets.js into public-facing code:
src/routes/+page.svelte
	src/routes/utils.js
		$lib/server/secrets.js
```

Even though only `add` is used, the entire import chain is unsafe.

Works with dynamic imports, including interpolated ones like ``await import(`./${foo}.js`)``.

> **Note:** Detection disabled during testing (`process.env.TEST === 'true'`).

## docs/kit/30-advanced/65-snapshots.md

# Snapshots

Preserves ephemeral DOM state (scroll positions, input values) across navigation.

## Basic Usage

Export `snapshot` object with `capture` and `restore` methods from `+page.svelte` or `+layout.svelte`:

```svelte
<!file: +page.svelte>
<script>
	let comment = $state('');

	/** @type {import('./$types').Snapshot<string>} */
	export const snapshot = {
		capture: () => comment,
		restore: (value) => comment = value
	};
</script>

<form method="POST">
	<label for="comment">Comment</label>
	<textarea id="comment" bind:value={comment} />
	<button>Post comment</button>
</form>
```

- `capture` called before page updates, returns value stored in browser history
- `restore` called with stored value when navigating back
- Data persisted to `sessionStorage`, survives page reloads

**Gotcha**: Data must be JSON serializable. Avoid large objects - they're retained in memory for the session.

## docs/kit/30-advanced/67-shallow-routing.md

# Shallow routing

Create history entries without navigating. Useful for modals that users can dismiss by going back.

## Basic Usage

Use `pushState` and `replaceState` to associate state with history entries:

```svelte
<!file: +page.svelte>
<script>
	import { pushState } from '$app/navigation';
	import { page } from '$app/state';
	import Modal from './Modal.svelte';

	function showModal() {
		pushState('', {
			showModal: true
		});
	}
</script>

{#if page.state.showModal}
	<Modal close={() => history.back()} />
{/if}
```

## API

- **`pushState(url, state)`** - Creates new history entry
- **`replaceState(url, state)`** - Updates current history entry
- First argument: URL relative to current (use `''` to stay on current URL)
- Second argument: State object accessible via `page.state`
- Type-safe with `App.PageState` interface in `src/app.d.ts`

## Loading Data for Routes

Use `preloadData` to load data for another route without navigating:

```svelte
<!file: src/routes/photos/+page.svelte>
<script>
	import { preloadData, pushState, goto } from '$app/navigation';
	import { page } from '$app/state';
	import Modal from './Modal.svelte';
	import PhotoPage from './[id]/+page.svelte';

	let { data } = $props();
</script>

{#each data.thumbnails as thumbnail}
	<a
		href="/photos/{thumbnail.id}"
		onclick={async (e) => {
			if (innerWidth < 640        // bail if the screen is too small
				|| e.shiftKey             // or the link is opened in a new window
				|| e.metaKey || e.ctrlKey // or a new tab (mac: metaKey, win/linux: ctrlKey)
				// should also consider clicking with a mouse scroll wheel
			) return;

			// prevent navigation
			e.preventDefault();

			const { href } = e.currentTarget;

			// run `load` functions (or rather, get the result of the `load` functions
			// that are already running because of `data-sveltekit-preload-data`)
			const result = await preloadData(href);

			if (result.type === 'loaded' && result.status === 200) {
				pushState(href, { selected: result.data });
			} else {
				// something bad happened! try navigating
				goto(href);
			}
		}}
	>
		<img alt={thumbnail.alt} src={thumbnail.src} />
	</a>
{/each}

{#if page.state.selected}
	<Modal onclose={() => history.back()}>

		<PhotoPage data={page.state.selected} />
	</Modal>
{/if}
```

## Caveats

- `page.state` is empty during SSR and on first page load
- Requires JavaScript - provide fallback behavior
- State lost on page reload

## docs/kit/40-best-practices/03-auth.md

# Auth

Authentication verifies user identity via credentials. Authorization determines allowed actions.

## Sessions vs Tokens

**Sessions**: Store ID in database, can be immediately revoked, requires DB query per request.

**JWT**: Not checked against datastore, cannot be immediately revoked, better latency and reduced DB load.

## Integration

Check auth [cookies](@sveltejs-kit#Cookies) in [server hooks](hooks#Server-hooks). Store user info in [`locals`](hooks#Server-hooks-handle) when credentials match.

## Implementation

[Lucia](https://lucia-auth.com/) provides session-based auth examples for SvelteKit:
- New project: `npx sv create`
- Existing project: `npx sv add lucia`

SvelteKit-specific guides are preferred over generic JS auth libraries to avoid multiple framework dependencies.

## docs/kit/40-best-practices/06-icons.md

# Icons

## CSS

Use Iconify for [popular icon sets](https://icon-sets.iconify.design/) via [CSS](https://iconify.design/docs/usage/css/). Works with CSS frameworks using [Tailwind CSS plugin](https://iconify.design/docs/usage/css/tailwind/) or [UnoCSS plugin](https://iconify.design/docs/usage/css/unocss/). No imports needed in `.svelte` files.

## Svelte

Choose [icon libraries](https://www.sveltesociety.dev/packages?category=icons) carefully. Avoid libraries with one `.svelte` file per icon - thousands of files slow down [Vite's dependency optimization](https://vite.dev/guide/dep-pre-bundling.html). Especially problematic with mixed umbrella and subpath imports ([vite-plugin-svelte FAQ](https://github.com/sveltejs/vite-plugin-svelte/blob/main/docs/faq.md#what-is-going-on-with-vite-and-pre-bundling-dependencies)).

## docs/kit/40-best-practices/07-images.md

# Images

Images impact app performance. Optimize by generating optimal formats (`.avif`, `.webp`), creating different sizes for different screens, and ensuring effective caching.

## Vite's Built-in Handling

[Vite automatically processes imported assets](https://vitejs.dev/guide/assets.html) - adds hashes for caching, inlines small assets, handles CSS `url()` references.

```svelte
<script>
	import logo from '$lib/assets/logo.png';
</script>

<img alt="The project logo" src={logo} />
```

## @sveltejs/enhanced-img

Plugin providing automatic image processing: serves smaller formats (`avif`/`webp`), sets intrinsic dimensions to avoid layout shift, creates multiple sizes, strips EXIF data. Only optimizes local files during build.

### Setup

```bash
npm install --save-dev @sveltejs/enhanced-img
```

```js
import { sveltekit } from '@sveltejs/kit/vite';
import { enhancedImages } from '@sveltejs/enhanced-img';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [
		enhancedImages(), // must come before SvelteKit plugin
		sveltekit()
	]
});
```

Build output cached in `./node_modules/.cache/imagetools`.

### Basic Usage

```svelte
<enhanced:img src="./path/to/your/image.jpg" alt="An alt text" />
```

Generates `<img>` wrapped by `<picture>` with multiple formats/sizes. Provide 2x resolution images - smaller versions auto-generated.

**CSS selector**: Use `enhanced\:img` to escape colon in tag name.

### Dynamic Images

```svelte
<script>
	import MyImage from './path/to/your/image.jpg?enhanced';
</script>

<enhanced:img src={MyImage} alt="some alt text" />
```

With `import.meta.glob`:

```svelte
<script>
	const imageModules = import.meta.glob(
		'/path/to/assets/*.{avif,gif,heif,jpeg,jpg,png,tiff,webp,svg}',
		{
			eager: true,
			query: {
				enhanced: true
			}
		}
	)
</script>

{#each Object.entries(imageModules) as [_path, module]}
	<enhanced:img src={module.default} alt="some alt text" />
{/each}
```

### Dimensions & Sizing

`width`/`height` auto-inferred and added to prevent layout shift. Override with CSS:

```svelte
<style>
	.hero-image img {
		width: var(--size);
		height: auto;
	}
</style>
```

### srcset and sizes

For large images, specify `sizes` for responsive loading:

```svelte
<enhanced:img src="./image.png" sizes="min(1280px, 100vw)"/>
```

Custom widths with `w` parameter:

```svelte
<enhanced:img
  src="./image.png?w=1280;640;400"
  sizes="(min-width:1920px) 1280px, (min-width:1080px) 640px, (min-width:768px) 400px"
/>
```

Without `sizes`: generates HiDPI + standard resolution versions.

### Per-image Transforms

Apply transforms via query string:

```svelte
<enhanced:img src="./path/to/your/image.jpg?blur=15" alt="An alt text" />
```

[Full directive list](https://github.com/JonasKruckenberg/imagetools/blob/main/docs/directives.md).

## CDN Images

For images not available at build time. CDNs provide dynamic optimization but may have setup costs and caching delays.

Libraries: [`@unpic/svelte`](https://unpic.pics/img/svelte/) (CDN-agnostic), [Cloudinary](https://svelte.cloudinary.dev/), CMS integrations (Contentful, Storyblok, Contentstack).

## Best Practices

- Mix solutions as needed per image type
- Serve via CDN for reduced latency
- Use 2x resolution originals for HiDPI displays
- Specify `sizes` for images >400px width
- Set `fetchpriority="high"` for LCP images, avoid `loading="lazy"`
- Constrain images to prevent layout shift
- Always provide `alt` text (compiler warns if missing)
- Don't modify `em`/`rem` defaults when using in `sizes` - causes preloader/layout mismatches

## docs/kit/40-best-practices/20-seo.md

# SEO

## Out of the box

### SSR
SvelteKit uses SSR by default for better search engine indexing. Don't disable it in [`handle`](hooks#Server-hooks-handle) unless necessary.

### Performance
[Core Web Vitals](https://web.dev/vitals/#core-web-vitals) impact search rankings. Test with [PageSpeed Insights](https://pagespeed.web.dev/) or [Lighthouse](https://developers.google.com/web/tools/lighthouse).

### Normalized URLs
SvelteKit redirects trailing slashes based on [configuration](page-options#trailingSlash) to avoid duplicate URLs.

## Manual setup

### &lt;title&gt; and &lt;meta&gt;
Add unique `<title>` and `<meta name="description">` in [`<svelte:head>`](../svelte/svelte-head). Common pattern: return SEO data from [`load`](load) functions, use as [`page.data`]($app-state) in root layout.

### Sitemaps
Create dynamic sitemaps with endpoints:

```js
/// file: src/routes/sitemap.xml/+server.js
export async function GET() {
	return new Response(
		`
		<?xml version="1.0" encoding="UTF-8" ?>
		<urlset
			xmlns="https://www.sitemaps.org/schemas/sitemap/0.9"
			xmlns:xhtml="https://www.w3.org/1999/xhtml"
			xmlns:mobile="https://www.google.com/schemas/sitemap-mobile/1.0"
			xmlns:news="https://www.google.com/schemas/sitemap-news/0.9"
			xmlns:image="https://www.google.com/schemas/sitemap-image/1.1"
			xmlns:video="https://www.google.com/schemas/sitemap-video/1.1"
		>

		</urlset>`.trim(),
		{
			headers: {
				'Content-Type': 'application/xml'
			}
		}
	);
}
```

### AMP
For [AMP](https://amp.dev/) support:

1. Set [`inlineStyleThreshold`](configuration#inlineStyleThreshold):
```js
/// file: svelte.config.js
/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		// since <link rel="stylesheet"> isn't
		// allowed, inline all styles
		inlineStyleThreshold: Infinity
	}
};

export default config;
```

2. Disable CSR:
```js
/// file: src/routes/+layout.server.js
export const csr = false;
```

3. Add `amp` to `app.html`:
```html
<html amp>
...
```

4. Transform HTML with `@sveltejs/amp`:
```js
/// file: src/hooks.server.js
import * as amp from '@sveltejs/amp';

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	let buffer = '';
	return await resolve(event, {
		transformPageChunk: ({ html, done }) => {
			buffer += html;
			if (done) return amp.transform(buffer);
		}
	});
}
```

5. Optional: Remove unused CSS with [`dropcss`](https://www.npmjs.com/package/dropcss):
```js
/// file: src/hooks.server.js
import * as amp from '@sveltejs/amp';
import dropcss from 'dropcss';

/** @type {import('@sveltejs/kit').Handle} */
export async function handle({ event, resolve }) {
	let buffer = '';

	return await resolve(event, {
		transformPageChunk: ({ html, done }) => {
			buffer += html;

			if (done) {
				let css = '';
				const markup = amp
					.transform(buffer)
					.replace('⚡', 'amp') // dropcss can't handle this character
					.replace(/<style amp-custom([^>]*?)>([^]+?)<\/style>/, (match, attributes, contents) => {
						css = contents;
						return `<style amp-custom${attributes}></style>`;
					});

				css = dropcss({ css, html: markup }).css;
				return markup.replace('</style>', `${css}</style>`);
			}
		}
	});
}
```

> Validate transformed HTML with `amphtml-validator` only during prerendering (it's slow).

Instructions for LLMs: <SYSTEM>Always use Svelte 5 runes and Svelte 5 syntax. Runes do not need to be imported, they are globals. $state() runes are always declared using `let`, never with `const`. When passing a function to $derived, you must always use $derived.by(() => ...). Error boundaries can only catch errors during component rendering and at the top level of an $effect inside the error boundary. Error boundaries do not catch errors in onclick or other event handlers.</SYSTEM>
