# Paroxytone Project Guidelines

## Build Commands
- `pnpm dev` - Start development server
- `pnpm build` - Build for production
- `pnpm preview` - Preview production build
- `pnpm check` - Run TypeScript type checking
- `pnpm format` - Format code with Prettier
- `pnpm lint` - Check formatting and lint with ESLint

## Database Commands (Justfile)
- `just init` - Initialize database
- `just lsj` - Process LSJ dictionary data
- `just treebanks` - Process treebank data

## Code Style
- **Imports**: Group external imports first, then internal imports with `$lib` aliasing
- **Types**: Use explicit TypeScript types, `$props()` for Svelte components
- **Naming**: camelCase for variables/functions, PascalCase for components/types
- **Components**: Script with `<script lang="ts">`, styles in matching CSS files
- **Reactivity**: Use `$state` and `$effect` for reactive variables
- **Error Handling**: Use optional chaining and null checks for safety

## Project Structure
- `src/lib/` - Shared components and utilities
- `src/routes/` - SvelteKit routes and page components
- `repo/` - XML database utilities
- `webapp/` - Web application configuration