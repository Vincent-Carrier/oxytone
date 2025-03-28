# Paroxytone Project Guidelines

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
- Frontend: SvelteKit with TypeScript and Tailwind CSS