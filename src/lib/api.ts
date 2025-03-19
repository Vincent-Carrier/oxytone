import ky from 'ky';

const DB_URL = 'http://localhost:8080';
const PYTHON_URL = 'http://localhost:8000';

export const makeBaseX = (fetch: any) => ky.create({ prefixUrl: DB_URL, fetch });
export const makePython = (fetch: any) => ky.create({ prefixUrl: PYTHON_URL, fetch });
