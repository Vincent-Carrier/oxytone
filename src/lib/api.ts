import ky from 'ky';
import { PUBLIC_BASEX_URL, PUBLIC_FASTAPI_URL } from '$env/static/public';

export const basex = ky.create({ prefixUrl: PUBLIC_BASEX_URL, fetch });
export const python = ky.create({ prefixUrl: PUBLIC_FASTAPI_URL, fetch });
