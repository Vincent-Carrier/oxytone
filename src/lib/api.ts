import ky from 'ky'

const DB_URL = 'http://localhost:8080'

const api = (fetch: any) => ky.create({ prefixUrl: DB_URL, fetch })

export default api

