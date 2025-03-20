import ky from 'ky';

const DB_URL = 'http://localhost:8080';
const PYTHON_URL = 'http://localhost:8000';

export const basex = ky.create({ prefixUrl: DB_URL, fetch });
export const python = ky.create({ prefixUrl: PYTHON_URL, fetch });
