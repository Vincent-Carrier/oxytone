import ky from 'ky'
import { PUBLIC_BASEX_URL } from '$env/static/public'

export const basex = ky.create({ prefixUrl: PUBLIC_BASEX_URL, fetch })
